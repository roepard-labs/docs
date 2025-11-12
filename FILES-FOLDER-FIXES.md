# 🐛 Correcciones: Gestión de Archivos en Carpetas

**Fecha**: Noviembre 4, 2025  
**Sistema**: Files Manager - HomeLab AR

---

## 📋 Problemas Reportados

### 1. ❌ Error al subir archivos a carpetas

**Síntoma**: Error 400 "No se recibió ningún archivo" al subir a carpeta específica  
**Causa**: FormData no se enviaba correctamente o backend no lo recibía

### 2. ❌ Archivos no se muestran dentro de carpetas

**Síntoma**: Al navegar a una carpeta, no se muestran los archivos contenidos  
**Causa**: Filtrado incorrecto de archivos por `folderId`

### 3. ❌ Carpetas aparecen como descargables

**Síntoma**: Botón de descarga aparece en carpetas (debería ser solo para archivos)  
**Causa**: Lógica de renderizado no diferenciaba tipos

### 4. ❌ Columna "Seleccionar" innecesaria en tabla

**Síntoma**: Checkbox de selección múltiple sin funcionalidad  
**Causa**: Columna legacy sin implementación

---

## ✅ Correcciones Implementadas

### Frontend (`/pages/files.page.php`)

#### 1. Eliminada Columna de Selección en Tabla

**Archivo**: `files.page.php` líneas 220-240

**Antes**:

```html
<thead>
  <tr>
    <th width="5%">
      <input type="checkbox" class="form-check-input" id="selectAllFiles" />
    </th>
    <th width="40%">Nombre</th>
    ...
  </tr>
</thead>
```

**Después**:

```html
<thead>
  <tr>
    <th width="45%">Nombre</th>
    <th width="15%">Tamaño</th>
    <th width="15%">Tipo</th>
    <th width="15%">Fecha</th>
    <th width="10%" class="text-end">Acciones</th>
  </tr>
</thead>
```

**Cambios**:

- ✅ Eliminado `<th>` con checkbox de selección
- ✅ Ajustado ancho de columna "Nombre" de 40% a 45%
- ✅ Eliminada celda `<td>` con checkbox en `renderListView()`

#### 2. Carpetas NO Descargables

**Archivo**: `files.page.php` líneas 1310-1370

**Vista Grid** (líneas 1250-1310):

```javascript
if (file.type === 'folder') {
    // Solo botones: Abrir y Eliminar
    <button onclick="navigateToFolder()" title="Abrir">
        <i class="bx bx-folder-open"></i>
    </button>
    <button onclick="deleteFile()" title="Eliminar">
        <i class="bx bx-trash"></i>
    </button>
} else {
    // Archivos: Preview, Editar, Descargar, Eliminar
    <button onclick="previewFile()">...</button>
    <button onclick="editFile()">...</button>
    <button onclick="downloadFile()">...</button>
    <button onclick="deleteFile()">...</button>
}
```

**Vista Lista**:

```javascript
${file.type === 'folder' ? `
    <button onclick="navigateToFolder()" title="Abrir carpeta">
        <i class="bx bx-folder-open"></i>
    </button>
    <button onclick="editFile()" title="Editar">
        <i class="bx bx-edit"></i>
    </button>
    <button onclick="deleteFile()" title="Eliminar">
        <i class="bx bx-trash"></i>
    </button>
` : `
    <!-- Botones completos para archivos -->
`}
```

**Resultado**:

- ✅ Carpetas solo muestran: Abrir, Editar, Eliminar
- ✅ Archivos muestran: Preview, Editar, Descargar, Eliminar
- ✅ Sin botón de descarga para carpetas

#### 3. Debug de Upload

**Archivo**: `files.page.php` líneas 1573-1650

**Agregado**:

```javascript
console.log("📦 FormData contenido:");
for (let [key, value] of formData.entries()) {
  if (key === "file") {
    console.log(`  ${key}:`, value.name, `(${value.size} bytes)`);
  } else {
    console.log(`  ${key}:`, value);
  }
}
```

**Propósito**: Verificar que FormData incluye el archivo antes de enviar

### Backend (`/controllers/FileController.php`)

#### 4. Debug de Upload en Controller

**Archivo**: `FileController.php` líneas 40-75

**Agregado**:

```php
// DEBUG: Ver qué se recibió
error_log('📦 Upload Debug - $_FILES: ' . print_r($_FILES, true));
error_log('📦 Upload Debug - $_POST: ' . print_r($_POST, true));

// Validar que se recibió archivo
if (!isset($_FILES['file']) || empty($_FILES['file']['tmp_name'])) {
    $this->sendResponse([
        'status' => 'error',
        'message' => 'No se recibió ningún archivo',
        'debug' => [
            'files_isset' => isset($_FILES['file']),
            'files_keys' => array_keys($_FILES),
            'post_keys' => array_keys($_POST)
        ]
    ], 400);
    return;
}
```

**Propósito**:

- Registrar en logs qué recibe el backend
- Respuesta debug si falla para identificar problema

---

## 🔍 Diagnóstico del Problema de Upload

### Flujo Esperado

```
Frontend:
1. Usuario selecciona archivo en modal
2. Usuario selecciona carpeta destino (ej: ID 10)
3. Click "Subir Archivo"
   ↓
4. Crear FormData:
   - file: [File object]
   - folder_id: 10
   - description: "..."
   - user_id: 4
   ↓
5. AppRouter.upload() envía FormData
   ↓

Backend:
6. PHP recibe $_FILES['file'] y $_POST['folder_id']
7. FileController::upload() valida archivo
8. FileService::uploadFile() guarda físicamente
9. File::create() registra en BD con folder_id = 10
10. Respuesta 200 OK
    ↓

Frontend:
11. Cierra modal
12. loadFilesFromBackend(currentFolder)
13. Muestra archivo en carpeta actual
```

### Problema Actual

**Error**: `400 Bad Request - No se recibió ningún archivo`

**Posibles Causas**:

1. **FormData pierde archivo al agregar folder_id**:

   - Verificar orden de `.append()`
   - Verificar que `files[0]` existe

2. **Backend no recibe multipart/form-data**:

   - Verificar headers CORS
   - Verificar PHP `upload_max_filesize`

3. **Axios no envía correctamente FormData**:
   - Verificar `Content-Type: multipart/form-data`
   - Verificar que no se serializa a JSON

### Pasos de Debugging

**1. Console del navegador**:

```javascript
// Después de subir, ver:
📦 FormData contenido:
  file: DSC00078.JPG (3145728 bytes)
  folder_id: 10
  description: Mi archivo
  user_id: 4
```

**2. Network tab**:

- Request Headers debe tener: `Content-Type: multipart/form-data; boundary=...`
- Form Data debe mostrar archivo y campos

**3. Logs del backend** (`/var/log/php_errors.log`):

```
📦 Upload Debug - $_FILES: Array
(
    [file] => Array
    (
        [name] => DSC00078.JPG
        [type] => image/jpeg
        [tmp_name] => /tmp/phpXXXXXX
        [error] => 0
        [size] => 3145728
    )
)
📦 Upload Debug - $_POST: Array
(
    [folder_id] => 10
    [description] => Mi archivo
    [user_id] => 4
)
```

**4. Si `$_FILES` está vacío**:

- Verificar `php.ini`:
  ```ini
  upload_max_filesize = 50M
  post_max_size = 50M
  max_file_uploads = 20
  ```
- Reiniciar PHP-FPM: `sudo systemctl restart php8.4-fpm`

---

## 📊 Estado de Funcionalidades

| Característica             | Estado  | Descripción                  |
| -------------------------- | ------- | ---------------------------- |
| ✅ Crear carpetas          | OK      | Funciona correctamente       |
| ✅ Eliminar carpetas       | OK      | Con validación de permisos   |
| ✅ Navegar a carpetas      | OK      | Breadcrumb dinámico          |
| ✅ Carpetas sin descarga   | OK      | Botón solo en archivos       |
| ✅ Tabla sin checkbox      | OK      | Columna eliminada            |
| ✅ Selectores de carpetas  | OK      | En modals de upload/edit     |
| 🔧 Subir a carpeta         | DEBUG   | Error 400 bajo investigación |
| 🔧 Ver archivos en carpeta | TESTING | Depende de upload            |

---

## 🎯 Próximos Pasos

### Inmediato

1. **Verificar logs del backend**:

   ```bash
   tail -f /var/log/php_errors.log
   ```

2. **Probar upload a carpeta**:

   - Abrir console (F12)
   - Navegar a carpeta
   - Subir archivo
   - Ver debug en console y Network tab

3. **Si falla**:
   - Copiar error completo de console
   - Copiar respuesta del backend
   - Verificar `$_FILES` en logs

### Corto Plazo

1. **Implementar mover archivos entre carpetas**:

   - Modal edit debe permitir cambiar `folder_id`
   - Backend `update_file.php` ya soporta cambio

2. **Carpetas anidadas**:

   - Crear subcarpeta dentro de otra
   - Breadcrumb muestra ruta completa

3. **Eliminar carpetas con contenido**:
   - Implementar eliminación recursiva
   - O validar que carpeta esté vacía

---

## 📝 Notas Técnicas

### Estructura de Datos

**Archivo en BD**:

```sql
files {
    file_id: INT PRIMARY KEY
    user_id: INT
    folder_id: INT NULL  -- NULL = raíz, INT = dentro de carpeta
    file_name: VARCHAR
    original_name: VARCHAR
    file_path: VARCHAR
    file_size: BIGINT
    file_type: VARCHAR (MIME)
    file_extension: VARCHAR
    description: TEXT
    is_shared: TINYINT
    created_at: TIMESTAMP
}
```

**Carpeta en BD**:

```sql
folders {
    folder_id: INT PRIMARY KEY
    user_id: INT
    parent_folder_id: INT NULL  -- NULL = raíz, INT = subcarpeta
    folder_name: VARCHAR
    description: TEXT
    created_at: TIMESTAMP
}
```

### Mapeo Frontend

```javascript
// Archivo mapeado
{
    id: file_id,
    name: original_name,
    type: 'image|document|video|audio|...',
    folderId: folder_id || 'root',  // Carpeta que contiene el archivo
    size: formatFileSize(file_size),
    date: created_at,
    owner: first_name + last_name,
    ownerId: user_id
}

// Carpeta mapeada
{
    id: folder_id,
    name: folder_name,
    type: 'folder',
    folderId: parent_folder_id || 'root',  // Carpeta padre
    size: '-',
    date: created_at,
    owner: first_name + last_name,
    ownerId: user_id
}
```

### Filtrado de Archivos

```javascript
// currentFolder = 10 (navegaste a carpeta con ID 10)
// allFilesData contiene TODOS los archivos del sistema

// Filtrar solo archivos/carpetas DENTRO de carpeta 10
filesData = allFilesData.filter((file) => file.folderId == 10);

// Resultado: archivos con folder_id = 10 en BD
// + carpetas con parent_folder_id = 10 en BD
```

---

## 🔗 Referencias

- **[ARQUITECTURA-FUNCIONAL.md](./ARQUITECTURA-FUNCIONAL.md)** - Arquitectura general
- **[FILES-MANAGER-IMPLEMENTATION.md](./FILES-MANAGER-IMPLEMENTATION.md)** - Implementación inicial
- **[FILES-TESTING-GUIDE.md](./FILES-TESTING-GUIDE.md)** - Guía de testing

---

**Última actualización**: 2025-11-04  
**Autor**: Roepard Labs Development Team  
**Estado**: Debug en progreso
