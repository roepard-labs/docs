# 🔐 Sistema de Gestión de Sesiones - HomeLab AR

## 📋 Resumen Ejecutivo

Sistema completo para rastrear, gestionar y controlar remotamente las sesiones activas de usuarios con información detallada de dispositivos, navegadores e IPs.

**✅ IMPORTANTE**: Este sistema ahora está completamente sincronizado. Cuando un usuario cierra sesión desde cualquier punto del frontend (header.ui.php, sidebar.ui.php), la sesión se marca automáticamente como `is_active = 0` en la base de datos. Ver: [FIX-LOGOUT-SESSION-DB-SYNC.md](FIX-LOGOUT-SESSION-DB-SYNC.md)

---

## 🗄️ Base de Datos

### Tabla: `user_sessions`

```sql
CREATE TABLE `user_sessions` (
    `session_id` VARCHAR(100) PRIMARY KEY,
    `user_id` INT(11) NOT NULL,
    `ip_address` VARCHAR(45) NOT NULL,
    `user_agent` TEXT NOT NULL,
    `browser` VARCHAR(100),
    `os` VARCHAR(100),
    `device_type` ENUM('desktop', 'mobile', 'tablet', 'unknown'),
    `is_active` TINYINT(1) DEFAULT 1,
    `last_activity` TIMESTAMP,
    `created_at` TIMESTAMP,
    `expires_at` TIMESTAMP,
    `closed_at` TIMESTAMP NULL,
    `closed_by` INT(11) NULL,
    `close_reason` ENUM('manual', 'remote', 'expired', 'logout')
);
```

### Vistas Disponibles

1. **`v_active_sessions`**: Sesiones activas con info de usuario
2. **`v_session_history`**: Historial de sesiones (últimas 30 días)

### Procedimientos Almacenados

1. **`sp_cleanup_expired_sessions()`**: Limpia sesiones expiradas
2. **`sp_get_user_sessions(user_id)`**: Obtiene sesiones de un usuario
3. **`sp_close_remote_session(session_id, user_id, reason)`**: Cierra sesión remota

---

## 🛠️ Instalación

### 1. Ejecutar Migración SQL

```bash
# En el servidor de base de datos
mysql -u root -p homelab < user_sessions_migration.sql
```

### 2. Verificar Tablas Creadas

```sql
SHOW TABLES LIKE 'user_sessions';
SELECT * FROM v_active_sessions;
```

---

## 🔌 API Endpoints

### 1. Listar Sesiones Activas

**Endpoint**: `GET /routes/user/list_sessions.php`

**Autenticación**: Requerida

**Respuesta**:

```json
{
  "status": "success",
  "message": "Sesiones recuperadas correctamente",
  "data": {
    "sessions": [
      {
        "session_id": "1d08bc22cc0f5d283526aaef49323404",
        "ip_address": "190.85.123.45",
        "browser": "Google Chrome",
        "os": "Windows 10/11",
        "device_type": "desktop",
        "created_at": "2025-11-05 22:00:39",
        "last_activity": "2025-11-05 22:30:15",
        "expires_at": "2025-11-05 23:00:39",
        "minutes_remaining": 25,
        "is_current": true
      },
      {
        "session_id": "abc123def456...",
        "ip_address": "192.168.1.100",
        "browser": "Apple Safari",
        "os": "iOS 17",
        "device_type": "mobile",
        "created_at": "2025-11-05 21:45:00",
        "last_activity": "2025-11-05 22:20:00",
        "expires_at": "2025-11-05 22:45:00",
        "minutes_remaining": 10,
        "is_current": false
      }
    ],
    "stats": {
      "total_active": 2,
      "current_session_id": "1d08bc22cc0f5d283526aaef49323404"
    }
  }
}
```

### 2. Cerrar Sesión Remota

**Endpoint**: `POST /routes/user/close_remote_session.php`

**Autenticación**: Requerida

**Body**:

```json
{
  "session_id": "abc123def456..."
}
```

**Respuesta**:

```json
{
  "status": "success",
  "message": "Sesión cerrada correctamente",
  "data": {
    "closed_session_id": "abc123def456..."
  }
}
```

### 3. Cerrar Todas las Sesiones (excepto la actual)

**Endpoint**: `POST /routes/user/close_all_sessions.php`

**Autenticación**: Requerida

**Body**: No requiere

**Respuesta**:

```json
{
  "status": "success",
  "message": "Se cerraron 3 sesión(es) correctamente",
  "data": {
    "sessions_closed": 3,
    "current_session_id": "1d08bc22cc0f5d283526aaef49323404"
  }
}
```

### 4. Historial de Sesiones

**Endpoint**: `GET /routes/user/session_history.php?limit=20`

**Autenticación**: Requerida

**Query Params**:

- `limit` (opcional): Número máximo de registros (default: 20, máx: 100)

**Respuesta**:

```json
{
  "status": "success",
  "message": "Historial recuperado correctamente",
  "data": {
    "history": [
      {
        "session_id": "xyz789...",
        "ip_address": "190.85.123.45",
        "browser": "Google Chrome",
        "os": "Windows 10/11",
        "device_type": "desktop",
        "created_at": "2025-11-05 20:00:00",
        "closed_at": "2025-11-05 21:00:00",
        "close_reason": "logout",
        "session_duration_minutes": 60
      }
    ],
    "total": 1
  }
}
```

---

## 💻 Uso en Frontend (JavaScript)

### Listar Sesiones Activas

```javascript
async function loadActiveSessions() {
  try {
    const response = await AppRouter.get("/routes/user/list_sessions.php");

    if (response.status === "success") {
      const sessions = response.data.sessions;

      sessions.forEach((session) => {
        console.log(`
                    ${session.is_current ? "✅ ACTUAL" : "🌐"}
                    ${session.browser} en ${session.os}
                    IP: ${session.ip_address}
                    Expira en: ${session.minutes_remaining} minutos
                `);
      });
    }
  } catch (error) {
    console.error("Error cargando sesiones:", error);
  }
}
```

### Cerrar Sesión Remota

```javascript
async function closeRemoteSession(sessionId) {
  Swal.fire({
    title: "¿Cerrar sesión remota?",
    text: "Esta acción cerrará la sesión en el otro dispositivo",
    icon: "warning",
    showCancelButton: true,
    confirmButtonText: "Sí, cerrar",
    cancelButtonText: "Cancelar",
  }).then(async (result) => {
    if (result.isConfirmed) {
      try {
        const response = await AppRouter.post(
          "/routes/user/close_remote_session.php",
          { session_id: sessionId }
        );

        if (response.status === "success") {
          Swal.fire("¡Cerrada!", "La sesión se cerró correctamente", "success");
          loadActiveSessions(); // Recargar lista
        }
      } catch (error) {
        Swal.fire("Error", "No se pudo cerrar la sesión", "error");
      }
    }
  });
}
```

### Cerrar Todas las Sesiones

```javascript
async function closeAllSessions() {
  Swal.fire({
    title: "¿Cerrar todas las sesiones?",
    text: "Se cerrarán todas las sesiones excepto la actual",
    icon: "warning",
    showCancelButton: true,
    confirmButtonText: "Sí, cerrar todas",
    cancelButtonText: "Cancelar",
  }).then(async (result) => {
    if (result.isConfirmed) {
      try {
        const response = await AppRouter.post(
          "/routes/user/close_all_sessions.php"
        );

        if (response.status === "success") {
          const count = response.data.sessions_closed;
          Swal.fire("¡Cerradas!", `Se cerraron ${count} sesión(es)`, "success");
          loadActiveSessions();
        }
      } catch (error) {
        Swal.fire("Error", "No se pudo cerrar las sesiones", "error");
      }
    }
  });
}
```

---

## 🎨 Componente UI: Vista de Sesiones

### Tarjeta de Sesión Activa

```html
<div class="card mb-3">
  <div class="card-body">
    <div class="d-flex justify-content-between align-items-center">
      <div>
        <h5 class="card-title mb-1">
          <i class="bx bx-desktop"></i>
          <!-- o bx-mobile -->
          <span class="browser-name">Google Chrome</span>
          <span class="badge bg-success ms-2">Actual</span>
        </h5>
        <p class="card-text text-muted mb-1">
          <i class="bx bx-map"></i> IP: <code>190.85.123.45</code>
        </p>
        <p class="card-text text-muted mb-1">
          <i class="bx bx-laptop"></i> Windows 10/11
        </p>
        <p class="card-text text-muted mb-0">
          <i class="bx bx-time"></i> Expira en: <strong>25 minutos</strong>
        </p>
      </div>
      <div>
        <button
          class="btn btn-danger btn-sm"
          onclick="closeRemoteSession('abc123')"
        >
          <i class="bx bx-x"></i> Cerrar
        </button>
      </div>
    </div>
  </div>
</div>
```

### Botón "Cerrar Todas las Sesiones"

```html
<button class="btn btn-warning" onclick="closeAllSessions()">
  <i class="bx bx-exit"></i> Cerrar Todas las Sesiones
</button>
```

---

## 🔍 Consultas SQL Útiles

### Ver Sesiones Activas de un Usuario

```sql
SELECT * FROM v_active_sessions
WHERE user_id = 4;
```

### Ver Estadísticas de Sesiones

```sql
SELECT
    u.username,
    COUNT(CASE WHEN s.is_active = 1 THEN 1 END) AS sesiones_activas,
    COUNT(*) AS total_sesiones
FROM users u
LEFT JOIN user_sessions s ON u.user_id = s.user_id
GROUP BY u.user_id;
```

### Sesiones por Tipo de Dispositivo

```sql
SELECT
    device_type,
    COUNT(*) AS total,
    COUNT(CASE WHEN is_active = 1 THEN 1 END) AS activas
FROM user_sessions
GROUP BY device_type;
```

### Sesiones por Navegador

```sql
SELECT
    browser,
    COUNT(*) AS total
FROM user_sessions
WHERE browser IS NOT NULL
GROUP BY browser
ORDER BY total DESC;
```

---

## 🧪 Testing

### Test 1: Registro de Sesión en Login

```bash
# 1. Hacer login
curl -X POST https://api.roepard.online/routes/user/auth_user.php \
  -d "username=user@example.com" \
  -d "password=password123" \
  -c cookies.txt

# 2. Verificar que se registró en BD
curl -X GET https://api.roepard.online/routes/user/list_sessions.php \
  -b cookies.txt
```

### Test 2: Cerrar Sesión Remota

```bash
# 1. Obtener session_id de otra sesión
curl -X GET https://api.roepard.online/routes/user/list_sessions.php \
  -b cookies.txt

# 2. Cerrar esa sesión
curl -X POST https://api.roepard.online/routes/user/close_remote_session.php \
  -b cookies.txt \
  -H "Content-Type: application/json" \
  -d '{"session_id": "abc123..."}'
```

### Test 3: Limpieza Automática de Sesiones Expiradas

```sql
-- Llamar procedimiento manualmente
CALL sp_cleanup_expired_sessions();
```

---

## ⚙️ Configuración de Producción

### 1. Habilitar Event Scheduler (MySQL/MariaDB)

```sql
-- Verificar si está habilitado
SHOW VARIABLES LIKE 'event_scheduler';

-- Habilitar si no lo está
SET GLOBAL event_scheduler = ON;

-- Agregar a my.cnf para persistencia
[mysqld]
event_scheduler=ON
```

### 2. Verificar Evento de Limpieza Automática

```sql
-- Ver eventos programados
SHOW EVENTS WHERE Db = 'homelab';

-- El evento debe ejecutarse cada 1 hora
-- Name: evt_cleanup_expired_sessions
-- Schedule: EVERY 1 HOUR
```

### 3. Logs de Sesiones

```bash
# Verificar logs de PHP
tail -f /var/log/php-fpm/error.log | grep "session"

# Verificar logs de MySQL
tail -f /var/log/mysql/error.log | grep "user_sessions"
```

---

## 🔐 Seguridad

### Consideraciones de Seguridad

1. **Validación de Propiedad**: Solo el propietario puede cerrar sus sesiones
2. **Sesión Actual Protegida**: `close_all_sessions` nunca cierra la sesión actual
3. **Logs Completos**: Todas las acciones quedan registradas con `closed_by` y `close_reason`
4. **IP Real**: Se captura la IP real considerando proxies (Cloudflare, Nginx)
5. **Expiración Automática**: Evento SQL limpia sesiones expiradas cada hora

### Prevención de Ataques

- ✅ **Session Hijacking**: Rastreo de IP y User Agent detecta sesiones sospechosas
- ✅ **Brute Force**: Límite de sesiones activas puede ser implementado
- ✅ **Account Takeover**: Usuario puede ver y cerrar sesiones no autorizadas

---

## 📊 Monitoreo y Alertas

### Consulta de Alertas: Múltiples Sesiones Activas

```sql
-- Usuarios con más de 3 sesiones activas (posible ataque)
SELECT
    u.user_id,
    u.username,
    u.email,
    COUNT(*) AS sesiones_activas
FROM user_sessions s
JOIN users u ON s.user_id = u.user_id
WHERE s.is_active = 1 AND s.expires_at > NOW()
GROUP BY u.user_id
HAVING sesiones_activas > 3;
```

### Consulta de Alertas: Sesiones desde IPs Diferentes

```sql
-- Usuario con sesiones desde múltiples IPs (posible cuenta comprometida)
SELECT
    u.username,
    COUNT(DISTINCT s.ip_address) AS ips_distintas,
    GROUP_CONCAT(DISTINCT s.ip_address) AS lista_ips
FROM user_sessions s
JOIN users u ON s.user_id = u.user_id
WHERE s.is_active = 1
GROUP BY u.user_id
HAVING ips_distintas > 2;
```

---

## 🚀 Próximas Mejoras

1. **Notificaciones Push**: Alertar al usuario cuando se detecte nueva sesión
2. **Geolocalización**: Mostrar ubicación aproximada basada en IP
3. **Límite de Sesiones**: Máximo de sesiones activas por usuario
4. **2FA para Sesiones**: Requerir 2FA si se detecta IP desconocida
5. **Dashboard Admin**: Vista global de sesiones de todos los usuarios

---

## 📞 Soporte

Para dudas o problemas:

1. Verificar logs de PHP y MySQL
2. Consultar documentación de API
3. Contactar al equipo de desarrollo

---

**Última actualización**: Noviembre 2025  
**Versión**: 1.0  
**Mantenido por**: Roepard Labs Development Team
