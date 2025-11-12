# 🐛 Corrección: Archivos No Aparecen Dentro de Carpetas

**Fecha**: Noviembre 4, 2025  
**Sistema**: Files Manager - Backend  
**Issue**: Admin no ve archivos al navegar dentro de carpetas

---

## 📋 Problema Identificado

### Síntoma

```javascript
// Console del navegador:
📂 Navegando a carpeta: 10
🔍 Filtrando archivos para carpeta: 10
📊 Total de archivos en sistema: 1  // ← Archivo existe en allFilesData
📂 Archivos encontrados: 0           // ← Pero no se muestra
📋 Lista de archivos: []
```

**Flujo del error**:

1. ✅ Usuario sube archivo `3.png` a carpeta ID 10
2. ✅ Backend guarda en BD con `folder_id = 10`
3. ✅ Upload exitoso: `{file_id: 7, folder_id: 10}`
4. ✅ Recarga archivos: `loadFilesFromBackend(10)`
5. ✅ Backend retorna archivo: `{file_id: 7, folder_id: 10}`
6. ❌ **Frontend filtra por folderId pero no encuentra nada**

### Causa Raíz

**Backend** (`FileService::getUserFiles`):

```php
// ❌ CÓDIGO ANTERIOR (líneas 82-91)
if ($isAdmin) {
    $files = $this->fileModel->listAll(); // Lista TODOS los archivos
} else {
    $files = $this->fileModel->listByUserAndFolder($userId, $folderId);
}
```

**Problema**:

- Admin navegando a carpeta 10 → `listAll()` retorna **todos los archivos de la BD**
- Luego filtra por `parent_folder_id` para carpetas, pero **NO filtra archivos por `folder_id`**
- Frontend recibe archivos de todas las carpetas mezclados
- Frontend filtra por `folderId == 10` pero los archivos tienen `folderId: 10` en el mapeo inconsistente

### Logs del Error

**Navegación exitosa a carpeta**:

```javascript
📂 Navegando a carpeta: 10
🔍 Filtrando archivos para carpeta: 10
📊 Total de archivos en sistema: 2  // ← 2 items: carpeta + archivo root
📂 Archivos encontrados: 0           // ← Filtro no encuentra archivos con folderId=10
```

**Upload exitoso**:

```javascript
✅ Archivo subido: {file_id: '7', folder_id: 10}
📂 Cargando archivos desde backend...
📁 Carpeta actual: 10
📥 Response: {files: [{file_id: 7, folder_id: 10}]}  // ← Backend retorna correcto
📊 Total archivos procesados: 1
🔍 Estructura mapeada: {id: 7, folderId: 10}  // ← Mapeo correcto
🔍 Filtrando archivos para carpeta: 10
📂 Archivos encontrados: 1  // ← ✅ Funciona después de recargar
```

**Diferencia**:

- **Antes de recargar**: Backend mezcla archivos de root con archivos de carpeta 10
- **Después de recargar**: Backend solo retorna archivos de carpeta 10

---

## ✅ Solución Implementada

### Backend: `FileService::getUserFiles()` (líneas 82-106)

**Código corregido**:

```php
// CRÍTICO: Admin también debe filtrar por carpeta cuando navega dentro de una
// Solo lista TODO cuando está en root
if ($isAdmin && $folderId === null) {
    // Admin en root: ver todos los archivos del nivel root
    $files = $this->fileModel->listAll();
    // Filtrar solo archivos de nivel root (folder_id IS NULL)
    $files = array_filter($files, function($file) {
        return $file['folder_id'] === null;
    });
} elseif ($isAdmin && $folderId !== null) {
    // Admin navegando dentro de carpeta: ver archivos de esa carpeta
    $files = $this->fileModel->listByFolder($folderId);
} else {
    // Usuario normal: ver solo sus archivos
    $files = $this->fileModel->listByUserAndFolder($userId, $folderId);
}
```

**Cambios clave**:

1. **Admin en root** → `listAll()` + filtro `folder_id IS NULL`
2. **Admin en carpeta** → `listByFolder($folderId)` (nuevo método)
3. **Usuario normal** → Sin cambios (ya funcionaba)

### Backend: Nuevo método `File::listByFolder()` (líneas 142-162)

**Archivo**: `/models/File.php`

```php
/**
 * Listar archivos de una carpeta específica (todos los usuarios, para admin)
 */
public function listByFolder($folderId): mixed
{
    try {
        $sql = "SELECT f.*, u.first_name, u.last_name, u.username
                FROM files f
                LEFT JOIN users u ON f.user_id = u.user_id
                WHERE f.folder_id = :folder_id
                ORDER BY f.created_at DESC";

        $stmt = $this->db->prepare($sql);
        $stmt->bindParam(':folder_id', $folderId, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (PDOException $e) {
        throw new Exception("Error al listar archivos de carpeta: " . $e->getMessage());
    }
}
```

**Propósito**:

- Listar **todos los archivos** (de cualquier usuario) dentro de una carpeta
- Solo para admin navegando dentro de carpetas
- Incluye JOIN con `users` para mostrar información del propietario

---

## 🔍 Flujo Corregido

### Caso 1: Admin en Root

```
GET /routes/files/list_files.php?folder_id=null&user_id=4
    ↓
FileService::getUserFiles(userId: 4, folderId: null, isAdmin: true)
    ↓
listAll() → Todos los archivos
array_filter() → Solo folder_id IS NULL
    ↓
listByUser(4, null) → Carpetas de nivel root
    ↓
Combinar: Archivos root + Carpetas root
    ↓
Response: {files: [carpeta1, carpeta2, archivo1, archivo2]}
```

### Caso 2: Admin Navegando en Carpeta

```
GET /routes/files/list_files.php?folder_id=10&user_id=4
    ↓
FileService::getUserFiles(userId: 4, folderId: 10, isAdmin: true)
    ↓
listByFolder(10) → Archivos con folder_id = 10
    ↓
listByUser(4, 10) → Carpetas con parent_folder_id = 10
    ↓
Combinar: Archivos de carpeta 10 + Subcarpetas
    ↓
Response: {files: [subcarpeta1, archivo_3.png, archivo_4.jpg]}
```

### Caso 3: Usuario Normal

```
GET /routes/files/list_files.php?folder_id=10&user_id=4
    ↓
FileService::getUserFiles(userId: 4, folderId: 10, isAdmin: false)
    ↓
listByUserAndFolder(4, 10) → Archivos del usuario con folder_id = 10
    ↓
listByUser(4, 10) → Carpetas del usuario con parent_folder_id = 10
    ↓
Combinar: Solo archivos/carpetas del usuario
    ↓
Response: {files: [mis_archivos, mis_carpetas]}
```

---

## 📊 Comparación Antes/Después

### Antes (Incorrecto)

**Admin navega a carpeta 10**:

```
Backend retorna:
- Archivo 1 (folder_id: NULL) ← De root
- Archivo 2 (folder_id: NULL) ← De root
- Carpeta 10 (parent_folder_id: NULL)
- Carpeta 11 (parent_folder_id: 10)
- Archivo 7 (folder_id: 10) ← El que buscamos

Frontend filtra folderId == 10:
- ❌ Carpeta 11 (folderId: 10) ✅ Se muestra
- ❌ Archivo 7 (folderId: 10) ✅ Se muestra
Total: 2 items PERO no se renderizaban por bug de mapeo
```

### Después (Correcto)

**Admin navega a carpeta 10**:

```
Backend retorna:
- Archivo 7 (folder_id: 10) ← Solo este
- Carpeta 11 (parent_folder_id: 10) ← Solo esta

Frontend filtra folderId == 10:
- ✅ Carpeta 11 (folderId: 10) ✅ Se muestra
- ✅ Archivo 7 (folderId: 10) ✅ Se muestra
Total: 2 items (correcto)
```

---

## 🧪 Testing

### Escenario 1: Admin sube archivo a carpeta

1. ✅ Navegar a carpeta "Documentos" (ID: 10)
2. ✅ Click "Subir Archivo"
3. ✅ Seleccionar imagen (3.png)
4. ✅ Click "Subir"
5. ✅ Verificar upload exitoso: `{file_id: 7, folder_id: 10}`
6. ✅ **Verificar que aparece en la carpeta inmediatamente**

### Escenario 2: Admin navega entre carpetas

1. ✅ Ver archivos en root
2. ✅ Navegar a carpeta "Documentos"
3. ✅ Ver solo archivos de "Documentos"
4. ✅ Volver a root (breadcrumb)
5. ✅ Ver de nuevo archivos de root

### Escenario 3: Usuario normal

1. ✅ Ver solo sus archivos en root
2. ✅ Navegar a su carpeta
3. ✅ Ver solo sus archivos en esa carpeta
4. ❌ **NO ver archivos de otros usuarios**

### Escenario 4: Carpetas anidadas

1. ✅ Crear carpeta "Contratos" dentro de "Documentos"
2. ✅ Subir archivo a "Contratos"
3. ✅ Navegar: Root → Documentos → Contratos
4. ✅ Verificar breadcrumb: `Root > Documentos > Contratos`
5. ✅ Ver solo archivos de "Contratos"

---

## 📝 Notas Técnicas

### Campos Críticos en BD

**Tabla `files`**:

```sql
file_id INT PRIMARY KEY
user_id INT              -- Propietario del archivo
folder_id INT NULL       -- NULL = root, INT = dentro de carpeta
file_name VARCHAR
```

**Tabla `folders`**:

```sql
folder_id INT PRIMARY KEY
user_id INT              -- Propietario de la carpeta
parent_folder_id INT NULL  -- NULL = root, INT = subcarpeta
folder_name VARCHAR
```

### Mapeo Frontend (no modificado)

```javascript
// Archivo mapeado (líneas 656-677)
{
    id: item.file_id,
    name: item.original_name,
    type: getFileTypeFromMime(item.file_type),
    folderId: item.folder_id || 'root',  // ← Carpeta que contiene el archivo
    // ...
}

// Carpeta mapeada (líneas 638-655)
{
    id: item.id || item.folder_id,
    name: item.name || item.folder_name,
    type: 'folder',
    folderId: item.folderId || 'root',  // ← Carpeta padre
    // ...
}
```

### Filtrado Frontend (no modificado)

```javascript
// filterFilesByFolder() línea 2176
filesData = allFilesData.filter((file) => file.folderId == folderId);
```

**Lógica**:

- `folderId == 'root'` → Archivos/carpetas de nivel raíz
- `folderId == 10` → Archivos dentro de carpeta 10 + Subcarpetas de carpeta 10

---

## 🎯 Resultado Final

### Antes

```javascript
// Navegas a carpeta 10
📂 Archivos encontrados: 0  // ❌ No se muestran archivos
📋 Lista: []
```

### Después

```javascript
// Navegas a carpeta 10
📂 Archivos encontrados: 1  // ✅ Se muestran archivos
📋 Lista: ['3.png (image)']
```

---

## 📊 Archivos Modificados

```
✅ /thepearlo_vr-backend/services/FileService.php
   - Líneas 82-106: Lógica de filtrado por carpeta para admin

✅ /thepearlo_vr-backend/models/File.php
   - Líneas 142-162: Nuevo método listByFolder()
```

---

## 🔗 Referencias

- **[FILES-FOLDER-FIXES.md](./FILES-FOLDER-FIXES.md)** - Correcciones anteriores
- **[FILES-MANAGER-IMPLEMENTATION.md](./FILES-MANAGER-IMPLEMENTATION.md)** - Implementación inicial
- **[ARQUITECTURA-FUNCIONAL.md](./ARQUITECTURA-FUNCIONAL.md)** - Arquitectura general

---

**Estado**: ✅ Corrección implementada y testeada  
**Fecha**: 2025-11-05  
**Autor**: Roepard Labs Development Team
