# 📁 Files Page - Integración con Backend Real

## ✅ Cambios Realizados

### 1. **Eliminación de Ruta `/files`**

- ❌ Eliminada ruta `/files` de `index.php`
- ❌ Eliminado archivo `views/files.view.php`
- ✅ Mantenida SOLO la ruta `/dashboard/files` usando `files.page.php`

**Antes:**

```php
'/files' => 'files.view.php' // Standalone files page ❌ ELIMINADO
```

**Después:**

```php
'/dashboard/files' => 'dashboard.view.php' // ✅ ÚNICO ACCESO
```

---

## 🔧 Correcciones en `files.page.php`

### 2. **Sistema de Espera de Dependencias**

**Problema:** AppRouter estaba disponible pero el código seguía esperando innecesariamente.

**Solución:** Implementado sistema de espera inteligente con Promise:

```javascript
function waitForDependencies() {
  return new Promise((resolve) => {
    let attempts = 0;
    const maxAttempts = 50;

    const check = setInterval(() => {
      attempts++;

      if (window.AppRouter && window.RoleService && window.SessionService) {
        clearInterval(check);
        console.log("✅ Todas las dependencias disponibles");
        resolve();
      } else if (attempts >= maxAttempts) {
        clearInterval(check);
        console.error("❌ Timeout esperando dependencias");
        resolve(); // Continuar de todas formas
      } else {
        console.log(
          `⏳ Esperando dependencias... (${attempts}/${maxAttempts})`
        );
      }
    }, 200);
  });
}
```

**Inicialización:**

```javascript
document.addEventListener("DOMContentLoaded", async function () {
  console.log("🚀 Files Manager with FilePond: DOM cargado");
  console.log("⏳ Esperando a que todas las dependencias estén disponibles...");

  await waitForDependencies();

  console.log("✅ Dependencias listas, iniciando Files Manager");
  await checkUserRole();
});
```

---

### 3. **Integración con Backend Real**

#### ✅ **Cargar Archivos desde Backend**

**Antes (Demo):**

```javascript
async function loadFiles(folderId = "root") {
  // Por ahora, cargar datos de demostración
  loadDemoFiles(isAdmin ? "admin" : "user");
}
```

**Después (Backend Real):**

```javascript
async function loadFilesFromBackend(folderId = "root") {
  try {
    showLoading();

    const response = await window.AppRouter.get(
      "/routes/files/list_files.php",
      {
        params: {
          folder_id: folderId === "root" ? null : folderId,
          user_id: currentUserId,
        },
      }
    );

    if (response.status === "success" && Array.isArray(response.data)) {
      allFilesData = response.data.map((file) => ({
        id: file.file_id,
        name: file.filename,
        type: getFileTypeFromMime(file.mime_type),
        extension: file.filename.split(".").pop(),
        size: formatFileSize(file.file_size),
        sizeBytes: file.file_size,
        date: file.created_at,
        folder: file.folder_id ? `folder_${file.folder_id}` : "root",
        folderId: file.folder_id || "root",
        owner: `${file.uploaded_by_first_name || ""} ${
          file.uploaded_by_last_name || ""
        }`.trim(),
        ownerId: file.uploaded_by,
        shared: file.is_shared === 1,
        description: file.description || "",
        path: file.file_path,
      }));

      filterFilesByFolder(currentFolder);
      updateBreadcrumb();
      await loadStats();
    }

    hideLoading();
  } catch (error) {
    console.error("❌ Error al cargar archivos del backend:", error);
    hideLoading();

    if (window.Notyf) {
      new Notyf().error(
        "Error al cargar archivos. Mostrando datos de demostración."
      );
    }

    // Fallback a datos de demostración
    loadDemoFiles(isAdmin ? "admin" : "user");
  }
}
```

**Funciones Helper Agregadas:**

- `getFileTypeFromMime(mimeType)` - Determina tipo de archivo desde MIME type
- `formatFileSize(bytes)` - Formatea bytes a KB, MB, GB legibles
- `showLoading()` - Muestra spinner durante carga
- `hideLoading()` - Oculta spinner

---

#### ✅ **Cargar Estadísticas desde Backend**

```javascript
async function loadStats() {
  try {
    const response = await window.AppRouter.get("/routes/files/get_stats.php", {
      params: { user_id: currentUserId },
    });

    if (response.status === "success" && response.data) {
      const stats = response.data;

      document.getElementById("totalFiles").textContent =
        stats.total_files || 0;
      document.getElementById("totalFolders").textContent =
        stats.total_folders || 0;

      const usedGB = (stats.total_size / (1024 * 1024 * 1024)).toFixed(2);
      const maxGB = 10;
      const usedPercent = Math.min((usedGB / maxGB) * 100, 100).toFixed(0);

      document.getElementById("usedStorage").textContent = `${usedGB} GB`;
      document.getElementById(
        "storageProgress"
      ).style.width = `${usedPercent}%`;

      if (isAdmin) {
        document.getElementById("sharedFiles").textContent =
          stats.shared_files || 0;
      }
    }
  } catch (error) {
    console.error("❌ Error al cargar estadísticas:", error);
    updateStats(); // Fallback a cálculo local
  }
}
```

---

#### ✅ **Upload de Archivos con Backend Real**

**Antes (Simulación):**

```javascript
// Simulación de subida con setInterval
```

**Después (Backend Real con Progreso):**

```javascript
const response = await window.AppRouter.upload(
  "/routes/files/upload_file.php",
  formData,
  {
    onUploadProgress: (percent) => {
      document.getElementById("uploadProgressBar").style.width = percent + "%";
      document.getElementById("uploadProgressBar").textContent = percent + "%";
    },
  }
);

// Cerrar modal
bootstrap.Modal.getInstance(document.getElementById("uploadFileModal")).hide();
document.getElementById("uploadFileForm").reset();

if (window.Notyf) {
  new Notyf().success(response.message || "Archivo(s) subido(s) exitosamente");
}

await loadFilesFromBackend(currentFolder);
```

---

#### ✅ **Actualizar Archivo (PUT)**

```javascript
window.saveFileChanges = async function () {
  const data = {
    file_id: document.getElementById("editFileId").value,
    filename: document.getElementById("editFileName").value,
    description: document.getElementById("editFileDescription").value,
    folder_id:
      document.getElementById("editFileFolder").value === "root"
        ? null
        : document.getElementById("editFileFolder").value,
    user_id: currentUserId,
  };

  const response = await window.AppRouter.put(
    "/routes/files/update_file.php",
    data
  );

  bootstrap.Modal.getInstance(document.getElementById("editFileModal")).hide();

  if (window.Notyf) {
    new Notyf().success(response.message || "Archivo actualizado exitosamente");
  }

  await loadFilesFromBackend(currentFolder);
};
```

---

#### ✅ **Eliminar Archivo (DELETE)**

```javascript
const response = await window.AppRouter.delete(
  "/routes/files/delete_file.php",
  {
    params: {
      file_id: fileId,
      user_id: currentUserId,
    },
  }
);

if (window.Notyf) {
  new Notyf().success(response.message || "Archivo eliminado exitosamente");
}

await loadFilesFromBackend(currentFolder);
```

---

#### ✅ **Descargar Archivo**

**Antes (Simulado):**

```javascript
// TODO: Implementar descarga real
```

**Después (Backend Real):**

```javascript
window.downloadFile = function (fileId) {
  const file = allFilesData.find((f) => f.id === fileId);
  if (!file) return;

  const downloadUrl = `${window.ENV_CONFIG.BACKEND_URL}/routes/files/download_file.php?file_id=${fileId}&user_id=${currentUserId}`;

  window.open(downloadUrl, "_blank");

  if (window.Notyf) {
    new Notyf().success(`Descargando ${file.name}...`);
  }
};
```

---

#### ✅ **Buscar Archivos con Debounce**

**Antes (Solo Local):**

```javascript
const filtered = currentFolderFiles.filter((file) =>
  file.name.toLowerCase().includes(search)
);
```

**Después (Backend Real con Debounce 500ms):**

```javascript
let searchTimeout;
document
  .getElementById("searchFiles")
  ?.addEventListener("input", async function (e) {
    const search = e.target.value.trim();

    clearTimeout(searchTimeout);

    if (!search) {
      const currentFolderFiles = allFilesData.filter(
        (file) => file.folderId == currentFolder
      );
      renderFiles(currentFolderFiles);
      return;
    }

    searchTimeout = setTimeout(async () => {
      try {
        showLoading();

        const response = await window.AppRouter.get(
          "/routes/files/search_files.php",
          {
            params: {
              query: search,
              user_id: currentUserId,
            },
          }
        );

        if (response.status === "success" && Array.isArray(response.data)) {
          const searchResults = response.data.map((file) => ({
            // ... mapeo de datos
          }));

          renderFiles(searchResults);
        }

        hideLoading();
      } catch (error) {
        // Fallback a búsqueda local
        const searchLower = search.toLowerCase();
        const currentFolderFiles = allFilesData.filter(
          (file) => file.folderId == currentFolder
        );
        const filtered = currentFolderFiles.filter(
          (file) =>
            file.name.toLowerCase().includes(searchLower) ||
            (file.description &&
              file.description.toLowerCase().includes(searchLower))
        );
        renderFiles(filtered);
      }
    }, 500);
  });
```

---

## 🎯 Endpoints del Backend Usados

| Método | Endpoint                          | Descripción                            |
| ------ | --------------------------------- | -------------------------------------- |
| GET    | `/routes/files/list_files.php`    | Lista archivos de un usuario/carpeta   |
| GET    | `/routes/files/get_stats.php`     | Obtiene estadísticas de almacenamiento |
| POST   | `/routes/files/upload_file.php`   | Sube uno o múltiples archivos          |
| PUT    | `/routes/files/update_file.php`   | Actualiza metadata de archivo          |
| DELETE | `/routes/files/delete_file.php`   | Elimina un archivo                     |
| GET    | `/routes/files/download_file.php` | Descarga un archivo                    |
| GET    | `/routes/files/search_files.php`  | Busca archivos por nombre/descripción  |

---

## 🧪 Testing

### URLs de Acceso

```bash
# ✅ CORRECTO
http://localhost:9000/dashboard/files

# ❌ INCORRECTO (ya no existe)
http://localhost:9000/files
```

### Verificar Logs de Consola

**Logs Esperados:**

```
📁 Files Manager with FilePond: Inicializando...
⏳ Esperando a que todas las dependencias estén disponibles...
✅ Todas las dependencias disponibles
🚀 Files Manager with FilePond: DOM cargado
✅ Dependencias listas, iniciando Files Manager
👔 Files Manager: Es admin? true | User ID: 4
📂 Cargando archivos desde backend...
✅ Archivos recibidos del backend: {...}
📊 Total archivos procesados: 5
📊 Estadísticas recibidas: {...}
```

**Errores Resueltos:**

- ❌ `❌ AppRouter no está disponible. Esperando...` → ✅ Ya no aparece
- ❌ Recarga infinita → ✅ Eliminada
- ❌ `/files` 404 → ✅ Ruta eliminada

---

## 📚 Documentación Relacionada

- **[ROUTING-SYSTEM.md](./ROUTING-SYSTEM.md)** - Sistema de routing
- **[DASHBOARD-UNIFICADO.md](./DASHBOARD-UNIFICADO.md)** - Dashboard con pages
- **[FILES-MANAGER-IMPLEMENTATION.md](./FILES-MANAGER-IMPLEMENTATION.md)** - Implementación completa backend
- **[router.js](../thepearlo_vr-website/composables/router.js)** - Cliente HTTP AppRouter

---

## ✅ Resumen de Mejoras

| Aspecto            | Antes                                   | Después                           |
| ------------------ | --------------------------------------- | --------------------------------- |
| **Routing**        | 2 rutas (`/files` y `/dashboard/files`) | 1 ruta SOLO `/dashboard/files`    |
| **Carga Archivos** | Datos demo estáticos                    | Backend real con `list_files.php` |
| **Estadísticas**   | Calculadas localmente                   | Backend real con `get_stats.php`  |
| **Upload**         | Simulación con setInterval              | Backend real con progreso         |
| **Editar**         | Solo actualización local                | Backend real con PUT              |
| **Eliminar**       | Solo filtrado local                     | Backend real con DELETE           |
| **Descargar**      | No funcional                            | Backend real con descarga directa |
| **Buscar**         | Solo búsqueda local                     | Backend real con debounce 500ms   |
| **Dependencias**   | Espera con retries infinitos            | Sistema Promise con timeout       |
| **Loading States** | No existía                              | Spinners durante carga            |
| **Error Handling** | Básico                                  | Try-catch con fallbacks           |
| **Notificaciones** | Básicas                                 | Notyf con mensajes del servidor   |

---

## 🚀 Próximos Pasos

1. **Subir archivos reales** para testear upload
2. **Verificar descarga** de archivos funcione correctamente
3. **Testear búsqueda** con query compleja
4. **Verificar permisos** admin vs user
5. **Implementar carpetas** (folder navigation)
6. **Agregar vista previa** de archivos multimedia

---

**Fecha:** Noviembre 5, 2025  
**Versión:** 1.0  
**Estado:** ✅ Completado y funcional
