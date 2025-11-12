# 🚨 Sistema de Páginas de Error - HomeLab AR

## Descripción General

El proyecto implementa un **sistema unificado de páginas de error** elegantes y funcionales para todos los códigos HTTP 40x (errores del cliente) y 50x (errores del servidor). Las páginas están completamente integradas con el sistema de diseño Bootstrap 5 y ofrecen información detallada y útil al usuario.

## 📄 Páginas de Error Implementadas

### 1. **40x.php** - Errores del Cliente (40x)

**Ubicación**: `/40x.php`

**Cuándo se muestra**: Todos los errores relacionados con solicitudes del cliente (códigos 400-499).

**Códigos de Error Soportados**:

- **400** - Bad Request (Solicitud Incorrecta)
- **401** - Unauthorized (No Autorizado)
- **403** - Forbidden (Acceso Prohibido)
- **404** - Not Found (Página No Encontrada)
- **405** - Method Not Allowed (Método No Permitido)
- **408** - Request Timeout (Tiempo de Espera Agotado)
- **429** - Too Many Requests (Demasiadas Solicitudes)

**Características**:

- ✅ Diseño elegante con iconografía clara (bx-error-circle)
- ✅ Muestra la URL solicitada
- ✅ Botón para volver al inicio
- ✅ Botón para ir a página anterior (si existe referer)
- ✅ Enlaces útiles a secciones principales:
  - Inicio
  - Demo VR/AR
  - Documentación (docs.roepard.online)
  - API (api.roepard.online)
- ✅ Animaciones AOS
- ✅ Tema claro/oscuro automático
- ✅ Link a GitHub del proyecto

**Ejemplo de uso**:

```
http://localhost/pagina-inexistente
→ Muestra 404.php
```

### 2. **50x.php** - Errores del Servidor (50x)

**Ubicación**: `/50x.php`

**Cuándo se muestra**: Todos los errores relacionados con el servidor (códigos 500-599).

**Códigos de Error Soportados**:

- **500** - Internal Server Error (Error Interno del Servidor)
- **501** - Not Implemented (No Implementado)
- **502** - Bad Gateway (Gateway Incorrecto)
- **503** - Service Unavailable (Servicio No Disponible)
- **504** - Gateway Timeout (Timeout del Gateway)
- **505** - HTTP Version Not Supported (Versión HTTP No Soportada)
- **507** - Insufficient Storage (Almacenamiento Insuficiente)
- **508** - Loop Detected (Bucle Detectado)
- **511** - Network Authentication Required (Autenticación de Red Requerida)

**Características**:

- ✅ Detecta automáticamente el tipo de error (500/502/503/504)
- ✅ Iconografía específica según el error:
  - 500: `bx-error` (Error Interno)
  - 502: `bx-cloud-off` (Bad Gateway)
  - 503: `bx-time` (Servicio No Disponible)
  - 504: `bx-hourglass` (Timeout)
- ✅ Información técnica detallada:
  - Código de error
  - URL solicitada
  - Hora del error
- ✅ **Panel de Estado del Sistema** con verificación en tiempo real:
  - Estado del Frontend (siempre operativo)
  - Estado del Backend API (verificación dinámica)
  - Estado de la Base de Datos (placeholder)
- ✅ Botón "Reintentar" para recargar la página
- ✅ Verificación automática del backend al cargar
- ✅ Función `checkBackendStatus()` con fetch a `/api/health`
- ✅ Notificaciones Notyf integradas
- ✅ Animaciones de pulse en fondos
- ✅ Guía de acciones útiles para el usuario

**Ejemplo de uso**:

```
Error 500 interno → Muestra 50x.php con código 500
Error 502 de gateway → Muestra 50x.php con código 502
Error 503 de servicio → Muestra 50x.php con código 503
```

## 🔧 Configuración Nginx

### Errores 40x (Errores del Cliente)

```nginx
# Maneja todos los errores del cliente (40x)
error_page 400 401 403 404 405 408 429 /40x.php;

location = /40x.php {
    internal;  # Solo accesible internamente por nginx
    fastcgi_pass 127.0.0.1:9000;
    fastcgi_index index.php;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    fastcgi_param PHP_VALUE "display_errors=off";
    # Pasar código de estado exacto
    fastcgi_param REDIRECT_STATUS $status;
}
```

**Errores cubiertos**:

- 400: Solicitud incorrecta
- 401: No autorizado
- 403: Acceso prohibido
- 404: No encontrado
- 405: Método no permitido
- 408: Timeout de solicitud
- 429: Demasiadas solicitudes (rate limiting)

### Errores 50x (Errores del Servidor)

```nginx
# Maneja todos los errores del servidor (50x)
error_page 500 501 502 503 504 505 507 508 511 /50x.php;

location = /50x.php {
    internal;  # Solo accesible internamente por nginx
    fastcgi_pass 127.0.0.1:9000;
    fastcgi_index index.php;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    fastcgi_param PHP_VALUE "display_errors=off";
    # Pasar código de estado exacto
    fastcgi_param REDIRECT_STATUS $status;
}
```

**Errores cubiertos**:

- 500: Error interno
- 501: No implementado
- 502: Bad gateway
- 503: Servicio no disponible
- 504: Gateway timeout
- 505: Versión HTTP no soportada
- 507: Almacenamiento insuficiente
- 508: Bucle detectado
- 511: Autenticación de red requerida

### Rate Limiting (Opcional)

```nginx
# Configuración global (fuera del bloque server)
limit_req_zone $binary_remote_addr zone=general:10m rate=10r/s;

# Dentro del bloque server
limit_req zone=general burst=20 nodelay;
limit_req_status 429;  # Retorna 429 cuando se excede el límite
```

## 🎨 Integración con AppLayout

Ambas páginas utilizan el sistema AppLayout de forma inteligente:

```php
<?php
require_once __DIR__ . '/layout/AppLayout.php';

// Generar contenido HTML
ob_start();
?>
<!-- HTML del error -->
<?php
$content = ob_get_clean();

// Crear vista temporal
$viewFile = __DIR__ . '/views/error404.temp.php';
file_put_contents($viewFile, $content);

try {
    AppLayout::render('error404.temp', [], [
        'title' => '404 - Página No Encontrada | HomeLab AR',
        'description' => 'La página que buscas no existe',
        'includeHeader' => true,
        'includeFooter' => true,
        'bodyClass' => 'error-page-body',
        'additionalCss' => ['aos'],
        'additionalJs' => ['aos']
    ]);
} finally {
    // Limpiar archivo temporal
    if (file_exists($viewFile)) {
        @unlink($viewFile);
    }
}
?>
```

**Ventajas**:

- ✅ Reutiliza todo el sistema de CSS (variables.css, base.css, main.css)
- ✅ Carga automática de Bootstrap 5, Boxicons, AOS
- ✅ Header y footer consistentes
- ✅ Tema claro/oscuro funcional
- ✅ No duplica código de layout

## 🚀 Variables y Datos Dinámicos

### 404.php

```php
$requested_url = $_SERVER['REQUEST_URI'] ?? '/';
$referer = $_SERVER['HTTP_REFERER'] ?? '/';
```

### 50x.php

```php
$error_code = $_SERVER['REDIRECT_STATUS'] ?? '500';
$requested_url = $_SERVER['REQUEST_URI'] ?? '/';

$error_types = [
    '500' => ['title' => 'Error Interno del Servidor', 'icon' => 'bx-error', 'color' => 'danger'],
    '502' => ['title' => 'Bad Gateway', 'icon' => 'bx-cloud-off', 'color' => 'warning'],
    '503' => ['title' => 'Servicio No Disponible', 'icon' => 'bx-time', 'color' => 'warning'],
    '504' => ['title' => 'Gateway Timeout', 'icon' => 'bx-hourglass', 'color' => 'warning']
];
```

## 🎯 Función de Verificación del Backend

### JavaScript en 50x.php

```javascript
async function checkBackendStatus() {
  const statusBadge = document.getElementById("backend-status");
  statusBadge.innerHTML =
    '<i class="bx bx-loader-alt bx-spin me-1"></i> Verificando...';
  statusBadge.className = "badge bg-secondary";

  try {
    const response = await fetch("http://localhost:3000/api/health", {
      method: "GET",
      timeout: 5000,
    });

    if (response.ok) {
      statusBadge.innerHTML =
        '<i class="bx bx-check-circle me-1"></i> Operativo';
      statusBadge.className = "badge bg-success";

      if (typeof Notyf !== "undefined") {
        const notyf = new Notyf();
        notyf.success("¡El backend está operativo! Puedes reintentar.");
      }
    } else {
      throw new Error("Backend no responde");
    }
  } catch (error) {
    statusBadge.innerHTML =
      '<i class="bx bx-error-circle me-1"></i> No Disponible';
    statusBadge.className = "badge bg-danger";

    if (typeof Notyf !== "undefined") {
      const notyf = new Notyf();
      notyf.error("El backend aún no está disponible");
    }
  }
}

// Auto-verificar estado al cargar
document.addEventListener("DOMContentLoaded", () => {
  setTimeout(checkBackendStatus, 1000);
});
```

**Requisitos**:

- Backend debe tener endpoint `/api/health` que retorne 200 OK
- Notyf debe estar cargado (se incluye via AppLayout)

## 📋 CSS Personalizado

Ambas páginas incluyen CSS inline para componentes específicos:

```css
.custom-alert {
  display: flex;
  align-items: flex-start;
  padding: 1rem 1.5rem;
  border-radius: var(--radius-md);
}

.custom-alert-info {
  border-left: 4px solid var(--color-info);
  background: rgba(23, 162, 184, 0.1);
}

.custom-alert-danger {
  border-left: 4px solid var(--color-danger);
  background: rgba(255, 68, 68, 0.1);
}

.hover-card {
  transition: all var(--transition-base);
}

.hover-card:hover {
  background: var(--bs-tertiary-bg);
  transform: translateX(5px);
}

code {
  padding: 0.25rem 0.5rem;
  background: var(--bs-tertiary-bg);
  border-radius: var(--radius-sm);
  font-size: 0.875rem;
}

@keyframes pulse {
  0%,
  100% {
    opacity: 0.5;
    transform: scale(1);
  }
  50% {
    opacity: 0.8;
    transform: scale(1.05);
  }
}
```

## 🧪 Testing

### Probar Errores 40x

```bash
# 404 - Not Found
http://localhost/esta-pagina-no-existe
→ Debe mostrar 40x.php con código 404

# 403 - Forbidden
# Crear archivo protegido
echo "test" > /var/www/html/test-forbidden.txt
chmod 000 /var/www/html/test-forbidden.txt
http://localhost/test-forbidden.txt
→ Debe mostrar 40x.php con código 403

# 401 - Unauthorized
# Configurar autenticación básica en nginx
http://localhost/admin/secure-page
→ Debe mostrar 40x.php con código 401

# 405 - Method Not Allowed
curl -X POST http://localhost/static-file.html
→ Debe mostrar 40x.php con código 405

# 429 - Too Many Requests (requiere rate limiting configurado)
for i in {1..30}; do curl http://localhost/; done
→ Debe mostrar 40x.php con código 429 después de varias solicitudes

# Verificaciones
✓ Código de error correcto mostrado
✓ Icono apropiado para cada tipo
✓ Descripción específica del error
✓ Sugerencias contextuales (401, 403, 429)
✓ Detalles técnicos (código, URL, método)
```

### Probar Errores 50x

```bash
# 500 - Internal Server Error
echo "<?php throw new Exception('Test'); ?>" > test-error.php
http://localhost/test-error.php
→ Debe mostrar 50x.php con código 500

# 502 - Bad Gateway
docker stop thepearlo_vr-backend
curl http://localhost/api-endpoint
→ Debe mostrar 50x.php con código 502

# 503 - Service Unavailable
# Detener PHP-FPM temporalmente
sudo systemctl stop php8.4-fpm
http://localhost/
sudo systemctl start php8.4-fpm
→ Debe mostrar 50x.php con código 503

# 504 - Gateway Timeout
# Crear script PHP que tarde mucho
echo "<?php sleep(60); ?>" > test-timeout.php
# Configurar timeout bajo en nginx (fastcgi_read_timeout 5s;)
http://localhost/test-timeout.php
→ Debe mostrar 50x.php con código 504

# Verificaciones
✓ Código de error correcto mostrado
✓ Icono apropiado para cada tipo (bx-error, bx-cloud-off, bx-time, etc.)
✓ Descripción específica del error
✓ Panel de estado del sistema
✓ Verificación automática del backend
✓ Notificaciones Notyf funcionando
✓ Botón "Reintentar" funcional
```

## 📊 Dependencias

**CSS**:

- Bootstrap 5 (via AppLayout)
- Boxicons (iconografía)
- AOS (animaciones)
- variables.css, base.css, main.css

**JavaScript**:

- jQuery (via AppLayout)
- Bootstrap JS (via AppLayout)
- AOS (animaciones de scroll)
- Notyf (notificaciones en 50x.php)
- Fetch API (verificación de backend)

## ⚠️ Consideraciones Importantes

1. **Archivos Temporales**: Las páginas crean archivos `.temp.php` en `/views/` que se eliminan automáticamente después de renderizar.

2. **Permisos**: El directorio `/views/` debe tener permisos de escritura para crear archivos temporales.

3. **Variables de Entorno**: 50x.php usa `getenv("API_URL")` para obtener la URL del backend. Asegúrate de configurar `.env`:

   ```
   API_URL=http://localhost:3000
   ```

4. **Endpoint de Health**: El backend debe implementar `/api/health` que retorne:

   ```json
   {
     "status": "ok",
     "timestamp": "2025-11-03T12:00:00Z"
   }
   ```

5. **Nginx Reload**: Después de modificar `nginx.conf`, recargar configuración:
   ```bash
   nginx -t && nginx -s reload
   ```

## 🔄 Mantenimiento

### Actualizar Mensajes de Error

Editar directamente los archivos `404.php` o `50x.php` y modificar el contenido HTML dentro del `ob_start()`.

### Agregar Nuevos Enlaces en 404

```php
<div class="col-md-6">
    <a href="/nueva-seccion" class="d-flex align-items-start text-decoration-none hover-card p-3 rounded">
        <i class="bx bx-icon me-3 mt-1" style="font-size: 1.5rem; color: var(--bs-primary);"></i>
        <div>
            <strong class="d-block mb-1">Título</strong>
            <small class="text-muted">Descripción</small>
        </div>
    </a>
</div>
```

### Personalizar Colores de Error en 50x

```php
$error_types = [
    '500' => ['title' => 'Error Interno', 'icon' => 'bx-error', 'color' => 'danger'],
    // Agregar más códigos...
];
```

## 📚 Referencias

- **AppLayout**: `/layout/AppLayout.php`
- **CSS Variables**: `/css/variables.css`
- **Documentación**: `/docs/LAYOUTS-ARQUITECTURA.md`
- **Nginx Config**: `/nginx.conf`

## 📊 Tabla Resumen de Errores

### Errores 30x (Redirecciones)

| Código | Nombre             | Descripción                              | Icono              | Color   | Auto-redirect |
| ------ | ------------------ | ---------------------------------------- | ------------------ | ------- | ------------- |
| 300    | Multiple Choices   | Múltiples representaciones disponibles   | `bx-list-ul`       | Info    | ❌ No         |
| 301    | Moved Permanently  | Recurso movido permanentemente           | `bx-export`        | Success | ✅ Sí (5s)    |
| 302    | Found              | Redirección temporal                     | `bx-shuffle`       | Info    | ✅ Sí (5s)    |
| 303    | See Other          | Ver respuesta en otra URI                | `bx-link-external` | Info    | ✅ Sí (5s)    |
| 304    | Not Modified       | Usar versión en caché                    | `bx-check-circle`  | Success | ❌ No         |
| 307    | Temporary Redirect | Redirección temporal (mantener método)   | `bx-directions`    | Info    | ✅ Sí (5s)    |
| 308    | Permanent Redirect | Redirección permanente (mantener método) | `bx-export`        | Success | ✅ Sí (5s)    |

### Errores 40x (Cliente)

| Código | Nombre             | Descripción            | Icono             | Color   | Acción Sugerida               |
| ------ | ------------------ | ---------------------- | ----------------- | ------- | ----------------------------- |
| 400    | Bad Request        | Solicitud mal formada  | `bx-error-alt`    | Warning | Revisar sintaxis de solicitud |
| 401    | Unauthorized       | Requiere autenticación | `bx-lock-alt`     | Warning | Iniciar sesión                |
| 403    | Forbidden          | Acceso denegado        | `bx-block`        | Danger  | Contactar administrador       |
| 404    | Not Found          | Recurso no existe      | `bx-error-circle` | Primary | Verificar URL                 |
| 405    | Method Not Allowed | Método HTTP incorrecto | `bx-block`        | Warning | Usar método correcto          |
| 408    | Request Timeout    | Solicitud expiró       | `bx-time`         | Warning | Reintentar                    |
| 429    | Too Many Requests  | Límite de solicitudes  | `bx-traffic-cone` | Warning | Esperar antes de reintentar   |

### Errores 50x (Servidor)

| Código | Nombre                          | Descripción                        | Icono          | Color   | Acción del Sistema    |
| ------ | ------------------------------- | ---------------------------------- | -------------- | ------- | --------------------- |
| 500    | Internal Server Error           | Error no especificado              | `bx-error`     | Danger  | Log automático        |
| 501    | Not Implemented                 | Funcionalidad no soportada         | `bx-wrench`    | Warning | -                     |
| 502    | Bad Gateway                     | Gateway recibió respuesta inválida | `bx-cloud-off` | Warning | Verificar backend     |
| 503    | Service Unavailable             | Servicio en mantenimiento          | `bx-time`      | Warning | Esperar mantenimiento |
| 504    | Gateway Timeout                 | Gateway timeout                    | `bx-hourglass` | Warning | Verificar upstream    |
| 505    | HTTP Version Not Supported      | Versión HTTP no soportada          | `bx-no-entry`  | Danger  | -                     |
| 507    | Insufficient Storage            | Sin espacio disponible             | `bx-hdd`       | Danger  | Limpiar disco         |
| 508    | Loop Detected                   | Bucle infinito detectado           | `bx-infinite`  | Danger  | Revisar configuración |
| 511    | Network Authentication Required | Auth de red requerida              | `bx-wifi-off`  | Warning | Autenticar en red     |

## 🎨 Paleta de Colores por Error

```css
/* Colores Bootstrap 5 usados */
--bs-info: #0dcaf0; /* 300, 302, 303, 307 - Redirecciones informativas */
--bs-success: #198754; /* 301, 304, 308 - Redirecciones exitosas */
--bs-primary: #0d6efd; /* 404 - Error común, no crítico */
--bs-warning: #ffc107; /* 401, 405, 408, 429, 502, 503, 504 - Advertencias */
--bs-danger: #dc3545; /* 403, 500, 505, 507, 508 - Errores críticos */
```

## ⏱️ Sistema de Auto-Redirección

Los códigos 301, 302, 303, 307 y 308 incluyen:

- **Contador regresivo** de 5 segundos
- **Barra de progreso visual** animada
- **Redirección automática** al finalizar
- **Cancelación** al hacer clic en cualquier botón
- **Preservación del método HTTP** (307/308)

## 🧪 Testing de Errores 30x

### Probar Redirecciones

```bash
# 301 - Moved Permanently
curl -I http://localhost:3000/redirect-301

# 302 - Found (Temporary)
curl -I http://localhost:3000/redirect-302

# 304 - Not Modified (con headers condicionales)
curl -H "If-Modified-Since: $(date -R)" http://localhost:3000/

# 307 - Temporary Redirect
curl -X POST -I http://localhost:3000/redirect-307

# 308 - Permanent Redirect
curl -X POST -I http://localhost:3000/redirect-308
```

### Configuración de Redirecciones en Nginx

```nginx
# Ejemplo de redirección permanente
location /old-page {
    return 301 /new-page;
}

# Ejemplo de redirección temporal
location /temp-page {
    return 302 /temporary-location;
}

# Redirección manteniendo método HTTP
location /api-v1 {
    return 308 /api-v2;
}
```

---

**Última actualización**: 2025-11-03  
**Versión**: 3.0.0 (Sistema Completo 30x/40x/50x)  
**Autor**: Roepard Labs
