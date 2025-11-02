# 🔒 Guía de Seguridad - Backend API

## Problema: Archivos Sensibles Accesibles

Si puedes descargar archivos `.env` u otros archivos sensibles desde tu deployment en Dokploy, aquí está la solución completa.

---

## ✅ Soluciones Implementadas

### 1. **Dockerfile con Protección**
El Dockerfile ahora:
- ✅ Elimina cualquier `.env` de la imagen durante el build
- ✅ Crea un `.env` vacío con permisos `600` (solo lectura para www-data)
- ✅ Protege directorios críticos con permisos `750`
- ✅ Verifica la configuración de Nginx antes de iniciar

### 2. **Nginx con Bloqueo Reforzado**
El `nginx.conf` bloquea:
- ✅ Archivos `.env` (primera regla, máxima prioridad)
- ✅ Todos los archivos ocultos (`.git`, `.gitignore`, etc.)
- ✅ Directorios internos (`config/`, `core/`, `models/`, etc.)
- ✅ Extensiones peligrosas (`.ini`, `.log`, `.conf`, `.sql`, `.bak`)
- ✅ Acceso directo a archivos PHP en directorios protegidos

### 3. **Permisos del Sistema de Archivos**
```bash
.env          → 600 (rw-------)  # Solo www-data puede leer
config/       → 750 (rwxr-x---)  # PHP puede ejecutar, web NO
core/         → 750 (rwxr-x---)
middleware/   → 750 (rwxr-x---)
models/       → 750 (rwxr-x---)
services/     → 750 (rwxr-x---)
controllers/  → 750 (rwxr-x---)
storage/private/ → 700 (rwx------)  # Solo www-data, total
```

---

## 🚀 Cómo Implementar en Dokploy

### Paso 1: Commit y Push de Cambios
```bash
git add .
git commit -m "🔒 Security: Protect .env and sensitive files"
git push origin main
```

### Paso 2: Configurar Variables en Dokploy
En el panel de Dokploy:
1. Ve a tu aplicación
2. Ve a la sección **Environment Variables**
3. Configura tus variables:
   ```
   DB_CONNECTION=mysql
   DB_HOST=tu-host
   DB_DATABASE=tu-db
   DB_PORT=3306
   DB_USERNAME=tu-usuario
   DB_PASSWORD=tu-password
   CORS_ALLOWED_ORIGINS=*
   WEBSITE_URL=https://tu-website.com
   ```

### Paso 3: Rebuild y Deploy
1. En Dokploy, haz click en **Rebuild**
2. Espera a que se complete el build
3. La aplicación se reiniciará automáticamente

### Paso 4: Verificar Seguridad
Intenta acceder a estos URLs (todos deben dar 404):
```
https://tu-api.com/.env
https://tu-api.com/config/db.php
https://tu-api.com/core/session.php
https://tu-api.com/.git/config
https://tu-api.com/.gitignore
```

---

## 🔍 Verificación de Seguridad

### Test 1: Intentar descargar .env
```bash
curl -I https://tu-api.com/.env
# Debe retornar: HTTP/1.1 404 Not Found
```

### Test 2: Intentar acceder a config
```bash
curl -I https://tu-api.com/config/db.php
# Debe retornar: HTTP/1.1 404 Not Found
```

### Test 3: Verificar que la API funciona
```bash
curl https://tu-api.com/routes/web/status.php
# Debe retornar: {"status":"success","message":"API is running",...}
```

---

## ⚠️ Por Qué Seguías Viendo el .env

**El problema era:**

1. **Dokploy inyecta el `.env`** después de que la imagen está construida
2. **El archivo existe físicamente** en `/var/www/html/.env`
3. **Nginx debe bloquearlo activamente**, no solo confiar en permisos

**La solución:**

- ✅ Nginx bloquea `.env` como **primera regla** (prioridad máxima)
- ✅ Permisos `600` impiden lectura desde otros usuarios
- ✅ `access_log off` y `log_not_found off` evitan logs de intentos
- ✅ Directorios protegidos no son accesibles vía web

---

## 🛡️ Capas de Seguridad Implementadas

```
┌─────────────────────────────────────┐
│  1. Nginx: Bloquea requests         │ ← Primera línea de defensa
├─────────────────────────────────────┤
│  2. Permisos: chmod 600 en .env     │ ← Sistema de archivos
├─────────────────────────────────────┤
│  3. Ubicación: Fuera de /public     │ ← Arquitectura
├─────────────────────────────────────┤
│  4. .dockerignore: No copiar        │ ← Build time
├─────────────────────────────────────┤
│  5. .gitignore: No versionar        │ ← Repositorio
└─────────────────────────────────────┘
```

---

## 📋 Checklist Final

Antes de hacer deploy, verifica:

- [ ] `.env` está en `.gitignore`
- [ ] `.env` NO está en el repositorio Git
- [ ] Variables configuradas en Dokploy
- [ ] Dockerfile actualizado con protecciones
- [ ] nginx.conf actualizado con bloqueos
- [ ] Rebuild completado exitosamente
- [ ] Tests de seguridad pasados (404 en archivos sensibles)
- [ ] API funcionando correctamente

---

## 🐛 Troubleshooting

### "Todavía puedo descargar .env"

1. **Verificar que la nueva imagen se deployó:**
   ```bash
   # En Dokploy, revisa los logs del build
   # Busca: "Copying nginx.conf"
   ```

2. **Verificar puerto correcto:**
   - Dockerfile expone: `3000`
   - nginx.conf escucha: `3000`
   - Dokploy debe mapear: `80:3000` o `443:3000`

3. **Verificar configuración de Nginx:**
   ```bash
   # Conectarse al contenedor
   docker exec -it <container-id> bash
   
   # Verificar nginx.conf
   cat /etc/nginx/sites-available/default | grep "location ~ /\.env"
   ```

4. **Verificar permisos:**
   ```bash
   # Dentro del contenedor
   ls -la /var/www/html/.env
   # Debe mostrar: -rw------- 1 www-data www-data
   ```

### "Error 500 después del deploy"

1. Revisa los logs de Nginx:
   ```bash
   docker logs <container-id> 2>&1 | grep nginx
   ```

2. Revisa que PHP-FPM esté corriendo:
   ```bash
   docker exec -it <container-id> ps aux | grep php-fpm
   ```

---

## 📚 Referencias

- **Nginx Security**: https://nginx.org/en/docs/http/ngx_http_access_module.html
- **Docker Best Practices**: https://docs.docker.com/develop/dev-best-practices/
- **PHP Security**: https://www.php.net/manual/en/security.php

---

**Última actualización**: Noviembre 2025  
**Estado**: ✅ Protección completa implementada
