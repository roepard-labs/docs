# 🚀 Quick Start: Sistema CRUD de Archivos - 5 Minutos

## ⚡ Instalación Rápida

### 1️⃣ Base de Datos (2 minutos)

```bash
cd /home/jemg/Documents/GitHub/roepard-labs/thepearlo_vr-website/.github/instructions/
mysql -u root -p homelab < files_tables.sql
```

Verificar:

```sql
mysql -u root -p homelab
SHOW TABLES LIKE '%file%';  # Debe mostrar: files, folders, file_access_log
exit
```

### 2️⃣ Estructura de Storage (1 minuto)

```bash
cd /home/jemg/Documents/GitHub/roepard-labs/thepearlo_vr-backend/storage/app

# Crear carpetas
mkdir -p private/user_{1..4} public

# Permisos
chmod 755 private public
chmod 775 private/user_*

# Verificar
ls -la private/
```

### 3️⃣ Configurar PHP (1 minuto)

```bash
# Editar php.ini
sudo nano /etc/php/8.4/fpm/php.ini

# Cambiar estas 3 líneas:
upload_max_filesize = 50M
post_max_size = 52M
max_execution_time = 300

# Guardar (Ctrl+O, Enter, Ctrl+X)
sudo systemctl restart php8.4-fpm
```

### 4️⃣ Iniciar Servidores (1 minuto)

```bash
# Terminal 1: Backend
cd /home/jemg/Documents/GitHub/roepard-labs/thepearlo_vr-backend
php -S localhost:3000

# Terminal 2: Frontend
cd /home/jemg/Documents/GitHub/roepard-labs/thepearlo_vr-website
php -S localhost:9000 router.php
```

---

## ✅ Test Rápido (2 minutos)

### Test Backend

```bash
# Login
curl -X POST http://localhost:3000/routes/user/auth_user.php \
  -H "Content-Type: application/json" \
  -d '{"username":"user@autonoma.edu.co","password":"user123"}' \
  -c cookies.txt

# Subir archivo
echo "Test" > test.txt
curl -X POST http://localhost:3000/routes/files/upload_file.php \
  -F "file=@test.txt" \
  -F "description=Test" \
  -b cookies.txt

# ✅ Debe retornar: {"status":"success","message":"Archivo subido exitosamente"...}
```

### Test Frontend

1. Abrir: http://localhost:9000
2. Login: `user@autonoma.edu.co` / `user123`
3. Ir a dashboard → Files
4. Subir un archivo
5. ✅ Debe aparecer en el grid

---

## 📦 Archivos Creados

### Backend (7 archivos principales)

```
thepearlo_vr-backend/
├── models/
│   ├── File.php              ✅ NUEVO
│   └── Folder.php            ✅ NUEVO
├── services/
│   ├── FileService.php       ✅ NUEVO
│   └── StorageService.php    ✅ NUEVO
├── controllers/
│   └── FileController.php    ✅ NUEVO
└── routes/files/
    ├── upload_file.php       ✅ NUEVO
    ├── list_files.php        ✅ NUEVO
    ├── get_file.php          ✅ NUEVO
    ├── update_file.php       ✅ NUEVO
    ├── delete_file.php       ✅ NUEVO
    ├── download_file.php     ✅ NUEVO
    └── get_stats.php         ✅ NUEVO
```

### Base de Datos (3 tablas)

```sql
files              -- Metadata de archivos
folders            -- Estructura de carpetas
file_access_log    -- Auditoría (opcional)
```

---

## 🔧 Conectar Frontend con Backend

Editar: `thepearlo_vr-website/pages/files.page.php`

### Buscar línea ~595: Reemplazar loadFiles()

```javascript
// ❌ ANTES
loadDemoFiles(isAdmin ? "admin" : "user");

// ✅ DESPUÉS
async function loadFiles(folderId = "root") {
  try {
    const response = await window.AppRouter.get(
      "/routes/files/list_files.php",
      {
        params: { folder_id: folderId === "root" ? null : folderId },
      }
    );
    if (response.status === "success") {
      allFilesData = response.files;
      filterFilesByFolder(currentFolder);
      updateBreadcrumb();
      updateStats();
    }
  } catch (error) {
    console.error("Error:", error);
  }
}
```

### Buscar línea ~1321: Reemplazar uploadFile()

```javascript
window.uploadFile = async function () {
  const fileInput = document.getElementById("fileInput");
  if (fileInput.files.length === 0) return;

  const formData = new FormData();
  formData.append("file", fileInput.files[0]);
  formData.append(
    "folder_id",
    document.getElementById("uploadFolder").value || null
  );
  formData.append(
    "description",
    document.getElementById("fileDescription").value
  );

  try {
    const response = await window.AppRouter.upload(
      "/routes/files/upload_file.php",
      formData
    );
    if (response.status === "success") {
      notyf.success("Archivo subido");
      const modal = bootstrap.Modal.getInstance(
        document.getElementById("uploadFileModal")
      );
      modal.hide();
      await loadFiles(currentFolder);
    }
  } catch (error) {
    notyf.error("Error al subir archivo");
  }
};
```

### Buscar línea ~1484: Reemplazar deleteFile()

```javascript
window.deleteFile = async function (fileId) {
  const result = await Swal.fire({
    title: "¿Eliminar archivo?",
    icon: "warning",
    showCancelButton: true,
  });
  if (!result.isConfirmed) return;

  try {
    const response = await window.AppRouter.delete(
      "/routes/files/delete_file.php",
      {
        params: { file_id: fileId },
      }
    );
    if (response.status === "success") {
      notyf.success("Archivo eliminado");
      await loadFiles(currentFolder);
    }
  } catch (error) {
    notyf.error("Error");
  }
};
```

---

## 📊 Endpoints Disponibles

| Método | URL                                         | Acción          |
| ------ | ------------------------------------------- | --------------- |
| POST   | `/routes/files/upload_file.php`             | Subir archivo   |
| GET    | `/routes/files/list_files.php`              | Listar archivos |
| GET    | `/routes/files/get_file.php?file_id=X`      | Detalles        |
| PUT    | `/routes/files/update_file.php`             | Editar metadata |
| DELETE | `/routes/files/delete_file.php?file_id=X`   | Eliminar        |
| GET    | `/routes/files/download_file.php?file_id=X` | Descargar       |
| GET    | `/routes/files/get_stats.php`               | Estadísticas    |

---

## 🆘 Troubleshooting Rápido

### Error: "No autenticado"

```bash
# Verificar CORS
curl -I http://localhost:3000/routes/files/list_files.php -H "Origin: http://localhost:9000"
# Debe incluir: Access-Control-Allow-Credentials: true
```

### Error: "Error al subir"

```bash
# Verificar permisos
ls -ld /path/to/backend/storage/app/private/user_3/
# Debe: drwxrwxr-x

# Ver logs
tail -f /var/log/php8.4-fpm.log
```

### Error: "Archivo no encontrado"

```bash
# Verificar BD vs filesystem
mysql -u root -p homelab -e "SELECT file_id, file_path FROM files LIMIT 5;"
ls -la /path/to/backend/storage/app/private/user_*/
```

---

## 📚 Documentación Completa

- **Guía Completa**: `/docs/FILES-BACKEND-FULL-STACK-GUIDE.md`
- **Script SQL**: `.github/instructions/files_tables.sql`
- **Frontend**: `pages/files.page.php` (ya existe, solo conectar)

---

## ✅ Checklist

- [ ] Ejecutar SQL script
- [ ] Crear carpetas storage
- [ ] Configurar permisos
- [ ] Actualizar php.ini
- [ ] Iniciar backend (puerto 3000)
- [ ] Iniciar frontend (puerto 9000)
- [ ] Test upload con cURL
- [ ] Test desde navegador
- [ ] Actualizar files.page.php (3 funciones)
- [ ] Test completo: subir, listar, descargar, eliminar

---

**Tiempo total**: ~10 minutos  
**Dificultad**: ⭐⭐☆☆☆ Fácil  
**Pre-requisitos**: MySQL, PHP 8.4, permisos sudo
