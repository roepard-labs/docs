# ⚡ Quick Deployment Checklist - HomeLab Frontend

## 🚀 Deployment Rápido en 5 Pasos

### ✅ Paso 1: Preparar Variables de Entorno
```env
# En Dokploy → Settings → Environment Variables

API_URL=https://api.roepard.online
APP_NAME=Roepard HomeLab
APP_ENV=production
APP_DEBUG=false
```

### ✅ Paso 2: Configurar Build
```yaml
# En Dokploy → Settings → Build

Dockerfile Path: thepearlo_vr-website/Dockerfile
Context: thepearlo_vr-website
Port: 3000
```

### ✅ Paso 3: Configurar Dominio
```
# En Dokploy → Settings → Domains

Domain: homelab.roepard.online
Port: 3000
SSL: Enable (Let's Encrypt)
```

### ✅ Paso 4: Deploy
```bash
# Push a GitHub (main branch)
git add .
git commit -m "Deploy: Configuración de seguridad Docker"
git push origin main

# Dokploy detecta cambios y hace build automático
```

### ✅ Paso 5: Verificar
```bash
# Test de seguridad
cd thepearlo_vr-website/scripts
./security-check.sh https://homelab.roepard.online

# Verificar sitio
open https://homelab.roepard.online
```

---

## 🔍 Verificación Rápida

### **Container Running:**
```bash
# En Dokploy Dashboard
Status: Running ✅
CPU: < 50%
RAM: < 512MB
```

### **Sitio Accesible:**
```bash
# Test básico
curl -I https://homelab.roepard.online
# Expected: HTTP/2 200
```

### **Seguridad Activa:**
```bash
# Test de .env bloqueado
curl -I https://homelab.roepard.online/.env
# Expected: HTTP/2 404
```

### **config.js Generado:**
```bash
# En consola del navegador (F12)
console.log(window.ENV_CONFIG);
# Expected: {API_URL: "https://api.roepard.online", ...}
```

---

## 🐛 Troubleshooting Rápido

### **Error: Build falla**
```bash
# Ver logs en Dokploy Dashboard → Logs
# Buscar:
# - npm install errors
# - chmod errors (Ya no debería pasar ✅)
# - nginx -t errors
```

### **Error: config.js no existe**
```bash
# Conectar al container
docker exec -it <container-id> bash
cd /var/www/html
npm run build:config
```

### **Error: 502 Bad Gateway**
```bash
# Verificar PHP-FPM
docker exec -it <container-id> ps aux | grep php-fpm

# Reiniciar container desde Dokploy
```

### **Error: Seguridad no funciona**
```bash
# Ejecutar tests
./scripts/security-check.sh https://homelab.roepard.online

# Si fallan, verificar nginx.conf en container
docker exec -it <container-id> cat /etc/nginx/sites-available/default
```

---

## 📋 Pre-Deploy Checklist

**Antes de hacer push:**
- [ ] Variables de entorno configuradas en Dokploy
- [ ] Dockerfile testeado localmente (`docker build -t test .`)
- [ ] nginx.conf validado (`nginx -t`)
- [ ] package.json con scripts correctos
- [ ] `.env` NO commiteado (debe estar en .gitignore)

**Después del deploy:**
- [ ] Container en estado "Running"
- [ ] Sitio accesible (https)
- [ ] Tests de seguridad pasando (30/30)
- [ ] config.js generado
- [ ] Sin errores en logs

---

## 🎯 Comandos Útiles

```bash
# Build local para testing
docker build -t homelab-test thepearlo_vr-website/

# Run local
docker run -p 3000:3000 homelab-test

# Tests de seguridad local
./scripts/security-check.sh http://localhost:3000

# Ver logs de container
docker logs <container-id> -f

# Conectar a container
docker exec -it <container-id> bash

# Verificar config.js en container
docker exec -it <container-id> cat /var/www/html/js/config.js

# Verificar permisos
docker exec -it <container-id> ls -lah /var/www/html/layout
docker exec -it <container-id> ls -lah /var/www/html/js/config.js
```

---

## 📚 Documentación Completa

- **DEPLOYMENT-FINAL-SUMMARY.md** - Resumen completo de cambios
- **DOCKER-SECURITY.md** - Arquitectura de seguridad
- **DOKPLOY-DEPLOYMENT.md** - Guía detallada de deployment
- **ENV-CONFIG.md** - Sistema de variables de entorno

---

## ✅ Todo Listo

**Si completaste los 5 pasos + verificación:**
🎉 **¡Tu aplicación está en producción!**

**URL:** https://homelab.roepard.online
**Status:** ✅ Seguro y funcionando
**Next:** Configurar CI/CD con webhooks (opcional)

---

*Quick Checklist - HomeLab VR Frontend Deployment*
