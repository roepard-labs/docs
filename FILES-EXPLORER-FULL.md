# 📁 Explorador de Archivos Completo - Documentación Técnica

**HomeLab AR - Roepard Labs**  
**Fecha**: 4 de Noviembre 2025  
**Versión**: 2.0 - File Explorer Full

---

## 📋 Resumen de Mejoras

### 🆕 Nuevas Funcionalidades Implementadas

1. **✅ Navegación de Carpetas Anidadas**

   - Sistema completo de navegación jerárquica
   - Breadcrumb dinámico que refleja la ruta actual
   - Doble click en carpetas para navegar
   - Función `navigateToFolder(folderId)` para navegación programática

2. **✅ Soporte para Modelos 3D**

   - Tipos de archivo: `.gltf`, `.glb`, `.obj`
   - Vista previa con información del modelo
   - Icono específico: `bx-cube-alt`
   - Integración con Three.js Editor para visualización

3. **✅ Soporte Mejorado para Multimedia**

   - **Videos**: Vista previa con reproductor HTML5 nativo
   - **Audio**: Reproductor de audio con metadata visual
   - **Imágenes**: Visualización optimizada en modal
   - URLs de demo funcionales para testing

4. **✅ Sistema de Breadcrumb Dinámico**

   - Actualización automática al navegar
   - Click en cualquier nivel para volver atrás
   - Icono de home para volver a raíz
   - Construcción recursiva de ruta

5. **✅ Estructura de Datos Jerárquica**
   - Carpetas con subcarpetas anidadas
   - Campo `folderId` para identificar padre
   - Campo `itemsCount` para mostrar contenido
   - Filtrado eficiente por carpeta actual

---

## 🏗️ Arquitectura del Sistema

### Estructura de Datos

```javascript
// Estado global expandido
let isAdmin = false;
let currentUserId = null;
let currentFolder = "root"; // ID de carpeta actual
let folderPath = []; // Ruta de carpetas para breadcrumb
let viewMode = "grid"; // 'grid' o 'list'
let filesData = []; // Archivos de carpeta actual
let allFilesData = []; // TODOS los archivos (para navegación)
```

### Modelo de Datos de Archivo/Carpeta

```javascript
{
    id: 1,                          // ID único
    name: 'Nombre del archivo',
    type: 'document',               // folder, image, document, video, audio, model, archive, other
    extension: 'pdf',               // Extensión del archivo
    size: '2.5 MB',                 // Tamaño legible
    sizeBytes: 2621440,             // Tamaño en bytes
    date: '2025-11-04',             // Fecha de creación/modificación
    folder: 'Documentos',           // Nombre de carpeta padre
    folderId: 4,                    // ID de carpeta padre ('root' para raíz)
    owner: 'Juan Pérez',            // Nombre del propietario
    ownerId: 1,                     // ID del propietario
    shared: false,                  // ¿Compartido?
    description: 'Descripción',     // Descripción opcional
    preview: 'https://...',         // URL de vista previa (opcional)
    itemsCount: 8                   // Solo para carpetas: cantidad de elementos
}
```

---

## 🗂️ Jerarquía de Carpetas Demo

```
📁 Mis Archivos (root)
├── 📄 Presentación HomeLab.pdf
├── 🖼️ Logo HomeLab.png
├── 🎬 Video Demo VR.mp4
├── 📄 Base de datos backup.sql
├── 🎵 Música Ambiente.mp3
│
├── 📁 Documentos (id: 4) - 8 archivos
│   ├── 📄 Manual Usuario.pdf
│   ├── 📄 Especificaciones.docx
│   ├── 📄 Presupuesto.xlsx
│   │
│   ├── 📁 Contratos (id: 44) - 4 archivos
│   │   ├── 📄 Contrato Proyecto A.pdf
│   │   └── 📄 Contrato Proveedor.pdf
│   │
│   └── 📁 Facturas (id: 45) - 15 archivos
│
├── 📁 Modelos 3D (id: 9) - 5 archivos
│   ├── 🧊 Servidor HomeLab.gltf
│   ├── 🧊 Router Virtualizado.glb
│   ├── 🧊 Edificio Campus.obj
│   │
│   └── 📁 Assets VR (id: 94) - 8 archivos
│
└── 📁 Multimedia (id: 10) - 12 archivos
    ├── 🎬 Tutorial AR.mp4
    ├── 🎵 Música de Fondo.mp3
    │
    ├── 📁 Sonidos (id: 103) - 20 archivos
    ├── 📁 Videos Tutoriales (id: 104) - 6 archivos
    └── 📁 Capturas Pantalla (id: 105) - 30 archivos
```

---

## 🔧 Funciones Principales

### 1. Navegación de Carpetas

#### `navigateToFolder(folderId)`

**Propósito**: Navega a una carpeta específica.

```javascript
window.navigateToFolder = function (folderId) {
  console.log("📂 Navegando a carpeta:", folderId);
  currentFolder = folderId;
  filterFilesByFolder(folderId);
  updateBreadcrumb();

  // Scroll to top
  window.scrollTo({ top: 0, behavior: "smooth" });
};
```

**Uso**:

```javascript
// Navegar a carpeta específica
navigateToFolder(4); // Abre carpeta "Documentos"

// Volver a raíz
navigateToFolder("root");

// Desde breadcrumb
onclick = "navigateToFolder(44)"; // Navega a "Contratos"
```

#### `filterFilesByFolder(folderId)`

**Propósito**: Filtra archivos de la carpeta actual.

```javascript
function filterFilesByFolder(folderId) {
  filesData = allFilesData.filter((file) => file.folderId == folderId);
  renderFiles(filesData);
  console.log(
    `📂 Mostrando ${filesData.length} archivos en carpeta:`,
    folderId
  );
}
```

### 2. Breadcrumb Dinámico

#### `updateBreadcrumb()`

**Propósito**: Actualiza el breadcrumb con la ruta actual.

```javascript
function updateBreadcrumb() {
  const breadcrumb = document.getElementById("folderBreadcrumb");
  if (!breadcrumb) return;

  let html = `
        <li class="breadcrumb-item">
            <a href="javascript:void(0);" class="text-decoration-none" onclick="navigateToFolder('root')">
                <i class="bx bx-home-alt me-1"></i>
                Mis Archivos
            </a>
        </li>
    `;

  // Construir ruta de carpetas
  if (currentFolder !== "root") {
    buildFolderPath(currentFolder);

    folderPath.forEach((folder, index) => {
      const isLast = index === folderPath.length - 1;
      if (isLast) {
        html += `
                    <li class="breadcrumb-item active" aria-current="page">
                        <i class="bx bx-folder me-1"></i>
                        ${folder.name}
                    </li>
                `;
      } else {
        html += `
                    <li class="breadcrumb-item">
                        <a href="javascript:void(0);" onclick="navigateToFolder(${folder.id})">
                            <i class="bx bx-folder me-1"></i>
                            ${folder.name}
                        </a>
                    </li>
                `;
      }
    });
  }

  breadcrumb.innerHTML = html;
}
```

**Ejemplo de Breadcrumb**:

```
🏠 Mis Archivos > 📁 Documentos > 📁 Contratos
```

#### `buildFolderPath(folderId)`

**Propósito**: Construye la ruta de carpetas recursivamente.

```javascript
function buildFolderPath(folderId) {
  folderPath = [];
  let currentId = folderId;

  while (currentId !== "root" && currentId !== null) {
    const folder = allFilesData.find(
      (f) => f.id == currentId && f.type === "folder"
    );
    if (!folder) break;

    folderPath.unshift({
      id: folder.id,
      name: folder.name,
    });

    currentId = folder.folderId;
  }
}
```

### 3. Vista Previa de Archivos

#### Soporte por Tipo de Archivo

**Imágenes** (PNG, JPG, GIF, SVG):

```javascript
content.innerHTML = `
    <div class="text-center">
        <img src="${file.preview}" 
             class="img-fluid rounded shadow" 
             alt="${file.name}"
             style="max-height: 70vh; object-fit: contain;">
    </div>
`;
```

**Videos** (MP4, WEBM, OGG):

```javascript
content.innerHTML = `
    <video controls class="w-100 rounded shadow" style="max-height: 70vh;">
        <source src="${file.preview}" type="video/mp4">
        Tu navegador no soporta el tag de video.
    </video>
`;
```

**Audio** (MP3, WAV, OGG):

```javascript
content.innerHTML = `
    <div class="d-flex flex-column align-items-center justify-content-center py-5">
        <i class="bx bx-music display-1 text-primary mb-4"></i>
        <h4>${file.name}</h4>
        <p class="text-muted mb-4">${file.size} • ${formatDate(file.date)}</p>
        <audio controls class="w-75">
            <source src="${file.preview}" type="audio/mpeg">
        </audio>
    </div>
`;
```

**Modelos 3D** (GLTF, GLB, OBJ):

```javascript
content.innerHTML = `
    <div class="d-flex flex-column align-items-center justify-content-center py-5">
        <i class="bx bx-cube-alt display-1 text-info mb-4" style="font-size: 8rem;"></i>
        <h4>${file.name}</h4>
        <p class="text-muted mb-3">${
          file.size
        } • Modelo 3D ${file.extension.toUpperCase()}</p>
        <div class="alert alert-info">
            <i class="bx bx-info-circle me-2"></i>
            <strong>Vista previa 3D:</strong> Descarga el archivo para visualizarlo
        </div>
        <div class="mt-3">
            <button class="btn btn-primary me-2" onclick="downloadFile(${
              file.id
            })">
                <i class="bx bx-download me-2"></i>
                Descargar Modelo
            </button>
            <button class="btn btn-outline-secondary" 
                    onclick="window.open('https://threejs.org/editor/', '_blank')">
                <i class="bx bx-link-external me-2"></i>
                Abrir en Three.js Editor
            </button>
        </div>
    </div>
`;
```

**PDFs**:

```javascript
content.innerHTML = `
    <iframe src="${file.preview}" 
            width="100%" 
            height="500px" 
            frameborder="0"
            class="rounded shadow">
    </iframe>
`;
```

### 4. Interacciones de Usuario

#### Doble Click en Carpetas

```html
<div
  class="card file-card folder-card"
  ondblclick="navigateToFolder(${file.id})"
>
  <!-- Contenido de la carpeta -->
</div>
```

#### Doble Click en Archivos

```html
<div class="card file-card" ondblclick="previewFile(${file.id})">
  <!-- Contenido del archivo -->
</div>
```

#### Botones de Acción

```html
<button onclick="navigateToFolder(${file.id})">Abrir</button>
<button onclick="previewFile(${file.id})">Vista previa</button>
<button onclick="editFile(${file.id})">Editar</button>
<button onclick="downloadFile(${file.id})">Descargar</button>
<button onclick="deleteFile(${file.id})">Eliminar</button>
```

---

## 🎨 Tipos de Archivo Soportados

### Tabla de Tipos

| Tipo         | Extensiones                    | Icono           | Color    | Vista Previa        |
| ------------ | ------------------------------ | --------------- | -------- | ------------------- |
| **folder**   | -                              | `bx-folder`     | Amarillo | Navega al contenido |
| **image**    | png, jpg, jpeg, gif, svg       | `bx-image`      | Azul     | Imagen completa     |
| **document** | pdf, doc, docx, xls, xlsx, txt | `bx-file-blank` | Primario | PDF iframe          |
| **video**    | mp4, webm, ogg, mov, avi       | `bx-video`      | Rojo     | Reproductor video   |
| **audio**    | mp3, wav, ogg, m4a, flac       | `bx-music`      | Verde    | Reproductor audio   |
| **model**    | gltf, glb, obj, fbx, dae       | `bx-cube-alt`   | Púrpura  | Info + descarga     |
| **archive**  | zip, rar, 7z, tar, gz          | `bx-archive`    | Amarillo | Info + descarga     |
| **other**    | Otros                          | `bx-file`       | Gris     | Info + descarga     |

### Función de Detección de Tipo

```javascript
function getFileIcon(file) {
  const icons = {
    folder: "bx-folder",
    image: "bx-image",
    document: "bx-file-blank",
    video: "bx-video",
    audio: "bx-music",
    archive: "bx-archive",
    model: "bx-cube-alt",
    other: "bx-file",
  };
  return icons[file.type] || icons.other;
}
```

---

## 📊 Estadísticas Mejoradas

### Cálculo de Estadísticas Globales

```javascript
function updateStats() {
  // Calcular con TODOS los archivos (no solo carpeta actual)
  const totalFiles = allFilesData.filter((f) => f.type !== "folder").length;
  const totalFolders = allFilesData.filter((f) => f.type === "folder").length;
  const sharedFiles = allFilesData.filter((f) => f.shared).length;

  // Calcular tamaño total
  const totalBytes = allFilesData.reduce(
    (sum, f) => sum + (f.sizeBytes || 0),
    0
  );
  const totalGB = (totalBytes / (1024 * 1024 * 1024)).toFixed(2);
  const usedGB = (totalBytes / (1024 * 1024 * 1024)).toFixed(2);
  const maxGB = 10; // 10 GB máximo
  const usedPercent = ((usedGB / maxGB) * 100).toFixed(0);

  // Actualizar UI
  document.getElementById("totalFiles").textContent = totalFiles;
  document.getElementById("totalFolders").textContent = totalFolders;
  document.getElementById("usedStorage").textContent = `${usedGB} GB`;
  document.getElementById("storageProgress").style.width = `${usedPercent}%`;

  if (isAdmin) {
    document.getElementById("sharedFiles").textContent = sharedFiles;
  }
}
```

**Cards de Estadísticas**:

- ✅ Total de archivos (excluyendo carpetas)
- ✅ Total de carpetas
- ✅ Almacenamiento usado con barra de progreso
- ✅ Archivos compartidos (solo admin)

---

## 🔍 Búsqueda y Filtros

### Búsqueda por Nombre

```javascript
document.getElementById("searchFiles")?.addEventListener("input", function (e) {
  const search = e.target.value.toLowerCase();
  const currentFolderFiles = allFilesData.filter(
    (file) => file.folderId == currentFolder
  );
  const filtered = currentFolderFiles.filter(
    (file) =>
      file.name.toLowerCase().includes(search) ||
      (file.description && file.description.toLowerCase().includes(search))
  );
  renderFiles(filtered);
});
```

**Características**:

- ✅ Búsqueda en tiempo real
- ✅ Busca en nombre y descripción
- ✅ Solo en carpeta actual (no global)

### Filtro por Tipo

```javascript
document.getElementById("filterType")?.addEventListener("change", function (e) {
  const type = e.target.value;
  const currentFolderFiles = allFilesData.filter(
    (file) => file.folderId == currentFolder
  );
  const filtered = type
    ? currentFolderFiles.filter((file) => file.type === type)
    : currentFolderFiles;
  renderFiles(filtered);
});
```

**Opciones**:

- 📁 Carpetas
- 🖼️ Imágenes
- 📄 Documentos
- 🎬 Videos
- 🎵 Audio
- 🧊 Modelos 3D
- 📦 Archivos
- 📋 Otros

### Filtro por Fecha

```javascript
document.getElementById("filterDate")?.addEventListener("change", function (e) {
  const dateFilter = e.target.value;
  const currentFolderFiles = allFilesData.filter(
    (file) => file.folderId == currentFolder
  );

  if (!dateFilter) {
    renderFiles(currentFolderFiles);
    return;
  }

  const now = new Date();
  const filtered = currentFolderFiles.filter((file) => {
    const fileDate = new Date(file.date);

    switch (dateFilter) {
      case "today":
        return fileDate.toDateString() === now.toDateString();
      case "week":
        const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        return fileDate >= weekAgo;
      case "month":
        const monthAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
        return fileDate >= monthAgo;
      case "year":
        const yearAgo = new Date(now.getTime() - 365 * 24 * 60 * 60 * 1000);
        return fileDate >= yearAgo;
      default:
        return true;
    }
  });

  renderFiles(filtered);
});
```

**Opciones**:

- Todas las fechas
- Hoy
- Esta semana
- Este mes
- Este año

---

## 🎯 Casos de Uso Completos

### 1. Navegar por Jerarquía de Carpetas

**Flujo**:

```
1. Usuario carga /dashboard/files
2. Sistema muestra archivos de raíz (root)
3. Usuario hace doble click en carpeta "Documentos"
4. Sistema llama navigateToFolder(4)
5. Breadcrumb actualiza: "Mis Archivos > Documentos"
6. Vista muestra archivos dentro de "Documentos"
7. Usuario hace click en "Contratos" en breadcrumb
8. Sistema vuelve a "Contratos" directamente
```

### 2. Ver Modelo 3D

**Flujo**:

```
1. Usuario navega a "Modelos 3D"
2. Usuario hace doble click en "Servidor HomeLab.gltf"
3. Modal se abre con:
   - Icono 3D grande
   - Nombre del archivo
   - Tamaño y tipo
   - Botón "Descargar Modelo"
   - Botón "Abrir en Three.js Editor"
4. Usuario puede descargar o abrir en visor externo
```

### 3. Reproducir Video

**Flujo**:

```
1. Usuario navega a "Multimedia"
2. Usuario hace doble click en "Tutorial AR.mp4"
3. Modal se abre con reproductor HTML5
4. Video comienza a reproducirse
5. Controles: play/pause, volumen, pantalla completa
6. Usuario puede descargar video desde botón
```

### 4. Escuchar Audio

**Flujo**:

```
1. Usuario busca archivo de audio
2. Usuario hace doble click en "Música de Fondo.mp3"
3. Modal muestra:
   - Icono musical
   - Metadata del archivo
   - Reproductor de audio con controles
4. Usuario reproduce y controla playback
```

### 5. Buscar Archivo Específico

**Flujo**:

```
1. Usuario navega a "Documentos"
2. Usuario escribe "contrato" en búsqueda
3. Sistema filtra y muestra solo archivos con "contrato"
4. Usuario puede refinar con filtro de tipo
5. Usuario hace click para ver o editar
```

---

## 🔒 Seguridad y Permisos

### Verificación de Permisos en Navegación

```javascript
window.navigateToFolder = function (folderId) {
  // Verificar si carpeta existe
  const folder = allFilesData.find(
    (f) => f.id == folderId && f.type === "folder"
  );

  if (folder && !isAdmin && folder.ownerId !== currentUserId) {
    if (window.Notyf) {
      new Notyf().error("No tienes permisos para acceder a esta carpeta");
    }
    return;
  }

  currentFolder = folderId;
  filterFilesByFolder(folderId);
  updateBreadcrumb();
};
```

### Eliminación con Confirmación

```javascript
window.deleteFile = async function (fileId) {
  const file = allFilesData.find((f) => f.id === fileId);
  if (!file) return;

  // Verificar permisos
  if (!isAdmin && file.ownerId !== currentUserId) {
    new Notyf().error("No tienes permisos para eliminar este archivo");
    return;
  }

  const isFolder = file.type === "folder";
  const confirmed = await Swal.fire({
    title: `¿Eliminar ${isFolder ? "carpeta" : "archivo"}?`,
    text: `${
      isFolder ? "Se eliminarán todos sus contenidos." : ""
    } Esta acción no se puede deshacer.`,
    icon: "warning",
    showCancelButton: true,
    confirmButtonText: "Sí, eliminar",
    cancelButtonText: "Cancelar",
    confirmButtonColor: "#dc3545",
  });

  if (confirmed.isConfirmed) {
    // Eliminar archivo y sus dependencias
    allFilesData = allFilesData.filter(
      (f) => f.id !== fileId && f.folderId !== fileId
    );
    filterFilesByFolder(currentFolder);
    updateStats();
    new Notyf().success(
      `${isFolder ? "Carpeta" : "Archivo"} eliminado exitosamente`
    );
  }
};
```

---

## 🚀 Integración con Backend

### Endpoints Necesarios

#### 1. Listar Archivos de Carpeta

```php
// GET /routes/files/list_files.php
// Params: folder_id, user_id

async function loadFiles(folderId = 'root') {
    const response = await window.AppRouter.get('/routes/files/list_files.php', {
        params: {
            folder_id: folderId,
            user_id: currentUserId
        }
    });

    allFilesData = response.data.files;
    filterFilesByFolder(folderId);
    updateBreadcrumb();
    updateStats();
}
```

#### 2. Crear Carpeta

```php
// POST /routes/files/create_folder.php
// Body: name, parent_folder_id, description, user_id

const data = {
    name: folderName,
    parent_folder_id: currentFolder,
    description: folderDescription,
    user_id: currentUserId
};

const response = await window.AppRouter.post('/routes/files/create_folder.php', data);
```

#### 3. Subir Archivo

```php
// POST /routes/files/upload_file.php (multipart/form-data)
// Body: files[], folder_id, user_id, description, share_with_all

const formData = new FormData();
for (let file of files) {
    formData.append('files[]', file);
}
formData.append('folder_id', currentFolder);
formData.append('user_id', currentUserId);

const response = await window.AppRouter.upload('/routes/files/upload_file.php', formData, {
    onUploadProgress: (percent) => updateProgressBar(percent)
});
```

### Base de Datos - Estructura de Tablas

```sql
CREATE TABLE files (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type ENUM('folder', 'image', 'document', 'video', 'audio', 'model', 'archive', 'other') NOT NULL,
    extension VARCHAR(10),
    size_bytes BIGINT DEFAULT 0,
    folder_id INT NULL,  -- NULL = root, INT = parent folder
    owner_id INT NOT NULL,
    shared BOOLEAN DEFAULT FALSE,
    description TEXT,
    file_path VARCHAR(500),  -- Ruta física del archivo
    preview_path VARCHAR(500),  -- Ruta de miniatura
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,  -- Soft delete

    FOREIGN KEY (folder_id) REFERENCES files(id) ON DELETE CASCADE,
    FOREIGN KEY (owner_id) REFERENCES users(user_id) ON DELETE CASCADE,

    INDEX idx_folder (folder_id),
    INDEX idx_owner (owner_id),
    INDEX idx_type (type),
    INDEX idx_deleted (deleted_at)
);
```

**Notas**:

- `folder_id NULL` = archivo/carpeta en raíz
- `folder_id INT` = archivo/carpeta dentro de otra carpeta
- Cascade delete: al eliminar carpeta, se eliminan sus contenidos
- Soft delete: `deleted_at` para recuperación

---

## 🧪 Testing del Sistema

### Checklist de Pruebas

#### Navegación

- [ ] ✅ Navegar a carpeta desde doble click
- [ ] ✅ Navegar a carpeta desde botón "Abrir"
- [ ] ✅ Breadcrumb actualiza correctamente
- [ ] ✅ Click en nivel de breadcrumb navega correctamente
- [ ] ✅ Volver a raíz desde breadcrumb home
- [ ] ✅ Navegar a carpetas anidadas (3+ niveles)
- [ ] ✅ URL se mantiene en /dashboard/files

#### Vista Previa

- [ ] ✅ Imágenes se muestran correctamente
- [ ] ✅ Videos reproducen con controles
- [ ] ✅ Audio reproduce con controles
- [ ] ✅ Modelos 3D muestran info + botones
- [ ] ✅ PDFs cargan en iframe
- [ ] ✅ Archivos sin preview muestran botón descarga

#### Búsqueda y Filtros

- [ ] ✅ Búsqueda filtra en tiempo real
- [ ] ✅ Filtro por tipo funciona
- [ ] ✅ Filtro por fecha funciona
- [ ] ✅ Filtros se aplican solo a carpeta actual
- [ ] ✅ Limpiar filtros restaura vista

#### Estadísticas

- [ ] ✅ Total de archivos correcto
- [ ] ✅ Total de carpetas correcto
- [ ] ✅ Almacenamiento usado se calcula bien
- [ ] ✅ Barra de progreso refleja porcentaje
- [ ] ✅ Admin ve archivos compartidos

#### Permisos

- [ ] ✅ Usuario solo ve sus archivos
- [ ] ✅ Admin ve todos los archivos
- [ ] ✅ Permisos verificados al editar
- [ ] ✅ Permisos verificados al eliminar
- [ ] ✅ Confirmación al eliminar carpeta

### Comandos de Testing

```bash
# Navegar al dashboard
http://localhost:9000/dashboard/files

# Abrir consola del navegador
F12 > Console

# Verificar variables globales
console.log('Current folder:', currentFolder);
console.log('All files:', allFilesData.length);
console.log('Current files:', filesData.length);
console.log('Folder path:', folderPath);

# Navegar programáticamente
navigateToFolder(4);  // Documentos
navigateToFolder(44); // Contratos
navigateToFolder('root');  // Raíz

# Ver estadísticas
updateStats();

# Filtrar archivos
filterFilesByFolder(9);  // Modelos 3D
```

---

## 📚 Recursos de Demo

### URLs de Archivos de Prueba

**Videos**:

```
https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4
https://storage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4
```

**Audio**:

```
https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3
https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3
```

**Modelos 3D**:

```
https://threejs.org/examples/models/gltf/DamagedHelmet/glTF/DamagedHelmet.gltf
```

**Editor 3D**:

```
https://threejs.org/editor/
```

---

## 🔮 Próximas Mejoras Sugeridas

### Funcionalidades Adicionales

1. **Visor 3D Integrado**

   - Integrar Three.js directamente en modal
   - Controles de rotación y zoom
   - Diferentes modos de visualización

2. **Generación de Miniaturas**

   - Thumbnails automáticos para imágenes
   - Frames de video como preview
   - Waveforms para audio

3. **Drag & Drop**

   - Arrastrar archivos para subir
   - Arrastrar archivos entre carpetas
   - Reorganización visual

4. **Selección Múltiple**

   - Checkboxes para seleccionar varios
   - Acciones en lote (mover, eliminar, descargar)
   - Select all/none

5. **Compartir Archivos**

   - Sistema de permisos granular
   - Links de compartir temporales
   - Gestión de accesos

6. **Historial de Versiones**

   - Versiones previas de archivos
   - Restaurar versión anterior
   - Comparación de versiones

7. **Tags y Categorías**

   - Etiquetar archivos
   - Buscar por tags
   - Categorías personalizadas

8. **Vista de Galería**
   - Grid de miniaturas para imágenes
   - Slideshow automático
   - Fullscreen gallery

---

## 📞 Soporte y Contacto

**Equipo de Desarrollo**: Roepard Labs  
**Proyecto**: HomeLab AR  
**Documentación**: `/docs/FILES-EXPLORER-FULL.md`

Para dudas o mejoras:

1. Consultar documentación completa
2. Revisar código en `/pages/files.page.php`
3. Contactar equipo de desarrollo

---

**Última actualización**: 4 de Noviembre 2025  
**Versión**: 2.0 - File Explorer Full  
**Estado**: ✅ Completamente funcional con datos demo
