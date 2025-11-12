# 🎨 FilePond - Ejemplos de Personalización

## 📋 Índice

1. [Configuración Básica](#configuración-básica)
2. [Validaciones Personalizadas](#validaciones-personalizadas)
3. [Editor de Imágenes](#editor-de-imágenes)
4. [Transformaciones](#transformaciones)
5. [Estilos CSS](#estilos-css)
6. [Eventos Personalizados](#eventos-personalizados)
7. [Integración con Backend](#integración-con-backend)

---

## 1. Configuración Básica

### Cambiar Límites de Archivos

```javascript
pond = FilePond.create(inputElement, {
  // Límites
  maxFiles: 20, // Máximo 20 archivos
  maxFileSize: "100MB", // 100MB por archivo
  maxTotalFileSize: "1GB", // 1GB total

  // Permitir múltiples
  allowMultiple: true,

  // Requerido
  required: true,

  // Instantáneo
  instantUpload: true, // Sube automáticamente al agregar

  // Permitir drop
  allowDrop: true,
  allowBrowse: true,
  allowPaste: true, // Permitir pegar imágenes
});
```

### Extensiones Permitidas

```javascript
pond = FilePond.create(inputElement, {
  acceptedFileTypes: [
    // Imágenes
    "image/jpeg",
    "image/png",
    "image/gif",
    "image/webp",
    "image/svg+xml",

    // Documentos
    "application/pdf",
    "application/msword",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "application/vnd.ms-excel",
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",

    // Videos
    "video/mp4",
    "video/webm",
    "video/ogg",

    // Audio
    "audio/mpeg",
    "audio/wav",
    "audio/ogg",

    // Archivos
    "application/zip",
    "application/x-rar-compressed",
    "application/x-7z-compressed",

    // Modelos 3D
    "model/gltf-binary",
    "model/gltf+json",
    ".glb",
    ".gltf",
    ".obj",
    ".fbx",
  ],

  // O usar categorías
  // acceptedFileTypes: ['image/*', 'video/*', 'audio/*']
});
```

---

## 2. Validaciones Personalizadas

### Validación de Tamaño por Tipo

```javascript
// Límites diferentes según tipo
FilePond.registerPlugin(FilePondPluginFileValidateSize);

pond = FilePond.create(inputElement, {
  // Validación global
  maxFileSize: "50MB",

  // Hook de validación personalizada
  beforeAddFile: (item) => {
    const file = item.file;

    // Videos hasta 100MB
    if (file.type.startsWith("video/")) {
      if (file.size > 100 * 1024 * 1024) {
        alert("Los videos no pueden superar 100MB");
        return false;
      }
    }

    // Imágenes hasta 10MB
    if (file.type.startsWith("image/")) {
      if (file.size > 10 * 1024 * 1024) {
        alert("Las imágenes no pueden superar 10MB");
        return false;
      }
    }

    // Documentos hasta 25MB
    if (file.type === "application/pdf" || file.type.includes("document")) {
      if (file.size > 25 * 1024 * 1024) {
        alert("Los documentos no pueden superar 25MB");
        return false;
      }
    }

    return true; // Permitir
  },
});
```

### Validación de Dimensiones de Imágenes

```javascript
FilePond.registerPlugin(FilePondPluginImageValidateSize);

pond = FilePond.create(inputElement, {
  // Dimensiones mínimas
  imageValidateSizeMinWidth: 640,
  imageValidateSizeMinHeight: 480,

  // Dimensiones máximas
  imageValidateSizeMaxWidth: 8000,
  imageValidateSizeMaxHeight: 8000,

  // Mensajes personalizados
  labelImageSizeTooBig: "La imagen es demasiado grande",
  labelImageSizeTooSmall: "La imagen es demasiado pequeña",
  labelImageValidateSizeMaxWidth: "Ancho máximo: {minWidth}px",
  labelImageValidateSizeMaxHeight: "Altura máxima: {maxHeight}px",
});
```

### Validación de Nombres de Archivos

```javascript
pond = FilePond.create(inputElement, {
  beforeAddFile: (item) => {
    const filename = item.file.name;

    // No permitir caracteres especiales
    const invalidChars = /[<>:"/\\|?*]/g;
    if (invalidChars.test(filename)) {
      alert("El nombre del archivo contiene caracteres no permitidos");
      return false;
    }

    // No permitir nombres muy largos
    if (filename.length > 255) {
      alert("El nombre del archivo es demasiado largo");
      return false;
    }

    // No permitir archivos ocultos
    if (filename.startsWith(".")) {
      alert("No se permiten archivos ocultos");
      return false;
    }

    return true;
  },
});
```

---

## 3. Editor de Imágenes

### Configuración Básica del Editor

```javascript
FilePond.registerPlugin(FilePondPluginImageEdit);

pond = FilePond.create(inputElement, {
  allowImageEdit: true,
  imageEditInstantEdit: false, // Requiere confirmación

  // Herramientas disponibles
  imageEditEditor: {
    // Opciones de edición
    editorControls: [
      "crop",
      "resize",
      "rotate",
      "flip",
      "filter",
      "brightness",
      "contrast",
      "saturation",
    ],
  },
});
```

### Crop Personalizado

```javascript
FilePond.registerPlugin(FilePondPluginImageCrop);

pond = FilePond.create(inputElement, {
  allowImageCrop: true,

  // Ratio de aspecto
  imageCropAspectRatio: "16:9", // '1:1', '4:3', '16:9', 'free'

  // O ratio numérico
  // imageCropAspectRatio: 1.777,  // 16:9 = 1.777

  // Crop forzado
  imageTransformBeforeCreateBlob: (canvas) => {
    // Canvas ya tiene el crop aplicado
    return canvas;
  },
});
```

### Filtros de Imagen

```javascript
FilePond.registerPlugin(FilePondPluginImageFilter);

pond = FilePond.create(inputElement, {
  allowImageFilter: true,

  // Filtros disponibles
  imageFilterColorMatrix: {
    // Sepia
    sepia: [
      [0.393, 0.769, 0.189, 0, 0],
      [0.349, 0.686, 0.168, 0, 0],
      [0.272, 0.534, 0.131, 0, 0],
      [0, 0, 0, 1, 0],
    ],

    // Grayscale
    grayscale: [
      [0.2126, 0.7152, 0.0722, 0, 0],
      [0.2126, 0.7152, 0.0722, 0, 0],
      [0.2126, 0.7152, 0.0722, 0, 0],
      [0, 0, 0, 1, 0],
    ],

    // Invertir colores
    invert: [
      [-1, 0, 0, 0, 255],
      [0, -1, 0, 0, 255],
      [0, 0, -1, 0, 255],
      [0, 0, 0, 1, 0],
    ],
  },
});
```

---

## 4. Transformaciones

### Redimensionar Imágenes Automáticamente

```javascript
FilePond.registerPlugin(FilePondPluginImageResize);
FilePond.registerPlugin(FilePondPluginImageTransform);

pond = FilePond.create(inputElement, {
  allowImageResize: true,

  // Tamaño objetivo
  imageResizeTargetWidth: 1920,
  imageResizeTargetHeight: 1080,

  // Modo de redimensión
  imageResizeMode: "contain", // 'contain', 'cover', 'force'

  // Upscale (agrandar imágenes pequeñas)
  imageResizeUpscale: false,

  // Transformación de salida
  allowImageTransform: true,
  imageTransformOutputMimeType: "image/jpeg",
  imageTransformOutputQuality: 85, // 0-100
  imageTransformOutputStripImageHead: false, // Mantener EXIF

  // Canvas background
  imageTransformCanvasMemoryLimit: 16777216, // 16MB
});
```

### Comprimir Imágenes

```javascript
pond = FilePond.create(inputElement, {
  allowImageTransform: true,

  // Diferentes calidades según tamaño
  imageTransformBeforeCreateBlob: async (canvas) => {
    const size = canvas.width * canvas.height;

    let quality;
    if (size > 1920 * 1080) {
      quality = 0.7; // 70% para imágenes grandes
    } else if (size > 1280 * 720) {
      quality = 0.8; // 80% para imágenes medianas
    } else {
      quality = 0.9; // 90% para imágenes pequeñas
    }

    return new Promise((resolve) => {
      canvas.toBlob((blob) => resolve(blob), "image/jpeg", quality);
    });
  },
});
```

### Watermark en Imágenes

```javascript
pond = FilePond.create(inputElement, {
  imageTransformBeforeCreateBlob: (canvas) => {
    const ctx = canvas.getContext("2d");

    // Watermark text
    const watermarkText = "© Roepard Labs 2025";

    // Configurar estilo
    ctx.font = "20px Arial";
    ctx.fillStyle = "rgba(255, 255, 255, 0.5)";
    ctx.textAlign = "right";
    ctx.textBaseline = "bottom";

    // Dibujar watermark en esquina inferior derecha
    ctx.fillText(watermarkText, canvas.width - 20, canvas.height - 20);

    return canvas;
  },
});
```

---

## 5. Estilos CSS

### Tema Personalizado

```css
/* Tema oscuro para FilePond */
.filepond--root {
  font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
}

/* Panel de drop */
.filepond--panel-root {
  background-color: #2d2d2d;
  border: 2px dashed #00ff88;
  border-radius: 12px;
}

/* Texto de drop */
.filepond--drop-label {
  color: #ffffff;
}

.filepond--drop-label label {
  color: #00ff88;
  font-weight: bold;
}

/* Hover state */
.filepond--panel-root:hover {
  background-color: #3d3d3d;
  border-color: #00ffaa;
}

/* Items */
.filepond--item {
  background-color: #1a1a1a;
  border-radius: 8px;
}

/* Progress bar */
.filepond--item-panel {
  background-color: #2d2d2d;
}

.filepond--file-action-button {
  background-color: #00ff88;
  color: #1a1a1a;
}

.filepond--file-action-button:hover {
  background-color: #00ffaa;
}

/* Success state */
.filepond--item-panel.filepond--item-panel-processing {
  background-color: #004422;
}

.filepond--item-panel.filepond--item-panel-processing-complete {
  background-color: #006633;
}

/* Error state */
.filepond--item-panel.filepond--item-panel-processing-error {
  background-color: #660000;
}
```

### Tamaño y Layout

```css
/* FilePond full width */
.filepond--root {
  max-width: 100%;
  margin-bottom: 1rem;
}

/* Altura del drop area */
.filepond--panel-root {
  min-height: 200px;
}

/* Grid de items */
.filepond--list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  gap: 1rem;
}

/* Item compacto */
.filepond--item {
  padding: 0.5rem;
}

/* Preview más grande */
.filepond--image-preview-wrapper {
  height: 200px;
}
```

### Animaciones

```css
/* Fade in al agregar */
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: scale(0.9);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

.filepond--item {
  animation: fadeIn 0.3s ease-out;
}

/* Shake en error */
@keyframes shake {
  0%,
  100% {
    transform: translateX(0);
  }
  25% {
    transform: translateX(-10px);
  }
  75% {
    transform: translateX(10px);
  }
}

.filepond--item-panel-processing-error {
  animation: shake 0.5s ease-in-out;
}

/* Progress bar animado */
@keyframes progress {
  from {
    width: 0%;
  }
  to {
    width: 100%;
  }
}

.filepond--file-status {
  animation: progress 0.3s ease-out;
}
```

---

## 6. Eventos Personalizados

### Eventos del Ciclo de Vida

```javascript
pond = FilePond.create(inputElement, {
  // Archivo agregado
  onaddfile: (error, file) => {
    if (error) {
      console.error("Error agregando archivo:", error);
      return;
    }

    console.log("📎 Archivo agregado:", file.filename);
    console.log("   Tamaño:", formatFileSize(file.fileSize));
    console.log("   Tipo:", file.fileType);
  },

  // Archivo procesado
  onprocessfile: (error, file) => {
    if (error) {
      console.error("❌ Error procesando archivo:", error);
      notyf.error(`Error subiendo ${file.filename}`);
      return;
    }

    console.log("✅ Archivo procesado:", file.filename);
    notyf.success(`${file.filename} subido correctamente`);

    // Actualizar estadísticas
    updateStats();
  },

  // Todos los archivos procesados
  onprocessfiles: () => {
    console.log("✅ Todos los archivos procesados");

    // Cerrar modal
    setTimeout(() => {
      const modal = bootstrap.Modal.getInstance(
        document.getElementById("uploadFileModal")
      );
      if (modal) modal.hide();

      // Limpiar FilePond
      pond.removeFiles();

      // Recargar lista
      loadFiles(currentFolder);
    }, 2000);
  },

  // Archivo removido
  onremovefile: (error, file) => {
    console.log("🗑️ Archivo removido:", file.filename);
  },

  // Error general
  onerror: (error) => {
    console.error("❌ Error general:", error);
    notyf.error("Error en FilePond");
  },

  // Actualización de progreso
  onprocessfileprogress: (file, progress) => {
    console.log(`📊 Progreso ${file.filename}: ${Math.round(progress * 100)}%`);

    // Actualizar UI personalizada
    const progressBar = document.getElementById(`progress-${file.id}`);
    if (progressBar) {
      progressBar.style.width = `${Math.round(progress * 100)}%`;
    }
  },
});
```

### Tracking Avanzado

```javascript
// Objeto para tracking
const uploadStats = {
  totalFiles: 0,
  uploadedFiles: 0,
  failedFiles: 0,
  totalSize: 0,
  uploadedSize: 0,
  startTime: null,
  endTime: null,
};

pond = FilePond.create(inputElement, {
  onaddfile: (error, file) => {
    if (!error) {
      uploadStats.totalFiles++;
      uploadStats.totalSize += file.fileSize;
      if (!uploadStats.startTime) {
        uploadStats.startTime = Date.now();
      }
    }
  },

  onprocessfile: (error, file) => {
    if (error) {
      uploadStats.failedFiles++;
    } else {
      uploadStats.uploadedFiles++;
      uploadStats.uploadedSize += file.fileSize;
    }

    // Verificar si terminaron todos
    if (
      uploadStats.uploadedFiles + uploadStats.failedFiles ===
      uploadStats.totalFiles
    ) {
      uploadStats.endTime = Date.now();
      const duration = (uploadStats.endTime - uploadStats.startTime) / 1000;
      const speed = uploadStats.uploadedSize / duration / 1024; // KB/s

      console.log("📊 Estadísticas de upload:");
      console.log("   Total:", uploadStats.totalFiles);
      console.log("   Exitosos:", uploadStats.uploadedFiles);
      console.log("   Fallidos:", uploadStats.failedFiles);
      console.log("   Tamaño total:", formatFileSize(uploadStats.totalSize));
      console.log("   Duración:", duration.toFixed(2), "segundos");
      console.log("   Velocidad:", speed.toFixed(2), "KB/s");
    }
  },
});
```

---

## 7. Integración con Backend

### Enviar Metadata Personalizada

```javascript
pond = FilePond.create(inputElement, {
  server: {
    url: window.ENV_CONFIG.BACKEND_URL,
    process: {
      url: "/routes/files/upload_file.php",
      method: "POST",
      withCredentials: true,

      // Headers personalizados
      headers: {
        "X-Upload-Source": "filepond",
        "X-Client-Version": "1.0.0",
      },

      // Timeout
      timeout: 300000, // 5 minutos

      // Callback antes de enviar
      ondata: (formData) => {
        // Agregar campos adicionales
        formData.append("timestamp", Date.now());
        formData.append(
          "timezone",
          Intl.DateTimeFormat().resolvedOptions().timeZone
        );
        formData.append("language", navigator.language);
        return formData;
      },

      // Callback al recibir respuesta
      onload: (response) => {
        const data = JSON.parse(response);

        if (data.status === "success") {
          console.log("✅ Archivo subido:", data.file_data);

          // Guardar en localStorage
          const recentFiles = JSON.parse(
            localStorage.getItem("recentFiles") || "[]"
          );
          recentFiles.unshift(data.file_data);
          localStorage.setItem(
            "recentFiles",
            JSON.stringify(recentFiles.slice(0, 10))
          );

          // Notificar
          notyf.success(`${data.file_data.file_name} subido correctamente`);
        } else {
          console.error("❌ Error:", data.message);
          notyf.error(data.message);
        }

        return response;
      },

      // Callback en error
      onerror: (response) => {
        console.error("❌ Error HTTP:", response);

        try {
          const data = JSON.parse(response);
          notyf.error(data.message || "Error al subir el archivo");
        } catch (e) {
          notyf.error("Error de conexión con el servidor");
        }

        return response;
      },
    },
  },

  // Metadata del archivo
  fileMetadataObject: {
    user_id: currentUserId,
    folder_id: currentFolder === "root" ? null : currentFolder,
    description: "",
    is_shared: false,
    tags: [],
    category: "general",
  },
});

// Actualizar metadata desde formulario
document
  .getElementById("uploadDescription")
  ?.addEventListener("change", function () {
    pond.setOptions({
      fileMetadataObject: {
        ...pond.getOptions().fileMetadataObject,
        description: this.value,
      },
    });
  });
```

### Chunked Upload (Archivos Grandes)

```javascript
pond = FilePond.create(inputElement, {
  server: {
    url: window.ENV_CONFIG.BACKEND_URL,
    process: {
      url: "/routes/files/upload_chunk.php",
      method: "POST",
      withCredentials: true,

      // Configuración de chunks
      chunkUploads: true,
      chunkSize: 5000000, // 5MB por chunk
      chunkRetryDelays: [500, 1000, 3000],

      ondata: (formData) => {
        // Agregar info del chunk
        const file = formData.get("file");
        const chunk = formData.get("chunk");
        const chunks = formData.get("chunks");

        formData.append("chunk_index", chunk);
        formData.append("total_chunks", chunks);
        formData.append("original_name", file.name);

        return formData;
      },
    },
  },
});
```

### Retry en Caso de Error

```javascript
pond = FilePond.create(inputElement, {
  server: {
    process: {
      url: "/routes/files/upload_file.php",
      method: "POST",
      withCredentials: true,

      // Reintentos automáticos
      retryDelays: [1000, 2000, 3000, 5000],

      onerror: (response, retryCount) => {
        console.log(`❌ Error (intento ${retryCount + 1}):`, response);

        if (retryCount >= 3) {
          notyf.error("Error al subir el archivo después de varios intentos");
          return false; // No reintentar más
        }

        notyf.info(`Reintentando... (${retryCount + 1}/4)`);
        return true; // Reintentar
      },
    },
  },
});
```

---

## 🎯 Conclusión

FilePond es extremadamente personalizable. Estos ejemplos cubren los casos de uso más comunes, pero puedes combinarlos y modificarlos según tus necesidades específicas.

**Recursos adicionales:**

- [FilePond Docs](https://pqina.nl/filepond/docs/)
- [FilePond API Reference](https://pqina.nl/filepond/docs/api/instance/)
- [FilePond Plugins](https://pqina.nl/filepond/docs/plugins/)

---

**Última actualización**: Noviembre 2025  
**Versión**: 1.0  
**Mantenido por**: Roepard Labs Development Team
