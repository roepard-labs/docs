# 🔧 Solución: Sesión se Pierde al Recargar (Frontend vs Backend)

## 🐛 Problema

### Síntomas

1. ✅ Login funciona correctamente
2. ✅ Header muestra usuario después del login
3. ❌ Al recargar la página (F5), header muestra botón "Identifícate"
4. ✅ Backend MANTIENE la sesión (verificable en Postman/curl)
5. ❌ Frontend "pierde" la sesión

### Ejemplo del Problema

```bash
# 1. Usuario hace login → Header muestra dropdown ✅
# 2. Usuario recarga página (F5)
# 3. Header muestra "Identifícate" ❌
# 4. PERO en Postman:
curl -b cookies.txt http://localhost:3000/routes/user/check_session.php
# Responde: {"logged": true, "user_data": {...}} ✅
```

## 🔍 Causa Raíz

### Arquitectura de Puertos

```
┌─────────────────────────────────────────┐
│  FRONTEND (localhost:9000)              │
│  ├── PHP Server (frontend)             │
│  ├── Sesiones: /tmp/sess_frontend_*    │
│  └── NO PUEDE leer sesiones del backend│
└─────────────────────────────────────────┘
                ↕ CORS + Cookies
┌─────────────────────────────────────────┐
│  BACKEND (localhost:3000)               │
│  ├── PHP API (backend)                  │
│  ├── Sesiones: /tmp/sess_backend_*     │
│  └── Tiene la sesión REAL del usuario  │
└─────────────────────────────────────────┘
```

### ¿Por Qué Pasa Esto?

1. **Login Exitoso**:

   ```
   auth-modal.js (frontend)
       ↓ AJAX POST
   Backend crea sesión en /tmp/sess_backend_abc123
       ↓ Set-Cookie header
   Navegador guarda cookie para localhost:3000
       ↓ JavaScript actualiza header
   Header muestra usuario ✅
   ```

2. **Usuario Recarga Página (F5)**:

   ```
   Navegador → GET http://localhost:9000/
       ↓
   PHP del FRONTEND intenta leer $_SESSION
       ↓
   Busca en /tmp/sess_frontend_* (VACÍO)
       ↓
   $isAuthenticated = false ❌
       ↓
   Renderiza botón "Identifícate"
   ```

3. **Backend TODAVÍA tiene la sesión**:
   ```
   fetch('http://localhost:3000/routes/user/check_session.php')
       ↓ Cookie: PHPSESSID=abc123
   Backend lee /tmp/sess_backend_abc123 ✅
       ↓
   {"logged": true, "user_data": {...}}
   ```

### El Problema: PHP del Frontend NO puede leer sesiones del Backend

PHP gestiona sesiones por **servidor**, no por aplicación:

- Frontend (9000): Sesiones independientes
- Backend (3000): Sesiones independientes
- **NO se comparten automáticamente**

## ✅ Solución Implementada

### Verificación Asíncrona del Backend al Cargar

En lugar de confiar solo en PHP del frontend, **verificamos la sesión del backend con JavaScript**:

```javascript
// header.ui.php

// PASO 1: PHP renderiza estado inicial (puede estar desincronizado)
const initialAuth = <?php echo $isAuthenticated ? 'true' : 'false'; ?>;

// PASO 2: Al cargar, verificar sesión del backend
function checkBackendSession() {
    fetch('http://localhost:3000/routes/user/check_session.php', {
        credentials: 'include' // Envía cookies
    })
    .then(response => response.json())
    .then(data => {
        if (data.logged === true && data.user_data) {
            // Backend tiene sesión pero frontend no
            const authBtn = document.getElementById('authModalTrigger');
            if (authBtn) {
                // Sincronizar: actualizar header con datos del backend
                window.updateHeaderAfterLogin(data.user_data);
            }
        }
    });
}

// PASO 3: Ejecutar al cargar página
document.addEventListener('DOMContentLoaded', function() {
    checkBackendSession(); // ← CRÍTICO
});
```

### Flujo Completo

```
┌──────────────────────────────────────────────────────┐
│  1. Usuario recarga página (F5)                      │
└──────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────┐
│  2. PHP Frontend renderiza HTML                      │
│     - No encuentra sesión local                      │
│     - Renderiza botón "Identifícate"                 │
└──────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────┐
│  3. JavaScript se ejecuta (DOMContentLoaded)         │
│     - Llama a checkBackendSession()                  │
└──────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────┐
│  4. AJAX fetch al backend                            │
│     GET http://localhost:3000/check_session.php      │
│     credentials: 'include' (envía cookies)           │
└──────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────┐
│  5. Backend verifica sesión                          │
│     - Lee /tmp/sess_backend_abc123                   │
│     - Encuentra sesión válida ✅                      │
│     - Responde: {"logged": true, "user_data": {...}} │
└──────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────┐
│  6. JavaScript detecta desincronización              │
│     - Frontend muestra "Identifícate"                │
│     - Backend tiene sesión                           │
│     - Llama a updateHeaderAfterLogin(userData)       │
└──────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────┐
│  7. Header se actualiza dinámicamente                │
│     - Reemplaza botón con dropdown                   │
│     - Muestra nombre del usuario                     │
│     - ✅ SIN RECARGAR PÁGINA                          │
└──────────────────────────────────────────────────────┘
```

## 🔑 Puntos Clave

### 1. PHP Frontend != PHP Backend

```php
// Frontend (localhost:9000)
$_SESSION['user_id']; // ❌ NULL (no hay sesión aquí)

// Backend (localhost:3000)
$_SESSION['user_id']; // ✅ 85 (sesión existe)
```

### 2. Cookies se Comparten por Dominio

```
Domain: localhost
Ports: 9000, 3000
Cookies: ✅ Se comparten entre puertos del mismo dominio
```

### 3. Verificación Asíncrona es la Solución

```javascript
// Al cargar página:
PHP renderiza → Estado inicial (puede estar mal)
    ↓
JavaScript verifica → Consulta backend (fuente de verdad)
    ↓
Si difiere → Sincroniza (actualiza header)
```

## 🧪 Testing

### Escenario 1: Login y Recarga

```bash
# 1. Iniciar servidores
php -S localhost:9000 router.php  # Frontend
php -S localhost:3000 index.php   # Backend

# 2. Abrir navegador
http://localhost:9000/

# 3. Hacer login
- Click "Identifícate"
- Ingresar credenciales
- ✅ Header muestra dropdown

# 4. Recargar página (F5)
# Antes: ❌ Header muestra "Identifícate"
# Ahora: ✅ Header mantiene dropdown (sincronización automática)
```

### Verificar en Consola del Navegador

```javascript
// Después de recargar página (F5), deberías ver:

// 🚀 DOM cargado, verificando sincronización con backend...
// 🔍 Verificando sesión del backend (localhost:3000)...
// 📥 Respuesta del backend: {logged: true, user_data: {...}}
// ✅ Sesión válida en backend
// 👤 Usuario: Juan
// 🔄 Frontend sin sesión, pero backend SÍ tiene sesión
// 🔄 Sincronizando header con datos del backend...
// 🔄 Actualizando header después de login: {first_name: "Juan", ...}
// ✅ Header actualizado con datos del usuario
```

### Verificar Backend Directamente

```bash
# Curl con cookies
curl -b cookies.txt -c cookies.txt \
  http://localhost:3000/routes/user/check_session.php

# Debe responder:
{
  "status": "success",
  "logged": true,
  "user_data": {
    "user_id": 85,
    "first_name": "Juan",
    "role_id": 1
  }
}
```

## 📊 Comparación

| Aspecto                    | Antes                         | Después                       |
| -------------------------- | ----------------------------- | ----------------------------- |
| **Renderizado inicial**    | PHP frontend (desincronizado) | ✅ PHP + verificación async   |
| **Después de login**       | Header actualiza              | ✅ Igual                      |
| **Después de recargar**    | ❌ Pierde sesión              | ✅ Sincroniza automáticamente |
| **Fuente de verdad**       | PHP frontend                  | ✅ Backend (API)              |
| **Experiencia de usuario** | ❌ Confusa                    | ✅ Consistente                |

## 🎯 Ventajas

1. **Sincronización Automática**

   - ✅ Header siempre refleja el estado real del backend
   - ✅ No importa si PHP frontend no tiene la sesión

2. **Sin Recarga Forzada**

   - ✅ Actualización dinámica con JavaScript
   - ✅ No pierde estado de otros componentes

3. **Debugging Fácil**

   - ✅ Logs claros en consola
   - ✅ Se ve exactamente qué está pasando

4. **Compatible con Producción**
   - ✅ Funciona con cualquier configuración de CORS
   - ✅ Usa `credentials: 'include'` para cookies

## 🚨 Importante: Configuración CORS

Para que esto funcione, el backend DEBE tener:

```php
// config/cors.php
header("Access-Control-Allow-Origin: http://localhost:9000");
header("Access-Control-Allow-Credentials: true"); // ← CRÍTICO
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
```

**SIN** `Access-Control-Allow-Credentials: true`, las cookies NO se envían.

## 🔮 Alternativas Consideradas

### 1. Session Sharing con Redis ❌

```
Pros: Sesiones compartidas entre servidores
Cons: Requiere Redis, más complejo
Veredicto: Innecesario para desarrollo
```

### 2. JWT Tokens ❌

```
Pros: Stateless, escalable
Cons: Cambio arquitectónico grande
Veredicto: Para futuro, no ahora
```

### 3. Proxy Reverse ❌

```
Pros: Frontend y backend en mismo puerto
Cons: Configuración de nginx/apache compleja
Veredicto: Overkill para desarrollo
```

### 4. Verificación Asíncrona ✅

```
Pros:
- Simple de implementar
- No requiere cambios arquitectónicos
- Funciona con setup actual
- Fácil de debuggear

Cons:
- Una petición extra al cargar

Veredicto: ✅ MEJOR SOLUCIÓN
```

## 📝 Resumen

### Problema

PHP del frontend (9000) no puede leer sesiones del backend (3000).

### Solución

Al cargar página, JavaScript verifica sesión del backend y sincroniza header.

### Resultado

✅ Header siempre muestra estado correcto  
✅ Sincronización automática después de recargar  
✅ No requiere cambios arquitectónicos  
✅ Funciona con setup actual

---

**Última actualización**: Noviembre 2025  
**HomeLab AR - Roepard Labs**
