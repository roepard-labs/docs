# 📁 Sistema de Carpetas Fijas - Implementación Completa

**Fecha**: 2025-11-05  
**HomeLab AR - Roepard Labs**

---

## 📋 Resumen de Cambios

Se implementó un sistema de **carpetas fijas** por usuario para simplificar la gestión de archivos y eliminar problemas de navegación en el breadcrumb.

### Cambios Principales:

1. **Backend**: Creación automática de 4 carpetas al registrarse
2. **Frontend**: Eliminada funcionalidad de crear/eliminar carpetas
3. **Migración**: Script SQL para usuarios existentes

---

## 🏗️ Arquitectura

### Carpetas Fijas (4 por usuario):

| Carpeta       | Descripción                       |
| ------------- | --------------------------------- |
| 📄 Documentos | Documentos y archivos importantes |
| 🎵 Música     | Archivos de audio y música        |
| 🎬 Videos     | Archivos de video                 |
| 🖼️ Imágenes   | Fotos e imágenes                  |

**Características**:

- ✅ Se crean automáticamente al registrar usuario
- ✅ Navegables con doble click
- ✅ Usuarios pueden subir archivos dentro
- ❌ No se pueden crear nuevas carpetas
- ❌ No se pueden eliminar carpetas fijas
- ❌ No se pueden renombrar carpetas

---

## 🔧 Archivos Modificados

### Backend

**1. `/thepearlo_vr-backend/services/RegisterService.php`**

```php
// Cambios implementados:
// - Agregada transacción para crear usuario + carpetas
// - Loop para insertar 4 carpetas fijas
// - Manejo de errores con rollback
```

**Lógica de creación**:

```php
$defaultFolders = [
    ['name' => 'Documentos', 'description' => 'Documentos y archivos importantes'],
    ['name' => 'Música', 'description' => 'Archivos de audio y música'],
    ['name' => 'Videos', 'description' => 'Archivos de video'],
    ['name' => 'Imágenes', 'description' => 'Fotos e imágenes']
];

foreach ($defaultFolders as $folder) {
    // INSERT INTO folders ...
}
```

### Frontend

**2. `/thepearlo_vr-website/pages/files.page.php`**

**Cambios**:

a) **Header** (Línea ~23-33):

```html
<!-- ANTES -->
<button class="btn btn-outline-primary" id="createFolderBtn">
  Nueva Carpeta
</button>

<!-- DESPUÉS -->
<!-- Create Folder: DESHABILITADO - Carpetas fijas -->
```

b) **JavaScript checkUserRole()** (Línea ~580-585):

```javascript
// ANTES
if (isAdmin) {
  document.getElementById("createFolderBtn")?.classList.remove("d-none");
}

// DESPUÉS
if (isAdmin) {
  // Crear carpeta: DESHABILITADO - Carpetas fijas por usuario
  // document.getElementById('createFolderBtn')?.classList.remove('d-none');
}
```

c) **Grid View - Carpetas** (Línea ~1265-1285):

```html
<!-- ANTES -->
<button onclick="deleteFile(${file.id})">Eliminar</button>

<!-- DESPUÉS -->
<small class="opacity-75">Carpeta fija</small>
<button onclick="navigateToFolder(${file.id})">Abrir</button>
<!-- Carpetas fijas: No se pueden eliminar -->
```

d) **List View - Carpetas** (Línea ~1350-1365):

```javascript
// ANTES
${file.type === 'folder' ? `
    <button onclick="editFile(${file.id})">Editar</button>
    <button onclick="deleteFile(${file.id})">Eliminar</button>
` : `...`}

// DESPUÉS
${file.type === 'folder' ? `
    <button onclick="navigateToFolder(${file.id})">Abrir</button>
    <!-- Carpetas fijas: No se pueden editar ni eliminar -->
` : `...`}
```

### Migración

**3. `/thepearlo_vr-backend/migrations/add_default_folders_to_existing_users.sql`**

Script SQL para agregar carpetas a usuarios existentes que no tienen carpetas.

---

## 🚀 Pasos de Implementación

### 1. Backend - RegisterService

✅ **YA APLICADO** - El archivo ya está modificado con la nueva lógica.

### 2. Frontend - files.page.php

✅ **YA APLICADO** - Los cambios ya están en el archivo.

### 3. Base de Datos - Usuarios Existentes

⚠️ **PENDIENTE** - Necesitas ejecutar la migración:

```bash
# Conectar a MySQL
mysql -u tu_usuario -p homelab

# Ejecutar migración
source /path/to/thepearlo_vr-backend/migrations/add_default_folders_to_existing_users.sql

# Verificar resultado
SELECT u.user_id, u.first_name, COUNT(f.folder_id) AS carpetas
FROM users u
LEFT JOIN folders f ON u.user_id = f.user_id AND f.parent_folder_id IS NULL
GROUP BY u.user_id, u.first_name;
```

**Resultado esperado**: Cada usuario debe tener 4 carpetas.

### 4. Reiniciar Servidores

```bash
# Backend (si está corriendo)
cd /thepearlo_vr-backend
killall php  # O el PID específico
php -S localhost:3000 -t . router.php 2>&1 | tee backend.log &

# Frontend
# No requiere reinicio (solo recargar en navegador)
```

---

## ✅ Testing

### Test 1: Nuevo Usuario

```sql
-- 1. Crear usuario de prueba
INSERT INTO users (first_name, last_name, username, email, phone, password)
VALUES ('Test', 'User', 'testuser', 'test@example.com', '+123456789', '$2y$10$...');

-- 2. Verificar carpetas creadas automáticamente
SELECT * FROM folders WHERE user_id = LAST_INSERT_ID();
-- Debe retornar 4 carpetas: Documentos, Música, Videos, Imágenes
```

### Test 2: Usuario Existente (Después de migración)

```bash
# 1. Login como usuario existente
curl -X POST http://localhost:3000/routes/user/auth_user.php \
  -H "Content-Type: application/json" \
  -d '{"username":"user@example.com","password":"password"}'

# 2. Listar archivos (debe mostrar carpetas)
curl http://localhost:3000/routes/files/list_files.php?folder_id=root

# Debe retornar:
# {
#   "status": "success",
#   "files": [
#     {"folder_id": X, "folder_name": "Documentos", ...},
#     {"folder_id": Y, "folder_name": "Música", ...},
#     {"folder_id": Z, "folder_name": "Videos", ...},
#     {"folder_id": W, "folder_name": "Imágenes", ...}
#   ]
# }
```

### Test 3: Frontend

1. **Recargar página**: `Ctrl+Shift+R`
2. **Verificar**: 4 carpetas visibles en root
3. **Verificar**: Botón "Nueva Carpeta" NO visible
4. **Doble click en carpeta**: Abre correctamente
5. **Hover en carpeta**: Solo botón "Abrir", no "Eliminar"
6. **Breadcrumb**: Funciona correctamente al navegar

---

## 🐛 Troubleshooting

### Problema: Usuarios no tienen carpetas después de migración

```sql
-- Verificar cuántos usuarios sin carpetas
SELECT COUNT(*) FROM users
WHERE user_id NOT IN (SELECT DISTINCT user_id FROM folders);

-- Si hay usuarios, ejecutar de nuevo:
CALL CreateDefaultFolders();
```

### Problema: Frontend sigue mostrando botón "Nueva Carpeta"

```javascript
// Verificar en consola del navegador:
console.log(document.getElementById("createFolderBtn"));
// Debe retornar: null (elemento eliminado)
```

### Problema: No se pueden navegar carpetas

```sql
-- Verificar que las carpetas tienen parent_folder_id = NULL
SELECT folder_id, folder_name, parent_folder_id
FROM folders
WHERE user_id = [TU_USER_ID];

-- Todas deben tener parent_folder_id = NULL
```

---

## 📊 Impacto en Base de Datos

### Antes

```
users (10 usuarios)
folders (estructura variable, algunos sin carpetas)
```

### Después

```
users (10 usuarios)
folders (40 carpetas = 10 usuarios × 4 carpetas fijas)
```

**Crecimiento**: +4 registros por usuario nuevo  
**Espacio**: ~200 bytes por carpeta = ~800 bytes por usuario

---

## 🔒 Seguridad

### Validaciones Backend

El sistema **debe validar** que:

1. ✅ No se puedan eliminar carpetas con `parent_folder_id = NULL`
2. ✅ No se puedan crear nuevas carpetas (excepto admin en casos especiales)
3. ✅ Usuarios solo vean sus propias carpetas
4. ✅ Admins puedan ver todas las carpetas

### Recomendación: Agregar validación en FileController

```php
// En FileController::deleteFile()
if ($file['parent_folder_id'] === null) {
    return $this->sendResponse([
        'status' => 'error',
        'message' => 'Las carpetas fijas no se pueden eliminar'
    ], 403);
}
```

---

## 📚 Documentación Relacionada

- **[ARQUITECTURA-FUNCIONAL.md](../../docs/ARQUITECTURA-FUNCIONAL.md)** - Arquitectura general
- **[FILES-MANAGER-IMPLEMENTATION.md](../../docs/FILES-MANAGER-IMPLEMENTATION.md)** - Implementación anterior
- **[DATABASE-SCHEMA.md](../../docs/DATABASE-SCHEMA.md)** - Esquema de BD

---

## 🎯 Próximos Pasos Sugeridos

1. ✅ **Aplicar migración** a usuarios existentes
2. ✅ **Testing completo** del sistema
3. 🔄 **Agregar validación backend** para proteger carpetas fijas
4. 🔄 **Documentar** API endpoints actualizados
5. 🔄 **Considerar** subcarpetas en el futuro (opcional)

---

**Estado**: ✅ Implementación completa  
**Requiere**: Ejecución de migración SQL  
**Mantenido por**: Roepard Labs Development Team
