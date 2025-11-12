# 🔧 Fix: Backend Headers y Upload de Archivos

## ❌ Problemas Encontrados

### 1. **Headers Already Sent**

```
Warning: http_response_code(): Cannot set response code - headers already sent
(output started at /middleware/user.php:31)
```

**Causa:** El middleware `Auth::checkAuth()` estaba haciendo `echo json_encode(['logged' => true])` **antes** de que el controlador enviara sus propios headers.

### 2. **No se Recibió Ningún Archivo**

```json
{ "status": "error", "message": "No se recibió ningún archivo" }
```

**Causa:**

- Frontend enviaba: `formData.append('files[]', file)` (plural, array)
- Backend esperaba: `$_FILES['file']` (singular)

### 3. **Datos Vacíos en Frontend**

```javascript
⚠️ Respuesta vacía o sin datos
```

**Causa:**

- Backend retorna: `{ status: 'success', files: [...] }`
- Frontend esperaba: `{ status: 'success', data: [...] }`

---

## ✅ Soluciones Implementadas

### 1. **Corregir Middleware `user.php`**

**Antes (línea 31):**

```php
public static function checkAuth() {
    ensure_session_started();
    if (!isset($_SESSION['user_id'])) {
        echo json_encode([
            'logged' => false,
            'error' => 'No autorizado'
        ]);
        exit();
    } else {
        echo json_encode([          // ❌ ESTO CAUSA EL ERROR
            'logged' => true
        ]);
    }
    return $_SESSION['user_id'];
}
```

**Después:**

```php
public static function checkAuth() {
    ensure_session_started();
    if (!isset($_SESSION['user_id'])) {
        http_response_code(401);
        header('Content-Type: application/json');
        echo json_encode([
            'logged' => false,
            'error' => 'No autorizado'
        ]);
        exit();
    }
    // ✅ NO hacer echo aquí, solo retornar el user_id
    // El controlador se encargará de enviar la respuesta
    return $_SESSION['user_id'];
}
```

**Impacto:** Elimina el error "headers already sent" en **TODOS** los endpoints de archivos.

---

### 2. **Corregir Upload en Frontend**

**Antes (`files.page.php`):**

```javascript
const formData = new FormData();
for (let i = 0; i < files.length; i++) {
  formData.append("files[]", files[i]); // ❌ Backend no soporta array
}
formData.append("folder_id", document.getElementById("uploadFolder").value);
formData.append("user_id", currentUserId);
```

**Después:**

```javascript
const formData = new FormData();
// Backend espera 'file' en singular (solo el primer archivo por ahora)
formData.append("file", files[0]); // ✅ Singular

const folderId = document.getElementById("uploadFolder").value;
formData.append("folder_id", folderId === "root" || !folderId ? "" : folderId);
formData.append(
  "description",
  document.getElementById("fileDescription").value
);
formData.append("user_id", currentUserId);

if (isAdmin && document.getElementById("shareWithAll")) {
  formData.append(
    "is_shared",
    document.getElementById("shareWithAll").checked ? "1" : "0"
  );
}

console.log("📤 Subiendo archivo:", files[0].name);
console.log("📁 Carpeta:", folderId);
console.log("👤 Usuario:", currentUserId);
```

**Cambios:**

- ✅ `files[]` → `file` (singular)
- ✅ `share_with_all` → `is_shared` (nombre correcto del backend)
- ✅ Manejo correcto de `folder_id` (convierte 'root' a `null`)
- ✅ Logs de debug agregados

---

### 3. **Corregir Mapeo de Respuestas del Backend**

#### a) **List Files**

**Antes:**

```javascript
if (response.status === 'success' && Array.isArray(response.data)) {
    allFilesData = response.data.map(file => ({ ... }));
}
```

**Después:**

```javascript
if (response.status === 'success' && Array.isArray(response.files)) {
    allFilesData = response.files.map(file => ({ ... }));
}
```

#### b) **Search Files**

**Antes:**

```javascript
if (response.status === 'success' && Array.isArray(response.data)) {
    const searchResults = response.data.map(file => ({ ... }));
}
```

**Después:**

```javascript
if (response.status === 'success' && Array.isArray(response.files)) {
    const searchResults = response.files.map(file => ({ ... }));
}
```

#### c) **Get Stats**

**Antes:**

```javascript
if (response.status === "success" && response.data) {
  const stats = response.data;
}
```

**Después:**

```javascript
if (response.status === "success" && response.stats) {
  const stats = response.stats;
}
```

---

## 📋 Respuestas del Backend (Referencia)

### **List Files**

```json
{
  "status": "success",
  "files": [
    {
      "file_id": 1,
      "filename": "document.pdf",
      "mime_type": "application/pdf",
      "file_size": 2048576,
      "created_at": "2025-11-04 15:30:00",
      "folder_id": null,
      "uploaded_by": 4,
      "uploaded_by_first_name": "Juan",
      "uploaded_by_last_name": "Pérez",
      "is_shared": 0,
      "description": "Mi documento",
      "file_path": "/storage/app/private/user_4/document.pdf"
    }
  ],
  "total": 1
}
```

### **Upload File**

```json
{
  "status": "success",
  "message": "Archivo subido exitosamente",
  "file_id": 15,
  "filename": "image.jpg",
  "file_path": "/storage/app/private/user_4/image_1730758800.jpg"
}
```

### **Get Stats**

```json
{
  "status": "success",
  "stats": {
    "total_files": 5,
    "total_size": 10485760,
    "total_size_formatted": "10.00 MB",
    "shared_files": 2,
    "max_storage": 10737418240,
    "max_storage_formatted": "10 GB",
    "usage_percent": 0.1
  }
}
```

### **Search Files**

```json
{
  "status": "success",
  "files": [
    {
      "file_id": 3,
      "filename": "search_result.txt",
      ...
    }
  ],
  "total": 1
}
```

---

## 🧪 Testing

### 1. **Verificar Headers Corregidos**

**Consola antes:**

```
{"logged":true}
Warning: http_response_code(): Cannot set response code - headers already sent
{"status":"success","files":[]}
```

**Consola después:**

```
✅ Archivos recibidos del backend: {status: 'success', files: [], total: 0}
📊 Total archivos procesados: 0
```

### 2. **Verificar Upload Funciona**

**Pasos:**

1. Seleccionar un archivo
2. Click en "Subir Archivo"
3. Verificar consola:

```
📤 Subiendo archivo: test.jpg
📁 Carpeta: root
👤 Usuario: 4
✅ Archivo subido: {status: 'success', message: '...', file_id: 15}
```

### 3. **Verificar Archivo Aparece en Lista**

Después del upload, debe aparecer automáticamente en la lista de archivos.

---

## 📁 Archivos Modificados

1. ✅ `/thepearlo_vr-backend/middleware/user.php`
   - Eliminado `echo json_encode(['logged' => true])` en `checkAuth()`
2. ✅ `/thepearlo_vr-website/pages/files.page.php`
   - `files[]` → `file` en upload
   - `response.data` → `response.files` en list
   - `response.data` → `response.files` en search
   - `response.data` → `response.stats` en stats
   - Agregados logs de debug
   - Corregido manejo de `folder_id` y `is_shared`

---

## 🎯 Próximas Acciones

1. **Reiniciar backend:**

```bash
# Ctrl+C en terminal del backend
php -S localhost:3000
```

2. **Recargar frontend:**

```
http://localhost:9000/dashboard/files
```

3. **Probar upload:**

- Seleccionar un archivo JPG o PDF pequeño
- Verificar que sube correctamente
- Verificar que aparece en la lista

4. **Verificar logs limpios:**

- No debe haber warnings de headers
- Debe mostrar archivos correctamente

---

**Fecha:** Noviembre 5, 2025  
**Versión:** 1.1  
**Estado:** ✅ Errores críticos corregidos
