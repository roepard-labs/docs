# 🔐 Sistema de Gestión de Sesiones - Diagrama Visual

## 📊 Arquitectura General

```
┌─────────────────────────────────────────────────────────────────────┐
│                         FRONTEND (localhost:9000)                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  /dashboard/profile                                                   │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  profile.page.php                                             │   │
│  │  ┌────────────────┬────────────────┬────────────────────┐    │   │
│  │  │  Tab Personal  │ Tab Sesiones ✨│  Tab Contacto      │    │   │
│  │  └────────────────┴────────────────┴────────────────────┘    │   │
│  │                                                                │   │
│  │  [Sesiones Tab Content]                                       │   │
│  │  ┌─────────────────────────────────────────────────────────┐ │   │
│  │  │  🔐 Sesiones Activas          [Cerrar Todas 🗙]        │ │   │
│  │  ├─────────────────────────────────────────────────────────┤ │   │
│  │  │  ℹ️ Alerta: Verifica dispositivos                       │ │   │
│  │  ├─────────────────────────────────────────────────────────┤ │   │
│  │  │                                                          │ │   │
│  │  │  🖥️  Desktop           [Sesión Actual 🗙]             │ │   │
│  │  │      🌐 Chrome en Windows 10                           │ │   │
│  │  │      📍 IP: 192.168.1.100                              │ │   │
│  │  │      ⏰ Última actividad: Hace 2 minutos               │ │   │
│  │  │                                                          │ │   │
│  │  │  📱 Mobile                        [🗙]                 │ │   │
│  │  │      🦊 Firefox en Android                             │ │   │
│  │  │      📍 IP: 192.168.1.200                              │ │   │
│  │  │      ⏰ Última actividad: Hace 1 hora                  │ │   │
│  │  │                                                          │ │   │
│  │  ├─────────────────────────────────────────────────────────┤ │   │
│  │  │  📊 Estadísticas                                        │ │   │
│  │  │  ⏰ Última Actividad: Hace 2 min | 🖥️ Dispositivos: 2  │ │   │
│  │  └─────────────────────────────────────────────────────────┘ │   │
│  └────────────────────────────────────────────────────────────────┘   │
│                                                                       │
│  JavaScript:                                                          │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  sessions.js (SessionsService)                                │   │
│  │  ├─ getActiveSessions()                                       │   │
│  │  ├─ closeRemoteSession(sessionId)                             │   │
│  │  ├─ closeAllSessions()                                        │   │
│  │  ├─ renderSessionCards(sessions, containerId)                 │   │
│  │  ├─ confirmCloseSession(sessionId, callback)                  │   │
│  │  └─ initSessionEvents(containerId, reloadCallback)            │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                              ↕️ HTTP (Axios/AppRouter)                │
└─────────────────────────────────────────────────────────────────────┘
                                 │
                                 │ GET /routes/user/user_data.php
                                 │ GET /routes/user/list_sessions.php
                                 │ POST /routes/user/close_remote_session.php
                                 │ POST /routes/user/close_all_sessions.php
                                 ↓
┌─────────────────────────────────────────────────────────────────────┐
│                         BACKEND (localhost:3000)                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  API Endpoints:                                                       │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  /routes/user/                                                │   │
│  │  ├─ user_data.php ✨                                          │   │
│  │  │  └─ Retorna: user_id, username, email, full_name,        │   │
│  │  │              member_since, last_login, role, status       │   │
│  │  │                                                            │   │
│  │  ├─ list_sessions.php                                        │   │
│  │  │  └─ Retorna: Array de sesiones activas                   │   │
│  │  │                                                            │   │
│  │  ├─ close_remote_session.php                                 │   │
│  │  │  └─ Cierra sesión específica (is_active = 0)             │   │
│  │  │                                                            │   │
│  │  └─ close_all_sessions.php                                   │   │
│  │     └─ Cierra todas excepto la actual                        │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                       │
│  Modelos:                                                             │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  UserAuth.php                                                 │   │
│  │  ├─ findById(userId)                                          │   │
│  │  └─ Retorna datos del usuario desde tabla users              │   │
│  │                                                                │   │
│  │  UserSession.php                                              │   │
│  │  ├─ getActiveUserSessions(userId)                             │   │
│  │  ├─ closeSession(sessionId, userId, reason)                   │   │
│  │  └─ closeAllUserSessions(userId, exceptSessionId)             │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                              ↕️ PDO                                   │
└─────────────────────────────────────────────────────────────────────┘
                                 │
                                 ↓
┌─────────────────────────────────────────────────────────────────────┐
│                         BASE DE DATOS (MySQL)                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  Tabla: users                                                         │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  user_id | username | email | first_name | last_name |       │   │
│  │  role_id | status_id | created_at | last_login | ...         │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                       │
│  Tabla: user_sessions                                                 │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  session_id | user_id | ip_address | user_agent | browser |  │   │
│  │  os | device_type | is_active | last_activity | expires_at | │   │
│  │  closed_at | closed_by | close_reason                         │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Flujo de Carga de Sesiones

```
Usuario → /dashboard/profile
            ↓
[1] profile.page.php renderiza
            ↓
[2] JavaScript init() ejecuta
            ↓
[3] loadUserData()
            ↓
    AppRouter.get('/routes/user/user_data.php')
            ↓
    Backend: Auth middleware → UserAuth.findById()
            ↓
    SQL: SELECT * FROM users WHERE user_id = ?
            ↓
    ← Retorna: { user_id, username, email, member_since, ... }
            ↓
[4] updateProfileUI(userData)
    - Actualiza nombre: "Juan Pérez"
    - Actualiza último acceso: "Hace 5 minutos"
    - Actualiza miembro desde: "Noviembre 2024"
            ↓
[5] loadActiveSessions()
            ↓
    AppRouter.get('/routes/user/list_sessions.php')
            ↓
    Backend: Auth middleware → UserSession.getActiveUserSessions()
            ↓
    SQL: SELECT * FROM user_sessions
         WHERE user_id = ? AND is_active = 1
            ↓
    ← Retorna: [
        { session_id, device_type, browser, os, ip, is_current },
        { session_id, device_type, browser, os, ip, is_current }
      ]
            ↓
[6] SessionsService.renderSessionCards(sessions, 'sessionsContainer')
    - Crea HTML de tarjetas
    - Agrega iconos según dispositivo/navegador
    - Agrega botón cerrar (solo remotas)
            ↓
[7] updateSessionStats(sessions)
    - Calcula última actividad
    - Cuenta dispositivos conectados
            ↓
[8] initSessionEvents()
    - Delegación de eventos para botones cerrar
            ↓
✅ UI renderizada y lista
```

---

## 🗙 Flujo de Cerrar Sesión Remota

```
Usuario → Click botón [🗙] de sesión remota
            ↓
[1] Evento delegado captura click
    - Obtiene session_id del data-attribute
            ↓
[2] SessionsService.confirmCloseSession(sessionId, callback)
            ↓
[3] SweetAlert2.fire()
    ┌─────────────────────────────────────┐
    │  ¿Cerrar esta sesión?               │
    │  Esta acción cerrará la sesión      │
    │  remota inmediatamente              │
    │                                     │
    │  [Cancelar]  [Sí, cerrar sesión]   │
    └─────────────────────────────────────┘
            ↓
    Usuario hace click en "Sí, cerrar sesión"
            ↓
[4] AppRouter.post('/routes/user/close_remote_session.php', {
      session_id: "abc123..."
    })
            ↓
    Backend: Auth middleware
            ↓
    Validaciones:
    - ✅ Usuario autenticado
    - ✅ Session existe
    - ✅ Session pertenece al usuario
    - ❌ NO es la sesión actual
            ↓
    UserSession.closeSession(sessionId, userId, 'remote')
            ↓
    SQL: UPDATE user_sessions
         SET is_active = 0,
             closed_at = NOW(),
             closed_by = ?,
             close_reason = 'remote'
         WHERE session_id = ?
           AND user_id = ?
           AND is_active = 1
            ↓
    ← Retorna: { status: "success", message: "Sesión cerrada exitosamente" }
            ↓
[5] Notyf.success("Sesión cerrada exitosamente")
            ↓
[6] callback() ejecuta → loadActiveSessions()
    - Recarga lista de sesiones
    - Sesión cerrada ya no aparece
    - Contador se actualiza
            ↓
✅ Sesión cerrada y UI actualizada
```

---

## 🔥 Flujo de Cerrar Todas las Sesiones

```
Usuario → Click botón "Cerrar Todas"
            ↓
[1] SessionsService.confirmCloseAllSessions(callback)
            ↓
[2] SweetAlert2.fire()
    ┌─────────────────────────────────────┐
    │  ¿Cerrar todas las sesiones?        │
    │  Se cerrarán todas las sesiones     │
    │  activas excepto la actual          │
    │                                     │
    │  [Cancelar]  [Sí, cerrar todas]    │
    └─────────────────────────────────────┘
            ↓
    Usuario hace click en "Sí, cerrar todas"
            ↓
[3] AppRouter.post('/routes/user/close_all_sessions.php')
            ↓
    Backend: Auth middleware
            ↓
    Obtener session_id actual:
    - session_id = session_id()
            ↓
    UserSession.closeAllUserSessions(userId, exceptSessionId)
            ↓
    SQL: UPDATE user_sessions
         SET is_active = 0,
             closed_at = NOW(),
             closed_by = ?,
             close_reason = 'remote'
         WHERE user_id = ?
           AND session_id != ?
           AND is_active = 1
            ↓
    Contar sesiones cerradas:
    - rowCount() → 3 sesiones cerradas
            ↓
    ← Retorna: {
        status: "success",
        message: "Se han cerrado 3 sesiones exitosamente",
        data: { sessions_closed: 3 }
      }
            ↓
[4] SweetAlert2.fire({
      title: "¡Sesiones cerradas!",
      text: "Se han cerrado 3 sesiones",
      icon: "success"
    })
            ↓
[5] callback() ejecuta → loadActiveSessions()
    - Recarga lista de sesiones
    - Solo queda sesión actual
    - Contador muestra "1 dispositivo"
            ↓
✅ Todas las sesiones remotas cerradas
```

---

## 📊 Componentes Clave

### Frontend Components

```
┌─────────────────────────────────────────┐
│  sessions.js                             │
│  (SessionsService)                       │
├─────────────────────────────────────────┤
│                                          │
│  ✅ getActiveSessions()                  │
│     └─ GET /list_sessions.php            │
│                                          │
│  ✅ closeRemoteSession(sessionId)        │
│     └─ POST /close_remote_session.php    │
│                                          │
│  ✅ closeAllSessions()                   │
│     └─ POST /close_all_sessions.php      │
│                                          │
│  ✅ renderSessionCards(sessions, id)     │
│     └─ Genera HTML de tarjetas           │
│                                          │
│  ✅ confirmCloseSession(id, callback)    │
│     └─ SweetAlert2 + callback            │
│                                          │
│  ✅ confirmCloseAllSessions(callback)    │
│     └─ SweetAlert2 + callback            │
│                                          │
│  ✅ initSessionEvents(id, callback)      │
│     └─ Event delegation                  │
│                                          │
└─────────────────────────────────────────┘
```

### Backend Endpoints

```
┌─────────────────────────────────────────┐
│  user_data.php ✨                        │
├─────────────────────────────────────────┤
│  GET /routes/user/user_data.php          │
│                                          │
│  Auth: ✅ Required                       │
│  Status: ✅ Active (1)                   │
│                                          │
│  Returns:                                │
│  {                                       │
│    user_id, username, email,             │
│    first_name, last_name,                │
│    full_name, member_since,              │
│    member_since_days, last_login,        │
│    role_id, role_name,                   │
│    status_id, status_name                │
│  }                                       │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  list_sessions.php                       │
├─────────────────────────────────────────┤
│  GET /routes/user/list_sessions.php      │
│                                          │
│  Auth: ✅ Required                       │
│                                          │
│  Returns:                                │
│  {                                       │
│    sessions: [                           │
│      {                                   │
│        session_id, device_type,          │
│        browser, os, ip_address,          │
│        last_activity, is_current         │
│      }                                   │
│    ]                                     │
│  }                                       │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  close_remote_session.php                │
├─────────────────────────────────────────┤
│  POST /routes/user/close_remote_session  │
│                                          │
│  Auth: ✅ Required                       │
│                                          │
│  Body: { session_id }                    │
│                                          │
│  Validations:                            │
│  - Session exists                        │
│  - Belongs to user                       │
│  - NOT current session                   │
│                                          │
│  Action:                                 │
│  - is_active = 0                         │
│  - closed_at = NOW()                     │
│  - close_reason = 'remote'               │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  close_all_sessions.php                  │
├─────────────────────────────────────────┤
│  POST /routes/user/close_all_sessions    │
│                                          │
│  Auth: ✅ Required                       │
│                                          │
│  Action:                                 │
│  - Close all sessions                    │
│  - EXCEPT current                        │
│  - Return count closed                   │
└─────────────────────────────────────────┘
```

---

## 🎨 UI Components

### Session Card

```
┌──────────────────────────────────────────────┐
│  🖥️  Desktop              [Sesión Actual 🗙]│
│      🌐 Chrome en Windows 10                 │
│                                              │
│  📍 IP: 192.168.1.100                        │
│  ⏰ Última actividad: Hace 2 minutos         │
└──────────────────────────────────────────────┘
 ↑           ↑              ↑           ↑
 │           │              │           │
device     browser        badge      close
icon        icon         (current)   button
```

### Session Stats

```
┌─────────────────────────┬─────────────────────────┐
│  ⏰ Última Actividad    │  🖥️ Dispositivos       │
│     Hace 2 min          │     2 dispositivos      │
└─────────────────────────┴─────────────────────────┘
```

---

**Creado por**: Roepard Labs Development Team  
**Fecha**: Noviembre 5, 2025
