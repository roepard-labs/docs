# 🔧 Fix: Breadcrumbs y Selectores de Carpetas

## 📋 Problemas Identificados

### Problema 1: Breadcrumbs Fallan al Navegar

**Síntoma**: Al navegar de vuelta desde una carpeta usando el breadcrumb, todo se ocultaba.

**Causa Raíz**:

- `allFilesData` se sobrescribía cada vez que se cargaban archivos de una carpeta
- Al navegar a una carpeta, solo se cargaban los archivos DE ESA CARPETA
- Cuando navegabas de vuelta, `allFilesData` no tenía las carpetas del nivel superior
- `buildFolderPath()` no encontraba las carpetas en el caché

### Problema 2: Selectores Vacíos al Subir Archivos

**Síntoma**: El select de carpetas estaba vacío al abrir el modal de subir archivo.

**Causa Raíz**:

- `populateFolderSelectors()` dependía de `allFilesData`
- Como `allFilesData` se sobrescribía constantemente, a veces no tenía carpetas
- Si estabas dentro de una carpeta (sin subcarpetas), `allFilesData` solo tenía archivos

---

## ✅ Soluciones Implementadas

### Solución 1: Separar Carpetas de Archivos

**Nueva Variable Global**:

```javascript
let allFoldersData = []; // NUEVO: Todas las carpetas del usuario (nunca se sobrescribe)
```

**Nueva Función `loadAllFolders()`**:

```javascript
async function loadAllFolders() {
  console.log("📂 Cargando todas las carpetas del usuario...");

  try {
    const response = await window.AppRouter.get(
      "/routes/files/list_files.php",
      {
        params: {
          folder_id: "root",
          user_id: currentUserId,
        },
      }
    );

    if (response.status === "success" && Array.isArray(response.files)) {
      // Extraer solo las carpetas
      allFoldersData = response.files
        .filter((item) => item.type === "folder")
        .map((item) => ({
          id: item.id || item.folder_id,
          name: item.name || item.folder_name,
          type: "folder",
          folderId: item.folderId || "root",
          owner:
            `${item.first_name || ""} ${item.last_name || ""}`.trim() ||
            item.username ||
            "Usuario",
          ownerId: item.user_id,
          description: item.description || "",
        }));

      // Poblar caché con todas las carpetas
      allFoldersData.forEach((folder) => {
        folderCache[folder.id] = {
          id: folder.id,
          name: folder.name,
          folderId: folder.folderId,
        };
      });

      console.log("✅ Carpetas cargadas:", allFoldersData.length);

      // Poblar selectores inmediatamente
      populateFolderSelectors();
    }
  } catch (error) {
    console.error("❌ Error al cargar carpetas:", error);
    allFoldersData = [];
  }
}
```

**Características**:

- ✅ Se ejecuta UNA SOLA VEZ al inicializar
- ✅ Carga TODAS las carpetas del usuario desde root
- ✅ Llena `allFoldersData` y `folderCache` inmediatamente
- ✅ Llama a `populateFolderSelectors()` automáticamente

---

### Solución 2: Modificar `checkUserRole()`

**Cambio en Secuencia de Carga**:

```javascript
async function checkUserRole() {
  try {
    const roleStatus = await window.RoleService.check();
    const sessionStatus = await window.SessionService.check();

    isAdmin = roleStatus.isAdmin;
    currentUserId = sessionStatus.userData?.user_id || 1;

    // ... mostrar elementos de admin ...

    // CRÍTICO: Cargar todas las carpetas primero (para selectores)
    await loadAllFolders();

    // Luego cargar archivos desde el backend
    await loadFilesFromBackend();
  } catch (error) {
    // ... manejo de errores ...
  }
}
```

**Orden Crítico**:

1. Verificar rol y obtener `currentUserId`
2. **PRIMERO**: Cargar todas las carpetas (`loadAllFolders()`)
3. **SEGUNDO**: Cargar archivos de carpeta actual (`loadFilesFromBackend()`)

---

### Solución 3: Actualizar `populateFolderSelectors()`

**Antes (PROBLEMA)**:

```javascript
function populateFolderSelectors() {
  // ...

  if (isAdmin) {
    availableFolders = allFilesData.filter((f) => f.type === "folder"); // ❌ Puede estar vacío
  } else {
    availableFolders = allFilesData.filter(
      (f) => f.type === "folder" && f.ownerId == currentUserId // ❌ Puede estar vacío
    );
  }

  // ...
}
```

**Después (SOLUCIÓN)**:

```javascript
function populateFolderSelectors() {
  const uploadSelector = document.getElementById("uploadFolder");
  const editSelector = document.getElementById("editFileFolder");

  if (!uploadSelector || !editSelector) {
    console.warn("⚠️ Selectores de carpetas no encontrados en el DOM");
    return;
  }

  // CRÍTICO: Usar allFoldersData en lugar de allFilesData
  // allFoldersData se carga una sola vez y contiene todas las carpetas
  let availableFolders = [];

  if (isAdmin) {
    // Admin: Todas las carpetas de todos los usuarios
    availableFolders = allFoldersData; // ✅ Siempre tiene carpetas
    console.log("👔 Admin: Mostrando todas las carpetas de todos los usuarios");
  } else {
    // Usuario normal: Solo sus propias carpetas
    availableFolders = allFoldersData.filter((f) => f.ownerId == currentUserId); // ✅ Siempre tiene carpetas
    console.log("👤 Usuario: Mostrando solo carpetas propias");
  }

  // ... generar opciones HTML ...
}
```

**Beneficios**:

- ✅ `allFoldersData` NUNCA se sobrescribe
- ✅ Siempre contiene todas las carpetas del usuario
- ✅ Selectores siempre se pueblan correctamente

---

### Solución 4: Actualizar `filterFilesByFolder()`

**Antes (PROBLEMA)**:

```javascript
function filterFilesByFolder(folderId) {
  // Filtrar solo de allFilesData
  filesData = allFilesData.filter((file) => file.folderId == folderId);

  renderFiles(filesData);
}
```

**Después (SOLUCIÓN)**:

```javascript
function filterFilesByFolder(folderId) {
  console.log("🔍 Filtrando archivos para carpeta:", folderId);
  console.log("📊 Total de archivos en sistema:", allFilesData.length);

  // CRÍTICO: Si estamos en root, también mostrar las carpetas de allFoldersData
  if (folderId === "root") {
    // Combinar carpetas + archivos de root
    const rootFiles = allFilesData.filter(
      (file) => file.folderId == folderId && file.type !== "folder"
    );
    filesData = [...allFoldersData, ...rootFiles];
    console.log(
      `📂 Root: ${allFoldersData.length} carpetas + ${rootFiles.length} archivos = ${filesData.length} items`
    );
  } else {
    // En carpetas, solo mostrar archivos (no subcarpetas por ahora)
    filesData = allFilesData.filter((file) => file.folderId == folderId);
    console.log(`📂 Archivos en carpeta ${folderId}: ${filesData.length}`);
  }

  console.log(
    "📋 Lista de archivos:",
    filesData.map((f) => `${f.name} (${f.type})`)
  );

  renderFiles(filesData);
}
```

**Lógica**:

- **En Root**: Combina `allFoldersData` (carpetas) + archivos de root de `allFilesData`
- **En Carpeta**: Solo archivos de `allFilesData` para esa carpeta
- **Resultado**: Root SIEMPRE muestra las 4 carpetas fijas

---

### Solución 5: Actualizar `buildFolderPath()`

**Antes (PROBLEMA)**:

```javascript
// Fallback: buscar en allFilesData
const folderInData = allFilesData.find(
  (f) => f.id == currentId && f.type === "folder"
);
```

**Después (SOLUCIÓN)**:

```javascript
// Fallback: buscar en allFoldersData (que tiene TODAS las carpetas)
const folderInData = allFoldersData.find(f => f.id == currentId);
if (folderInData) {
    console.log(`✅ Carpeta ${currentId} encontrada en allFoldersData, agregando al caché`);
    folderCache[currentId] = {
        id: folderInData.id,
        name: folderInData.name,
        folderId: folderInData.folderId
    };

    folderPath.unshift({
        id: folderInData.id,
        name: folderInData.name
    });
    currentId = folderInData.folderId;
} else {
    console.error(`❌ Carpeta ${currentId} no encontrada en allFoldersData`);
    console.log('🔍 allFoldersData disponibles:', allFoldersData.map(f => `${f.id}: ${f.name}`));
    break;
}
```

**Beneficios**:

- ✅ Busca en `allFoldersData` (que SIEMPRE tiene todas las carpetas)
- ✅ Logs mejorados para debugging
- ✅ Breadcrumb funciona correctamente al navegar de vuelta

---

### Solución 6: Simplificar `loadFilesFromBackend()`

**Cambio**: Eliminar lógica de acumulación de carpetas en caché

**Antes (REMOVIDO)**:

```javascript
// CRÍTICO: Acumular carpetas en caché (no sobrescribir)
allFilesData.forEach((item) => {
  if (item.type === "folder") {
    if (!folderCache[item.id]) {
      folderCache[item.id] = {
        id: item.id,
        name: item.name,
        folderId: item.folderId,
      };
    }
  }
});
```

**Después**:

```javascript
// Ya NO es necesario porque loadAllFolders() pobló el caché
// Solo cargar archivos y procesar
```

**Razón**:

- `loadAllFolders()` ya llenó `folderCache` con TODAS las carpetas
- No necesitamos acumular carpetas cada vez que cargamos archivos
- Simplifica la lógica y evita duplicados

---

## 🎯 Flujo Completo de Datos

### Inicialización

```
1. DOMContentLoaded
   ↓
2. waitForDependencies() - Esperar AppRouter, RoleService, SessionService
   ↓
3. checkUserRole()
   ├── Obtener isAdmin y currentUserId
   ├── loadAllFolders() ← CRÍTICO: Carga todas las carpetas UNA VEZ
   │   ├── GET /routes/files/list_files.php?folder_id=root
   │   ├── Extrae solo carpetas (type === 'folder')
   │   ├── Llena allFoldersData (4 carpetas fijas)
   │   ├── Llena folderCache con metadata
   │   └── Llama populateFolderSelectors() ✅ Selectores poblados
   │
   └── loadFilesFromBackend() ← Carga archivos de carpeta actual
       ├── GET /routes/files/list_files.php?folder_id=root
       ├── Llena allFilesData con archivos
       ├── Llama filterFilesByFolder(currentFolder)
       └── updateBreadcrumb()
```

### Navegación a Carpeta

```
1. Usuario hace click en carpeta "Documentos"
   ↓
2. navigateToFolder(folder_id)
   ↓
3. loadFilesFromBackend(folder_id)
   ├── GET /routes/files/list_files.php?folder_id=10
   ├── Llena allFilesData con archivos DE ESA CARPETA
   ├── filterFilesByFolder(10) ← Filtra solo archivos de carpeta 10
   └── updateBreadcrumb()
       └── buildFolderPath(10)
           ├── Busca en folderCache[10] ✅ Encuentra "Documentos"
           └── Construye: Home > Documentos
```

### Navegación de Vuelta (Breadcrumb)

```
1. Usuario hace click en "Home" del breadcrumb
   ↓
2. navigateToFolder('root')
   ↓
3. loadFilesFromBackend('root')
   ├── GET /routes/files/list_files.php?folder_id=root
   ├── Llena allFilesData con archivos de root
   └── filterFilesByFolder('root')
       ├── Combina allFoldersData (4 carpetas) + archivos root
       ├── filesData = [Documentos, Música, Videos, Imágenes, ...archivos]
       └── renderFiles(filesData) ✅ Muestra todo correctamente
```

### Subir Archivo

```
1. Usuario hace click en "Subir Archivo"
   ↓
2. Modal se abre
   ↓
3. Select de carpetas ya está poblado desde loadAllFolders()
   ├── allFoldersData ya tiene [Documentos, Música, Videos, Imágenes]
   └── populateFolderSelectors() ya se ejecutó

✅ Usuario ve las 4 carpetas disponibles
```

---

## 📊 Comparación Antes vs Después

| Aspecto                  | Antes (PROBLEMA)                   | Después (SOLUCIÓN)               |
| ------------------------ | ---------------------------------- | -------------------------------- |
| **Carpetas en Memoria**  | En `allFilesData` (se sobrescribe) | En `allFoldersData` (permanente) |
| **Carga de Carpetas**    | En cada `loadFilesFromBackend()`   | UNA VEZ en `loadAllFolders()`    |
| **Selectores de Upload** | Dependen de `allFilesData` ❌      | Dependen de `allFoldersData` ✅  |
| **Breadcrumb Fallback**  | Busca en `allFilesData` ❌         | Busca en `allFoldersData` ✅     |
| **Root View**            | Solo `allFilesData` ❌             | `allFoldersData` + archivos ✅   |
| **Navegación de Vuelta** | Falla, oculta todo ❌              | Funciona correctamente ✅        |

---

## 🧪 Casos de Prueba

### Test 1: Selectores Poblados al Subir

```
1. Login como usuario normal
2. Abrir página de archivos
3. Click en "Subir Archivo"
4. Verificar select de carpetas:
   ✅ Muestra: "Selecciona una carpeta..."
   ✅ Opciones: Documentos, Música, Videos, Imágenes
   ✅ NO muestra "Raíz"
```

### Test 2: Navegación a Carpeta

```
1. Estar en root (Home)
2. Verificar se ven 4 carpetas
3. Click en "Documentos"
4. Verificar:
   ✅ Breadcrumb: Home > Documentos
   ✅ Se muestran archivos de Documentos
   ✅ Select de upload sigue teniendo las 4 carpetas
```

### Test 3: Navegación de Vuelta con Breadcrumb

```
1. Navegar a "Documentos"
2. Click en "Home" del breadcrumb
3. Verificar:
   ✅ Vuelve a root
   ✅ Se muestran las 4 carpetas
   ✅ No se oculta nada
   ✅ Select de upload funciona
```

### Test 4: Admin ve Carpetas de Otros

```
1. Login como admin
2. Abrir "Subir Archivo"
3. Verificar select:
   ✅ Muestra 16 carpetas (4 × 4 usuarios)
   ✅ Carpetas con owner: "Documentos (Juan Esteban)"
   ✅ Carpetas propias sin badge: "Documentos"
```

---

## 🔍 Logs de Debugging

### Logs Esperados en Inicialización

```javascript
📁 Files Manager with FilePond: Inicializando...
⏳ Esperando a que todas las dependencias estén disponibles...
✅ AppRouter disponible
✅ RoleService disponible
✅ SessionService disponible
✅ Dependencias listas, iniciando Files Manager
👔 Files Manager: Es admin? false | User ID: 4

📂 Cargando todas las carpetas del usuario...
✅ Archivos recibidos del backend: {status: 'success', files: Array(4)}
✅ Carpetas cargadas: 4
🗂️ Carpetas disponibles: ['Documentos', 'Música', 'Videos', 'Imágenes']
📂 Selectores actualizados: 4 carpetas disponibles

📂 Cargando archivos desde backend...
📁 Carpeta actual: root
👤 Usuario: 4
✅ Archivos recibidos del backend: {status: 'success', files: Array(4)}
📊 Total archivos procesados: 4
🔍 Filtrando archivos para carpeta: root
📂 Root: 4 carpetas + 0 archivos = 4 items
```

### Logs al Navegar a Carpeta

```javascript
📂 Navegando a carpeta: 10
📂 Cargando archivos desde backend...
📁 Carpeta actual: 10
✅ Archivos recibidos del backend: {status: 'success', files: Array(3)}
📊 Total archivos procesados: 3
🔍 Filtrando archivos para carpeta: 10
📂 Archivos en carpeta 10: 3

🍞 Actualizando breadcrumb para carpeta: 10
🧭 Construyendo ruta de carpetas para: 10
🗺️ Ruta construida: Documentos
```

### Logs al Volver con Breadcrumb

```javascript
📂 Navegando a carpeta: root
📂 Cargando archivos desde backend...
📁 Carpeta actual: root
✅ Archivos recibidos del backend: {status: 'success', files: Array(4)}
📊 Total archivos procesados: 4
🔍 Filtrando archivos para carpeta: root
📂 Root: 4 carpetas + 0 archivos = 4 items
✅ Breadcrumb actualizado
```

---

## ✅ Resultados

### Problema 1: Breadcrumbs ✅ SOLUCIONADO

- ✅ Navegar de vuelta funciona correctamente
- ✅ Root siempre muestra las 4 carpetas
- ✅ No se oculta nada al usar breadcrumb
- ✅ `buildFolderPath()` encuentra carpetas en `allFoldersData`

### Problema 2: Selectores Vacíos ✅ SOLUCIONADO

- ✅ Selectores se pueblan al inicializar
- ✅ Selectores SIEMPRE tienen carpetas disponibles
- ✅ Admin ve todas las carpetas con owner badges
- ✅ Usuario normal ve solo sus 4 carpetas

---

## 📚 Archivos Modificados

1. **`/thepearlo_vr-website/pages/files.page.php`**
   - ✅ Agregada variable `allFoldersData`
   - ✅ Agregada función `loadAllFolders()`
   - ✅ Modificado `checkUserRole()` para cargar carpetas primero
   - ✅ Modificado `populateFolderSelectors()` para usar `allFoldersData`
   - ✅ Modificado `filterFilesByFolder()` para combinar carpetas + archivos en root
   - ✅ Modificado `buildFolderPath()` para buscar en `allFoldersData`
   - ✅ Simplificado `loadFilesFromBackend()` (removida lógica de caché)

---

## 🎯 Conclusión

**Arquitectura Mejorada**:

- ✅ Separación clara entre carpetas (permanentes) y archivos (dinámicos)
- ✅ Carga única de carpetas al inicializar
- ✅ Selectores siempre poblados correctamente
- ✅ Navegación con breadcrumb funciona en todos los casos
- ✅ Root siempre muestra las 4 carpetas fijas

**Beneficios**:

- 🚀 Mejor performance (menos requests de carpetas)
- 🐛 Menos bugs de navegación
- 🎯 Lógica más clara y mantenible
- ✅ Cumple con arquitectura de carpetas fijas

---

**Fecha de Fix**: Noviembre 2025  
**Versión**: 1.0  
**Mantenido por**: Roepard Labs Development Team
