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

*Guía actualizada el 02/01/2025 - HomeLab VR Deployment Guide*
