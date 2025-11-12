# 📷 Sistema de Foto de Perfil - HomeLab AR

## 📋 Resumen Ejecutivo

Sistema completo de subida, visualización y eliminación de fotos de perfil con FilePond, similar a la funcionalidad de `files.page.php`.

**Fecha**: 6 de Noviembre, 2025  
**Características**:

- ✅ Subida de imágenes con FilePond
- ✅ Máximo 5MB por imagen
- ✅ Crop y resize automático (400x400px)
- ✅ Formatos: JPG, PNG, GIF, WEBP
- ✅ Imagen por defecto al crear usuario
- ✅ Eliminación de foto personalizada

---

## 🏗️ Arquitectura del Sistema

### Flujo Completo

```
Usuario selecciona imagen en FilePond
    ↓
Cliente valida: tamaño, formato, dimensiones
    ↓
FilePond procesa: crop 1:1, resize 400x400px
    ↓
FormData enviado a /routes/profile/upload_picture.php
    ↓
Backend valida: MIME type, extensión, tamaño
    ↓
Genera nombre único: profile_{user_id}_{timestamp}.{ext}
    ↓
Guarda en /uploads/profiles/profile_4_1730918400.jpg
    ↓
Elimina foto anterior (si existe y no es default)
    ↓
Actualiza users.profile_picture en BD
    ↓
Respuesta JSON con nueva ruta
    ↓
Frontend actualiza UI inmediatamente
```

---

## 🎯 Componentes Implementados

### 1️⃣ Backend

#### **upload_picture.php** - Subir/Actualizar Foto

**Ruta**: `POST /routes/profile/upload_picture.php`

**Validaciones**:

- ✅ Usuario autenticado (Auth::checkAuth())
- ✅ Usuario activo (Status::checkStatus(1))
- ✅ Archivo recibido correctamente
- ✅ Tamaño máximo: 5MB
- ✅ MIME type válido: image/jpeg, image/png, image/gif, image/webp
- ✅ Extensión permitida: jpg, jpeg, png, gif, webp

**Proceso**:

1. Verificar upload sin errores
2. Validar tamaño y formato
3. Crear directorio `/uploads/profiles/` si no existe
4. Obtener foto anterior de BD
5. Generar nombre único: `profile_{user_id}_{timestamp}.{ext}`
6. Mover archivo a carpeta de uploads
7. Actualizar `profile_picture` en tabla `users`
8. Eliminar foto anterior (si no es default)
9. Responder con ruta de nueva imagen

**Response JSON**:

```json
{
  "status": "success",
  "message": "Foto de perfil actualizada exitosamente",
  "data": {
    "profile_picture": "/uploads/profiles/profile_4_1730918400.jpg",
    "file_name": "profile_4_1730918400.jpg",
    "file_size": 245678,
    "mime_type": "image/jpeg"
  }
}
```

#### **delete_picture.php** - Eliminar Foto

**Ruta**: `DELETE /routes/profile/delete_picture.php`

**Validaciones**:

- ✅ Usuario autenticado
- ✅ Usuario activo
- ✅ Tiene foto personalizada (no default)

**Proceso**:

1. Obtener `profile_picture` actual de BD
2. Verificar que no sea `/assets/img/default-avatar.png`
3. Actualizar BD con ruta default
4. Eliminar archivo físico
5. Responder confirmación

**Response JSON**:

```json
{
  "status": "success",
  "message": "Foto de perfil eliminada exitosamente",
  "data": {
    "profile_picture": "/assets/img/default-avatar.png"
  }
}
```

#### **det_user.php** - Ya Incluye profile_picture

El endpoint `GET /routes/profile/det_user.php` ya devuelve:

```json
{
  "status": "success",
  "data": {
    "user_id": 4,
    "profile_picture": "/uploads/profiles/profile_4_1730918400.jpg"
    // ... otros campos
  }
}
```

#### **RegisterService.php** - Foto Default al Registrar

Al crear un usuario nuevo, se asigna automáticamente:

```php
':profile_picture' => '/assets/img/default-avatar.png'
```

---

### 2️⃣ Frontend

#### **profile.page.php** - UI Completa

**HTML - Avatar Container**:

```html
<div id="profileAvatarContainer" class="avatar-xl bg-primary rounded-circle">
  <!-- Imagen de perfil (oculta si es default) -->
  <img
    id="profileAvatarImg"
    src="/assets/img/default-avatar.png"
    class="w-100 h-100 object-fit-cover"
    style="display: none;"
  />

  <!-- Icono por defecto (visible si no hay imagen) -->
  <i
    id="profileAvatarIcon"
    class="bx bx-user text-white"
    style="font-size: 60px;"
  ></i>
</div>

<!-- Botón para cambiar foto -->
<button data-bs-toggle="modal" data-bs-target="#uploadProfilePictureModal">
  <i class="bx bx-camera"></i>
</button>

<!-- Botón para eliminar foto (oculto si es default) -->
<button
  id="deleteProfilePictureBtn"
  class="btn btn-outline-danger btn-sm mt-2 d-none"
>
  <i class="bx bx-trash me-1"></i> Eliminar foto
</button>
```

**Modal con FilePond**:

```html
<div class="modal fade" id="uploadProfilePictureModal">
  <div class="modal-content">
    <div class="modal-header">
      <h5>
        <i class="bx bx-image-add me-2 text-primary"></i> Cambiar Foto de Perfil
      </h5>
    </div>
    <div class="modal-body">
      <div class="alert alert-info">
        Requisitos: Máximo 5MB. Formatos: JPG, PNG, GIF, WEBP.
      </div>

      <!-- FilePond Input -->
      <input type="file" id="profilePictureFilePond" accept="image/*" />
    </div>
    <div class="modal-footer">
      <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
        Cancelar
      </button>
      <button
        type="button"
        class="btn btn-primary"
        id="uploadProfilePictureBtn"
        disabled
      >
        <i class="bx bx-upload me-1"></i> Subir Foto
      </button>
    </div>
  </div>
</div>
```

**JavaScript - Funciones Principales**:

1. **updateProfilePicture()** - Actualizar UI

```javascript
function updateProfilePicture(profilePicture) {
  const avatarImg = document.getElementById("profileAvatarImg");
  const avatarIcon = document.getElementById("profileAvatarIcon");
  const deleteBtn = document.getElementById("deleteProfilePictureBtn");

  if (!profilePicture || profilePicture === "/assets/img/default-avatar.png") {
    // Mostrar icono por defecto
    avatarImg.style.display = "none";
    avatarIcon.style.display = "block";
    deleteBtn?.classList.add("d-none");
  } else {
    // Mostrar imagen personalizada
    avatarImg.src = profilePicture;
    avatarImg.style.display = "block";
    avatarIcon.style.display = "none";
    deleteBtn?.classList.remove("d-none");
  }
}
```

2. **initFilePond()** - Configurar FilePond

```javascript
function initFilePond() {
  FilePond.registerPlugin(
    FilePondPluginFileValidateType,
    FilePondPluginFileValidateSize,
    FilePondPluginImagePreview,
    FilePondPluginImageCrop,
    FilePondPluginImageResize,
    FilePondPluginImageTransform,
    FilePondPluginImageExifOrientation
  );

  profilePicturePond = FilePond.create(inputElement, {
    acceptedFileTypes: [
      "image/jpeg",
      "image/jpg",
      "image/png",
      "image/gif",
      "image/webp",
    ],
    maxFileSize: "5MB",
    maxFiles: 1,
    imageCropAspectRatio: "1:1",
    imageResizeTargetWidth: 400,
    imageResizeTargetHeight: 400,
    imageResizeMode: "cover",
    imageTransformOutputQuality: 90,
    // ... más configuración
  });
}
```

3. **uploadProfilePicture()** - Subir Imagen

```javascript
async function uploadProfilePicture() {
  const files = profilePicturePond.getFiles();
  const file = files[0].file;

  const formData = new FormData();
  formData.append("profile_picture", file);

  const response = await window.AppRouter.upload(
    "/routes/profile/upload_picture.php",
    formData
  );

  if (response.status === "success") {
    getNotyf().success("Foto de perfil actualizada exitosamente");
    updateProfilePicture(response.data.profile_picture);
    profilePicturePond.removeFiles();
    modal.hide();
    await loadUserData(); // Recargar datos completos
  }
}
```

4. **deleteProfilePicture()** - Eliminar Imagen

```javascript
async function deleteProfilePicture() {
  const result = await Swal.fire({
    title: "¿Eliminar foto de perfil?",
    text: "Tu foto será reemplazada por la imagen por defecto",
    icon: "warning",
    showCancelButton: true,
    confirmButtonText: "Sí, eliminar",
  });

  if (!result.isConfirmed) return;

  const response = await window.AppRouter.delete(
    "/routes/profile/delete_picture.php"
  );

  if (response.status === "success") {
    getNotyf().success("Foto de perfil eliminada exitosamente");
    updateProfilePicture(response.data.profile_picture);
    await loadUserData();
  }
}
```

---

## 🎨 CSS Implementado

```css
/* Avatar container */
#profileAvatarContainer {
  position: relative;
  border: 3px solid rgba(var(--bs-primary-rgb), 0.2);
}

#profileAvatarImg {
  object-fit: cover;
  object-position: center;
}

#profileAvatarContainer:hover {
  border-color: var(--bs-primary);
  transform: scale(1.05);
  transition: all 0.3s ease;
}

/* FilePond customization */
#uploadProfilePictureModal .filepond--root {
  margin-bottom: 0;
}

#uploadProfilePictureModal .filepond--drop-label {
  min-height: 200px;
}
```

---

## 📁 Estructura de Archivos

```
/thepearlo_vr-backend/
├── routes/
│   └── profile/
│       ├── upload_picture.php  ✅ NUEVO - Subir foto
│       ├── delete_picture.php  ✅ NUEVO - Eliminar foto
│       ├── det_user.php        ✅ YA INCLUYE profile_picture
│       └── up_user.php         ✅ Sin cambios
├── services/
│   └── RegisterService.php     ✅ ACTUALIZADO - Default al registrar
├── uploads/
│   └── profiles/               ✅ NUEVO - Carpeta de fotos
│       └── profile_4_1730918400.jpg
└── models/
    └── UserRegister.php        ✅ Sin cambios

/thepearlo_vr-website/
├── assets/
│   └── img/
│       └── default-avatar.png  ✅ REQUERIDO - Imagen por defecto
└── pages/
    └── profile.page.php        ✅ ACTUALIZADO - UI completa con FilePond
```

---

## 🧪 Testing del Sistema

### Test 1: Subir Nueva Foto de Perfil

**Acción**:

1. Navegar a `/dashboard/profile`
2. Click en botón de cámara (esquina inferior derecha del avatar)
3. Modal se abre con FilePond
4. Arrastrar imagen JPG de 2MB
5. FilePond procesa: crop 1:1, resize 400x400
6. Click en "Subir Foto"

**Esperado**:

```javascript
// Console
📷 Imagen agregada: mi-foto.jpg
📤 Subiendo foto de perfil: mi-foto.jpg
✅ Foto de perfil actualizada: {profile_picture: "/uploads/profiles/profile_4_1730918400.jpg", ...}
� Cargando datos completos del perfil...
✅ Perfil completo cargado: {...}
```

**UI**:

- ✅ Toast verde: "Foto de perfil actualizada exitosamente"
- ✅ Modal se cierra automáticamente
- ✅ Avatar muestra nueva imagen
- ✅ Botón "Eliminar foto" se hace visible
- ✅ FilePond se limpia (sin archivos)

**Base de Datos**:

```sql
SELECT profile_picture FROM users WHERE user_id = 4;
-- Resultado: /uploads/profiles/profile_4_1730918400.jpg
```

**Archivos**:

```bash
ls -lh /uploads/profiles/
# profile_4_1730918400.jpg (aprox. 150KB después de optimización)
```

---

### Test 2: Eliminar Foto Personalizada

**Acción**:

1. Usuario con foto personalizada
2. Click en "Eliminar foto" (botón rojo bajo avatar)
3. SweetAlert2 confirma: "¿Eliminar foto de perfil?"
4. Click en "Sí, eliminar"

**Esperado**:

```javascript
// Console
🗑️ Eliminando foto de perfil...
✅ Foto de perfil eliminada
� Cargando datos completos del perfil...
```

**UI**:

- ✅ Toast verde: "Foto de perfil eliminada exitosamente"
- ✅ Avatar vuelve a mostrar icono por defecto
- ✅ Botón "Eliminar foto" se oculta

**Base de Datos**:

```sql
SELECT profile_picture FROM users WHERE user_id = 4;
-- Resultado: /assets/img/default-avatar.png
```

**Archivos**:

```bash
# Archivo anterior fue eliminado
ls -lh /uploads/profiles/
# (vacío o sin archivo del usuario)
```

---

### Test 3: Validación de Tamaño (>5MB)

**Acción**:

1. Intentar subir imagen de 8MB

**Esperado**:

```javascript
// Console
⚠️ FilePond: Archivo muy grande
```

**UI**:

- ❌ FilePond muestra error: "Archivo muy grande. Tamaño máximo: 5MB"
- ❌ Botón "Subir Foto" permanece deshabilitado
- ❌ No se envía request al backend

---

### Test 4: Validación de Formato (PDF)

**Acción**:

1. Intentar subir archivo PDF

**Esperado**:

```javascript
// Console
⚠️ FilePond: Tipo de archivo no permitido
```

**UI**:

- ❌ FilePond muestra error: "Tipo de archivo no permitido. Permitidos: image/jpeg, image/png, image/gif, image/webp"
- ❌ Botón "Subir Foto" permanece deshabilitado

---

### Test 5: Usuario Nuevo (Sin Foto)

**Acción**:

1. Crear usuario nuevo con `reg_user.php`
2. Login con nuevo usuario
3. Navegar a `/dashboard/profile`

**Esperado**:

```javascript
// Console
✅ Perfil completo cargado: {profile_picture: "/assets/img/default-avatar.png", ...}
```

**UI**:

- ✅ Avatar muestra icono por defecto (bx-user)
- ✅ Botón "Eliminar foto" está oculto
- ✅ Botón de cámara disponible para subir primera foto

**Base de Datos**:

```sql
SELECT profile_picture FROM users WHERE user_id = {nuevo_id};
-- Resultado: /assets/img/default-avatar.png (asignado al crear usuario)
```

---

### Test 6: Reemplazo de Foto Existente

**Acción**:

1. Usuario con foto: `profile_4_1730918400.jpg`
2. Subir nueva foto: `nueva-foto.png`

**Esperado Backend**:

```php
// Backend detecta foto anterior
$oldPicture = '/uploads/profiles/profile_4_1730918400.jpg';

// Guarda nueva foto
$filePath = '/uploads/profiles/profile_4_1730920000.png';

// Actualiza BD
UPDATE users SET profile_picture = '/uploads/profiles/profile_4_1730920000.png' WHERE user_id = 4;

// Elimina foto anterior
unlink('/uploads/profiles/profile_4_1730918400.jpg');
```

**Archivos**:

```bash
# Antes
ls /uploads/profiles/
profile_4_1730918400.jpg

# Después
ls /uploads/profiles/
profile_4_1730920000.png  # Nueva foto, anterior eliminada
```

---

## 🔒 Seguridad Implementada

### 1. Validación de Autenticación

```php
// Middleware Auth y Status
Auth::checkAuth();           // Usuario logueado
Status::checkStatus(1);      // Usuario activo
$userId = $_SESSION['user_id']; // Solo modifica su propia foto
```

### 2. Validación de Archivos

```php
// Tipo MIME real (no confía en extensión)
$finfo = finfo_open(FILEINFO_MIME_TYPE);
$mimeType = finfo_file($finfo, $file['tmp_name']);

if (!in_array($mimeType, $allowedTypes)) {
    throw new Exception("Formato de imagen no permitido");
}
```

### 3. Tamaño Máximo

```php
$maxFileSize = 5 * 1024 * 1024; // 5MB
if ($file['size'] > $maxFileSize) {
    throw new Exception("La imagen excede el tamaño máximo de 5MB");
}
```

### 4. Nombres de Archivo Únicos

```php
// Evita colisiones y ataques de path traversal
$fileName = 'profile_' . $userId . '_' . time() . '.' . $extension;
// Resultado: profile_4_1730918400.jpg
```

### 5. Directorio Aislado

```php
// Solo uploads/profiles/, no puede acceder a otras rutas
$uploadDir = __DIR__ . '/../../uploads/profiles/';
```

### 6. Eliminación Segura de Fotos Anteriores

```php
// Solo elimina si no es default
if ($oldPicture && $oldPicture !== '/assets/img/default-avatar.png') {
    $oldFilePath = __DIR__ . '/../../' . ltrim($oldPicture, '/');
    if (file_exists($oldFilePath)) {
        unlink($oldFilePath);
    }
}
```

---

## 📊 Flujo de Datos Completo

### Upload Flow

```
Usuario selecciona imagen
    ↓
FilePond valida localmente:
    - Formato: image/*
    - Tamaño: ≤5MB
    ↓
FilePond procesa:
    - Crop: 1:1 aspect ratio
    - Resize: 400x400px
    - Quality: 90%
    ↓
FormData generado:
    profile_picture: (binary data)
    ↓
POST /routes/profile/upload_picture.php
    Headers: Content-Type: multipart/form-data
    ↓
Backend valida:
    - Auth: Usuario logueado
    - Status: Usuario activo
    - File: Subido sin errores
    - MIME: image/jpeg|png|gif|webp
    - Size: ≤5MB
    - Extension: jpg|jpeg|png|gif|webp
    ↓
Backend procesa:
    1. Generar nombre único
    2. Mover a /uploads/profiles/
    3. Obtener foto anterior de BD
    4. UPDATE users SET profile_picture
    5. Eliminar foto anterior
    ↓
Response JSON:
    {
      "status": "success",
      "data": {
        "profile_picture": "/uploads/profiles/profile_4_xxx.jpg"
      }
    }
    ↓
Frontend actualiza:
    - Avatar img.src
    - Oculta icono, muestra imagen
    - Muestra botón "Eliminar"
    - Toast success
    - Cierra modal
    - Recarga datos completos
```

---

## 🛠️ Configuración de FilePond

### Plugins Utilizados

```javascript
FilePond.registerPlugin(
  FilePondPluginFileValidateType, // Validar MIME type
  FilePondPluginFileValidateSize, // Validar tamaño
  FilePondPluginImagePreview, // Preview de imagen
  FilePondPluginImageCrop, // Crop de imagen
  FilePondPluginImageResize, // Resize de imagen
  FilePondPluginImageTransform, // Transformaciones
  FilePondPluginImageExifOrientation // Corregir orientación
);
```

### Configuración Crítica

```javascript
{
    acceptedFileTypes: ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'],
    maxFileSize: '5MB',
    maxFiles: 1,
    allowMultiple: false,

    // Crop cuadrado perfecto
    imageCropAspectRatio: '1:1',

    // Resize a dimensiones estándar
    imageResizeTargetWidth: 400,
    imageResizeTargetHeight: 400,
    imageResizeMode: 'cover',

    // Calidad de compresión
    imageTransformOutputQuality: 90,

    // UI compacta para modal
    stylePanelLayout: 'compact'
}
```

---

## 🚀 Mejoras Futuras Sugeridas

### 1. Detección de Caras con AI

```javascript
// Implementar detección de caras para auto-crop centrado
imageTransformBeforeCreateBlob: (canvas) => {
  return new Promise((resolve) => {
    faceDetectionAPI(canvas).then((faces) => {
      if (faces.length > 0) {
        // Auto-crop centrado en cara detectada
        cropToFace(canvas, faces[0]);
      }
      resolve(canvas);
    });
  });
};
```

### 2. Múltiples Tamaños (Thumbnails)

```php
// Generar múltiples versiones al subir
$sizes = [
    'thumb' => 100,   // Thumbnails pequeños
    'medium' => 400,  // Avatar normal
    'large' => 800    // Perfil completo
];

foreach ($sizes as $size => $dimension) {
    $resized = resizeImage($file, $dimension);
    saveImage($resized, "profile_{$userId}_{$size}.jpg");
}
```

### 3. CDN Integration

```php
// Subir a CDN después de guardar localmente
$cdnUrl = uploadToCDN($filePath);
$relativePath = $cdnUrl; // Usar URL de CDN en BD
```

### 4. Caché de Imágenes

```html
<!-- Agregar cache-busting para actualizaciones inmediatas -->
<img :src="profilePicture + '?v=' + Date.now()" />
```

### 5. WebP Automático

```php
// Convertir todas las imágenes a WebP para mejor compresión
if (function_exists('imagewebp')) {
    $webpPath = str_replace($extension, 'webp', $filePath);
    imagewebp($image, $webpPath, 90);
    $relativePath = str_replace($extension, 'webp', $relativePath);
}
```

---

## 📞 Soporte y Contacto

Para dudas sobre el sistema de fotos de perfil:

1. Revisar este documento
2. Verificar implementación en `profile.page.php`
3. Consultar endpoints en `/routes/profile/`
4. Testing con `curl` o Postman
5. Contactar al equipo de desarrollo

---

## ✅ Checklist de Implementación

### Backend

- [x] Endpoint `upload_picture.php` creado
- [x] Endpoint `delete_picture.php` creado
- [x] Validación de tamaño (5MB)
- [x] Validación de formato (MIME type real)
- [x] Generación de nombres únicos
- [x] Eliminación de fotos anteriores
- [x] Directorio `/uploads/profiles/` creado
- [x] RegisterService actualizado con default
- [x] det_user.php ya incluye profile_picture

### Frontend

- [x] UI de avatar actualizada
- [x] Modal de upload con FilePond
- [x] Configuración de FilePond completa
- [x] Función `uploadProfilePicture()` implementada
- [x] Función `deleteProfilePicture()` implementada
- [x] Función `updateProfilePicture()` implementada
- [x] Event listeners configurados
- [x] CSS para avatar y modal
- [x] Integración con Notyf y SweetAlert2

### Testing

- [x] Test de subida exitosa
- [x] Test de eliminación
- [x] Test de validación de tamaño
- [x] Test de validación de formato
- [x] Test de usuario nuevo (default)
- [x] Test de reemplazo de foto

### Documentación

- [x] Este documento completo
- [x] Ejemplos de uso
- [x] Casos de prueba
- [x] Guía de seguridad

---

**Última actualización**: Noviembre 6, 2025  
**Versión**: 1.0  
**Mantenido por**: Roepard Labs Development Team
