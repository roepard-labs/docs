# 🔒 Sistema de Cierre Automático de Sesiones - HomeLab AR

**Fecha**: Noviembre 2025  
**Autor**: Roepard Labs Development Team  
**Versión**: 1.0

---

## 📋 Resumen Ejecutivo

Sistema completo de verificación y cierre automático de sesiones basado en el estado de `user_sessions.is_active` en la base de datos.

### Características Principales:

1. ✅ **Verificación en BD**: Backend verifica `is_active` en cada request
2. ✅ **Cierre automático**: Si `is_active = 0`, cierra sesión PHP automáticamente
3. ✅ **Frontend reactivo**: Detecta sesión cerrada y redirige a home
4. ✅ **Verificación de usuario**: Valida `users.status_id` (activo/suspendido/baneado)
5. ✅ **Notificaciones**: Usuario recibe aviso antes de ser redirigido

---

## 🏗️ Arquitectura del Sistema

### Flujo Completo:

```
1. Usuario navega en dashboard
   ↓
2. SessionService.check() cada 5 minutos
   ↓
3. Backend: check_session.php
   ├── Verifica sesión PHP válida
   ├── Consulta user_sessions.is_active
   ├── Consulta users.status_id
   │
   ├─→ is_active = 0? → Destruir sesión PHP
   │   └─→ Retornar: {action_required: 'logout'}
   │
   └─→ status_id != 1? → Usuario inactivo
       └─→ Retornar: {action_required: 'logout'}
   ↓
4. Frontend: sessionCheck.js
   ├── Detecta action_required = 'logout'
   ├── Muestra notificación al usuario
   ├── Actualiza SessionStatus.isAuthenticated = false
   └── Redirige a home después de 2 segundos
```

---

## 🔧 Implementación Backend

### Archivo: `/routes/user/check_session.php`

#### Query SQL para Verificar Sesión:

```sql
SELECT is_active, status_id
FROM user_sessions us
INNER JOIN users u ON us.user_id = u.user_id
WHERE us.session_id = :session_id
AND us.user_id = :user_id
LIMIT 1
```

#### Lógica de Validación:

```php
// 1. Obtener session_id de PHP
$phpSessionId = session_id();

// 2. Consultar estado en BD
$sessionData = $stmtCheckSession->fetch(PDO::FETCH_ASSOC);

// 3. Validar is_active
$sessionActive = (int)$sessionData['is_active'] === 1;
$userActive = (int)$sessionData['status_id'] === 1;

// 4. Si sesión NO está activa → CERRAR
if (!$sessionActive) {
    session_unset();
    session_destroy();

    return [
        'status' => 'error',
        'message' => 'Sesión cerrada remotamente',
        'logged' => false,
        'session_active' => false,
        'user_active' => $userActive,
        'action_required' => 'logout'
    ];
}

// 5. Si usuario NO está activo → CERRAR
if (!$userActive) {
    return [
        'status' => 'error',
        'message' => 'Usuario inactivo o suspendido',
        'logged' => false,
        'session_active' => $sessionActive,
        'user_active' => false,
        'action_required' => 'logout'
    ];
}

// 6. Todo OK → SESIÓN VÁLIDA
return [
    'status' => 'success',
    'message' => 'Sesión válida y usuario activo',
    'logged' => true,
    'session_active' => true,
    'user_active' => true,
    'user_data' => $user_data
];
```

---

## 🎯 Implementación Frontend

### Archivo: `/composables/sessionCheck.js`

#### Detección de Sesión Cerrada:

```javascript
// Verificar respuesta del backend
if (response.session_active === false || response.user_active === false) {
  console.warn("⚠️ SessionService: Sesión cerrada remotamente");

  // Actualizar estado global
  window.SessionStatus.isAuthenticated = false;
  window.SessionStatus.userData = null;
  window.SessionStatus.error = response.message;

  // Si backend requiere logout
  if (response.action_required === "logout") {
    // Notificar al usuario
    if (window.Notyf) {
      const notyf = new Notyf({ duration: 5000 });
      notyf.error(response.message || "Tu sesión ha sido cerrada");
    }

    // Redirigir a home después de 2 segundos
    setTimeout(() => {
      window.location.href = "/";
    }, 2000);
  }

  return window.SessionStatus;
}
```

#### Verificación Periódica:

```javascript
// Verificación automática cada 5 minutos
setInterval(async function () {
  if (window.AppRouter && window.AppRouter.axiosInstance) {
    await window.SessionService.check();
  }
}, 300000); // 5 minutos
```

---

## 📊 Respuestas del Backend

### ✅ Respuesta: Sesión Válida (200)

```json
{
  "status": "success",
  "message": "Sesión válida y usuario activo",
  "logged": true,
  "session_active": true,
  "user_active": true,
  "user_data": {
    "user_id": 4,
    "first_name": "Juan",
    "last_name": "Pérez",
    "email": "juan@example.com",
    "role_id": 1
  }
}
```

### ❌ Respuesta: Sesión Cerrada Remotamente (401)

```json
{
  "status": "error",
  "message": "Sesión cerrada remotamente",
  "logged": false,
  "session_active": false,
  "user_active": true,
  "action_required": "logout"
}
```

**Causa**: Administrador cerró la sesión desde el dashboard (cambió `is_active = 0`)

### ❌ Respuesta: Usuario Inactivo (403)

```json
{
  "status": "error",
  "message": "Usuario inactivo o suspendido",
  "logged": false,
  "session_active": true,
  "user_active": false,
  "action_required": "logout"
}
```

**Causa**: Usuario fue suspendido/baneado (`status_id != 1`)

---

## 🧪 Testing del Sistema

### Test 1: Sesión Normal (Activa)

```bash
# 1. Usuario inicia sesión
curl -X POST http://localhost:3000/routes/user/auth_user.php \
  -d "username=user@example.com&password=test123" \
  -c cookies.txt

# 2. Verificar sesión (debe retornar 200)
curl -X GET http://localhost:3000/routes/user/check_session.php \
  -b cookies.txt | jq '.'

# Respuesta esperada:
{
  "status": "success",
  "logged": true,
  "session_active": true,
  "user_active": true
}
```

### Test 2: Cerrar Sesión Remotamente

```sql
-- 1. En MySQL/MariaDB, cerrar sesión manualmente
UPDATE user_sessions
SET is_active = 0,
    closed_at = NOW(),
    close_reason = 'Cerrada por administrador'
WHERE session_id = 'abc123...';
```

```bash
# 2. Usuario intenta verificar sesión (debe retornar 401)
curl -X GET http://localhost:3000/routes/user/check_session.php \
  -b cookies.txt | jq '.'

# Respuesta esperada:
{
  "status": "error",
  "message": "Sesión cerrada remotamente",
  "logged": false,
  "session_active": false,
  "action_required": "logout"
}
```

**Resultado en Frontend**:

- Notificación: "Sesión cerrada remotamente"
- Redirección a `/` después de 2 segundos

### Test 3: Usuario Suspendido

```sql
-- 1. Suspender usuario
UPDATE users
SET status_id = 3  -- 3 = suspendido
WHERE user_id = 4;
```

```bash
# 2. Usuario intenta verificar sesión (debe retornar 403)
curl -X GET http://localhost:3000/routes/user/check_session.php \
  -b cookies.txt | jq '.'

# Respuesta esperada:
{
  "status": "error",
  "message": "Usuario inactivo o suspendido",
  "logged": false,
  "user_active": false,
  "action_required": "logout"
}
```

---

## 🔐 Casos de Uso

### Caso 1: Administrador Cierra Sesión de Usuario

**Escenario**: Admin detecta actividad sospechosa y cierra sesión remota.

1. Admin va a dashboard → Sesiones Activas
2. Busca sesión del usuario sospechoso
3. Click en "Cerrar Sesión"
4. Backend: `UPDATE user_sessions SET is_active = 0`
5. Usuario sigue navegando...
6. 5 minutos después (o al navegar): `SessionService.check()`
7. Backend detecta `is_active = 0` → retorna `action_required: 'logout'`
8. Frontend muestra notificación: "Tu sesión ha sido cerrada"
9. Frontend redirige a home

**Tiempo de cierre**: Hasta 5 minutos (o inmediato al navegar)

### Caso 2: Usuario Suspendido Durante Sesión Activa

**Escenario**: Usuario viola términos de servicio, admin lo suspende.

1. Admin suspende usuario: `UPDATE users SET status_id = 3`
2. Usuario tiene sesión activa (`is_active = 1`)
3. Usuario intenta verificar sesión
4. Backend detecta `status_id != 1` → retorna error 403
5. Frontend cierra sesión automáticamente
6. Usuario es redirigido a home

### Caso 3: Sesión Expirada (Limpieza Automática)

**Escenario**: Cron job cierra sesiones expiradas.

```sql
-- Cron job (cada hora)
UPDATE user_sessions
SET is_active = 0,
    closed_at = NOW(),
    close_reason = 'Sesión expirada'
WHERE expires_at < NOW()
AND is_active = 1;
```

1. Sesión expira (24 horas sin actividad)
2. Cron job ejecuta UPDATE
3. Usuario intenta acceder
4. Backend detecta `is_active = 0`
5. Frontend cierra sesión y redirige

---

## 📈 Métricas y Monitoreo

### Query: Sesiones Cerradas Automáticamente (Últimas 24h)

```sql
SELECT
    session_id,
    user_id,
    close_reason,
    closed_at,
    TIMESTAMPDIFF(SECOND, created_at, closed_at) AS session_duration_seconds
FROM user_sessions
WHERE closed_at >= NOW() - INTERVAL 24 HOUR
AND close_reason LIKE '%remota%'
ORDER BY closed_at DESC;
```

### Query: Usuarios con Sesiones Forzadas a Cerrar

```sql
SELECT
    u.user_id,
    u.first_name,
    u.last_name,
    COUNT(us.session_id) AS closed_sessions,
    MAX(us.closed_at) AS last_forced_close
FROM users u
INNER JOIN user_sessions us ON u.user_id = us.user_id
WHERE us.close_reason LIKE '%administrador%'
AND us.closed_at >= NOW() - INTERVAL 7 DAY
GROUP BY u.user_id
ORDER BY closed_sessions DESC;
```

---

## 🚨 Troubleshooting

### Problema 1: Sesión NO se cierra automáticamente

**Síntomas**: `is_active = 0` pero usuario sigue conectado.

**Diagnóstico**:

```bash
# Verificar session_id en BD
SELECT session_id, is_active FROM user_sessions WHERE user_id = 4;

# Verificar session_id en PHP
php -r "session_start(); echo 'PHP Session ID: ' . session_id();"
```

**Solución**: Verificar que `session_id()` coincida con el de la BD.

### Problema 2: Verificación no ejecuta cada 5 minutos

**Síntomas**: Usuario no es cerrado automáticamente después de cambiar `is_active`.

**Diagnóstico**:

```javascript
// En consola del navegador
console.log("SessionService:", window.SessionService);
console.log("Última verificación:", window.SessionStatus.lastCheck);
```

**Solución**: Verificar que `sessionCheck.js` esté cargado y `setInterval` esté activo.

### Problema 3: Redirección en bucle

**Síntomas**: Usuario es redirigido continuamente a home.

**Causa**: `action_required: 'logout'` se dispara en home también.

**Solución**: Agregar verificación de URL actual:

```javascript
if (response.action_required === "logout" && window.location.pathname !== "/") {
  setTimeout(() => {
    window.location.href = "/";
  }, 2000);
}
```

---

## 📚 Documentación Relacionada

- **[SESSION-MANAGER-SYSTEM.md](SESSION-MANAGER-SYSTEM.md)** - Sistema completo de gestión de sesiones
- **[FIX-LOGOUT-SESSION-DB-SYNC.md](FIX-LOGOUT-SESSION-DB-SYNC.md)** - Sincronización logout PHP ↔ BD
- **[PROFILE-SESSIONS-IMPLEMENTATION.md](PROFILE-SESSIONS-IMPLEMENTATION.md)** - Implementación UI de sesiones

---

## 🎯 Checklist de Implementación

- [x] Backend: Consulta `user_sessions.is_active` en `check_session.php`
- [x] Backend: Consulta `users.status_id` para verificar estado de usuario
- [x] Backend: Destruir sesión PHP si `is_active = 0`
- [x] Backend: Retornar `action_required: 'logout'` en respuesta
- [x] Frontend: Detectar `action_required` en `sessionCheck.js`
- [x] Frontend: Mostrar notificación al usuario
- [x] Frontend: Redirigir a home después de 2 segundos
- [x] Frontend: Verificación periódica cada 5 minutos
- [x] Documentación completa del sistema
- [x] Testing manual de casos de uso

---

**Última actualización**: Noviembre 2025  
**Mantenido por**: Roepard Labs Development Team
