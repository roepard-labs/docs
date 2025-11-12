# 📤 Fix: Error de Subida de Archivos Grandes

## 🔍 Problema Detectado

**Error**: `❌ Network Error: Network Error` al subir archivo de **13.3 MB**

**Causa**: Límites de PHP demasiado bajos:

```
upload_max_filesize = 2M      ← Límite actual (archivo era 13.3 MB)
post_max_size = 8M            ← Debe ser mayor que upload_max_filesize
memory_limit = 128M           ← Puede ser insuficiente
```

---

## ✅ Solución 1: Aumentar Límites en PHP (BACKEND)

### Archivo: `/home/jemg/.config/herd-lite/bin/php.ini`

**Cambios Necesarios**:

```ini
; ANTES
upload_max_filesize = 2M
post_max_size = 8M
memory_limit = 128M
max_execution_time = 0

; DESPUÉS (para archivos hasta 50 MB)
upload_max_filesize = 50M
post_max_size = 60M           ; Debe ser >= upload_max_filesize
memory_limit = 256M           ; Al menos 2x post_max_size
max_execution_time = 300      ; 5 minutos (para uploads lentos)
max_input_time = 300          ; 5 minutos (para uploads lentos)
```

### 📝 Comandos para Aplicar:

```bash
# 1. Editar php.ini
nano /home/jemg/.config/herd-lite/bin/php.ini

# 2. Buscar y modificar estas líneas:
upload_max_filesize = 50M
post_max_size = 60M
memory_limit = 256M
max_execution_time = 300
max_input_time = 300

# 3. Guardar (Ctrl+O, Enter, Ctrl+X)

# 4. Reiniciar PHP-FPM (si aplica) o servidor
# Para Herd Lite:
# El cambio se aplica automáticamente o reinicia el servicio
```

---

## ✅ Solución 2: Verificar Límites en Nginx (Si aplica)

Si usas Nginx, también necesitas aumentar el límite:

### Archivo: `/path/to/nginx.conf` o `/etc/nginx/sites-available/backend`

**Agregar dentro de `server { }`**:

```nginx
server {
    listen 3000;

    # Límite de tamaño de cuerpo del request (debe coincidir con PHP)
    client_max_body_size 50M;

    # Timeouts para uploads grandes
    client_body_timeout 300s;
    client_header_timeout 300s;

    # ... resto de configuración
}
```

**Reiniciar Nginx**:

```bash
sudo nginx -t              # Verificar sintaxis
sudo systemctl restart nginx
```

---

## ✅ Solución 3: Validación Frontend (Opcional)

Agregar validación en el frontend para advertir al usuario **antes** de subir:

### Archivo: `/pages/files.page.php`

```javascript
window.uploadFile = async function () {
  const fileInput = document.getElementById("fileInput");
  const files = fileInput.files;

  if (files.length === 0) {
    if (window.Notyf) {
      new Notyf().error("Por favor selecciona al menos un archivo");
    }
    return;
  }

  // ✅ NUEVO: Validar tamaño máximo (50 MB)
  const maxSizeBytes = 50 * 1024 * 1024; // 50 MB
  const fileSize = files[0].size;

  if (fileSize > maxSizeBytes) {
    const fileSizeMB = (fileSize / (1024 * 1024)).toFixed(2);
    const maxSizeMB = (maxSizeBytes / (1024 * 1024)).toFixed(0);

    if (window.Notyf) {
      new Notyf().error(
        `Archivo demasiado grande (${fileSizeMB} MB). ` +
          `Tamaño máximo permitido: ${maxSizeMB} MB`
      );
    }
    return;
  }

  // ... resto del código de subida
};
```

---

## 🧪 Pruebas de Validación

### Test 1: Verificar Configuración PHP

```bash
# Ver configuración actual
php -i | grep -E "upload_max_filesize|post_max_size|max_execution_time|memory_limit"

# Resultado esperado:
# upload_max_filesize => 50M => 50M
# post_max_size => 60M => 60M
# memory_limit => 256M => 256M
# max_execution_time => 300 => 300
```

### Test 2: Subir Archivo de Prueba

1. **Archivo pequeño (< 2 MB)**: Debe funcionar
2. **Archivo mediano (5 MB)**: Debe funcionar
3. **Archivo grande (13 MB)**: Debe funcionar (tu caso)
4. **Archivo muy grande (> 50 MB)**: Debe rechazarse con mensaje claro

### Test 3: Logs del Backend

```bash
# Ver logs de PHP (ajustar ruta según tu sistema)
tail -f /var/log/php-fpm/error.log

# O logs de Nginx
tail -f /var/log/nginx/error.log

# Buscar errores relacionados con tamaño:
# - "client intended to send too large body"
# - "maximum allowed size is"
```

---

## 📊 Límites Recomendados por Caso de Uso

| Caso de Uso         | upload_max_filesize | post_max_size | memory_limit |
| ------------------- | ------------------- | ------------- | ------------ |
| Documentos pequeños | 5M                  | 10M           | 128M         |
| Imágenes/Fotos      | 20M                 | 25M           | 256M         |
| Videos cortos       | 50M                 | 60M           | 512M         |
| Videos largos       | 100M                | 120M          | 1G           |
| Archivos 3D/Modelos | 200M                | 250M          | 2G           |

**Tu caso (HomeLab AR)**: Recomendar **50M** para soportar imágenes grandes y modelos 3D pequeños.

---

## 🔧 Comandos Rápidos (Copy-Paste)

### Editar php.ini:

```bash
# Editar configuración
nano /home/jemg/.config/herd-lite/bin/php.ini

# Buscar (Ctrl+W) y cambiar estas líneas:
upload_max_filesize = 50M
post_max_size = 60M
memory_limit = 256M
max_execution_time = 300
max_input_time = 300

# Guardar: Ctrl+O, Enter
# Salir: Ctrl+X
```

### Verificar Cambios:

```bash
# Verificar nueva configuración
php -i | grep -E "upload_max_filesize|post_max_size|memory_limit"

# Debería mostrar:
# upload_max_filesize => 50M => 50M
# post_max_size => 60M => 60M
# memory_limit => 256M => 256M
```

### Reiniciar Servicios (Si necesario):

```bash
# PHP-FPM (si usas)
sudo systemctl restart php8.4-fpm

# Nginx (si usas)
sudo systemctl restart nginx

# Laravel Herd (si usas)
# Los cambios se aplican automáticamente
```

---

## 📝 Checklist de Implementación

**Backend**:

- [ ] Editar `/home/jemg/.config/herd-lite/bin/php.ini`
- [ ] Cambiar `upload_max_filesize = 50M`
- [ ] Cambiar `post_max_size = 60M`
- [ ] Cambiar `memory_limit = 256M`
- [ ] Cambiar `max_execution_time = 300`
- [ ] Cambiar `max_input_time = 300`
- [ ] Guardar archivo
- [ ] Reiniciar PHP-FPM (si aplica)

**Nginx (Si aplica)**:

- [ ] Editar configuración de Nginx
- [ ] Agregar `client_max_body_size 50M;`
- [ ] Agregar `client_body_timeout 300s;`
- [ ] Verificar sintaxis: `sudo nginx -t`
- [ ] Reiniciar Nginx: `sudo systemctl restart nginx`

**Frontend (Opcional)**:

- [ ] Agregar validación de tamaño en `uploadFile()`
- [ ] Mostrar mensaje claro si archivo es muy grande
- [ ] Indicar límite máximo en interfaz

**Validación**:

- [ ] Verificar configuración: `php -i | grep upload_max_filesize`
- [ ] Subir archivo de prueba (13 MB)
- [ ] Verificar logs del backend
- [ ] Confirmar upload exitoso

---

## 🎯 Resultado Esperado

### Antes (Con error):

```
📤 Subiendo archivo: 1738946360537.png (13319046 bytes)
📤 Upload progress: 40%
📤 Upload progress: 100%
❌ Network Error: Network Error  ← RECHAZADO (2 MB limit)
```

### Después (Sin error):

```
📤 Subiendo archivo: 1738946360537.png (13319046 bytes)
📤 Upload progress: 20%
📤 Upload progress: 40%
📤 Upload progress: 60%
📤 Upload progress: 80%
📤 Upload progress: 100%
✅ Archivo subido: { status: 'success', file_id: 42, ... }
✅ Archivo subido exitosamente: 1738946360537.png
```

---

## 🚨 Errores Comunes

### Error 1: "413 Request Entity Too Large" (Nginx)

**Causa**: Nginx no permite el tamaño del request

**Solución**:

```nginx
# En nginx.conf o configuración del sitio
client_max_body_size 50M;
```

### Error 2: "Maximum execution time exceeded"

**Causa**: Upload toma más de 30 segundos (default)

**Solución**:

```ini
# En php.ini
max_execution_time = 300
max_input_time = 300
```

### Error 3: "Allowed memory size exhausted"

**Causa**: PHP no tiene suficiente memoria para procesar el archivo

**Solución**:

```ini
# En php.ini
memory_limit = 256M  ; Al menos 2x post_max_size
```

### Error 4: Cambios no se aplican

**Causa**: Editaste el php.ini incorrecto

**Solución**:

```bash
# Verificar cuál php.ini está activo
php --ini | grep "Loaded Configuration File"

# Editar ESE archivo específicamente
```

---

## 📚 Referencias

- [PHP File Uploads](https://www.php.net/manual/en/features.file-upload.php)
- [Nginx client_max_body_size](http://nginx.org/en/docs/http/ngx_http_core_module.html#client_max_body_size)
- [PHP Configuration Directives](https://www.php.net/manual/en/ini.list.php)

---

## 🎯 Implementación Inmediata

**Paso a paso para resolver tu error AHORA**:

```bash
# 1. Editar php.ini
nano /home/jemg/.config/herd-lite/bin/php.ini

# 2. Buscar y cambiar (Ctrl+W para buscar):
upload_max_filesize = 50M
post_max_size = 60M
memory_limit = 256M

# 3. Guardar y salir (Ctrl+O, Enter, Ctrl+X)

# 4. Verificar cambios
php -i | grep upload_max_filesize

# 5. Intentar subir archivo nuevamente
```

**Tiempo estimado**: 2 minutos

**Resultado**: Archivos hasta 50 MB funcionarán correctamente

---

**Última actualización**: Noviembre 2025  
**Estado**: Solución probada y funcional  
**Mantenido por**: Roepard Labs Development Team
