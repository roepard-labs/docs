# 🔧 Solución: Header no muestra usuario después de login

## 🐛 Problema Identificado

### Síntomas

1. ✅ Primera llamada a `check_session.php` retorna usuario logueado
2. ❌ Segunda llamada retorna `{"logged":false,"error":"No autorizado"}`
3. ❌ Header no muestra dropdown de usuario después del login
4. ✅ Usuario está logueado (verificable manualmente en backend)
5. ❌ Los servicios de autenticación no actualizan el header correctamente

### Causa Raíz

El problema tenía **dos causas principales**:

#### 1. **Problema de Timing y CORS**

- Los servicios (`SessionService`, `RoleService`) intentan verificar sesión antes de que PHP renderice
- Las peticiones AJAX con `withCredentials: true` pueden fallar si:
  - Backend no responde rápido
  - CORS no está configurado correctamente
  - Cookies no se comparten entre puertos (9000 → 3000)

#### 2. **Header Dependía Solo de JavaScript**

- El header actualizado usaba **solo** `sessionChanged` y `roleChanged` events
- Si los servicios fallan, el header nunca se actualiza
- No había fallback al estado PHP del servidor

## ✅ Solución Implementada

### Enfoque Híbrido: PHP + JavaScript

```
┌─────────────────────────────────────────────────────┐
│  PHP del Servidor (SSR)                             │
│  - Renderiza estado inicial del header              │
│  - Si hay sesión → muestra dropdown                 │
│  - Si no hay sesión → muestra botón "Identifícate"  │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│  JavaScript (Actualización Dinámica)                │
│  - Solo se usa para ACTUALIZAR después de login     │
│  - NO depende de verificaciones asíncronas          │
│  - Usa evento personalizado 'userLoggedIn'          │
└─────────────────────────────────────────────────────┘
```

### Cambios en `header.ui.php`

#### Antes ❌

```javascript
// Dependía completamente de eventos asíncronos
window.addEventListener("sessionChanged", function (event) {
  // Esperaba que SessionService verificara primero
  updateHeaderUI(session, role);
});

window.addEventListener("roleChanged", function (event) {
  // Esperaba que RoleService verificara primero
  updateHeaderUI(session, role);
});
```

#### Después ✅

```javascript
// Estado inicial desde PHP
const initialAuth = <?php echo $isAuthenticated ? 'true' : 'false'; ?>;
const initialUser = <?php echo json_encode($userData); ?>;

// Evento personalizado desde auth-modal.js
window.addEventListener('userLoggedIn', function(event) {
    window.updateHeaderAfterLogin(event.detail.userData);
});

// Función global simple para actualizar header
window.updateHeaderAfterLogin = function(userData) {
    // Construir dropdown con datos del usuario
    // Adjuntar LogoutService
    // NO recargar página
};
```

### Cambios en `auth-modal.js`

#### Antes ❌

```javascript
// Recargaba la página después del login
setTimeout(function () {
  updateHeaderWithUser(response.user_data);
  setTimeout(function () {
    window.location.reload(); // ← Recarga completa
  }, 500);
}, 1500);
```

#### Después ✅

```javascript
// Dispara evento personalizado
const userLoggedInEvent = new CustomEvent("userLoggedIn", {
  detail: { userData: response.user_data },
});
window.dispatchEvent(userLoggedInEvent);

// Llama directamente a la función del header
setTimeout(function () {
  if (typeof window.updateHeaderAfterLogin === "function") {
    window.updateHeaderAfterLogin(response.user_data);
    // NO recarga - actualización dinámica
  }
}, 100);
```

## 🔄 Flujo Completo

### 1. Carga Inicial de la Página

```
Usuario → http://localhost:9000/
    ↓
PHP verifica $_SESSION
    ↓
Si hay sesión → Renderiza dropdown
Si no hay sesión → Renderiza botón "Identifícate"
    ↓
HTML enviado al navegador
    ↓
JavaScript carga y adjunta LogoutService (si aplica)
```

### 2. Usuario Hace Login

```
Usuario → Click "Identifícate"
    ↓
Modal de autenticación se abre
    ↓
Usuario ingresa credenciales
    ↓
auth-modal.js → AJAX POST /routes/user/auth_user.php
    ↓
Backend crea sesión PHP
    ↓
Backend responde: { status: 'success', user_data: {...} }
    ↓
auth-modal.js dispara evento 'userLoggedIn'
    ↓
header.ui.php escucha evento
    ↓
window.updateHeaderAfterLogin(userData)
    ↓
Header se actualiza dinámicamente
    ↓
LogoutService se adjunta al botón
    ↓
✅ Header muestra usuario SIN RECARGAR
```

### 3. Usuario Hace Logout

```
Usuario → Click "Cerrar Sesión"
    ↓
LogoutService.logout()
    ↓
Confirmación con SweetAlert2
    ↓
AJAX POST /routes/user/logout_user.php
    ↓
Backend destruye sesión PHP
    ↓
Frontend limpia estados globales
    ↓
Notificación Notyf
    ↓
Redirige a home (/)
    ↓
PHP detecta que no hay sesión
    ↓
Renderiza botón "Identifícate"
```

## 📊 Comparación Antes/Después

| Aspecto                            | Antes (Con Servicios)       | Después (Híbrido)              |
| ---------------------------------- | --------------------------- | ------------------------------ |
| **Renderizado inicial**            | Solo JavaScript             | ✅ PHP (SSR)                   |
| **Verificación de sesión**         | AJAX asíncrono              | ✅ PHP directo                 |
| **Actualización después de login** | Recarga completa            | ✅ Dinámica sin recargar       |
| **Dependencias**                   | SessionService, RoleService | ✅ Evento personalizado        |
| **Problemas CORS**                 | Frecuentes                  | ✅ Minimizados                 |
| **Velocidad de carga**             | Lenta (espera AJAX)         | ✅ Instantánea                 |
| **Confiabilidad**                  | Baja (puede fallar)         | ✅ Alta (PHP siempre funciona) |

## 🎯 Ventajas de la Solución

### 1. **Server-Side Rendering (SSR)**

- ✅ Estado inicial correcto siempre
- ✅ No depende de JavaScript
- ✅ SEO-friendly
- ✅ Funciona incluso si JavaScript falla

### 2. **Actualización Dinámica**

- ✅ No recarga página después del login
- ✅ UX mejorada (sin parpadeos)
- ✅ Mantiene scroll position
- ✅ Mantiene estado de otros componentes

### 3. **Sin Dependencias Complejas**

- ✅ No depende de SessionService
- ✅ No depende de RoleService
- ✅ Evento personalizado simple
- ✅ Fácil de debuggear

### 4. **Compatibilidad con Servicios**

- ✅ LogoutService sigue funcionando
- ✅ Servicios disponibles para otras páginas
- ✅ No se eliminan, solo no se usan en carga inicial

## 🧪 Testing

### Verificar Estado Inicial

```bash
# 1. Sin sesión
curl -I http://localhost:9000/
# Debe mostrar botón "Identifícate" en el HTML

# 2. Con sesión (después de login)
curl -I http://localhost:9000/
# Debe mostrar dropdown con nombre de usuario
```

### Verificar Actualización Dinámica

```javascript
// En consola del navegador después de abrir modal:

// 1. Verificar evento
window.addEventListener("userLoggedIn", (e) => {
  console.log("Evento recibido:", e.detail);
});

// 2. Hacer login y verificar que no recarga
// ✅ Header debe actualizarse sin recargar página

// 3. Verificar función global
console.log(typeof window.updateHeaderAfterLogin);
// Debe retornar: "function"
```

### Verificar Logout

```javascript
// 1. Click en "Cerrar Sesión"
// ✅ Debe mostrar confirmación SweetAlert2

// 2. Confirmar
// ✅ Debe mostrar notificación Notyf
// ✅ Debe redirigir a home

// 3. Página recargada debe mostrar botón "Identifícate"
```

## 🚀 Próximos Pasos

### Para el Usuario (Testing)

1. **Probar flujo completo**:

   ```bash
   cd /home/jemg/Documents/GitHub/roepard-labs/thepearlo_vr-website
   php -S localhost:9000 router.php
   ```

2. **Verificar en navegador**:
   - http://localhost:9000/
   - Click en "Identifícate"
   - Login con credenciales
   - **Verificar**: Header se actualiza SIN recargar
   - Click en "Cerrar Sesión"
   - **Verificar**: Redirige a home

### Para Desarrollo

1. **Mantener servicios para otras páginas**:

   - SessionService útil para dashboards
   - RoleService útil para permisos
   - LogoutService útil en cualquier página

2. **No eliminar servicios**:

   - Solo no se usan en carga inicial del header
   - Disponibles para uso en otras vistas

3. **Documentar patrón**:
   - PHP para estado inicial (SSR)
   - JavaScript para actualizaciones dinámicas
   - Eventos personalizados para comunicación

## 📝 Resumen

### Problema

Header no se actualizaba después del login porque dependía de verificaciones asíncronas que podían fallar.

### Solución

Enfoque híbrido: PHP renderiza estado inicial + JavaScript actualiza dinámicamente usando eventos personalizados.

### Resultado

✅ Header siempre muestra estado correcto  
✅ Actualización dinámica sin recargar  
✅ No depende de servicios asíncronos  
✅ Compatible con LogoutService

---

**Última actualización**: Noviembre 2025  
**HomeLab AR - Roepard Labs**
