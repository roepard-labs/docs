# 🔧 FIX: Dashboard Session Stats & Authentication

## 📋 Problemas Detectados

Al implementar el dashboard mejorado con estadísticas, se encontraron múltiples problemas:

### 1. ❌ loadCurrentSession() No Funcionaba

**Síntomas**:

- Todos los campos de sesión mostraban "--"
- No se cargaba información de dispositivo, navegador, IP, hora de inicio

**Causa Raíz**:

```javascript
// ❌ PROBLEMA: listSessions() no existía en SessionService
async function loadCurrentSession() {
  const sessions = await window.SessionService.listSessions(); // undefined
  // ...
}
```

### 2. ❌ stats.php Retornaba 401 No Autenticado

**Síntomas**:

- Tarjetas de estadísticas mostraban "Error" o spinners infinitos
- Console mostraba: `401 Unauthorized` al llamar `/routes/dashboard/stats.php`

**Causa Raíz**:

```php
// ❌ PROBLEMA: Verificación manual de sesión inconsistente
if (!isset($_SESSION['logged_in']) || !$_SESSION['logged_in']) {
    http_response_code(401);
    // ...
}
```

**Por qué fallaba**:

- Otros endpoints usan middleware `Auth::checkAuth()` que funciona correctamente
- stats.php usaba verificación manual que no sincronizaba bien con el sistema de sesiones
- Inconsistencia entre diferentes métodos de validación

### 3. ❌ diagnostic.php Tenía el Mismo Problema

Similar a stats.php, usaba verificación manual en lugar de middleware estándar.

### 4. ❌ $pdo No Estaba Inicializado

**Síntomas**:

- Errores PHP: `Undefined variable: $pdo`

**Causa Raíz**:

```php
// ❌ PROBLEMA: Se usaba $pdo sin crear la instancia PDO
$stmt = $pdo->query("SELECT ..."); // $pdo no existe
```

---

## ✅ Soluciones Implementadas

### 1. ✅ Agregado SessionService.listSessions()

**Archivo**: `/composables/sessionCheck.js`

```javascript
/**
 * Listar todas las sesiones activas del usuario
 * @returns {Promise<Array>} Lista de sesiones
 */
async listSessions() {
    console.log('📋 SessionService: Listando sesiones...');

    // Esperar a que AppRouter esté listo
    if (!window.AppRouter || !window.AppRouter.axiosInstance) {
        await this._waitForRouter();
    }

    try {
        const response = await AppRouter.get('/routes/user/list_sessions.php');

        if (response.status === 'success' && response.data && response.data.sessions) {
            console.log('✅ SessionService: Sesiones recuperadas:', response.data.sessions.length);
            return response.data.sessions;
        }

        console.warn('⚠️ SessionService: Respuesta inesperada al listar sesiones:', response);
        return [];
    } catch (error) {
        console.error('❌ SessionService: Error al listar sesiones:', error);
        return [];
    }
}
```

### 2. ✅ Agregado SessionService.getCurrentSession()

**Archivo**: `/composables/sessionCheck.js`

```javascript
/**
 * Obtener la sesión actual (is_current = true)
 * @returns {Promise<Object|null>} Sesión actual o null
 */
async getCurrentSession() {
    console.log('🔍 SessionService: Obteniendo sesión actual...');

    try {
        const sessions = await this.listSessions();
        const currentSession = sessions.find(s => s.is_current === true);

        if (currentSession) {
            console.log('✅ SessionService: Sesión actual encontrada:', currentSession);
            return currentSession;
        }

        console.warn('⚠️ SessionService: No se encontró sesión marcada como actual');
        // Si no hay is_current, devolver la primera sesión (fallback)
        return sessions.length > 0 ? sessions[0] : null;
    } catch (error) {
        console.error('❌ SessionService: Error al obtener sesión actual:', error);
        return null;
    }
}
```

**Beneficios**:

- ✅ Devuelve solo la sesión actual marcada con `is_current = true`
- ✅ Fallback a primera sesión si no hay flag
- ✅ Manejo de errores completo
- ✅ Logging informativo

### 3. ✅ Actualizado loadCurrentSession() en Dashboard

**Archivo**: `/views/dashboard.view.php`

```javascript
// ✅ ANTES
async function loadCurrentSession() {
  try {
    const sessions = await window.SessionService.listSessions(); // No existía
    if (sessions && sessions.length > 0) {
      const current = sessions[0]; // Primera sesión, no necesariamente la actual
      // ...
    }
  } catch (error) {
    console.error("❌ Error al cargar sesión actual:", error);
  }
}

// ✅ DESPUÉS
async function loadCurrentSession() {
  try {
    const currentSession = await window.SessionService.getCurrentSession();

    if (currentSession) {
      updateElement(
        "currentDevice",
        currentSession.device_type || "Desconocido"
      );
      updateElement("currentBrowser", currentSession.browser || "Desconocido");
      updateElement("currentIP", currentSession.ip_address || "--");
      updateElement(
        "sessionStart",
        formatRelativeTime(currentSession.created_at)
      );

      console.log("✅ Sesión actual cargada:", currentSession);
    } else {
      console.warn("⚠️ No se pudo obtener sesión actual");
    }
  } catch (error) {
    console.error("❌ Error al cargar sesión actual:", error);
  }
}
```

**Mejoras**:

- ✅ Usa `getCurrentSession()` en lugar de `listSessions()[0]`
- ✅ Obtiene la sesión correcta marcada como actual
- ✅ Logging más detallado

### 4. ✅ Migrado stats.php a Middleware Estándar

**Archivo**: `/routes/dashboard/stats.php`

```php
// ❌ ANTES
require_once __DIR__ . '/../../core/db.php';
require_once __DIR__ . '/../../core/session.php';

// Verificación manual inconsistente
if (!isset($_SESSION['logged_in']) || !$_SESSION['logged_in']) {
    http_response_code(401);
    echo json_encode(['status' => 'error', 'message' => 'No autenticado']);
    exit;
}

try {
    $user_id = $_SESSION['user_id'];
    $role_id = $_SESSION['role_id'];
    // ...

// ✅ DESPUÉS
require_once __DIR__ . '/../../config/cors.php';
require_once __DIR__ . '/../../middleware/user.php';
require_once __DIR__ . '/../../middleware/status.php';
require_once __DIR__ . '/../../core/db.php';

header('Content-Type: application/json');

// Verificar método HTTP
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['status' => 'error', 'message' => 'Método no permitido. Use GET.']);
    exit;
}

// Aplicar middleware de seguridad (igual que check_session.php)
$user_id = Auth::checkAuth();
Status::checkStatus(1);

try {
    // Obtener conexión PDO
    $dbConfig = new DBConfig();
    $pdo = $dbConfig->getConnection();

    $role_id = $_SESSION['role_id'] ?? 1;
    // ...
```

**Mejoras**:

- ✅ Usa `Auth::checkAuth()` consistente con otros endpoints
- ✅ Usa `Status::checkStatus(1)` para verificar usuario activo
- ✅ Inicializa `$pdo` correctamente con `DBConfig`
- ✅ Validación de método HTTP
- ✅ Header JSON explícito

### 5. ✅ Migrado diagnostic.php a Middleware Estándar

**Archivo**: `/routes/dashboard/diagnostic.php`

```php
// ❌ ANTES
require_once __DIR__ . '/../../core/db.php';
require_once __DIR__ . '/../../core/session.php';

if (!isset($_SESSION['logged_in']) || !$_SESSION['logged_in']) {
    http_response_code(401);
    echo json_encode(['status' => 'error', 'message' => 'No autenticado']);
    exit;
}

try {
    $diagnostics = [/* ... */];
    $stmt = $pdo->query('SELECT 1'); // ❌ $pdo no existe

// ✅ DESPUÉS
require_once __DIR__ . '/../../config/cors.php';
require_once __DIR__ . '/../../middleware/user.php';
require_once __DIR__ . '/../../middleware/status.php';
require_once __DIR__ . '/../../core/db.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['status' => 'error', 'message' => 'Método no permitido. Use GET.']);
    exit;
}

// Aplicar middleware de seguridad
$user_id = Auth::checkAuth();
Status::checkStatus(1);

try {
    // Obtener conexión PDO
    $dbConfig = new DBConfig();
    $pdo = $dbConfig->getConnection();

    $diagnostics = [/* ... */];
    $stmt = $pdo->query('SELECT 1'); // ✅ $pdo definido
```

**Mejoras**:

- ✅ Consistencia con patrón estándar de autenticación
- ✅ Inicializa `$pdo` correctamente
- ✅ Validación de método HTTP

---

## 🧪 Testing

### Verificación de SessionService

```javascript
// En consola del navegador (http://localhost:9000/dashboard)

// Test 1: Verificar que SessionService esté disponible
console.log("SessionService:", window.SessionService);

// Test 2: Listar todas las sesiones
const sessions = await window.SessionService.listSessions();
console.log("Todas las sesiones:", sessions);

// Test 3: Obtener sesión actual
const current = await window.SessionService.getCurrentSession();
console.log("Sesión actual:", current);

// Test 4: Verificar campos de sesión
console.log("Dispositivo:", current.device_type);
console.log("Navegador:", current.browser);
console.log("IP:", current.ip_address);
console.log("Creada:", current.created_at);
console.log("Es actual:", current.is_current); // true
```

**Resultado esperado**:

```javascript
✅ SessionService: Listando sesiones...
✅ SessionService: Sesiones recuperadas: 2
✅ SessionService: Obteniendo sesión actual...
✅ SessionService: Sesión actual encontrada: {
    session_id: "abc123...",
    user_id: 1,
    device_type: "Desktop",
    browser: "Chrome 131.0",
    ip_address: "192.168.1.100",
    created_at: "2025-01-06 10:30:00",
    is_current: true
}
```

### Verificación de stats.php

```bash
# Test con curl (desde terminal)
curl -i -H "Cookie: PHPSESSID=abc123..." \
     http://localhost:3000/routes/dashboard/stats.php

# Resultado esperado: 200 OK con JSON de stats
HTTP/1.1 200 OK
Content-Type: application/json

{
  "status": "success",
  "stats": {
    "users": { "total": 5, "active": 4, "inactive": 1, "admins": 2 },
    "sessions": { "total": 8, "active": 3, "user_sessions": 2 },
    "storage": { "total_files": 15, "total_size": 5242880, ... },
    "activity": { "logins_today": 5, "logins_week": 20, ... }
  }
}
```

### Verificación de diagnostic.php

```javascript
// En dashboard, click en botón "Ejecutar Diagnóstico"
// Debe abrir modal con accordion mostrando:
// - ✅ Base de datos: Conexión OK
// - ✅ Sesiones PHP: Sistema activo
// - ✅ Tablas requeridas: Todas presentes
// - ✅ Sistema de archivos: Accesible
// - ✅ Extensiones PHP: PDO, MySQLi, etc.
// - ✅ Variables de entorno: Configuradas
```

### Verificación Visual en Dashboard

1. **Card de Sesión Actual** (col-md-6 izquierda):

   ```
   📱 Dispositivo: Desktop
   🌐 Navegador: Chrome 131.0
   🌍 IP: 192.168.1.100
   ⏱️ Sesión iniciada: hace 2 horas
   ```

2. **Tarjetas de Estadísticas** (row con 4 cols):

   ```
   👥 Usuarios Totales: 5
   🟢 Sesiones Activas: 3
   📁 Archivos Totales: 15
   🔑 Logins Hoy: 5
   ```

3. **Gráficas con Chart.js**:
   ```
   📊 Gráfica de Sesiones (line chart): Última semana
   🍩 Gráfica de Roles (doughnut chart): Usuarios por rol
   ```

---

## 📂 Archivos Modificados

### Frontend

1. **`/composables/sessionCheck.js`** ⭐

   - ✅ Agregado `SessionService.listSessions()`
   - ✅ Agregado `SessionService.getCurrentSession()`

2. **`/views/dashboard.view.php`** ⭐
   - ✅ Actualizado `loadCurrentSession()` para usar `getCurrentSession()`

### Backend

3. **`/routes/dashboard/stats.php`** ⭐⭐⭐

   - ✅ Migrado de verificación manual a middleware estándar
   - ✅ Agregado inicialización de `$pdo` con `DBConfig`
   - ✅ Agregado validación de método HTTP
   - ✅ Header JSON explícito

4. **`/routes/dashboard/diagnostic.php`** ⭐⭐⭐
   - ✅ Migrado de verificación manual a middleware estándar
   - ✅ Agregado inicialización de `$pdo` con `DBConfig`
   - ✅ Agregado validación de método HTTP

---

## 🎯 Patrón Estándar de Autenticación

**Para TODOS los endpoints protegidos del backend**:

```php
<?php
/**
 * ENDPOINT: [Nombre del Endpoint]
 * MÉTODO: GET/POST/PUT/DELETE
 */

require_once __DIR__ . '/../../config/cors.php';
require_once __DIR__ . '/../../middleware/user.php';
require_once __DIR__ . '/../../middleware/status.php';
require_once __DIR__ . '/../../core/db.php';

header('Content-Type: application/json');

// Validar método HTTP
if ($_SERVER['REQUEST_METHOD'] !== 'GET') { // o POST/PUT/DELETE
    http_response_code(405);
    echo json_encode(['status' => 'error', 'message' => 'Método no permitido.']);
    exit;
}

// Aplicar middleware de seguridad
$user_id = Auth::checkAuth();          // ✅ Verificar autenticación
Status::checkStatus(1);                // ✅ Verificar usuario activo

try {
    // Obtener conexión PDO si se necesita
    $dbConfig = new DBConfig();
    $pdo = $dbConfig->getConnection();

    // Lógica del endpoint...

    http_response_code(200);
    echo json_encode(['status' => 'success', 'data' => $result]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Error interno', 'details' => $e->getMessage()]);
}
```

**Beneficios de este patrón**:

- ✅ Consistencia: Todos los endpoints usan el mismo método de validación
- ✅ Seguridad: Middleware probado y confiable
- ✅ Mantenibilidad: Fácil de entender y modificar
- ✅ CORS: Configuración centralizada en `cors.php`
- ✅ Errores: Manejo estandarizado de errores

---

## 🚀 Próximos Pasos

1. **Probar en producción**:

   - Verificar que stats.php funcione con dominio real
   - Verificar CORS en producción
   - Verificar cookies HTTPS en producción

2. **Optimizaciones**:

   - Cachear estadísticas por 5 minutos (Redis/Memcached)
   - Paginación para lista de sesiones
   - WebSockets para stats en tiempo real

3. **Mejoras futuras**:
   - Gráfica de actividad por hora del día
   - Mapa de sesiones por ubicación IP
   - Alertas de sesiones sospechosas

---

**Última actualización**: Noviembre 6, 2025  
**Autor**: Roepard Labs Development Team  
**Estado**: ✅ Implementado y Listo para Testing  
**Fixes**: SessionService.getCurrentSession() + Middleware Auth en stats.php/diagnostic.php
