# 🚀 Iniciar Backend API - Guía Rápida

**Fecha**: 3 de noviembre de 2025  
**Proyecto**: HomeLab VR - Backend API  
**Puerto**: `localhost:3000`

---

## 🔴 Problema Común

```
❌ Network Error: Network Error
📤 GET: /routes/web/status.php
💡 El backend no está corriendo en localhost:3000
```

---

## ✅ Solución: Iniciar el Backend

### Opción 1: PHP Built-in Server (Desarrollo)

```bash
# Navegar al directorio del backend
cd thepearlo_vr-backend

# Iniciar servidor PHP en puerto 3000
php -S localhost:3000

# Verificar que esté corriendo
# Deberías ver: "Development Server (http://localhost:3000) started"
```

**Output esperado**:

```
[Sun Nov  3 10:00:00 2025] PHP 8.4.0 Development Server (http://localhost:3000) started
```

### Opción 2: Docker (Producción)

```bash
# Desde el directorio raíz
cd thepearlo_vr-backend

# Construir imagen Docker
docker build -t thepearlo-backend .

# Ejecutar contenedor
docker run -d -p 3000:3000 --name thepearlo-backend thepearlo-backend

# Verificar que esté corriendo
docker ps | grep thepearlo-backend
```

### Opción 3: Nginx + PHP-FPM (Producción)

```bash
# Configurar virtual host en Nginx
sudo nano /etc/nginx/sites-available/thepearlo-backend

# Reiniciar servicios
sudo systemctl restart php8.4-fpm
sudo systemctl restart nginx
```

---

## 🧪 Verificar que el Backend Funciona

### Test 1: Desde el navegador

Abre en tu navegador:

```
http://localhost:3000/routes/web/status.php
```

**Respuesta esperada**:

```json
{
  "status": "success",
  "message": "API is running",
  "timestamp": "2025-11-03 10:00:00"
}
```

### Test 2: Desde la consola con curl

```bash
curl http://localhost:3000/routes/web/status.php
```

**Respuesta esperada**:

```json
{
  "status": "success",
  "message": "API is running",
  "timestamp": "2025-11-03 10:00:00"
}
```

### Test 3: Desde la consola del navegador (Frontend)

```javascript
// En la consola del navegador con la página cargada
AppRouter.get("/routes/web/status.php")
  .then((data) => console.log("✅ Backend conectado:", data))
  .catch((err) => console.error("❌ Backend no disponible:", err));
```

**Respuesta esperada**:

```
📤 GET: /routes/web/status.php
📥 Response [200]: {status: 'success', message: 'API is running', ...}
✅ Backend conectado: {status: 'success', message: 'API is running', ...}
```

---

## 📋 Checklist de Verificación

Antes de trabajar con el frontend, asegúrate de:

- [ ] El backend está corriendo en `localhost:3000`
- [ ] El endpoint `/routes/web/status.php` responde correctamente
- [ ] La base de datos está configurada (`.env` en backend)
- [ ] CORS está habilitado para `localhost:9000` (frontend)
- [ ] No hay errores en los logs del backend

---

## 🔧 Solución de Problemas

### Error: "Address already in use"

```bash
# Ver qué proceso está usando el puerto 3000
lsof -i :3000

# Matar el proceso (reemplaza PID con el número correcto)
kill -9 PID

# O usar otro puerto
php -S localhost:3001
# Recuerda actualizar .env en frontend: API_URL=http://localhost:3001
```

### Error: "Permission denied"

```bash
# Verificar permisos del directorio
ls -la thepearlo_vr-backend/

# Dar permisos de ejecución si es necesario
chmod +x thepearlo_vr-backend/
```

### Error: "Database connection failed"

```bash
# Verificar que MySQL/MariaDB esté corriendo
sudo systemctl status mariadb

# Verificar configuración en .env
cat thepearlo_vr-backend/.env | grep DB_
```

---

## 🌐 URLs del Proyecto

### Desarrollo

- **Frontend**: `http://localhost:9000` (puerto por defecto de PHP/Nginx)
- **Backend API**: `http://localhost:3000`
- **Base de datos**: `localhost:3306` (MySQL/MariaDB)

### Producción

- **Frontend**: `https://roepard.online`
- **Backend API**: `https://api.roepard.online`
- **Base de datos**: `localhost:3306` (acceso interno)

---

## 📝 Flujo de Trabajo Recomendado

```bash
# Terminal 1: Backend
cd thepearlo_vr-backend
php -S localhost:3000

# Terminal 2: Frontend (si usas servidor de desarrollo)
cd thepearlo_vr-website
php -S localhost:9000

# Terminal 3: Base de datos (si es necesario)
sudo systemctl start mariadb
```

---

## 🔍 Logs Útiles

```bash
# Logs del servidor PHP built-in
# Se muestran directamente en la terminal donde ejecutaste php -S

# Logs de Nginx
tail -f /var/log/nginx/error.log
tail -f /var/log/nginx/access.log

# Logs de PHP-FPM
tail -f /var/log/php8.4-fpm.log

# Logs de MySQL
tail -f /var/log/mysql/error.log
```

---

**Estado**: 📖 **DOCUMENTADO**  
**Autor**: GitHub Copilot  
**Próximos pasos**: Iniciar backend con `php -S localhost:3000` y recargar frontend
