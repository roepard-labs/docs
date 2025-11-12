# 🔧 FIX: Sincronización de Logout con Base de Datos

## 🔴 Problema Identificado

### Descripción

Cuando un usuario cerraba sesión desde el frontend (header.ui.php o sidebar.ui.php), la sesión se destruía correctamente en PHP pero **NO se actualizaba el registro en la base de datos**.

**Síntomas**:

- ✅ Sesión de PHP destruida correctamente
- ❌ Registro en `user_sessions` quedaba como `is_active = 1`
- ❌ La sesión cerrada seguía apareciendo en la lista de sesiones activas
- ❌ Acumulación de registros "activos" que en realidad están cerrados

### Causa Raíz

El `LogoutService.php` solo estaba manejando la sesión de PHP pero **no estaba llamando** a `UserSession::closeSession()` para actualizar la base de datos.

**Código anterior**:

```php
// LogoutService.php - ANTES
public function logout() {
    ensure_session_started();
    $_SESSION = [];
    session_destroy();
    // ❌ NO actualiza user_sessions en BD
    return true;
}
```

---

## ✅ Solución Implementada

### Cambios en `/services/LogoutService.php`

**Modificaciones**:

1. ✅ Agregado `require_once` de `UserSession.php`
2. ✅ Constructor para instanciar `UserSession` model
3. ✅ Captura de `session_id` ANTES de destruir sesión PHP
4. ✅ Llamada a `closeSession()` para actualizar BD
5. ✅ Preservación de la lógica original de destrucción de sesión PHP

**Código nuevo**:

```php
<?php
require_once __DIR__ . '/../core/session.php';
require_once __DIR__ . '/../models/UserSession.php';

class LogoutService {
    private $sessionModel;

    public function __construct() {
        $this->sessionModel = new UserSession();
    }

    public function logout() {
        ensure_session_started();

        // CRÍTICO: Obtener session_id ANTES de destruir la sesión
        $currentSessionId = session_id();
        $userId = $_SESSION['user_id'] ?? null;

        // 1. Cerrar sesión en la base de datos
        if ($currentSessionId && $userId) {
            $this->sessionModel->closeSession($currentSessionId, $userId, 'logout');
        }

        // 2. Destruir sesión de PHP
        $_SESSION = [];
        if (ini_get('session.use_cookies')) {
            $params = session_get_cookie_params();
            setcookie(session_name(), '', time() - 42000, $params['path'], $params['domain'], $params['secure'], $params['httponly']);
        }
        session_unset();
        session_destroy();

        return true;
    }
}
?>
```

### Flujo de Logout Actualizado

```
Usuario hace click en "Cerrar Sesión"
         ↓
Frontend llama /routes/user/logout_user.php
         ↓
LogoutController → LogoutService.logout()
         ↓
1. Captura session_id actual y user_id
         ↓
2. UserSession::closeSession(session_id, user_id, 'logout')
   ↓
   UPDATE user_sessions SET:
   - is_active = 0
   - closed_at = NOW()
   - closed_by = user_id
   - close_reason = 'logout'
   WHERE session_id = current_session_id
         ↓
3. Destruir sesión de PHP
   - $_SESSION = []
   - session_destroy()
   - Invalidar cookie
         ↓
✅ Sesión cerrada en BD y en PHP
```

---

## 🧪 Testing

### Test 1: Logout Normal

```bash
# 1. Hacer login
curl -X POST https://api.roepard.online/routes/user/auth_user.php \
  -d "username=user@example.com" \
  -d "password=password123" \
  -c cookies.txt

# 2. Verificar sesión activa en BD
curl -X GET https://api.roepard.online/routes/user/list_sessions.php \
  -b cookies.txt

# Respuesta esperada:
# {
#   "data": {
#     "sessions": [
#       {
#         "session_id": "abc123...",
#         "is_active": 1,  // ✅ Activa
#         "is_current": true
#       }
#     ]
#   }
# }

# 3. Hacer logout
curl -X POST https://api.roepard.online/routes/user/logout_user.php \
  -b cookies.txt

# 4. Verificar que la sesión se cerró en BD
mysql -u root -p homelab -e "
  SELECT session_id, is_active, closed_at, close_reason
  FROM user_sessions
  WHERE session_id = 'abc123...'
"

# Resultado esperado:
# session_id   | is_active | closed_at           | close_reason
# -------------+-----------+---------------------+-------------
# abc123...    |     0     | 2025-11-05 22:00:00 | logout
```

### Test 2: Verificar en Frontend

```javascript
// 1. Login desde frontend
// 2. Abrir dashboard de sesiones
// 3. Verificar sesión actual aparece como activa
// 4. Hacer logout
// 5. Volver a hacer login
// 6. Abrir dashboard de sesiones
// 7. Verificar que la sesión anterior YA NO aparece como activa
```

### Test 3: Verificar Close Reason

```sql
-- Ver últimas sesiones cerradas
SELECT
    user_id,
    session_id,
    closed_at,
    close_reason,
    closed_by
FROM user_sessions
WHERE closed_at IS NOT NULL
ORDER BY closed_at DESC
LIMIT 10;

-- Resultado esperado para logout normal:
-- close_reason = 'logout'
-- closed_by = user_id (el propio usuario)
```

---

## 📊 Beneficios de la Solución

### Antes del Fix

```
❌ Sesiones acumuladas en BD con is_active = 1
❌ Inconsistencia entre sesión PHP y registro BD
❌ Dashboard de sesiones muestra sesiones ya cerradas
❌ Métricas de sesiones activas incorrectas
❌ Imposible distinguir sesiones cerradas manualmente vs expiradas
```

### Después del Fix

```
✅ Sesiones se marcan como is_active = 0 al cerrar
✅ Sincronización perfecta entre PHP y BD
✅ Dashboard muestra solo sesiones realmente activas
✅ Métricas precisas de sesiones activas
✅ Historial completo con close_reason diferenciado:
   - 'logout': Usuario cerró sesión manualmente
   - 'remote': Usuario cerró sesión remota desde otro dispositivo
   - 'expired': Sesión expiró automáticamente
```

---

## 🔐 Seguridad

### Validaciones Implementadas

1. **Captura de session_id ANTES de destruir**:

   ```php
   // CRÍTICO: Hacerlo ANTES de session_destroy()
   $currentSessionId = session_id();
   ```

2. **Validación de datos existentes**:

   ```php
   if ($currentSessionId && $userId) {
       // Solo actualizar si tenemos los datos necesarios
       $this->sessionModel->closeSession(...);
   }
   ```

3. **Registro de auditoría**:
   - `closed_by`: Quién cerró la sesión (el propio usuario)
   - `close_reason`: Razón del cierre ('logout')
   - `closed_at`: Timestamp exacto del cierre

---

## 🚀 Próximos Pasos

### Mejoras Adicionales Sugeridas

1. **Notificación de Sesiones Cerradas**:

   ```php
   // Opcional: Notificar al usuario cuando se cierra una sesión
   if ($sessionClosed) {
       // Enviar notificación push o email
   }
   ```

2. **Logging Centralizado**:

   ```php
   // Log de auditoría para compliance
   error_log("Session closed: user_id={$userId}, session_id={$currentSessionId}");
   ```

3. **Cleanup Automático Mejorado**:
   ```sql
   -- Event programado cada hora
   -- Ya existe: evt_cleanup_expired_sessions
   -- Ahora solo limpiará sesiones expiradas, no las cerradas manualmente
   ```

---

## 📚 Archivos Modificados

- ✅ `/services/LogoutService.php` - Lógica de logout actualizada
- 📄 `/models/UserSession.php` - Ya tenía método `closeSession()`
- 📄 `/routes/user/logout_user.php` - Sin cambios (solo llama al servicio)
- 📄 `/controllers/LogoutController.php` - Sin cambios necesarios

---

## 🧹 Limpieza de Sesiones Huérfanas

### Script para Limpiar Sesiones Antiguas

Si tienes sesiones "activas" que en realidad ya fueron cerradas, puedes ejecutar:

```sql
-- Marcar como cerradas las sesiones sin actividad reciente
UPDATE user_sessions
SET
    is_active = 0,
    closed_at = last_activity,
    close_reason = 'expired'
WHERE
    is_active = 1
    AND last_activity < DATE_SUB(NOW(), INTERVAL 2 HOUR)
    AND closed_at IS NULL;

-- Verificar resultados
SELECT COUNT(*) as sesiones_limpiadas
FROM user_sessions
WHERE close_reason = 'expired' AND closed_at > DATE_SUB(NOW(), INTERVAL 1 DAY);
```

---

## 📞 Soporte

Para dudas sobre este fix:

1. Verificar logs de PHP: `tail -f /var/log/php-fpm/error.log`
2. Verificar BD: `SELECT * FROM user_sessions WHERE user_id = X ORDER BY created_at DESC`
3. Contactar al equipo de desarrollo

---

**Fecha del Fix**: Noviembre 5, 2025  
**Versión**: 1.1  
**Issue**: Sesiones no se cerraban en BD al hacer logout  
**Status**: ✅ RESUELTO  
**Mantenido por**: Roepard Labs Development Team
