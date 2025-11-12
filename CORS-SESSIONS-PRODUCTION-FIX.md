# 🔐 CORS y Sesiones en Producción - Solución Completa

## 📋 Resumen Ejecutivo

Este documento describe la solución completa al problema de **sesiones que no persisten en producción** debido a configuración CORS incorrecta.

**Fecha**: Noviembre 2025  
**Problema**: Network Error con `withCredentials: true`, sesiones no persisten después de reload  
**Causa Raíz**: nginx retornando `access-control-allow-origin: *` en lugar de origen específico  
**Solución**: Configuración dual nginx + PHP para manejar CORS correctamente

---

## 🎯 El Problema Original

### Síntomas

```javascript
// Frontend (router.js)
withCredentials: true  // ✅ Correcto - envía cookies

// Pero en DevTools Network tab:
Response Headers:
  access-control-allow-origin: *              // ❌ INCORRECTO
  access-control-allow-credentials: (missing) // ❌ FALTA

// Resultado:
❌ Network Error
❌ Cookie no se envía
❌ Sesión no persiste después de reload
```

### Por Qué Falla

**Regla del Navegador (CORS Spec):**

```
SI withCredentials = true
ENTONCES Access-Control-Allow-Origin NO PUEDE SER "*"
DEBE SER el origen específico: "https://website.roepard.online"
Y Access-Control-Allow-Credentials DEBE SER "true"
```

Cuando nginx retorna `*`, el navegador **bloquea la petición** por seguridad.

---

## 🔧 La Solución Implementada

### Arquitectura Dual: nginx + PHP

```
OPTIONS Request (preflight)
    ↓
nginx.conf maneja
    └─→ Retorna headers CORS
        └─→ return 204 (sin PHP)

GET/POST/PUT/DELETE Requests
    ↓
nginx → PHP
    └─→ cors.php maneja
        └─→ Retorna headers CORS + datos
```

### 1️⃣ nginx.conf - Maneja OPTIONS (Preflight)

**Archivo**: `/thepearlo_vr-backend/nginx.conf`

```nginx
server {
    listen 3000;
    root /var/www/html;

    location / {
        # CRÍTICO: Manejar OPTIONS primero
        if ($request_method = 'OPTIONS') {
            # PRODUCCIÓN: Origen específico (NO usar *)
            add_header 'Access-Control-Allow-Origin' 'https://website.roepard.online' always;
            add_header 'Access-Control-Allow-Credentials' 'true' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
            add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization, X-Requested-With, X-CSRF-Token' always;
            add_header 'Access-Control-Max-Age' '86400' always;
            add_header 'Content-Type' 'text/plain; charset=utf-8';
            add_header 'Content-Length' '0';
            return 204;  # No Content - sin ejecutar PHP
        }

        try_files $uri $uri/ /index.php?$query_string;
    }

    # ... resto de configuración
}
```

**Por Qué Funciona:**

- ✅ OPTIONS requests son manejados **antes** de llegar a PHP
- ✅ `return 204` evita ejecución de PHP (más rápido)
- ✅ `always` flag asegura headers en todas las respuestas
- ✅ Origen específico cumple con CORS spec para credentials

### 2️⃣ cors.php - Maneja GET/POST/PUT/DELETE

**Archivo**: `/thepearlo_vr-backend/config/cors.php`

```php
class CORS {
    public static function setHeaders(): void {
        // Leer orígenes permitidos desde .env
        $allowedOrigins = $_ENV['CORS_ALLOWED_ORIGINS'] ?? 'https://website.roepard.online';
        $originsArray = array_map('trim', explode(',', $allowedOrigins));

        // Obtener origen de la petición
        $origin = $_SERVER['HTTP_ORIGIN'] ?? '';

        // Fallback: extraer de Referer si Origin no está presente
        if (empty($origin) && !empty($_SERVER['HTTP_REFERER'])) {
            $parsedReferer = parse_url($_SERVER['HTTP_REFERER']);
            $origin = $parsedReferer['scheme'] . '://' . $parsedReferer['host'];
        }

        // Si el origen está en la lista permitida, configurar CORS
        if (!empty($origin) && in_array($origin, $originsArray)) {
            header("Access-Control-Allow-Origin: $origin");
            header("Access-Control-Allow-Credentials: true");
            header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
            header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, X-CSRF-Token");
            header("Access-Control-Max-Age: 86400");
        }
    }
}

// Auto-ejecutar al incluir el archivo
CORS::setHeaders();
```

**Por Qué Funciona:**

- ✅ Lee `HTTP_ORIGIN` de la petición
- ✅ Valida contra lista permitida en `.env`
- ✅ Retorna origen específico (no wildcard)
- ✅ Incluye `Access-Control-Allow-Credentials: true`
- ✅ Fallback a `HTTP_REFERER` si Origin falta

### 3️⃣ .env - Configuración de Producción

**Archivo**: `/thepearlo_vr-backend/.env`

```env
# CORS - Orígenes permitidos (comma separated)
CORS_ALLOWED_ORIGINS=https://website.roepard.online,https://api.roepard.online

# Session - Cookie domain para compartir entre subdominios
SESSION_COOKIE_DOMAIN=.roepard.online

# Session - Forzar cookie segura en HTTPS
FORCE_SECURE_COOKIE=true

# Session - SameSite policy
SESSION_SAMESITE=Lax
```

**Configuraciones Clave:**

| Variable                | Valor                            | Por Qué                                         |
| ----------------------- | -------------------------------- | ----------------------------------------------- |
| `CORS_ALLOWED_ORIGINS`  | `https://website.roepard.online` | Origen específico requerido para credentials    |
| `SESSION_COOKIE_DOMAIN` | `.roepard.online`                | Punto inicial comparte cookie entre subdominios |
| `FORCE_SECURE_COOKIE`   | `true`                           | HTTPS only (seguridad)                          |
| `SESSION_SAMESITE`      | `Lax`                            | Balance entre seguridad y funcionalidad         |

### 4️⃣ Frontend - router.js con withCredentials

**Archivo**: `/thepearlo_vr-website/composables/router.js`

```javascript
class Router {
  constructor() {
    this.baseURL = window.ENV_CONFIG?.API_URL || "https://api.roepard.online";
    this.initAxios();
  }

  initAxios() {
    this.axiosInstance = axios.create({
      baseURL: this.baseURL,
      timeout: 30000,
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        "X-Requested-With": "XMLHttpRequest",
      },
      withCredentials: true, // ✅ CRÍTICO: Envía cookies en cross-origin
    });
  }
}
```

**Por Qué withCredentials:**

- ✅ Envía cookies `ROEPARDSESSID` al backend
- ✅ Permite sesiones persistentes
- ✅ Funciona con CORS correcto (origen específico)

---

## 🧪 Verificación de la Solución

### Test 1: Verificar Headers de OPTIONS

```bash
curl -X OPTIONS \
  -H "Origin: https://website.roepard.online" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: X-Requested-With" \
  -I https://api.roepard.online/routes/web/status.php
```

**Output Esperado:**

```http
HTTP/2 204
access-control-allow-origin: https://website.roepard.online  ✅
access-control-allow-credentials: true                       ✅
access-control-allow-methods: GET, POST, PUT, DELETE, OPTIONS
access-control-allow-headers: Content-Type, Authorization, X-Requested-With, X-CSRF-Token
access-control-max-age: 86400
```

### Test 2: Verificar Headers de GET

```bash
curl -X GET \
  -H "Origin: https://website.roepard.online" \
  -H "Cookie: ROEPARDSESSID=abc123" \
  -I https://api.roepard.online/routes/web/status.php
```

**Output Esperado:**

```http
HTTP/2 200
access-control-allow-origin: https://website.roepard.online  ✅
access-control-allow-credentials: true                       ✅
content-type: application/json
```

### Test 3: DevTools Network Tab

Abrir https://website.roepard.online y verificar en DevTools:

**Request Headers:**

```
cookie: ROEPARDSESSID=eb8a944ca578fb4c4ea70dcbd901a045  ✅
origin: https://website.roepard.online                 ✅
```

**Response Headers:**

```
access-control-allow-origin: https://website.roepard.online  ✅
access-control-allow-credentials: true                       ✅
```

**Console Logs:**

```
✅ Backend conectado correctamente
✅ SessionService: Usuario autenticado
```

---

## 🚨 Problemas Comunes y Soluciones

### Problema 1: Nginx No Actualiza Después de Deploy

**Síntoma:**

- nginx.conf modificado localmente
- Git push exitoso
- Pero producción sigue retornando headers viejos

**Causa:**
Dokploy no reconstruyó el contenedor (cacheó imagen antigua).

**Solución:**

```bash
# Opción 1: Commit vacío para forzar rebuild
git commit --allow-empty -m "chore: force redeploy"
git push

# Opción 2: Redeploy manual en Dokploy
# Dashboard → Application → Redeploy button
```

### Problema 2: Bind Mount Sobrescribe storage/

**Síntoma:**

- Backend deployed exitosamente
- No aparecen logs en Dokploy
- Status: Running pero no funciona

**Causa:**
Bind mount configurado incorrectamente:

```
❌ Host Path: /root/roepard-labs/
❌ Mount Path: /var/www/html/storage/
```

Esto **destruye** la estructura interna del contenedor:

```
/var/www/html/storage/
├── app/       ❌ Sobrescrito
├── logs/      ❌ Sobrescrito
├── cache/     ❌ Sobrescrito
└── sessions/  ❌ Sobrescrito
```

**Solución:**

1. **Remover el Bind Mount:**
   - Dokploy → Settings → Mounts → Delete
2. **Redesplegar:**
   - Click "Redeploy"
3. **Si necesitas persistencia:**

   ```
   # Opción A: Named Volume (Recomendado)
   Mount Type: VOLUME
   Volume Name: backend-storage
   Mount Path: /var/www/html/storage/

   # Opción B: Bind Mount Específico
   Host Path: /root/backend-data/logs/
   Mount Path: /var/www/html/storage/logs/
   ```

### Problema 3: Wildcard (\*) en Access-Control-Allow-Origin

**Síntoma:**

```
access-control-allow-origin: *
```

**Causa:**

- Variable `$cors_origin` vacía en nginx
- O PHP `cors.php` no ejecutándose
- O Traefik/proxy sobrescribiendo headers

**Solución:**

1. **Verificar nginx.conf tiene origen hardcoded:**

   ```nginx
   add_header 'Access-Control-Allow-Origin' 'https://website.roepard.online' always;
   ```

2. **Verificar cors.php se incluye:**

   ```php
   // En index.php o bootstrap
   require_once __DIR__ . '/config/cors.php';
   ```

3. **Si persiste, revisar proxy (Traefik/Nginx Proxy Manager):**
   - Puede estar agregando headers CORS propios
   - Desactivar CORS en proxy, manejar solo en aplicación

---

## 📊 Checklist de Implementación

### Backend

- [x] nginx.conf con OPTIONS handler hardcoded
- [x] cors.php con validación de origen
- [x] .env con `CORS_ALLOWED_ORIGINS`
- [x] .env con `SESSION_COOKIE_DOMAIN=.roepard.online`
- [x] Dockerfile copia nginx.conf correctamente
- [x] Deploy exitoso en Dokploy
- [x] Test curl OPTIONS retorna origen específico
- [x] Test curl GET retorna origen específico

### Frontend

- [x] router.js con `withCredentials: true`
- [x] config.js con `API_URL` correcto
- [x] sessionCheck.js verifica sesión del backend
- [x] header.ui.php sincroniza con backend
- [x] Deploy exitoso
- [x] DevTools muestra cookie enviada
- [x] DevTools muestra headers CORS correctos
- [x] No hay Network Error en console

### Testing

- [x] Login funciona
- [x] Reload (F5) mantiene sesión
- [x] Navegación entre páginas mantiene sesión
- [x] Logout limpia sesión correctamente
- [x] Backend status check conecta exitosamente

---

## 🎓 Lecciones Aprendidas

### 1. CORS con Credentials es Estricto

```javascript
// Browser enforces:
if (withCredentials === true) {
  if (Access - Control - Allow - Origin === "*") {
    throw new Error("Network Error"); // ❌ Bloqueado
  }
  if (Access - Control - Allow - Credentials !== "true") {
    throw new Error("Network Error"); // ❌ Bloqueado
  }
}
```

**Nunca usar wildcard `*` con credentials.**

### 2. OPTIONS Requests Son Especiales

```
Flujo de Browser:
1. Detecta cross-origin request con credentials
2. Envía OPTIONS (preflight) PRIMERO
3. Si headers correctos → continúa con GET/POST
4. Si headers incorrectos → bloquea TODO
```

**Manejar OPTIONS antes de llegar a PHP (más rápido).**

### 3. Dual nginx + PHP es la Mejor Práctica

```
OPTIONS → nginx (rápido, no ejecuta PHP)
GET/POST/PUT/DELETE → nginx → PHP (lógica de negocio)
```

**Separar concerns: nginx para preflight, PHP para requests reales.**

### 4. Dokploy Puede Cachear Builds

```
git push ≠ Automatic Redeploy
```

**Siempre verificar que el container se reconstruyó.**

### 5. Bind Mounts Pueden Ser Peligrosos

```
❌ /root/data/ → /var/www/html/storage/  (sobrescribe TODO)
✅ /root/data/logs/ → /var/www/html/storage/logs/  (solo logs)
```

**Solo montar subdirectorios específicos, nunca directorios completos.**

---

## 📚 Referencias

- [CORS Specification (W3C)](https://www.w3.org/TR/cors/)
- [MDN - CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
- [MDN - withCredentials](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest/withCredentials)
- [Nginx CORS Guide](https://enable-cors.org/server_nginx.html)
- [PHP Sessions](https://www.php.net/manual/en/book.session.php)
- [Dokploy Documentation](https://dokploy.com/docs)

---

## 🎯 Próximos Pasos

### Mejoras Sugeridas

1. **Monitoreo de CORS:**

   ```javascript
   // Agregar logging de CORS errors
   window.addEventListener("error", (e) => {
     if (e.message.includes("CORS")) {
       console.error("CORS Error:", e);
       // Enviar a analytics
     }
   });
   ```

2. **Health Check de CORS:**

   ```bash
   # Script que verifica CORS periódicamente
   ./scripts/check-cors.sh https://api.roepard.online
   ```

3. **Documentación de Deployment:**

   - ✅ DOKPLOY-DEPLOYMENT.md actualizado
   - ✅ Sección de troubleshooting agregada
   - ✅ Ejemplos de bind mounts correctos

4. **Testing Automatizado:**
   ```javascript
   // Cypress test para verificar CORS
   describe("CORS", () => {
     it("should allow credentials", () => {
       cy.request({
         url: "https://api.roepard.online/routes/web/status.php",
         failOnStatusCode: false,
       }).then((response) => {
         expect(response.headers).to.have.property(
           "access-control-allow-credentials",
           "true"
         );
       });
     });
   });
   ```

---

**Documentado por**: Roepard Labs Development Team  
**Fecha**: Noviembre 2025  
**Versión**: 1.0  
**Estado**: ✅ Problema resuelto, documentado y testeado
