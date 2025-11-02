# 🐳 Docker Security & Build - Resumen de Implementación

## 📋 Cambios Implementados

### 1. **Dockerfile - Build Optimizado con Seguridad** ✅

**Mejoras de Seguridad:**
```dockerfile
# Eliminar archivos sensibles
RUN rm -f /var/www/html/.env \
    && rm -rf /var/www/html/.git \
    && rm -f /var/www/html/.gitignore \
    && rm -f /var/www/html/.dockerignore

# Crear .env placeholder
RUN touch /var/www/html/.env \
    && chmod 600 /var/www/html/.env \
    && chown www-data:www-data /var/www/html/.env
```

**Build de npm con config.js:**
```dockerfile
# Instalar Node.js 22.x
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs

# Instalar dependencias y generar config.js
RUN npm install --production \
    && npm run build:config \
    && echo "✅ Config.js generado desde .env"
```

**Protección de Directorios (Condicional):**
```dockerfile
# Solo proteger directorios que existen
RUN if [ -d /var/www/html/layout ]; then chmod 750 /var/www/html/layout; fi \
    && if [ -d /var/www/html/layouts ]; then chmod 750 /var/www/html/layouts; fi \
    && if [ -d /var/www/html/utils ]; then chmod 750 /var/www/html/utils; fi \
    && if [ -d /var/www/html/scripts ]; then chmod 750 /var/www/html/scripts; fi \
    && if [ -d /var/www/html/pages ]; then chmod 750 /var/www/html/pages; fi
```

**Beneficios:**
- ✅ No falla si una carpeta no existe
- ✅ Genera `js/config.js` desde `.env` automáticamente
- ✅ Elimina archivos sensibles del contenedor final
- ✅ Crea `.env` placeholder con permisos restrictivos (600)

---

### 2. **nginx.conf - Reglas de Seguridad Frontend** ✅

**Bloqueo de Archivos Sensibles:**
```nginx
# Bloquear .env
location ~ /\.env {
    deny all;
    return 404;
}

# Bloquear archivos ocultos
location ~ /\. {
    deny all;
    return 404;
}

# Bloquear config.js generado
location ~ ^/js/config\.js$ {
    deny all;
    return 404;
}

# Bloquear package.json
location ~ ^/package.*\.json$ {
    deny all;
    return 404;
}
```

**Bloqueo de Directorios:**
```nginx
# Bloquear directorios de sistema (sin /ui que no existe)
location ~ ^/(layout|layouts|utils|scripts|pages|node_modules) {
    deny all;
    return 404;
}
```

**Bloqueo de Extensiones Peligrosas:**
```nginx
location ~* \.(ini|log|conf|sql|bak|old|dist|sh|yml|yaml)$ {
    deny all;
    return 404;
}
```

**Prevención de Ejecución PHP en Directorios Protegidos:**
```nginx
location ~ \.php$ {
    # Bloquear PHP en directorios protegidos
    if ($request_uri ~* "^/(layout|layouts|utils|scripts|pages)/.*\.php$") {
        return 404;
    }
    # ... fastcgi_pass
}
```

---

### 3. **package.json - Scripts Optimizados** ✅

**Scripts Reorganizados:**
```json
{
  "scripts": {
    "install:deps": "npm install",
    "install:system": "apt-get update && apt-get install -y build-essential libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev",
    "build:config": "node scripts/generate-config.js",
    "build": "npm run build:config",
    "postinstall": "npm run build:config",
    "dev": "npm run install:deps && npm run build:config",
    "start": "echo '🚀 HomeLab VR Website - Use Docker or nginx+php-fpm para producción'"
  }
}
```

**Comportamiento:**
- `npm install` → automáticamente ejecuta `postinstall` → genera `config.js`
- `npm run dev` → instala deps + genera config
- `npm run build` → solo genera config (útil en CI/CD)

---

## 🔒 Arquitectura de Seguridad

### **Capas de Protección:**

```
🌐 Internet
    ↓
🛡️ NGINX (Layer 1)
    ├── Bloquea: .env, .git, hidden files
    ├── Bloquea: config.js, package.json
    ├── Bloquea: layout/, layouts/, utils/, scripts/, pages/
    ├── Bloquea: extensiones: .ini, .log, .conf, .sql, .bak
    └── Previene: PHP en directorios protegidos
    ↓
📁 Filesystem (Layer 2)
    ├── .env (chmod 600, solo www-data)
    ├── config.js (chmod 644, lectura www-data)
    ├── layout/ (chmod 750, no ejecutable por web)
    ├── layouts/ (chmod 750, no ejecutable por web)
    ├── utils/ (chmod 750, no ejecutable por web)
    ├── scripts/ (chmod 750, no ejecutable por web)
    └── pages/ (chmod 750, no ejecutable por web)
    ↓
🐳 Docker Container (Layer 3)
    ├── Archivos sensibles eliminados (.git, .gitignore, .dockerignore)
    ├── .env original eliminado (placeholder creado)
    └── node_modules incluido pero bloqueado por nginx
```

---

## 🚀 Proceso de Build

### **1. Build Local (Desarrollo):**
```bash
# Instalar dependencias
npm install  # → postinstall ejecuta build:config

# Generar config.js manualmente
npm run build:config

# Verificar config.js
cat js/config.js
# window.ENV_CONFIG = {"API_URL":"https://api.roepard.online",...}
```

### **2. Build Docker (Producción):**
```bash
# Build de imagen
docker build -t homelab-frontend:latest .

# Pasos ejecutados:
# 1. Copiar archivos (respetando .dockerignore)
# 2. Instalar Node.js 22.x
# 3. npm install --production
# 4. npm run build:config (genera js/config.js)
# 5. Eliminar .env original
# 6. Crear .env placeholder (chmod 600)
# 7. Proteger directorios (chmod 750 condicional)
# 8. Configurar nginx + supervisor
# 9. Exponer puerto 3000
```

### **3. Deploy en Dokploy:**
```bash
# Variables de entorno a configurar en Dokploy:
API_URL=https://api.roepard.online
APP_NAME=Roepard HomeLab
APP_ENV=production
APP_DEBUG=false
```

---

## ✅ Verificación de Seguridad

### **Checklist de Validación:**

**Archivos Bloqueados (404):**
```bash
# Intentar acceder (debe retornar 404)
curl https://tu-dominio.com/.env
curl https://tu-dominio.com/.git/config
curl https://tu-dominio.com/js/config.js
curl https://tu-dominio.com/package.json
curl https://tu-dominio.com/node_modules/jquery/package.json
```

**Directorios Bloqueados (404):**
```bash
curl https://tu-dominio.com/layout/AppLayout.php
curl https://tu-dominio.com/layouts/AdminLayout.php
curl https://tu-dominio.com/utils/helpers.php
curl https://tu-dominio.com/scripts/generate-config.js
```

**Extensiones Bloqueadas (404):**
```bash
curl https://tu-dominio.com/config/database.ini
curl https://tu-dominio.com/logs/error.log
curl https://tu-dominio.com/backup.sql
```

**Archivos Accesibles (200):**
```bash
curl https://tu-dominio.com/  # index.php
curl https://tu-dominio.com/css/main.css
curl https://tu-dominio.com/js/main.js
curl https://tu-dominio.com/views/template.view.php  # Si es público
```

---

## 🐛 Debugging

### **Verificar config.js en Container:**
```bash
# Conectar al container
docker exec -it <container-id> bash

# Verificar config.js existe y tiene contenido
ls -lah /var/www/html/js/config.js
cat /var/www/html/js/config.js

# Verificar .env placeholder
ls -lah /var/www/html/.env
cat /var/www/html/.env  # Debe estar vacío

# Verificar permisos de directorios
ls -ld /var/www/html/layout
ls -ld /var/www/html/layouts
ls -ld /var/www/html/utils
```

### **Logs de nginx:**
```bash
# Ver logs de acceso
docker logs <container-id> | grep nginx

# Ver logs de error
tail -f /var/log/nginx/error.log
```

### **Verificar npm build:**
```bash
# Logs del build de Docker
docker build -t test-build . --no-cache --progress=plain

# Buscar línea: "✅ Config.js generado desde .env"
```

---

## 📊 Comparación: Antes vs Después

### **❌ Antes (Inseguro):**
```nginx
# Sin protecciones
location / {
    try_files $uri $uri/ /index.php?$query_string;
}

# .env accesible
curl https://dominio.com/.env  # ⚠️ 200 OK (expone credenciales)

# Directorios accesibles
curl https://dominio.com/layout/AppLayout.php  # ⚠️ 200 OK (código fuente)
```

### **✅ Después (Seguro):**
```nginx
# Protecciones en múltiples capas

# Layer 1: nginx bloquea acceso
curl https://dominio.com/.env  # ✅ 404 Not Found
curl https://dominio.com/js/config.js  # ✅ 404 Not Found
curl https://dominio.com/layout/AppLayout.php  # ✅ 404 Not Found

# Layer 2: filesystem con permisos restrictivos
chmod 600 .env  # Solo www-data puede leer
chmod 750 layout/  # No ejecutable desde web

# Layer 3: archivos sensibles eliminados del container
ls -lah .git  # ✅ No existe en imagen final
```

---

## 🎯 Conclusiones

### **Mejoras Implementadas:**
1. ✅ **Build automatizado**: `npm install` → `postinstall` → `config.js` generado
2. ✅ **Seguridad en capas**: nginx + filesystem + Docker
3. ✅ **Sin fallos de build**: Verificación condicional de directorios
4. ✅ **Documentación completa**: ENV-CONFIG.md + DOCKER-SECURITY.md
5. ✅ **Compatibilidad Dokploy**: Variables de entorno en runtime

### **Archivos Críticos Protegidos:**
- `.env` (bloqueado + chmod 600)
- `js/config.js` (bloqueado desde web)
- `package.json` (bloqueado)
- `layout/`, `layouts/`, `utils/`, `scripts/`, `pages/` (bloqueados)
- `node_modules/` (bloqueado)

### **Performance:**
- Tamaño de imagen optimizado (`.dockerignore` excluye innecesarios)
- `npm install --production` (sin devDependencies)
- nginx con gzip y cache de assets estáticos

---

## 📚 Referencias

- **ENV-CONFIG.md**: Sistema de variables de entorno
- **LAYOUTS-ARQUITECTURA.md**: Sistema de layouts del proyecto
- **Dockerfile**: Imagen Docker con seguridad
- **nginx.conf**: Configuración de servidor web
- **package.json**: Scripts de build y dependencias

---

*Documentación generada el 02/01/2025 - HomeLab VR Frontend Security Implementation*
