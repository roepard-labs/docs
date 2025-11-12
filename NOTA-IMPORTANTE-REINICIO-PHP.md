# ⚠️ NOTA IMPORTANTE: Reinicio Requerido para Cambios en php.ini

## 🔄 Resumen

**Problema**: Después de ejecutar `increase-upload-limits.sh`, los cambios en `php.ini` no se aplicaban inmediatamente.

**Solución**: **Reiniciar el sistema completo** (PC/servidor).

**Causa**: Algunos entornos de desarrollo PHP (como **Herd Lite**) cargan la configuración de `php.ini` al iniciar y mantienen esa configuración en memoria. Los cambios en el archivo no se reflejan hasta que el proceso PHP se reinicia completamente.

---

## 🎯 ¿Cuándo es Necesario Reiniciar?

### Entornos que REQUIEREN Reinicio del Sistema

- ✅ **Herd Lite** (macOS/Linux)
- ✅ **XAMPP** (Windows/macOS/Linux)
- ✅ **WAMP** (Windows)
- ✅ **MAMP** (macOS)
- ✅ **Laragon** (Windows)

### Entornos que Solo Requieren Reiniciar Servicio

- ⚙️ **PHP-FPM** con systemd:

  ```bash
  sudo systemctl restart php-fpm
  # o
  sudo systemctl restart php8.4-fpm
  ```

- ⚙️ **Apache** con mod_php:

  ```bash
  sudo systemctl restart apache2
  # o
  sudo apachectl restart
  ```

- ⚙️ **Nginx** con PHP-FPM:
  ```bash
  sudo systemctl restart php-fpm
  sudo systemctl restart nginx
  ```

---

## 🧪 Verificación Paso a Paso

### 1. Ejecutar Script de Configuración

```bash
cd /path/to/thepearlo_vr-backend/scripts
bash increase-upload-limits.sh
```

**Salida Esperada**:

```
✅ upload_max_filesize agregado con valor 50M
✅ post_max_size agregado con valor 60M
✅ memory_limit agregado con valor 256M
```

### 2. Verificar Cambios ANTES de Reiniciar

```bash
php -i | grep upload_max_filesize
```

**Resultado Común** (valores viejos aún en memoria):

```
upload_max_filesize => 2M => 2M  ❌ No cambió
```

### 3. Reiniciar Sistema/Servicio

**Opción A - Reiniciar Sistema Completo** (Herd Lite, XAMPP, etc.):

```bash
# Linux/macOS
sudo reboot

# Windows
# Usar menú Inicio → Reiniciar
```

**Opción B - Reiniciar Solo Servicio PHP** (PHP-FPM, Apache):

```bash
# PHP-FPM
sudo systemctl restart php8.4-fpm

# Apache
sudo systemctl restart apache2
```

### 4. Verificar Cambios DESPUÉS de Reiniciar

```bash
php -i | grep upload_max_filesize
```

**Resultado Esperado** (valores nuevos aplicados):

```
upload_max_filesize => 50M => 50M  ✅ Cambió correctamente
```

---

## 📋 Checklist de Aplicación de Cambios

- [ ] Script ejecutado sin errores
- [ ] Backup de `php.ini` creado
- [ ] **Sistema/servicio reiniciado**
- [ ] Verificación con `php -i` muestra nuevos valores
- [ ] Prueba de subida de archivo funciona

---

## 🐛 Troubleshooting

### Problema 1: "Los valores no cambian después del script"

**Síntoma**:

```bash
php -i | grep upload_max_filesize
# upload_max_filesize => 2M => 2M  ❌ Sigue en 2M
```

**Solución**:

```bash
# PASO 1: Verificar que el archivo se modificó
cat /path/to/php.ini | grep upload_max_filesize
# Debe mostrar: upload_max_filesize = 50M

# PASO 2: Reiniciar sistema completo
sudo reboot

# PASO 3: Verificar después del reinicio
php -i | grep upload_max_filesize
# upload_max_filesize => 50M => 50M  ✅
```

### Problema 2: "No sé qué archivo php.ini se está usando"

**Solución**:

```bash
# Ver qué php.ini está activo
php --ini

# Salida:
# Configuration File (php.ini) Path: /etc/php/8.4/cli
# Loaded Configuration File:         /home/user/.config/herd-lite/bin/php.ini
#                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#                                     ESTE es el archivo que se está usando
```

### Problema 3: "Cambié php.ini manualmente pero no funciona"

**Causa**: Editaste el php.ini incorrecto (hay varios)

**Solución**:

```bash
# 1. Encontrar php.ini activo
PHP_INI=$(php --ini | grep "Loaded Configuration File" | awk '{print $4}')
echo $PHP_INI

# 2. Editar ese archivo específico
nano "$PHP_INI"

# 3. Buscar y modificar
# upload_max_filesize = 50M
# post_max_size = 60M
# memory_limit = 256M

# 4. Guardar y reiniciar
sudo reboot
```

### Problema 4: "Script dice 'Nginx detectado' pero no reinicia"

**Causa**: Nginx no necesita reinicio para cambios de PHP (PHP-FPM es independiente)

**Solución**:

```bash
# Reiniciar PHP-FPM (no Nginx)
sudo systemctl restart php-fpm

# O reiniciar sistema completo si usas Herd Lite
sudo reboot
```

---

## 💡 Lecciones Aprendidas

### Por qué Herd Lite Requiere Reinicio Completo

**Herd Lite** es un entorno de desarrollo que:

1. Inicia servicios PHP al arrancar el sistema
2. Carga `php.ini` en memoria al inicio
3. **No recarga** el archivo automáticamente
4. No expone comandos directos para reiniciar servicios

**Por lo tanto**: La única forma de aplicar cambios es **reiniciar el sistema completo**.

### Alternativa: Script con Detección Automática

El script `increase-upload-limits.sh` ya incluye detección de servicios:

```bash
# Detecta PHP-FPM, Apache, Nginx
if systemctl is-active --quiet php-fpm; then
    sudo systemctl restart php-fpm
elif systemctl is-active --quiet apache2; then
    sudo systemctl restart apache2
else
    echo "⚠️ Reinicia el sistema manualmente"
fi
```

**Pero en Herd Lite**: Los servicios no son gestionados por `systemctl`, por lo que el mensaje de advertencia es correcto: **"Reinicia el sistema manualmente"**.

---

## 📊 Comparativa de Métodos de Reinicio

| Entorno         | Método de Reinicio            | Comando                          | Tiempo    |
| --------------- | ----------------------------- | -------------------------------- | --------- |
| Herd Lite       | Reinicio completo del sistema | `sudo reboot`                    | 1-2 min   |
| XAMPP           | Reinicio de panel de control  | GUI de XAMPP                     | 10-20 seg |
| PHP-FPM         | Reinicio de servicio          | `sudo systemctl restart php-fpm` | 1-2 seg   |
| Apache          | Reinicio de servicio          | `sudo systemctl restart apache2` | 2-3 seg   |
| Nginx + PHP-FPM | Reinicio de PHP-FPM           | `sudo systemctl restart php-fpm` | 1-2 seg   |
| Docker          | Reinicio de contenedor        | `docker restart php-container`   | 5-10 seg  |

---

## ✅ Caso Resuelto: Herd Lite

**Usuario**: @jemg  
**Fecha**: Noviembre 5, 2025  
**Entorno**: Herd Lite en Linux

**Problema**:

```bash
# Después de ejecutar script
php -i | grep upload_max_filesize
# upload_max_filesize => 2M => 2M  ❌ No cambió
```

**Solución Aplicada**:

```bash
# 1. Script ejecutado exitosamente
bash increase-upload-limits.sh
# ✅ upload_max_filesize agregado con valor 50M

# 2. Sistema reiniciado
sudo reboot

# 3. Verificación después del reinicio
php -i | grep upload_max_filesize
# upload_max_filesize => 50M => 50M  ✅ Funciona
```

**Resultado**:

- ✅ Límites aplicados correctamente
- ✅ Archivos de hasta 50 MB se pueden subir
- ✅ Sistema funcionando sin errores

---

## 📚 Referencias

- **Script de Configuración**: `/thepearlo_vr-backend/scripts/increase-upload-limits.sh`
- **Documentación Completa**: `/docs/FIX-UPLOAD-SIZE-LIMIT.md`
- **Resumen de Solución**: `/docs/SOLUCION-UPLOAD-SIZE-COMPLETA.md`
- **Manual del Script**: `/thepearlo_vr-backend/scripts/README.md`

---

## 🎯 Recomendación Final

**Para entornos de desarrollo local** (Herd Lite, XAMPP, MAMP, Laragon):

1. ✅ Ejecuta el script de configuración
2. ✅ **Reinicia el sistema completo**
3. ✅ Verifica los cambios con `php -i`
4. ✅ Prueba la subida de archivos

**Para servidores de producción** (PHP-FPM, Apache, Nginx):

1. ✅ Ejecuta el script de configuración
2. ✅ **Reinicia solo el servicio PHP**
3. ✅ Verifica los cambios con `php -i`
4. ✅ Prueba la subida de archivos

**Regla de Oro**: Si después del script los valores no cambian con `php -i`, siempre intenta reiniciar (sistema o servicio) antes de buscar otras soluciones.

---

**Fecha de Documentación**: Noviembre 5, 2025  
**Estado**: Verificado y Funcionando  
**Mantenido por**: Roepard Labs Development Team
