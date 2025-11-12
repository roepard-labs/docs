# 📁 Guía Completa: Sistema CRUD de Archivos y Carpetas - Backend Full Stack

**HomeLab AR - Roepard Labs**  
**Fecha**: Noviembre 4, 2025  
**Versión**: 2.0 - Backend MVC Completo

---

## 📋 Tabla de Contenidos

1. [Resumen Ejecutivo](#-resumen-ejecutivo)
2. [Arquitectura del Sistema](#-arquitectura-del-sistema)
3. [Instalación de Base de Datos](#-instalación-de-base-de-datos)
4. [Archivos Backend Creados](#-archivos-backend-creados)
5. [Configuración del Servidor](#-configuración-del-servidor)
6. [Integración con Frontend](#-integración-con-frontend)
7. [Testing y Verificación](#-testing-y-verificación)
8. [Seguridad y Permisos](#-seguridad-y-permisos)
9. [Troubleshooting](#-troubleshooting)

---

## 🎯 Resumen Ejecutivo

### ¿Qué se implementó?

Sistema **completo** de gestión de archivos y carpetas con:

- ✅ **Arquitectura MVC estricta** (igual que tu sistema de autenticación)
- ✅ **Permisos por roles**: Admin ve TODO, usuario solo su carpeta
- ✅ **Base de datos**: 3 tablas nuevas (`files`, `folders`, `file_access_log`)
- ✅ **Almacenamiento físico**: `/storage/app/private/user_X/`
- ✅ **CRUD completo**: Upload, Download, Edit, Delete, View, Search
- ✅ **Gestión de carpetas**: Navegación jerárquica con breadcrumb
- ✅ **API REST**: 7 endpoints funcionales
- ✅ **Frontend**: Ya existe en `/pages/files.page.php` (solo necesita conexión)

### Stack Tecnológico

**Backend**: PHP 8.4 + MySQL + MVC Pattern  
**Frontend**: HTML + JavaScript (AppRouter con Axios) + Bootstrap 5  
**Storage**: Sistema de archivos (no se guarda binario en BD)  
**Auth**: Sistema existente con sesiones PHP

---

## 🏗️ Arquitectura del Sistema

### Flujo Completo

```
📱 FRONTEND
   └─ files.page.php (JavaScript)
        ↓ HTTP Request (AppRouter)

🌐 RUTAS API
   └─ /routes/files/*.php
        ├─ CORS headers
        ├─ Sesión PHP
        └─ Llama al controlador
             ↓

🎮 CONTROLADOR
   └─ FileController.php
        ├─ Valida método HTTP
        ├─ Verifica autenticación (Auth::checkAuth())
        ├─ Obtiene user_id y role_id de sesión
        └─ Coordina servicios
             ↓

⚙️ SERVICIOS
   ├─ FileService.php (Lógica de negocio)
   │    ├─ Validaciones
   │    ├─ Procesamiento
   │    └─ Llama a StorageService + Modelo
   │
   └─ StorageService.php (Filesystem)
        ├─ Validar archivo (tamaño, tipo, extensión)
        ├─ Generar nombre único
        ├─ Mover archivo a storage/
        └─ Retornar metadata
             ↓

🗄️ MODELOS
   ├─ File.php (Tabla files)
   │    ├─ create() - INSERT
   │    ├─ findById() - SELECT por ID
   │    ├─ listByUserAndFolder() - SELECT por usuario
   │    ├─ update() - UPDATE metadata
   │    └─ delete() - DELETE
   │
   └─ Folder.php (Tabla folders)
        ├─ create() - Crear carpeta
        ├─ listByUser() - Listar carpetas
        └─ delete() - Eliminar carpeta
             ↓

💾 BASE DE DATOS + 📂 FILESYSTEM
   ├─ MySQL: Metadata (nombre, tamaño, tipo, user_id)
   └─ Storage: Archivos físicos (storage/app/private/user_X/)
```

### Separación de Responsabilidades (MVC Estricto)

| Capa            | Responsabilidad      | NO debe hacer                    |
| --------------- | -------------------- | -------------------------------- |
| **Modelo**      | Acceso a datos (SQL) | Validaciones, sesiones, HTTP     |
| **Servicio**    | Lógica de negocio    | Acceso directo a BD, manejo HTTP |
| **Controlador** | HTTP + Coordinación  | Lógica compleja, SQL directo     |

---

## 💾 Instalación de Base de Datos

### Paso 1: Ejecutar Script SQL

El script ya fue creado en:  
`/home/jemg/Documents/GitHub/roepard-labs/thepearlo_vr-website/.github/instructions/files_tables.sql`

```bash
# Opción A: Desde terminal
cd /home/jemg/Documents/GitHub/roepard-labs/thepearlo_vr-website/.github/instructions/
mysql -u root -p homelab < files_tables.sql

# Opción B: Desde MySQL
mysql -u root -p homelab
SOURCE /home/jemg/Documents/GitHub/roepard-labs/thepearlo_vr-website/.github/instructions/files_tables.sql;
```

### Paso 2: Verificar Instalación

```sql
-- 1. Ver tablas creadas
SHOW TABLES LIKE '%file%';
SHOW TABLES LIKE '%folder%';

-- Debe mostrar:
-- +---------------------------+
-- | Tables_in_homelab (%file%)|
-- +---------------------------+
-- | file_access_log           |
-- | files                     |
-- | folders                   |
-- +---------------------------+

-- 2. Ver estructura de files
DESCRIBE files;

-- 3. Ver estructura de folders
DESCRIBE folders;

-- 4. Verificar Foreign Keys
SELECT
    CONSTRAINT_NAME,
    TABLE_NAME,
    REFERENCED_TABLE_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'homelab'
AND TABLE_NAME IN ('files', 'folders', 'file_access_log')
AND REFERENCED_TABLE_NAME IS NOT NULL;

-- Debe mostrar:
-- fk_files_user → users
-- fk_files_folder → folders
-- fk_folders_user → users
-- fk_folders_parent → folders (self-reference)
-- fk_log_file → files
-- fk_log_user → users
```

### Paso 3: Datos de Prueba (Incluidos en el Script)

El script ya crea carpetas de ejemplo:

**Usuario 3 (user@autonoma.edu.co)**:

- Documentos/
- Imágenes/
- Proyectos/
  - HomeLab AR/

**Usuario 1 (admin@autonoma.edu.co)**:

- Sistema/
- Backups/
- Compartidos/

```sql
-- Ver carpetas creadas
SELECT folder_id, user_id, folder_name, folder_path
FROM folders
ORDER BY user_id, folder_id;
```

---

## 📦 Archivos Backend Creados

### 1. Modelos (Solo acceso a datos)

#### `/models/File.php`

```php
✅ create($data)                    - Insertar archivo en BD
✅ findById($fileId)                - Obtener archivo por ID
✅ listByUserAndFolder($userId, $folderId) - Listar archivos de usuario
✅ listAll()                        - Listar TODOS (solo admin)
✅ update($fileId, $data)           - Actualizar metadata
✅ delete($fileId)                  - Eliminar de BD
✅ incrementDownloads($fileId)      - Contador de descargas
✅ getUserStats($userId)            - Estadísticas de almacenamiento
✅ search($userId, $term, $isAdmin) - Buscar archivos
```

#### `/models/Folder.php`

```php
✅ create($data)                    - Crear carpeta
✅ findById($folderId)              - Obtener carpeta por ID
✅ listByUser($userId, $parentId)   - Listar carpetas de usuario
✅ listAll()                        - Listar TODAS (solo admin)
✅ update($folderId, $data)         - Actualizar carpeta
✅ delete($folderId)                - Eliminar carpeta
✅ countFiles($folderId)            - Contar archivos en carpeta
✅ getFullPath($folderId)           - Obtener ruta completa (breadcrumb)
```

### 2. Servicios (Lógica de negocio)

#### `/services/StorageService.php`

```php
✅ validateUpload($file)            - Validar archivo subido
✅ saveFile($file, $userId)         - Guardar físicamente en storage/
✅ deleteFile($filePath)            - Eliminar archivo físico
✅ getFullPath($filePath)           - Obtener ruta completa
✅ fileExists($filePath)            - Verificar si existe
✅ getFileTypeCategory($ext)        - Categorizar por extensión
✅ formatFileSize($bytes)           - Formatear tamaño (MB, GB)
✅ createUserDirectory($userId)     - Crear carpeta de usuario
```

#### `/services/FileService.php`

```php
✅ uploadFile($file, $userId, ...)  - Subir archivo completo
✅ getUserFiles($userId, $folderId, $isAdmin) - Obtener archivos
✅ getFileDetails($fileId, $userId, $isAdmin) - Detalles de archivo
✅ updateFile($fileId, $userId, $data, $isAdmin) - Actualizar
✅ deleteFile($fileId, $userId, $isAdmin) - Eliminar (BD + físico)
✅ prepareDownload($fileId, ...)    - Preparar descarga
✅ getUserStats($userId)            - Estadísticas
✅ searchFiles($userId, $term, ...)  - Buscar
```

### 3. Controlador (Coordinación HTTP)

#### `/controllers/FileController.php`

```php
✅ upload()      - POST: Subir archivo
✅ listFiles()   - GET: Listar archivos
✅ getFile()     - GET: Detalles de archivo
✅ update()      - PUT: Actualizar metadata
✅ delete()      - DELETE: Eliminar archivo
✅ download()    - GET: Descargar archivo
✅ getStats()    - GET: Estadísticas
✅ search()      - GET: Buscar archivos
```

### 4. Rutas API

```
/routes/files/
├── upload_file.php     ✅ POST   - Subir archivo
├── list_files.php      ✅ GET    - Listar archivos (?folder_id=X)
├── get_file.php        ✅ GET    - Detalles (?file_id=X)
├── update_file.php     ✅ PUT    - Actualizar metadata
├── delete_file.php     ✅ DELETE - Eliminar (?file_id=X)
├── download_file.php   ✅ GET    - Descargar (?file_id=X)
├── get_stats.php       ✅ GET    - Estadísticas de usuario
└── search_files.php    ✅ GET    - Buscar (?q=termino)
```

---

## 🔧 Configuración del Servidor

### Paso 1: Crear Estructura de Storage

```bash
# Ir al backend
cd /home/jemg/Documents/GitHub/roepard-labs/thepearlo_vr-backend/storage/app

# Crear directorios
mkdir -p private/user_1 private/user_2 private/user_3 private/user_4
mkdir -p public

# Permisos correctos
chmod 755 private
chmod 755 public
chmod 775 private/user_1
chmod 775 private/user_2
chmod 775 private/user_3
chmod 775 private/user_4

# Verificar
ls -la private/
# Debe mostrar: drwxrwxr-x para cada user_X
```

### Paso 2: Configurar Límites PHP

```bash
# Editar php.ini
sudo nano /etc/php/8.4/fpm/php.ini

# Cambiar estas líneas:
upload_max_filesize = 50M
post_max_size = 52M
memory_limit = 256M
max_execution_time = 300
max_input_time = 300

# Guardar y reiniciar
sudo systemctl restart php8.4-fpm
```

### Paso 3: Configurar Nginx (opcional)

```bash
# Editar nginx.conf del backend
sudo nano /home/jemg/Documents/GitHub/roepard-labs/thepearlo_vr-backend/nginx.conf

# Agregar dentro de server block:
client_max_body_size 50M;
client_body_timeout 300s;
send_timeout 300s;

# Reiniciar
sudo systemctl restart nginx
```

---

## 🔌 Integración con Frontend

El frontend ya está listo en `/pages/files.page.php`, solo necesita conectar con el backend real.

### Cambios Necesarios en files.page.php

#### 1. Reemplazar loadFiles() - Línea ~595

```javascript
// ❌ ANTES (demo data)
loadDemoFiles(isAdmin ? "admin" : "user");

// ✅ DESPUÉS (API real)
async function loadFiles(folderId = "root") {
  currentFolder = folderId;
  console.log("📂 Cargando archivos de carpeta:", folderId);

  try {
    const response = await window.AppRouter.get(
      "/routes/files/list_files.php",
      {
        params: {
          folder_id: folderId === "root" ? null : folderId,
        },
      }
    );

    if (response.status === "success") {
      allFilesData = response.files;
      filterFilesByFolder(currentFolder);
      updateBreadcrumb();
      updateStats();
    } else {
      notyf.error(response.message || "Error al cargar archivos");
    }
  } catch (error) {
    console.error("❌ Error al cargar archivos:", error);
    notyf.error("Error de conexión con el servidor");
  }
}
```

#### 2. Implementar uploadFile() Real - Línea ~1321

```javascript
window.uploadFile = async function () {
  const fileInput = document.getElementById("fileInput");
  const files = fileInput.files;

  if (files.length === 0) {
    notyf.error("Por favor selecciona un archivo");
    return;
  }

  const formData = new FormData();
  formData.append("file", files[0]);
  formData.append(
    "folder_id",
    document.getElementById("uploadFolder").value || null
  );
  formData.append(
    "description",
    document.getElementById("fileDescription").value
  );

  // Mostrar progreso
  document.getElementById("uploadProgressDiv").classList.remove("d-none");
  const progressBar = document.getElementById("uploadProgress");

  try {
    const response = await window.AppRouter.upload(
      "/routes/files/upload_file.php",
      formData,
      {
        onUploadProgress: (percent) => {
          progressBar.style.width = percent + "%";
          progressBar.textContent = percent + "%";
        },
      }
    );

    if (response.status === "success") {
      notyf.success("✅ Archivo subido exitosamente");

      // Cerrar modal
      const modal = bootstrap.Modal.getInstance(
        document.getElementById("uploadFileModal")
      );
      modal.hide();

      // Recargar
      await loadFiles(currentFolder);
      await loadStats(); // Actualizar estadísticas

      // Reset
      fileInput.value = "";
      document.getElementById("fileDescription").value = "";
    } else {
      notyf.error(response.message || "Error al subir archivo");
    }
  } catch (error) {
    console.error("❌ Error:", error);
    notyf.error("Error de conexión con el servidor");
  } finally {
    document.getElementById("uploadProgressDiv").classList.add("d-none");
    progressBar.style.width = "0%";
  }
};
```

#### 3. Implementar deleteFile() Real - Línea ~1484

```javascript
window.deleteFile = async function (fileId) {
  const result = await Swal.fire({
    title: "¿Estás seguro?",
    text: "Esta acción no se puede deshacer",
    icon: "warning",
    showCancelButton: true,
    confirmButtonText: "Sí, eliminar",
    cancelButtonText: "Cancelar",
    confirmButtonColor: "#dc3545",
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
      notyf.success("✅ Archivo eliminado");
      await loadFiles(currentFolder);
      await loadStats();
    } else {
      notyf.error(response.message || "Error al eliminar archivo");
    }
  } catch (error) {
    console.error("❌ Error:", error);
    notyf.error("Error de conexión");
  }
};
```

#### 4. Implementar downloadFile() Real - Línea ~1535

```javascript
window.downloadFile = function (fileId) {
  const downloadUrl = `${window.ENV_CONFIG.API_URL}/routes/files/download_file.php?file_id=${fileId}`;
  window.open(downloadUrl, "_blank");
  notyf.success("📥 Descargando archivo...");
};
```

#### 5. Cargar Estadísticas Reales - Nueva Función

```javascript
// Agregar después de loadFiles()
async function loadStats() {
  try {
    const response = await window.AppRouter.get("/routes/files/get_stats.php");

    if (response.status === "success") {
      const stats = response.stats;

      // Actualizar UI
      document.getElementById("totalFiles").textContent = stats.total_files;
      document.getElementById("totalFolders").textContent =
        stats.total_folders || 0;
      document.getElementById("usedStorage").textContent =
        stats.total_size_formatted;
      document.getElementById("storageProgress").style.width =
        stats.usage_percent + "%";

      if (isAdmin && stats.shared_files) {
        document.getElementById("sharedFilesCount").textContent =
          stats.shared_files;
        document.getElementById("sharedFilesCard").classList.remove("d-none");
      }
    }
  } catch (error) {
    console.error("❌ Error al cargar estadísticas:", error);
  }
}

// Llamar en DOMContentLoaded después de checkUserRole()
document.addEventListener("DOMContentLoaded", async function () {
  await checkUserRole();
  await loadStats(); // ← AGREGAR
});
```

---

## 🧪 Testing y Verificación

### Test 1: Backend está corriendo

```bash
# Terminal 1: Iniciar backend
cd /home/jemg/Documents/GitHub/roepard-labs/thepearlo_vr-backend
php -S localhost:3000

# Terminal 2: Verificar
curl -I http://localhost:3000/routes/web/status.php
# Debe retornar: HTTP/1.1 200 OK
```

### Test 2: Subir archivo con cURL

```bash
# Crear archivo de prueba
echo "Contenido de prueba" > test.txt

# Login primero para obtener session
curl -X POST http://localhost:3000/routes/user/auth_user.php \
  -H "Content-Type: application/json" \
  -d '{"username":"user@autonoma.edu.co","password":"user123"}' \
  -c cookies.txt

# Subir archivo
curl -X POST http://localhost:3000/routes/files/upload_file.php \
  -F "file=@test.txt" \
  -F "description=Archivo de prueba desde cURL" \
  -b cookies.txt

# Debe retornar:
# {"status":"success","message":"Archivo subido exitosamente","file_id":1,...}
```

### Test 3: Listar archivos

```bash
curl -X GET "http://localhost:3000/routes/files/list_files.php" \
  -b cookies.txt

# Debe retornar:
# {"status":"success","files":[...],"total":1}
```

### Test 4: Verificar estadísticas

```bash
curl -X GET "http://localhost:3000/routes/files/get_stats.php" \
  -b cookies.txt

# Debe retornar:
# {"status":"success","stats":{"total_files":1,"total_size":20,"total_size_formatted":"20 bytes",...}}
```

### Test 5: Verificar archivo físico existe

```bash
ls -la /home/jemg/Documents/GitHub/roepard-labs/thepearlo_vr-backend/storage/app/private/user_3/

# Debe mostrar un archivo como: file_673f7d...1234567890.txt
```

### Test 6: Desde Frontend (con navegador)

1. **Login como usuario**

   - Email: `user@autonoma.edu.co`
   - Password: `user123`

2. **Navegar a Files Manager**

   - URL: `/user` o `/admin` dashboard
   - Click en "Files" en sidebar

3. **Subir archivo**

   - Click "Subir Archivo"
   - Seleccionar imagen o PDF
   - Agregar descripción
   - Upload

4. **Verificar**
   - Debe aparecer en el grid
   - Estadísticas deben actualizarse
   - Descargar archivo funciona
   - Eliminar archivo funciona

### Test 7: Como Admin

1. **Login como admin**

   - Email: `admin@autonoma.edu.co`
   - Password: `admin123`

2. **Verificar permisos**
   - Debe ver archivos de TODOS los usuarios
   - Card "Archivos Compartidos" visible
   - Puede eliminar cualquier archivo

---

## 🔒 Seguridad y Permisos

### Validaciones Implementadas

| Validación           | Dónde            | Descripción                                       |
| -------------------- | ---------------- | ------------------------------------------------- |
| ✅ Autenticación     | `FileController` | Todos los endpoints requieren `Auth::checkAuth()` |
| ✅ Propietario       | `FileService`    | Usuario solo accede a sus archivos                |
| ✅ Admin bypass      | `FileService`    | Admin puede ver/editar todo                       |
| ✅ Extensiones       | `StorageService` | Lista blanca de 40+ extensiones                   |
| ✅ Tamaño            | `StorageService` | Límite de 50 MB por archivo                       |
| ✅ MIME type         | `StorageService` | Verificación con `finfo_file()`                   |
| ✅ Nombres únicos    | `StorageService` | `uniqid() + timestamp`                            |
| ✅ Path traversal    | `StorageService` | Rutas relativas desde `baseStoragePath`           |
| ✅ Permisos carpetas | Sistema          | `chmod 775` en carpetas de usuarios               |

### Extensiones Permitidas

```
Imágenes: jpg, jpeg, png, gif, webp, svg, bmp, ico
Documentos: pdf, doc, docx, xls, xlsx, ppt, pptx, txt, rtf, odt
Comprimidos: zip, rar, 7z, tar, gz
Videos: mp4, avi, mov, wmv, flv, mkv, webm
Audio: mp3, wav, ogg, flac, aac, m4a
Modelos 3D: gltf, glb, obj, fbx, dae, stl, ply (para VR/AR)
Código: js, css, html, php, json, xml, yml, yaml
Otros: csv, sql, md
```

### Estructura de Permisos

```bash
storage/
└── app/
    ├── private/           # 755 (rwxr-xr-x)
    │   ├── user_1/        # 775 (rwxrwxr-x) - Admin
    │   ├── user_2/        # 775 - Mantenedor
    │   ├── user_3/        # 775 - Usuario
    │   └── user_4/        # 775 - Usuario
    └── public/            # 755
        └── shared/        # 775 - Archivos compartidos
```

---

## 🛠️ Troubleshooting

### Error: "No autenticado"

```bash
# Verificar sesión en backend
php -r "session_start(); var_dump($_SESSION);"

# Verificar CORS configurado
curl -I http://localhost:3000/routes/files/list_files.php \
  -H "Origin: http://localhost:9000"

# Debe incluir:
# Access-Control-Allow-Credentials: true
# Access-Control-Allow-Origin: http://localhost:9000
```

### Error: "Archivo no encontrado"

```bash
# Verificar BD
mysql -u root -p homelab -e "SELECT file_id, file_path FROM files WHERE file_id = 1;"

# Verificar archivo físico
ls -la /path/to/backend/storage/app/private/user_X/

# Verificar ruta coincide
```

### Error: "Error al subir archivo"

```bash
# Verificar permisos
ls -ld storage/app/private/user_3/
# Debe: drwxrwxr-x

# Verificar límites PHP
php -r "echo ini_get('upload_max_filesize');"
php -r "echo ini_get('post_max_size');"

# Ver logs
tail -f /var/log/nginx/error.log
tail -f /var/log/php8.4-fpm.log
```

### Limpiar Archivos Huérfanos

```sql
-- Ver archivos sin usuario
SELECT * FROM files WHERE user_id NOT IN (SELECT user_id FROM users);

-- Limpiar (usa procedimiento del script)
CALL sp_cleanup_orphan_files();
```

---

## 📊 Endpoints API Completos

| Método   | URL                               | Parámetros                                    | Respuesta                                       |
| -------- | --------------------------------- | --------------------------------------------- | ----------------------------------------------- |
| `POST`   | `/routes/files/upload_file.php`   | `file` (FormData), `folder_id`, `description` | `{status, message, file_id, file_data}`         |
| `GET`    | `/routes/files/list_files.php`    | `folder_id` (opcional)                        | `{status, files[], total}`                      |
| `GET`    | `/routes/files/get_file.php`      | `file_id`                                     | `{status, file{}}`                              |
| `PUT`    | `/routes/files/update_file.php`   | JSON: `{file_id, file_name, description}`     | `{status, message}`                             |
| `DELETE` | `/routes/files/delete_file.php`   | `file_id`                                     | `{status, message}`                             |
| `GET`    | `/routes/files/download_file.php` | `file_id`                                     | **Binary file download**                        |
| `GET`    | `/routes/files/get_stats.php`     | -                                             | `{status, stats{total_files, total_size, ...}}` |
| `GET`    | `/routes/files/search_files.php`  | `q` (término búsqueda)                        | `{status, files[], total}`                      |

---

## ✅ Checklist de Implementación

### Backend (Completado)

- [x] ✅ Crear tablas en BD (`files_tables.sql`)
- [x] ✅ Crear `File.php` modelo
- [x] ✅ Crear `Folder.php` modelo
- [x] ✅ Crear `StorageService.php`
- [x] ✅ Crear `FileService.php`
- [x] ✅ Crear `FileController.php`
- [x] ✅ Crear 7 rutas API en `/routes/files/`

### Pendiente de Configuración

- [ ] ⏳ Ejecutar `files_tables.sql` en MySQL
- [ ] ⏳ Crear carpetas en `storage/app/private/`
- [ ] ⏳ Configurar permisos (chmod)
- [ ] ⏳ Actualizar `php.ini` con límites

### Frontend (Pendiente de Conexión)

- [ ] ⏳ Reemplazar `loadFiles()` con API real
- [ ] ⏳ Reemplazar `uploadFile()` con API real
- [ ] ⏳ Reemplazar `deleteFile()` con API real
- [ ] ⏳ Implementar `loadStats()` con API real
- [ ] ⏳ Probar upload de archivos
- [ ] ⏳ Probar download de archivos
- [ ] ⏳ Probar eliminación
- [ ] ⏳ Verificar permisos usuario vs admin

---

## 📚 Archivos de Referencia

| Archivo         | Ubicación                                | Descripción             |
| --------------- | ---------------------------------------- | ----------------------- |
| SQL Script      | `.github/instructions/files_tables.sql`  | Crear tablas en BD      |
| File Model      | `backend/models/File.php`                | Acceso a datos archivos |
| Folder Model    | `backend/models/Folder.php`              | Acceso a datos carpetas |
| Storage Service | `backend/services/StorageService.php`    | Manejo filesystem       |
| File Service    | `backend/services/FileService.php`       | Lógica de negocio       |
| File Controller | `backend/controllers/FileController.php` | Coordinación HTTP       |
| API Routes      | `backend/routes/files/*.php`             | 7 endpoints REST        |
| Frontend        | `website/pages/files.page.php`           | Interfaz usuario        |

---

## 📞 Soporte

Si encuentras errores durante la implementación:

1. **Verificar logs**:

   ```bash
   tail -f /var/log/nginx/error.log
   tail -f /var/log/php8.4-fpm.log
   ```

2. **Verificar BD**:

   ```sql
   SELECT * FROM files;
   SELECT * FROM folders;
   ```

3. **Verificar permisos**:

   ```bash
   ls -la storage/app/private/
   ```

4. **Verificar sesión**:
   ```bash
   curl -X GET http://localhost:3000/routes/user/check_session.php -b cookies.txt
   ```

---

**Fecha de Creación**: Noviembre 4, 2025  
**Versión**: 2.0 - Backend MVC Completo  
**Autor**: GitHub Copilot + Roepard Labs  
**Basado en**: Arquitectura MVC existente de HomeLab AR
