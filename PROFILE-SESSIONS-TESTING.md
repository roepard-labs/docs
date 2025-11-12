# 🧪 Testing Rápido - Sistema de Gestión de Sesiones en Perfil

## 🎯 Objetivo

Verificar que el sistema de gestión de sesiones funciona correctamente en `/dashboard/profile`.

---

## 📋 Pre-requisitos

- ✅ Backend corriendo en `localhost:3000` o `api.roepard.online`
- ✅ Frontend corriendo en `localhost:9000` o `website.roepard.online`
- ✅ Usuario autenticado en el sistema
- ✅ Al menos 1 sesión activa (la actual)

---

## 🔧 Testing Backend

### 1. Verificar endpoint user_data.php

```bash
# Hacer login primero
curl -X POST http://localhost:3000/routes/user/auth_user.php \
  -d "username=admin@gmail.com" \
  -d "password=Admin123!" \
  -c cookies.txt

# Obtener datos del usuario
curl -X GET http://localhost:3000/routes/user/user_data.php \
  -b cookies.txt

# Resultado esperado:
# {
#   "status": "success",
#   "message": "Datos del usuario obtenidos exitosamente",
#   "data": {
#     "user_id": 1,
#     "username": "admin",
#     "email": "admin@gmail.com",
#     "first_name": "Admin",
#     "last_name": "User",
#     "full_name": "Admin User",
#     "member_since": "Noviembre 2024",
#     "member_since_days": 5,
#     "last_login": "2024-11-05 22:00:00",
#     "role_id": 2,
#     "role_name": "admin",
#     ...
#   }
# }
```

### 2. Verificar list_sessions.php

```bash
curl -X GET http://localhost:3000/routes/user/list_sessions.php \
  -b cookies.txt

# Resultado esperado:
# {
#   "status": "success",
#   "data": {
#     "sessions": [
#       {
#         "session_id": "abc123...",
#         "device_type": "desktop",
#         "browser": "Chrome",
#         "os": "Linux",
#         "ip_address": "127.0.0.1",
#         "last_activity": "2024-11-05 22:05:00",
#         "is_current": true
#       }
#     ]
#   }
# }
```

### 3. Verificar close_remote_session.php

**NOTA**: No puedes cerrar la sesión actual, necesitas tener 2+ sesiones.

```bash
# Primero, obtener session_id de otra sesión
curl -X GET http://localhost:3000/routes/user/list_sessions.php \
  -b cookies.txt \
  | jq '.data.sessions[] | select(.is_current == false) | .session_id'

# Cerrar esa sesión
curl -X POST http://localhost:3000/routes/user/close_remote_session.php \
  -b cookies.txt \
  -H "Content-Type: application/json" \
  -d '{"session_id": "SESSION_ID_AQUI"}'

# Resultado esperado:
# {
#   "status": "success",
#   "message": "Sesión cerrada exitosamente"
# }
```

### 4. Verificar close_all_sessions.php

```bash
curl -X POST http://localhost:3000/routes/user/close_all_sessions.php \
  -b cookies.txt

# Resultado esperado:
# {
#   "status": "success",
#   "message": "Se han cerrado X sesiones exitosamente",
#   "data": {
#     "sessions_closed": 2
#   }
# }
```

---

## 🌐 Testing Frontend

### 1. Verificar Carga de sessions.js

**Pasos**:

1. Abrir DevTools (F12)
2. Navegar a `/dashboard/profile`
3. Ver consola

**Resultado esperado**:

```
✅ SessionsService cargado correctamente
📊 Dashboard: Inicializando con SessionService y RoleService
```

### 2. Verificar Tab "Sesiones"

**Pasos**:

1. Navegar a `/dashboard/profile`
2. Click en tab "Sesiones"

**Resultado esperado**:

- ✅ Tab cambia a "Sesiones"
- ✅ Muestra loading spinner inicial
- ✅ Después de 1-2 segundos, muestra tarjetas de sesiones
- ✅ Botón "Cerrar Todas" visible

### 3. Verificar Estadísticas

**Pasos**:

1. Ver card izquierdo "Estadísticas Rápidas"

**Resultado esperado**:

- ✅ "Último acceso" → "Hace X minutos"
- ✅ "Miembro desde" → "Noviembre 2024"
- ✅ "Sesiones activas" → "X dispositivos"

### 4. Verificar Tarjetas de Sesiones

**Pasos**:

1. Navegar a tab "Sesiones"
2. Observar tarjetas

**Resultado esperado**:

- ✅ Icono de dispositivo correcto (🖥️, 📱, 📲)
- ✅ Icono de navegador correcto (🌐, 🦊, 🧭)
- ✅ Badge "Sesión Actual" en sesión actual
- ✅ IP address visible
- ✅ Última actividad formateada ("Hace X minutos")
- ✅ Botón [🗙] solo en sesiones remotas

### 5. Verificar Hover Effects

**Pasos**:

1. Hover sobre una tarjeta de sesión

**Resultado esperado**:

- ✅ Tarjeta se eleva (translateY)
- ✅ Sombra más pronunciada
- ✅ Icono se agranda (scale)

### 6. Verificar Cerrar Sesión Remota

**Pre-requisito**: Tener 2+ sesiones activas

**Pasos**:

1. Click en botón [🗙] de una sesión remota
2. Ver SweetAlert2

**Resultado esperado**:

- ✅ SweetAlert2 aparece con: "¿Cerrar esta sesión?"
- ✅ Botones: "Cancelar" y "Sí, cerrar sesión"

**Si confirmas**:

- ✅ Notyf notifica: "Sesión cerrada exitosamente"
- ✅ Lista se recarga automáticamente
- ✅ Sesión cerrada desaparece de la lista
- ✅ Contador se actualiza

### 7. Verificar Cerrar Todas las Sesiones

**Pre-requisito**: Tener 2+ sesiones activas

**Pasos**:

1. Click en botón "Cerrar Todas"
2. Ver SweetAlert2

**Resultado esperado**:

- ✅ SweetAlert2 aparece con: "¿Cerrar todas las sesiones?"
- ✅ Texto: "Se cerrarán todas las sesiones activas excepto la actual"

**Si confirmas**:

- ✅ SweetAlert2 notifica: "Se han cerrado X sesiones"
- ✅ Lista se recarga automáticamente
- ✅ Solo queda la sesión actual
- ✅ Contador muestra "1 dispositivo"

---

## 🔍 Debugging

### Consola del Navegador

**Mensajes esperados al cargar `/dashboard/profile`**:

```
✅ Router (Axios) configurado y listo para usar
✅ SessionsService cargado correctamente
📊 Dashboard: Inicializando con SessionService y RoleService
👤 Página: Perfil - Inicializando
🚀 Inicializando perfil...
📊 Cargando datos del usuario...
✅ Datos del usuario cargados: {user_id: 1, username: "admin", ...}
🔐 Cargando sesiones activas...
✅ Sesiones activas cargadas: 1
✅ Perfil inicializado completamente
```

### Network Tab

**Peticiones esperadas**:

1. `GET /routes/user/user_data.php` → Status 200
2. `GET /routes/user/list_sessions.php` → Status 200
3. (Si cierras sesión) `POST /routes/user/close_remote_session.php` → Status 200
4. (Si cierras todas) `POST /routes/user/close_all_sessions.php` → Status 200

### Errores Comunes

#### ❌ "SessionsService is not defined"

**Causa**: `sessions.js` no se cargó correctamente.

**Solución**:

1. Verificar que `sessions.js` esté en `/js/sessions.js`
2. Verificar que el script se carga en `dashboard.view.php`:
   ```html
   <script src="../js/sessions.js"></script>
   ```
3. Limpiar caché del navegador (Ctrl + Shift + R)

#### ❌ "AppRouter is not defined"

**Causa**: `router.js` no se cargó antes de `sessions.js`.

**Solución**:

1. Verificar orden de carga en `AppLayout.php`:
   - Primero: `config.js`
   - Segundo: `router.js` (exporta AppRouter)
   - Tercero: `sessions.js` (usa AppRouter)

#### ❌ "401 Unauthorized"

**Causa**: Usuario no está autenticado.

**Solución**:

1. Hacer login en `/`
2. Verificar sesión en backend
3. Verificar cookies en DevTools → Application → Cookies

#### ❌ Sesiones no se cargan

**Causa**: Endpoint `list_sessions.php` no responde o hay error CORS.

**Solución**:

1. Verificar backend corriendo: `curl http://localhost:3000/routes/user/list_sessions.php`
2. Verificar CORS headers en `/config/cors.php`
3. Ver errores en consola del navegador

#### ❌ "Cannot read property 'length' of undefined"

**Causa**: `activeSessions` no se inicializó correctamente.

**Solución**:

1. Verificar que `getActiveSessions()` retorna array válido
2. Agregar validación: `activeSessions = response.data?.sessions || []`

---

## ✅ Checklist Final

### Backend

- [ ] `user_data.php` retorna datos correctos
- [ ] `list_sessions.php` retorna sesiones activas
- [ ] `close_remote_session.php` cierra sesión específica
- [ ] `close_all_sessions.php` cierra todas las sesiones

### Frontend - Carga Inicial

- [ ] `sessions.js` se carga sin errores
- [ ] Tab "Sesiones" aparece en perfil
- [ ] Estadísticas se cargan correctamente
- [ ] Tarjetas de sesiones se renderizan

### Frontend - Interacción

- [ ] Click en tab "Sesiones" funciona
- [ ] Hover sobre tarjetas funciona (efectos visuales)
- [ ] Botón "Cerrar" sesión remota funciona
- [ ] Confirmación SweetAlert2 aparece
- [ ] Lista se recarga después de cerrar
- [ ] Botón "Cerrar Todas" funciona

### Diseño

- [ ] Iconos de dispositivos correctos
- [ ] Iconos de navegadores correctos
- [ ] Badge "Sesión Actual" solo en sesión actual
- [ ] Colores y estilos consistentes con tema
- [ ] Responsive en móvil y desktop

---

## 🚀 Testing Automatizado (Opcional)

### Playwright Test Example

```javascript
// tests/profile-sessions.spec.js
import { test, expect } from "@playwright/test";

test("debe mostrar sesiones activas en perfil", async ({ page }) => {
  // Login
  await page.goto("http://localhost:9000/");
  await page.click("#loginBtn");
  await page.fill('input[name="username"]', "admin@gmail.com");
  await page.fill('input[name="password"]', "Admin123!");
  await page.click("#submitLogin");

  // Navegar a perfil
  await page.goto("http://localhost:9000/dashboard/profile");

  // Click en tab Sesiones
  await page.click("#sessions-tab");

  // Verificar que se cargan sesiones
  await page.waitForSelector(".session-card", { timeout: 5000 });

  const sessionCards = await page.$$(".session-card");
  expect(sessionCards.length).toBeGreaterThan(0);

  // Verificar badge "Sesión Actual"
  const currentBadge = await page.$(".badge.bg-success");
  expect(currentBadge).toBeTruthy();
});
```

---

**Autor**: Roepard Labs Development Team  
**Fecha**: Noviembre 5, 2025  
**Versión**: 1.0.0
