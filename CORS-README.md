# Configuración CORS - Backend API

## Descripción General

Este backend implementa un sistema CORS (Cross-Origin Resource Sharing) vanilla en PHP que permite controlar qué orígenes externos pueden acceder a la API.

## Archivos Principales

### 1. `/config/cors.php`
Archivo central que maneja toda la lógica CORS:
- **Clase `CorsHandler`**: Gestiona los headers CORS
- **Método `handleCors()`**: Aplica automáticamente los headers CORS
- **Soporte para peticiones OPTIONS** (preflight requests)
- **Configuración flexible** basada en variables de entorno

### 2. `.env` y `.env.example`
Variables de configuración:

```bash
# Enable CSRF protection (true/false)
CSRF_PROTECTION=true

# CSRF token lifetime in seconds
CSRF_TOKEN_LIFETIME=3600

# Allowed origins for CORS (comma separated, * for all)
CORS_ALLOWED_ORIGINS=*

# Website URL (used for redirects from API root)
WEBSITE_URL=https://yourwebsite.com
```

## Configuración

### Permitir Todos los Orígenes (Desarrollo)
```bash
CORS_ALLOWED_ORIGINS=*
```

### Permitir Orígenes Específicos (Producción)
```bash
CORS_ALLOWED_ORIGINS=https://app.example.com,https://admin.example.com
```

## Implementación en Rutas

Todas las rutas ahora incluyen CORS automáticamente:

```php
<?php
// Aplicar CORS headers (debe ser lo primero)
require_once __DIR__ . '/../../config/cors.php';

// Resto del código de la ruta...
header('Content-Type: application/json');
```

### Rutas Actualizadas

#### Rutas de Usuario (`/routes/user/`)
- ✅ `auth_user.php` - Autenticación
- ✅ `check_session.php` - Verificación de sesión
- ✅ `check_role.php` - Verificación de rol
- ✅ `logout_user.php` - Cierre de sesión

#### Rutas de Admin (`/routes/admin/`)
- ✅ `list_users.php` - Listado de usuarios
- ✅ `det_user.php` - Detalles de usuario
- ✅ `reg_user.php` - Registro de usuario

#### Rutas Web (`/routes/web/`)
- ✅ `status.php` - Estado de la API

## Redirección en Index

El archivo `index.php` ahora redirige automáticamente a la URL del website configurada:

```php
<?php
require_once __DIR__ . '/config/env.php';
require_once __DIR__ . '/config/cors.php';

$websiteUrl = EnvLoader::get('WEBSITE_URL', 'https://thepearlo.com');
header("Location: $websiteUrl");
exit;
```

## Headers CORS Implementados

El sistema configura automáticamente los siguientes headers:

```
Access-Control-Allow-Origin: * (o el origen específico)
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, X-CSRF-Token
Access-Control-Allow-Credentials: true (cuando no es *)
Access-Control-Max-Age: 86400
```

## Manejo de Preflight Requests

El sistema maneja automáticamente las peticiones OPTIONS (preflight):

```php
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    self::setHeaders($allowedOrigins);
    http_response_code(200);
    exit;
}
```

## Uso desde el Frontend

### Ejemplo con Fetch API

```javascript
// Con CORS_ALLOWED_ORIGINS=*
fetch('https://api.example.com/routes/user/auth_user.php', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({
        username: 'user@example.com',
        password: 'password123'
    })
})
.then(response => response.json())
.then(data => console.log(data));
```

### Ejemplo con credenciales

```javascript
// Con orígenes específicos configurados
fetch('https://api.example.com/routes/user/check_session.php', {
    method: 'GET',
    credentials: 'include', // Incluir cookies de sesión
    headers: {
        'Content-Type': 'application/json'
    }
})
.then(response => response.json())
.then(data => console.log(data));
```

## Seguridad

### Recomendaciones para Producción

1. **Nunca usar `*` en producción** con credenciales
2. **Especificar orígenes exactos**:
   ```bash
   CORS_ALLOWED_ORIGINS=https://app.midominio.com
   ```
3. **Activar CSRF protection**:
   ```bash
   CSRF_PROTECTION=true
   CSRF_TOKEN_LIFETIME=3600
   ```

### Ejemplo de Configuración Segura

```bash
# .env para producción
CORS_ALLOWED_ORIGINS=https://app.midominio.com,https://admin.midominio.com
CSRF_PROTECTION=true
CSRF_TOKEN_LIFETIME=3600
WEBSITE_URL=https://www.midominio.com
```

## Troubleshooting

### Error: "No 'Access-Control-Allow-Origin' header"

1. Verificar que `config/cors.php` esté incluido al inicio de la ruta
2. Comprobar configuración en `.env`:
   ```bash
   CORS_ALLOWED_ORIGINS=*
   ```

### Error: Credenciales no se envían

1. Si usas `*`, las credenciales no funcionarán
2. Cambiar a orígenes específicos:
   ```bash
   CORS_ALLOWED_ORIGINS=https://tu-frontend.com
   ```
3. En el frontend usar `credentials: 'include'`

### Error: Preflight request fails

1. Verificar que el servidor responda a OPTIONS
2. El sistema ya maneja esto automáticamente en `cors.php`

## Testing

### Verificar CORS desde el navegador

```javascript
// Abrir consola del navegador y ejecutar:
fetch('https://tu-api.com/routes/web/status.php')
    .then(r => r.json())
    .then(d => console.log(d));
```

### Verificar headers con curl

```bash
curl -X OPTIONS \
  -H "Origin: https://example.com" \
  -H "Access-Control-Request-Method: POST" \
  -v \
  https://tu-api.com/routes/user/auth_user.php
```

## Ventajas de esta Implementación

1. ✅ **Vanilla PHP** - Sin dependencias externas
2. ✅ **Centralizado** - Un solo archivo de configuración
3. ✅ **Flexible** - Soporta múltiples orígenes o wildcards
4. ✅ **Automático** - Solo incluir una línea en cada ruta
5. ✅ **Configurable** - Variables de entorno para diferentes ambientes
6. ✅ **Preflight** - Manejo automático de OPTIONS requests
7. ✅ **Seguro** - Validación de orígenes cuando es necesario

## Estructura de Headers

```
Cliente (Browser)          API Backend
    |                          |
    |-- OPTIONS (Preflight) -->|
    |                          |
    |<-- 200 + CORS Headers ---|
    |                          |
    |-- POST/GET Request ----->|
    |                          |
    |<-- Response + CORS ------|
```

## Notas Adicionales

- El sistema CORS se aplica **antes** de cualquier lógica de negocio
- Los headers CORS se envían en **todas las respuestas**
- El archivo `index.php` siempre redirige a `WEBSITE_URL`
- Compatible con sesiones y cookies (cuando no se usa `*`)

---

**Última actualización**: Noviembre 2025
**Versión**: 1.0.0
