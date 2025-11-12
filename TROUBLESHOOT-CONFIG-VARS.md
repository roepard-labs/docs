# 🐛 Troubleshooting: Config.js sin Variables en Producción

**Fecha**: 3 de noviembre de 2025  
**Problema**: `config.js` generado sin variables de entorno en Dokploy  
**Estado**: ✅ **RESUELTO**

---

## 🔍 Síntomas

```bash
⚠️  API_URL: no definida (usando fallback en router.js)
⚠️  APP_NAME: no definida (usando fallback en router.js)
⚠️  APP_ENV: no definida (usando fallback en router.js)
📊 Variables encontradas: 0/3
```

Pero en la configuración de Dokploy las variables **SÍ están definidas**:

```bash
API_URL=https://api.roepard.online
APP_NAME=Roepard Homelab
APP_ENV=production
```

---

## 🎯 Causa Raíz

El problema tiene **dos momentos** de ejecución de `generate-config.js`:

### 1️⃣ **Build Time** (Docker Build)

```dockerfile
# En Dockerfile, durante npm install
RUN npm install --production
```

`npm install` ejecuta el script `postinstall` que llama a `npm run build:config`, pero en este momento **las variables de Dokploy aún NO están disponibles** (se inyectan en runtime).

**Resultado**: Se genera `config.js` vacío durante el build.

### 2️⃣ **Runtime** (Inicio del Contenedor)

```bash
# En docker-entrypoint.sh
npm run build:config  # ✅ Aquí SÍ hay variables
```

El contenedor regenera `config.js` correctamente al iniciar, pero el error mostrado es del build time.

---

## ✅ Solución Implementada

### Cambio 1: Actualizar `docker-entrypoint.sh`

**Problema**: Buscaba `config.js` en `/var/www/html/js/` pero se genera en `/var/www/html/composables/`

**Solución**:

```bash
# ANTES (❌ Ruta incorrecta)
if [ -f /var/www/html/js/config.js ]; then

# DESPUÉS (✅ Ruta correcta)
if [ -f /var/www/html/composables/config.js ]; then
```

### Cambio 2: Verificación Completa

```bash
# Verificar ruta correcta
if [ -f /var/www/html/composables/config.js ]; then
    echo "✅ config.js generado correctamente"
    cat /var/www/html/composables/config.js
else
    echo "❌ ERROR: config.js no se generó en composables/"
    # Fallback a ruta legacy
    if [ -f /var/www/html/js/config.js ]; then
        echo "⚠️  Encontrado en ruta legacy"
    fi
    exit 1
fi
```

### Cambio 3: Ajustar Permisos en Ruta Correcta

```bash
# Ajustar permisos en composables/
if [ -f /var/www/html/composables/config.js ]; then
    chmod 644 /var/www/html/composables/config.js
    chown www-data:www-data /var/www/html/composables/config.js
fi
```

---

## 🧪 Verificación Post-Deploy

### 1. Verificar Variables de Entorno en Dokploy

En la configuración del proyecto en Dokploy:

```
Environment Variables:
✅ API_URL=https://api.roepard.online
✅ APP_NAME=Roepard Homelab
✅ APP_ENV=production
```

### 2. Verificar Logs del Deployment

**Build Time** (puede mostrar warnings):

```bash
⚠️  Variables no definidas (normal durante build)
📊 Variables encontradas: 0/3
```

**Runtime** (debe mostrar variables correctas):

```bash
🚀 Iniciando HomeLab Frontend...
⚙️  Generando config.js desde variables de entorno...
✅ API_URL: https://api.roepard.online
✅ APP_NAME: Roepard Homelab
✅ APP_ENV: production
📊 Variables encontradas: 3/3
✅ config.js generado correctamente
```

### 3. Verificar Contenido de config.js

Ejecutar en el contenedor:

```bash
docker exec <container-id> cat /var/www/html/composables/config.js
```

**Output esperado**:

```javascript
window.ENV_CONFIG = {
  API_URL: "https://api.roepard.online",
  APP_NAME: "Roepard Homelab",
  APP_ENV: "production",
};
```

### 4. Verificar desde el Frontend

Abrir consola del navegador en `https://roepard.online`:

```javascript
console.log(window.ENV_CONFIG);
console.log(AppRouter.baseURL);
```

**Output esperado**:

```javascript
{API_URL: "https://api.roepard.online", APP_NAME: "Roepard Homelab", APP_ENV: "production"}
"https://api.roepard.online"
```

---

## 📋 Checklist de Deployment

Antes de hacer push:

- [ ] Variables de entorno configuradas en Dokploy
- [ ] `docker-entrypoint.sh` verifica ruta correcta (`composables/config.js`)
- [ ] `generate-config.js` genera en `../composables/config.js`
- [ ] Permisos 644 para `composables/config.js`
- [ ] Owner `www-data:www-data`

Después del deploy:

- [ ] Logs de runtime muestran `✅ API_URL: https://api.roepard.online`
- [ ] Logs de runtime muestran `📊 Variables encontradas: 3/3`
- [ ] `cat composables/config.js` muestra variables correctas
- [ ] Navegador muestra `window.ENV_CONFIG` correctamente
- [ ] `AppRouter.baseURL` apunta a `https://api.roepard.online`

---

## 🔧 Comandos Útiles

### Verificar Variables en Contenedor

```bash
# Listar variables de entorno
docker exec <container-id> env | grep -E "(API_URL|APP_NAME|APP_ENV)"

# Ver config.js generado
docker exec <container-id> cat /var/www/html/composables/config.js
```

### Regenerar config.js Manualmente

```bash
# Entrar al contenedor
docker exec -it <container-id> bash

# Regenerar config.js
cd /var/www/html
npm run build:config

# Verificar
cat composables/config.js
```

### Ver Logs en Tiempo Real

```bash
# Logs del contenedor
docker logs -f <container-id>

# Logs de Nginx
docker exec <container-id> tail -f /var/log/nginx/error.log

# Logs de PHP-FPM
docker exec <container-id> tail -f /var/log/php8.3-fpm.log
```

---

## 🚨 Errores Comunes

### Error 1: `config.js` no se genera

**Causa**: Variables de entorno no inyectadas en Dokploy  
**Solución**: Verificar en Dokploy que las variables estén guardadas

### Error 2: `config.js` generado pero vacío

**Causa**: `docker-entrypoint.sh` no se ejecuta o falla antes de `npm run build:config`  
**Solución**: Ver logs del contenedor para identificar el error

### Error 3: Frontend usa fallback URLs

**Causa**: `config.js` no se carga en el HTML o se carga después de `router.js`  
**Solución**: Verificar orden de carga en `<head>`:

```html
<script src="../composables/npm-loader.js"></script>
<script src="../composables/config.js"></script>
<!-- ANTES de router -->
<script>
  /* Cargar Axios y router.js aquí */
</script>
```

### Error 4: CORS errors en producción

**Causa**: `API_URL` apunta a localhost en vez de `https://api.roepard.online`  
**Solución**: Verificar que `config.js` tenga la URL correcta de producción

---

## 📚 Documentos Relacionados

- **[ENV-CONFIG.md](ENV-CONFIG.md)** - Sistema de variables de entorno
- **[DOKPLOY-DEPLOYMENT.md](DOKPLOY-DEPLOYMENT.md)** - Guía de deployment
- **[DOCKER-SECURITY.md](DOCKER-SECURITY.md)** - Seguridad en Docker
- **[NPM-ARCHITECTURE-UPDATE.md](NPM-ARCHITECTURE-UPDATE.md)** - Arquitectura NPM

---

**Estado**: ✅ **RESUELTO**  
**Archivos modificados**:

- `docker-entrypoint.sh` - Ruta corregida a `composables/config.js`
- `scripts/generate-config.js` - Mensajes actualizados

**Próximo deploy**: Las variables de entorno se cargarán correctamente en runtime
