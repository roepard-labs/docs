# 🚀 Guía de Deployment en Dokploy - HomeLab Frontend

## 📋 Pre-requisitos

- ✅ Repositorio Git con el código (GitHub/GitLab/Bitbucket)
- ✅ Cuenta Dokploy configurada
- ✅ Dominio configurado (ej: `homelab.roepard.online`)
- ✅ Variables de entorno preparadas

---

## 🔧 Configuración en Dokploy

### **Paso 1: Crear Aplicación**

1. Login en Dokploy
2. **Projects** → **Create Project**
3. Configurar:
   ```
   Project Name: homelab-frontend
   Type: Docker
   Repository: https://github.com/tu-usuario/roepard-labs
   Branch: main
   ```

### **Paso 2: Configurar Variables de Entorno**

En **Settings → Environment Variables**, agregar:

```env
# API Configuration
API_URL=https://api.roepard.online

# Application
APP_NAME=Roepard HomeLab
APP_ENV=production
APP_DEBUG=false

# URLs
APP_URL=https://homelab.roepard.online

# Optional: Si usas analytics
ANALYTICS_ID=UA-XXXXXXXXX-X
```

**⚠️ IMPORTANTE:**

- Dokploy inyectará estas variables en el container
- El script `npm run build:config` las leerá y generará `js/config.js`
- **NO** commitear `.env` al repositorio

---

### **Paso 3: Configurar Build Settings**

En **Settings → Build**:

```yaml
# Dockerfile Path
Dockerfile: thepearlo_vr-website/Dockerfile

# Context Path
Context: thepearlo_vr-website

# Port
Port: 3000

# Health Check
Health Check Path: /
```

---

### **Paso 4: Configurar Dominio**

En **Settings → Domains**:

1. **Add Domain**
2. Configurar:
   ```
   Domain: homelab.roepard.online
   Port: 3000
   SSL: Enable (Let's Encrypt)
   ```
3. **Save**

---

### **Paso 5: Configurar Volumes (Opcional - Solo Backend)**

⚠️ **IMPORTANTE**: Para el **backend** solamente, si necesitas persistir datos entre redeploys.

**❌ NO USAR para frontend** - Los archivos estáticos no necesitan persistencia.

#### **Opción 1: Named Volume (Recomendado)**

En **Settings → Mounts**:

```
Mount Type: VOLUME
Volume Name: backend-storage
Mount Path: /var/www/html/storage/
```

**Ventajas:**

- ✅ Docker gestiona el volume automáticamente
- ✅ Persistencia entre redeploys
- ✅ Backups más fáciles
- ✅ No interfiere con permisos del contenedor

#### **Opción 2: Bind Mount Específico**

Solo si necesitas acceder a archivos desde el host:

```
Mount Type: BIND
Host Path: /root/storage-data/logs/
Mount Path: /var/www/html/storage/logs/
```

**⚠️ ADVERTENCIA:**

- **NO** montar directorios completos como `/var/www/html/storage/`
- Esto sobrescribe la estructura interna del contenedor
- Causa errores de "no logs" y aplicación no funcional
- Solo montar subdirectorios específicos que necesites

#### **Opción 3: Sin Volumes (Más Simple)**

Para desarrollo o si no necesitas persistir logs/uploads:

```
NO configurar ningún mount
```

**Ventajas:**

- ✅ Setup más simple
- ✅ Sin problemas de permisos
- ✅ Cada redeploy es "limpio"

**Desventajas:**

- ❌ Logs se pierden al redesplegar
- ❌ Uploads se pierden al redesplegar

---

## 🐳 Proceso de Build

### **Flujo Automático:**

```
1. Dokploy detecta push en GitHub
   ↓
2. Clona repositorio
   ↓
3. Build de imagen Docker
   ├── Instala dependencias PHP
   ├── Instala Node.js 22.x
   ├── Ejecuta npm install --production
   ├── Ejecuta npm run build:config (genera js/config.js)
   ├── Elimina archivos sensibles (.env, .git)
   ├── Crea .env placeholder
   └── Protege directorios (chmod 750)
   ↓
4. Inicia container con supervisord
   ├── nginx en puerto 3000
   └── PHP-FPM en socket unix
   ↓
5. Dominio disponible en https://homelab.roepard.online
```

---

## 🔍 Verificar Deployment

### **1. Verificar Container en Ejecución:**

En Dokploy Dashboard:

- **Status**: Running (verde)
- **Logs**: Ver logs de build y runtime
- **Metrics**: CPU, RAM, Network

### **2. Verificar Sitio Web:**

Abrir navegador:

```
https://homelab.roepard.online
```

**Debe mostrar:**

- ✅ Home page cargando
- ✅ Estilos aplicados (Bootstrap)
- ✅ Sin errores en consola del navegador

### **3. Ejecutar Tests de Seguridad:**

Desde terminal local:

```bash
cd thepearlo_vr-website/scripts
./security-check.sh https://homelab.roepard.online
```

**Output esperado:**

```
═══════════════════════════════════════════════════════════
  🔒 HomeLab Frontend - Security Verification
═══════════════════════════════════════════════════════════

🌐 Testing: https://homelab.roepard.online

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📁 ARCHIVOS SENSIBLES (deben retornar 404)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ PASS - Bloquear .env
✅ PASS - Bloquear .git/config
...

📊 RESUMEN DE TESTS
Total Tests:  30
Passed:       30
Failed:       0

Success Rate: 100%

🎉 ¡Todos los tests de seguridad pasaron!
```

---

## 🐛 Troubleshooting

### **Error 1: Container no inicia**

**Síntoma:**

```
Error: Cannot start container
Status: Exited (1)
```

**Solución:**

1. Ver logs de container:

   ```
   Dokploy Dashboard → Logs → Container Logs
   ```

2. Buscar errores comunes:

   ```
   # npm install falló
   # Solución: Verificar que package.json existe en thepearlo_vr-website/

   # nginx -t falló
   # Solución: Verificar nginx.conf sintaxis

   # generate-config.js falló
   # Solución: Verificar que variables de entorno estén configuradas
   ```

---

### **Error 2: config.js no se genera**

**Síntoma:**

```
Console Error: ENV_CONFIG is not defined
```

**Solución:**

1. Conectar al container:

   ```bash
   docker exec -it <container-id> bash
   ls -lah /var/www/html/js/config.js
   cat /var/www/html/js/config.js
   ```

2. Si no existe, ejecutar manualmente:

   ```bash
   cd /var/www/html
   npm run build:config
   ```

3. Verificar variables de entorno en Dokploy:
   - ¿Están configuradas?
   - ¿Están inyectadas en el container?

---

### **Error 3: 502 Bad Gateway**

**Síntoma:**

```
nginx: 502 Bad Gateway
```

**Solución:**

1. Verificar PHP-FPM:

   ```bash
   docker exec -it <container-id> bash
   ps aux | grep php-fpm
   ```

2. Verificar logs de PHP-FPM:

   ```bash
   tail -f /var/log/php-fpm.log
   ```

3. Reiniciar container desde Dokploy Dashboard

---

### **Error 4: Archivos sensibles accesibles (404 NO funciona)**

**Síntoma:**

```bash
curl https://homelab.roepard.online/.env
# Retorna 200 OK (⚠️ PELIGRO)
```

**Solución:**

1. Verificar nginx.conf en container:

   ```bash
   docker exec -it <container-id> cat /etc/nginx/sites-available/default
   ```

2. Verificar que las reglas de bloqueo estén presentes:

   ```nginx
   location ~ /\.env {
       deny all;
       return 404;
   }
   ```

3. Recargar nginx:
   ```bash
   docker exec -it <container-id> nginx -s reload
   ```

---

## 📊 Monitoreo Post-Deployment

### **Métricas a Monitorear:**

**1. Disponibilidad:**

```bash
# Uptime monitoring
curl -I https://homelab.roepard.online
# Debe retornar 200 OK
```

**2. Performance:**

```bash
# Load time
curl -w "@curl-format.txt" -o /dev/null -s https://homelab.roepard.online

# curl-format.txt:
time_namelookup:  %{time_namelookup}\n
time_connect:     %{time_connect}\n
time_starttransfer: %{time_starttransfer}\n
time_total:       %{time_total}\n
```

**3. Logs:**

```bash
# Logs de nginx (desde Dokploy)
docker logs <container-id> --tail 100 -f

# Filtrar por errores
docker logs <container-id> | grep -i error
```

**4. Seguridad:**

```bash
# Ejecutar security-check.sh periódicamente
./scripts/security-check.sh https://homelab.roepard.online
```

---

## 🔄 CI/CD - Deployment Automático

### **Configurar Webhook en GitHub:**

1. **GitHub Repo** → **Settings** → **Webhooks** → **Add webhook**
2. Configurar:
   ```
   Payload URL: https://dokploy.roepard.online/webhook/<app-id>
   Content type: application/json
   Secret: <webhook-secret>
   Events: Just the push event
   ```
3. **Add webhook**

### **Flujo Automático:**

```
1. Desarrollador hace push a main
   ↓
2. GitHub envía webhook a Dokploy
   ↓
3. Dokploy detecta cambios
   ↓
4. Build automático de nueva imagen
   ↓
5. Deploy automático (zero-downtime)
   ↓
6. Verificación de health check
   ↓
7. ✅ Nueva versión en producción
```

---

## 📝 Checklist de Deployment

**Pre-Deployment:**

- [ ] Variables de entorno configuradas en Dokploy
- [ ] Dominio configurado y DNS apuntando
- [ ] SSL/TLS habilitado (Let's Encrypt)
- [ ] Dockerfile testeado localmente
- [ ] nginx.conf validado (`nginx -t`)

**Durante Deployment:**

- [ ] Build de imagen exitoso
- [ ] Container iniciado correctamente
- [ ] Health check pasando
- [ ] Logs sin errores críticos

**Post-Deployment:**

- [ ] Sitio web accesible
- [ ] `js/config.js` generado correctamente
- [ ] Tests de seguridad pasando (30/30)
- [ ] Performance aceptable (< 2s load time)
- [ ] Monitoreo configurado

---

## 🚨 Troubleshooting Común

### **Problema 1: Backend No Muestra Logs Después de Bind Mount**

**Síntomas:**

- ✅ Container deployed
- ✅ Status: Running
- ❌ No aparecen logs en Dokploy
- ❌ Backend no responde correctamente

**Causa:**
Bind mount con `Host Path: /root/roepard-labs/` → `Mount Path: /var/www/html/storage/` sobrescribió el directorio interno del contenedor, destruyendo la estructura de carpetas (logs/, app/, cache/).

**Solución:**

1. **Remover el Bind Mount:**

   - Dokploy Dashboard → Application → **Settings → Mounts**
   - **Delete** el mount problemático:
     ```
     ❌ Host Path: /root/roepard-labs/
     ❌ Mount Path: /var/www/html/storage/
     ```
   - **Save**

2. **Redesplegar:**

   - Click **Redeploy** en Dokploy
   - Esperar a que termine el build
   - Verificar logs ahora aparecen correctamente

3. **Si necesitas persistencia de datos:**

   **Opción A - Named Volume (Recomendado):**

   ```
   Mount Type: VOLUME
   Volume Name: backend-storage
   Mount Path: /var/www/html/storage/
   ```

   **Opción B - Bind Mount Específico:**
   Solo montar subdirectorios que necesites:

   ```
   Host Path: /root/backend-data/logs/
   Mount Path: /var/www/html/storage/logs/
   ```

   **⚠️ NUNCA montar el directorio completo `/var/www/html/storage/`**

### **Problema 2: CORS Network Error con withCredentials**

**Síntomas:**

- ❌ Network Error en DevTools console
- ❌ `access-control-allow-origin: *` en response headers
- ❌ Sessions no persisten después de reload (F5)
- ❌ Cookie no se envía al backend

**Causa:**
nginx.conf no está retornando origen específico para OPTIONS (preflight) requests. Browser bloquea requests cuando `withCredentials: true` y origin es wildcard `*`.

**Solución:**

1. **Verificar nginx.conf tiene CORS correcto:**

   ```nginx
   location / {
       if ($request_method = 'OPTIONS') {
           add_header 'Access-Control-Allow-Origin' 'https://website.roepard.online' always;
           add_header 'Access-Control-Allow-Credentials' 'true' always;
           add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
           add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization, X-Requested-With, X-CSRF-Token' always;
           add_header 'Access-Control-Max-Age' '86400' always;
           return 204;
       }
       try_files $uri $uri/ /index.php?$query_string;
   }
   ```

2. **Forzar redeploy si nginx.conf cambió:**

   ```bash
   cd thepearlo_vr-backend
   git commit --allow-empty -m "chore: force redeploy for CORS fix"
   git push
   ```

3. **Verificar headers después del deploy:**
   ```bash
   curl -X OPTIONS \
     -H "Origin: https://website.roepard.online" \
     -H "Access-Control-Request-Method: GET" \
     -I https://api.roepard.online/routes/web/status.php
   ```

**Debe mostrar:**

```http
HTTP/2 204
access-control-allow-origin: https://website.roepard.online
access-control-allow-credentials: true
access-control-allow-methods: GET, POST, PUT, DELETE, OPTIONS
```

**✅ Cuando funciona, verás en DevTools:**

```
Request Headers:
  cookie: ROEPARDSESSID=abc123...
  origin: https://website.roepard.online

Response Headers:
  access-control-allow-origin: https://website.roepard.online
  access-control-allow-credentials: true
```

### **Problema 3: Variables de Entorno No Cargan**

**Síntomas:**

- ❌ `window.ENV_CONFIG` es undefined en console
- ❌ Frontend conecta a `localhost:3000` en producción
- ❌ `config.js` no existe o está vacío

**Causa:**
`npm run build:config` no se ejecutó durante el build, o variables de entorno no están en Dokploy.

**Solución:**

1. **Verificar variables en Dokploy:**

   - Settings → Environment Variables
   - Debe tener:
     ```env
     API_URL=https://api.roepard.online
     APP_NAME=Roepard HomeLab
     APP_ENV=production
     ```

2. **Verificar Dockerfile incluye build step:**

   ```dockerfile
   RUN npm install --production
   RUN npm run build:config  # ← Debe estar presente
   ```

3. **Redesplegar para forzar regeneración:**

   ```bash
   git commit --allow-empty -m "chore: regenerate config.js"
   git push
   ```

4. **Verificar después del deploy:**
   ```bash
   curl https://website.roepard.online/composables/config.js
   # Debe mostrar: window.ENV_CONFIG = { API_URL: 'https://...' }
   ```

### **Problema 4: nginx -t Fails During Build**

**Síntomas:**

- ❌ Build falla en step `RUN nginx -t`
- ❌ Error: "directive not allowed here"
- ❌ Error: "add_header directive is not allowed here"

**Causa:**
Sintaxis incorrecta en nginx.conf. `add_header` tiene restricciones en bloques `if`.

**Solución:**

1. **Reglas de nginx para CORS en `if` blocks:**

   ```nginx
   # ✅ CORRECTO: add_header + return en if
   if ($request_method = 'OPTIONS') {
       add_header 'Access-Control-Allow-Origin' '...' always;
       return 204;
   }

   # ❌ INCORRECTO: add_header sin return en if
   if ($request_method = 'OPTIONS') {
       add_header 'Access-Control-Allow-Origin' '...';
       proxy_pass http://backend;  # ← NO funciona
   }
   ```

2. **Probar nginx.conf localmente antes de push:**

   ```bash
   # Opción 1: Con Docker
   docker run --rm -v $(pwd)/nginx.conf:/etc/nginx/sites-available/default nginx nginx -t

   # Opción 2: Si tienes nginx local
   nginx -t -c ./nginx.conf
   ```

3. **Si el error persiste:**
   - Revisar que `always` flag esté presente en `add_header`
   - Asegurar que `return` esté al final del bloque `if`
   - No mezclar `add_header` con `proxy_pass` en mismo `if`

---

## 📚 Recursos Adicionales

- [Dokploy Documentation](https://dokploy.com/docs)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Nginx CORS Configuration](https://enable-cors.org/server_nginx.html)
- [MDN CORS Guide](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
- [PHP-FPM Tuning](https://www.php.net/manual/en/install.fpm.configuration.php)

---

**Última actualización**: Noviembre 2025  
**Versión**: 1.1  
**Mantenido por**: Roepard Labs Development Team

---

## 🎯 Conclusión

**Flujo Simplificado:**

```
1. Configurar variables de entorno en Dokploy
2. Conectar repositorio GitHub
3. Deploy automático
4. Verificar con security-check.sh
5. ✅ Listo para producción
```

**Ventajas de esta Configuración:**

- ✅ Build automático con npm
- ✅ `config.js` generado dinámicamente
- ✅ Seguridad en múltiples capas
- ✅ Zero-downtime deployments
- ✅ SSL/TLS automático
- ✅ Logs centralizados

---

## 📚 Referencias

- **DOCKER-SECURITY.md**: Documentación de seguridad
- **ENV-CONFIG.md**: Sistema de variables de entorno
- **Dockerfile**: Imagen Docker del frontend
- **nginx.conf**: Configuración de servidor web
- **security-check.sh**: Script de verificación

---

_Guía actualizada el 02/01/2025 - HomeLab VR Deployment Guide_
