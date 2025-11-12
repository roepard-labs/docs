# 🔐 Implementación del Sistema de Gestión de Sesiones en Perfil de Usuario

**Fecha**: 5 de Noviembre, 2025
**Proyecto**: HomeLab AR - Roepard Labs

---

## 📋 Resumen Ejecutivo

Se ha implementado un **sistema completo de gestión de sesiones** en la página de perfil del usuario (`/dashboard/profile`), permitiendo a los usuarios:

- ✅ Ver todas sus sesiones activas con información detallada
- ✅ Cerrar sesiones remotas individuales
- ✅ Cerrar todas las sesiones excepto la actual
- ✅ Ver estadísticas de último acceso y miembro desde
- ✅ Monitorear dispositivos, navegadores e IPs conectados

---

## 🏗️ Arquitectura Implementada

### Backend (API)

```
/thepearlo_vr-backend/routes/user/
├── user_data.php           ← ✨ NUEVO - Datos completos del usuario
├── list_sessions.php       ← Existente - Lista sesiones activas
├── close_remote_session.php ← Existente - Cierra sesión específica
├── close_all_sessions.php  ← Existente - Cierra todas las sesiones
└── session_history.php     ← Existente - Historial de sesiones
```

### Frontend (UI)

```
/thepearlo_vr-website/
├── js/
│   └── sessions.js         ← ✨ NUEVO - Servicio de gestión de sesiones
├── pages/
│   └── profile.page.php    ← ✨ ACTUALIZADO - Nueva pestaña "Sesiones"
└── views/
    └── dashboard.view.php  ← ✨ ACTUALIZADO - Carga sessions.js
```

---

## 🆕 Archivos Creados

### 1. `/routes/user/user_data.php`

**Función**: Endpoint API que retorna información completa del usuario autenticado.

**Método**: `GET`

**Autenticación**: Requerida (middleware Auth + Status)

**Respuesta**:

```json
{
  "status": "success",
  "message": "Datos del usuario obtenidos exitosamente",
  "data": {
    "user_id": 1,
    "username": "juanperez",
    "email": "juan@example.com",
    "first_name": "Juan",
    "last_name": "Pérez",
    "phone": "+56912345678",
    "role_id": 1,
    "role_name": "user",
    "status_id": 1,
    "status_name": "active",
    "created_at": "2024-01-15 10:30:00",
    "updated_at": "2024-11-05 14:20:00",
    "last_login": "2024-11-05 14:20:00",
    "full_name": "Juan Pérez",
    "member_since": "Enero 2024",
    "member_since_days": 294
  }
}
```

**Características**:

- ✅ Calcula nombre completo automáticamente
- ✅ Formatea "miembro desde" en español (ej: "Noviembre 2024")
- ✅ Calcula días como miembro desde el registro
- ✅ Mapea role_id → role_name (1: user, 2: admin, 3: supervisor)
- ✅ Mapea status_id → status_name (1: active, 2: inactive, etc.)

---

### 2. `/js/sessions.js`

**Función**: Servicio JavaScript para gestión completa de sesiones.

**Características**:

#### Métodos Principales

```javascript
// Obtener sesiones activas
window.SessionsService.getActiveSessions();
// Retorna: Array de sesiones

// Cerrar sesión remota específica
window.SessionsService.closeRemoteSession(sessionId);
// Retorna: Promesa con resultado

// Cerrar todas las sesiones
window.SessionsService.closeAllSessions();
// Retorna: Promesa con resultado

// Obtener historial de sesiones
window.SessionsService.getSessionHistory(limit);
// Retorna: Array de historial
```

#### UI Helpers

```javascript
// Renderizar tarjetas de sesiones en el DOM
window.SessionsService.renderSessionCards(sessions, "containerId");

// Crear HTML de una tarjeta individual
window.SessionsService.createSessionCard(session);

// Confirmar y cerrar sesión (con SweetAlert2)
window.SessionsService.confirmCloseSession(sessionId, callback);

// Confirmar y cerrar todas (con SweetAlert2)
window.SessionsService.confirmCloseAllSessions(callback);

// Inicializar eventos de botones
window.SessionsService.initSessionEvents("containerId", reloadCallback);
```

#### Integración con AppRouter (Axios)

Todas las peticiones usan `window.AppRouter`:

```javascript
// GET - Obtener sesiones
await window.AppRouter.get("/routes/user/list_sessions.php");

// POST - Cerrar sesión remota
await window.AppRouter.post("/routes/user/close_remote_session.php", {
  session_id: sessionId,
});

// POST - Cerrar todas
await window.AppRouter.post("/routes/user/close_all_sessions.php");
```

---

## 📝 Archivos Actualizados

### 1. `/pages/profile.page.php`

**Cambios realizados**:

#### a) Estadísticas Dinámicas

**ANTES** (estático):

```html
<strong>Hace 5 minutos</strong>
<strong>Enero 2024</strong>
<strong>3 dispositivos</strong>
```

**DESPUÉS** (dinámico con IDs):

```html
<strong id="lastAccessTime">Cargando...</strong>
<strong id="memberSince">Cargando...</strong>
<strong id="activeSessions">Cargando...</strong>
```

#### b) Nueva Pestaña "Sesiones"

**Agregado en nav-tabs**:

```html
<li class="nav-item" role="presentation">
  <button
    class="nav-link"
    id="sessions-tab"
    data-bs-toggle="tab"
    data-bs-target="#sessions"
    type="button"
    role="tab"
  >
    <i class="bx bx-shield-quarter me-2"></i>
    Sesiones
  </button>
</li>
```

**Contenido de la pestaña**:

- ✅ Alerta informativa de seguridad
- ✅ Botón "Cerrar Todas" las sesiones
- ✅ Contenedor dinámico para tarjetas de sesiones (`#sessionsContainer`)
- ✅ Estadísticas: Última Actividad y Dispositivos Conectados
- ✅ Loading state mientras cargan los datos

#### c) JavaScript Completo

**Funciones implementadas**:

1. **`loadUserData()`**: Obtiene datos del usuario desde `user_data.php`
2. **`updateProfileUI(userData)`**: Actualiza nombre, username, último acceso, miembro desde
3. **`loadActiveSessions()`**: Carga y renderiza sesiones activas
4. **`updateSessionStats(sessions)`**: Actualiza estadísticas de sesiones
5. **`initSessionEvents()`**: Inicializa eventos de botones de cerrar sesión

**Flujo de inicialización**:

```javascript
async function init() {
  // 1. Cargar datos del usuario
  await loadUserData();

  // 2. Cargar sesiones activas
  await loadActiveSessions();
  initSessionEvents();

  console.log("✅ Perfil inicializado completamente");
}
```

**Evento de cambio de tab**:

```javascript
// Recargar sesiones al abrir tab "Sesiones"
const sessionsTab = document.getElementById("sessions-tab");
sessionsTab.addEventListener("shown.bs.tab", function () {
  loadActiveSessions();
  initSessionEvents();
});
```

---

### 2. `/views/dashboard.view.php`

**Cambios realizados**:

#### a) Carga de sessions.js

**Agregado antes del script principal**:

```html
<!-- Sessions Management Service -->
<script src="../js/sessions.js"></script>
```

#### b) Estilos CSS para Tarjetas de Sesiones

**Agregado en `<style>`**:

```css
/* SESSION CARDS - Profile Page */
.session-card {
  transition: all 0.3s ease;
}

.session-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15) !important;
}

.session-icon {
  transition: transform 0.3s ease;
}

.session-card:hover .session-icon {
  transform: scale(1.1);
}

.btn-close-session {
  opacity: 0.7;
  transition: all 0.2s ease;
}

.btn-close-session:hover {
  opacity: 1;
  transform: scale(1.1);
}
```

---

## 🎨 Diseño de Tarjetas de Sesión

Cada sesión activa se muestra como una tarjeta con:

### Información Mostrada

1. **Icono del Dispositivo**:

   - 🖥️ `bx-desktop` → Desktop
   - 📱 `bx-mobile` → Mobile
   - 📲 `bx-tablet` → Tablet
   - 🔧 `bx-devices` → Unknown

2. **Icono del Navegador**:

   - 🌐 `bxl-chrome` → Chrome
   - 🦊 `bxl-firefox` → Firefox
   - 🧭 `bxl-safari` → Safari
   - 🌊 `bxl-edge` → Edge
   - 🎭 `bxl-opera` → Opera

3. **Badge "Sesión Actual"**: Solo en la sesión del usuario actual

4. **Información Detallada**:

   - Tipo de dispositivo (Desktop, Mobile, Tablet)
   - Navegador y Sistema Operativo
   - Dirección IP
   - Última actividad (formato: "Hace 5 minutos")

5. **Botón de Cerrar**: Solo en sesiones remotas (no en la actual)

### Ejemplo Visual

```
┌─────────────────────────────────────────────────────┐
│  🖥️  Desktop              [Sesión Actual] 🗙       │
│      🌐 Chrome en Windows 10                        │
│                                                      │
│  📍 IP: 192.168.1.100                               │
│  ⏰ Última actividad: Hace 2 minutos                │
└─────────────────────────────────────────────────────┘
```

---

## 🔄 Flujo de Usuario

### Ver Sesiones Activas

```
Usuario → Dashboard → Perfil
              ↓
    Click en tab "Sesiones"
              ↓
    JavaScript llama loadActiveSessions()
              ↓
    GET /routes/user/list_sessions.php
              ↓
    SessionsService.renderSessionCards()
              ↓
    ✅ Tarjetas de sesiones renderizadas
```

### Cerrar Sesión Remota

```
Usuario → Click en botón [🗙]
              ↓
    SweetAlert2: "¿Cerrar esta sesión?"
              ↓
    Usuario confirma
              ↓
    POST /routes/user/close_remote_session.php
    { session_id: "abc123..." }
              ↓
    Backend actualiza BD: is_active = 0
              ↓
    Notyf: "Sesión cerrada exitosamente"
              ↓
    Recargar lista de sesiones
              ↓
    ✅ Sesión removida de la lista
```

### Cerrar Todas las Sesiones

```
Usuario → Click en "Cerrar Todas"
              ↓
    SweetAlert2: "¿Cerrar todas las sesiones?"
              ↓
    Usuario confirma
              ↓
    POST /routes/user/close_all_sessions.php
              ↓
    Backend cierra todas excepto la actual
              ↓
    SweetAlert2: "Se han cerrado X sesiones"
              ↓
    Recargar lista de sesiones
              ↓
    ✅ Solo queda sesión actual
```

---

## 📊 Estadísticas Calculadas

### 1. Último Acceso (last_login)

**Fuente**: `user_data.php` → campo `last_login`

**Formato**:

- "Ahora mismo" → < 1 minuto
- "Hace X minutos" → 1-59 minutos
- "Hace X horas" → 1-23 horas
- "Hace X días" → 24+ horas

**Código**:

```javascript
const diffMinutes = Math.floor((now - lastLoginDate) / 60000);

if (diffMinutes < 1) {
  timeText = "Ahora mismo";
} else if (diffMinutes < 60) {
  timeText = `Hace ${diffMinutes} ${diffMinutes === 1 ? "minuto" : "minutos"}`;
} else if (diffMinutes < 1440) {
  const hours = Math.floor(diffMinutes / 60);
  timeText = `Hace ${hours} ${hours === 1 ? "hora" : "horas"}`;
} else {
  const days = Math.floor(diffMinutes / 1440);
  timeText = `Hace ${days} ${days === 1 ? "día" : "días"}`;
}
```

### 2. Miembro Desde (created_at)

**Fuente**: `user_data.php` → campo `member_since`

**Formato**: "Noviembre 2024", "Enero 2025", etc.

**Cálculo en Backend**:

```php
$createdDate = new DateTime($userData['created_at']);
$memberSince = strftime('%B %Y', $createdDate->getTimestamp());
$memberSince = ucfirst($memberSince); // Primera letra mayúscula
```

### 3. Sesiones Activas

**Fuente**: `list_sessions.php`

**Formato**: "3 dispositivos", "1 dispositivo"

**Código**:

```javascript
const count = activeSessions.length;
activeSessionsCount.textContent = `${count} ${
  count === 1 ? "dispositivo" : "dispositivos"
}`;
```

---

## 🧪 Testing

### Checklist de Pruebas

#### Backend

- [ ] `GET /routes/user/user_data.php` retorna datos correctos
- [ ] `GET /routes/user/list_sessions.php` retorna sesiones del usuario
- [ ] `POST /routes/user/close_remote_session.php` cierra sesión específica
- [ ] `POST /routes/user/close_all_sessions.php` cierra todas menos la actual
- [ ] Middleware Auth verifica autenticación correctamente
- [ ] Middleware Status verifica usuario activo

#### Frontend

- [ ] Tab "Sesiones" muestra correctamente al hacer click
- [ ] Tarjetas de sesiones se renderizan con datos correctos
- [ ] Iconos de dispositivos se muestran según tipo
- [ ] Iconos de navegadores se muestran según browser
- [ ] Badge "Sesión Actual" solo aparece en sesión actual
- [ ] Botón cerrar solo en sesiones remotas (no en actual)
- [ ] Estadísticas se actualizan correctamente
- [ ] Último acceso formatea correctamente el tiempo
- [ ] Miembro desde muestra mes y año en español
- [ ] Contador de sesiones activas es correcto

#### Interacción

- [ ] Click en "Cerrar" sesión remota funciona
- [ ] SweetAlert2 confirma antes de cerrar
- [ ] Notyf notifica cierre exitoso
- [ ] Lista se recarga después de cerrar sesión
- [ ] Click en "Cerrar Todas" funciona
- [ ] SweetAlert2 muestra cantidad cerrada
- [ ] Lista se recarga después de cerrar todas
- [ ] Estilos hover funcionan en tarjetas

---

## 🔐 Seguridad

### Validaciones Implementadas

1. **Autenticación Requerida**: Todos los endpoints requieren sesión válida
2. **Usuario Activo**: Middleware Status verifica status_id = 1
3. **Propiedad de Sesiones**: Solo se pueden cerrar sesiones propias
4. **Sesión Actual Protegida**: No se puede cerrar la sesión actual individualmente
5. **Confirmación Usuario**: SweetAlert2 requiere confirmación explícita

### Datos Sensibles

- ✅ IPs se muestran al usuario (necesario para identificar dispositivos)
- ✅ User agents se muestran (necesario para identificar navegadores)
- ❌ Session IDs NO se muestran en UI (solo en data-attributes)
- ❌ Contraseñas NO están involucradas en este flujo

---

## 📚 Dependencias

### Backend

- PHP 8.4+
- PDO (MySQL/MariaDB)
- Middleware: Auth, Status
- Modelos: UserAuth, UserSession

### Frontend

- **Axios** (vía AppRouter) - Peticiones HTTP
- **Bootstrap 5** - Framework CSS
- **Boxicons** - Iconografía
- **SweetAlert2** - Alertas de confirmación
- **Notyf** - Notificaciones toast

---

## 🚀 Próximas Mejoras Sugeridas

### Funcionalidades

1. **Historial de Sesiones**: Agregar pestaña para ver sesiones cerradas
2. **Notificaciones**: Alertar cuando se detecta login desde nuevo dispositivo
3. **Geolocalización**: Mostrar ciudad/país basado en IP
4. **Filtros**: Filtrar sesiones por dispositivo, navegador, fecha
5. **Exportar**: Descargar historial de sesiones en CSV/PDF

### UX/UI

1. **Animaciones**: Transiciones al cargar/eliminar tarjetas
2. **Skeleton Screens**: Loading states más elegantes
3. **Paginación**: Para usuarios con muchas sesiones
4. **Búsqueda**: Buscar por IP, dispositivo, navegador
5. **Gráficas**: Visualizar sesiones por dispositivo/navegador

### Seguridad

1. **2FA**: Requerir autenticación adicional al cerrar sesiones
2. **Logs Detallados**: Registrar IP que solicitó cierre de sesión
3. **Rate Limiting**: Limitar peticiones de cierre de sesiones
4. **Bloqueo Preventivo**: Bloquear IPs sospechosas automáticamente

---

## 📞 Soporte

**Documentación relacionada**:

- [SESSION-MANAGER-SYSTEM.md](SESSION-MANAGER-SYSTEM.md)
- [FIX-LOGOUT-SESSION-DB-SYNC.md](FIX-LOGOUT-SESSION-DB-SYNC.md)
- [ARQUITECTURA-FUNCIONAL.md](ARQUITECTURA-FUNCIONAL.md)

**Archivos clave**:

- Backend: `/routes/user/user_data.php`, `/routes/user/list_sessions.php`
- Frontend: `/js/sessions.js`, `/pages/profile.page.php`
- Vistas: `/views/dashboard.view.php`

---

**Implementado por**: Roepard Labs Development Team  
**Fecha**: Noviembre 5, 2025  
**Versión**: 1.0.0
