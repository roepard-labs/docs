# 🎨 Mejoras UI - HomeLab VR Dashboard Page

## 📋 Cambios Implementados

### 1. ✅ **Selección Activa en Sidebar**

**Problema anterior:**

- Cuando navegabas a `/dashboard/homelab`, el enlace no se resaltaba como activo

**Solución:**

- Agregada lógica en `highlightActivePage()` para detectar la ruta `/dashboard/homelab`
- El enlace "HomeLab VR" ahora se marca con clase `.active` cuando estás en esa página

**Archivo modificado:** `/ui/sidebar.ui.php`

```javascript
} else if (currentPath.includes('/dashboard/homelab')) {
    activePage = 'homelab';
} else if (currentPath.includes('/dashboard/users')) {
```

---

### 2. ✅ **Reorganización: "Tu Sesión" con Foto de Perfil**

**Diseño anterior:**

```
┌─────────────────────────────────────┐
│ Tu Sesión                           │
├─────────────────────────────────────┤
│ [Info del Usuario] | [Botón Entrar]│
└─────────────────────────────────────┘
```

**Diseño nuevo:**

```
┌──────────────────────────────────────────────────┐
│ Tu Sesión                                        │
├──────────────────────────────────────────────────┤
│ ┌────┐  Nombre                | ┌─────────┐     │
│ │Foto│  Rol                    │ [Icono  ]│     │
│ │    │  Usuario                │  VR     │     │
│ └────┘  Email                  │ Exp. VR │     │
│                                 │ [Entrar]│     │
│                                 └─────────┘     │
└──────────────────────────────────────────────────┘
```

**Características:**

- ✅ Foto de perfil circular (100px × 100px en desktop, 80px en móvil)
- ✅ Borde de color primario con sombra elegante
- ✅ Efecto hover: escala 1.05 y cambia borde a color info
- ✅ La foto se carga desde el backend automáticamente
- ✅ Fallback a avatar por defecto si la imagen falla
- ✅ Información del usuario alineada verticalmente junto a la foto
- ✅ Sección "Experiencia VR" en la columna derecha

---

### 3. ✅ **Carga Dinámica de Foto de Perfil**

**JavaScript agregado:**

```javascript
// Actualizar foto de perfil
const profilePictureContainer = document.querySelector(
  "#userProfilePicture img"
);
if (profilePictureContainer && userData.profile_picture) {
  const backendUrl = window.ENV_CONFIG?.BACKEND_URL || "http://localhost:3000";
  profilePictureContainer.src = `${backendUrl}${userData.profile_picture}`;
  profilePictureContainer.onerror = function () {
    // Si la imagen falla, usar avatar por defecto
    this.src = "/assets/icons/user-default.png";
  };
  console.log("✅ Foto de perfil actualizada:", userData.profile_picture);
}
```

**Flujo:**

1. Se obtienen datos del usuario desde `/routes/user/check_session.php`
2. Si existe `userData.profile_picture`, se construye la URL completa
3. Se actualiza el `src` de la imagen
4. Si falla la carga, se usa el avatar por defecto

---

### 4. ✅ **Estilos CSS Agregados**

```css
/* Profile Picture */
.profile-picture-wrapper {
  position: relative;
}

.profile-picture {
  position: relative;
  transition: all 0.3s ease;
}

.profile-picture:hover {
  transform: scale(1.05);
}

.profile-picture img {
  transition: all 0.3s ease;
}

.profile-picture:hover img {
  border-color: var(--bs-info) !important;
}
```

**Efectos:**

- Transición suave en hover
- Escala aumenta ligeramente (1.05)
- Borde cambia de color primario a info

---

### 5. ✅ **Responsive Design Mejorado**

**Desktop (≥768px):**

- Foto de perfil: 100px × 100px
- Layout horizontal: Foto + Info | Experiencia VR

**Mobile (<768px):**

- Foto de perfil: 80px × 80px
- Layout vertical: Foto centrada, info centrada
- Toda la información alineada al centro

```css
@media (max-width: 767.98px) {
  /* Profile picture más pequeña en móvil */
  .profile-picture img {
    width: 80px !important;
    height: 80px !important;
  }

  /* Alinear info de sesión en móvil */
  .d-flex.gap-4 {
    flex-direction: column;
    align-items: center !important;
    text-align: center;
  }

  .session-info {
    text-align: center;
  }
}
```

---

## 📁 Archivos Modificados

### 1. `/ui/sidebar.ui.php`

**Líneas modificadas:** ~888-900

**Cambio:**

```javascript
// ANTES:
if (currentPath === '/dashboard') {
    activePage = 'dashboard';
} else if (currentPath.includes('/dashboard/users')) {

// DESPUÉS:
if (currentPath === '/dashboard') {
    activePage = 'dashboard';
} else if (currentPath.includes('/dashboard/homelab')) {
    activePage = 'homelab';
} else if (currentPath.includes('/dashboard/users')) {
```

---

### 2. `/pages/homelab.page.php`

**Cambios realizados:**

#### A. Estructura HTML (líneas ~120-162)

- Agregado `<div class="profile-picture-wrapper">`
- Agregado `<img>` para foto de perfil
- Reorganizado layout con flexbox
- Agregado `align-items-center` al row

#### B. Estilos CSS (líneas ~333-351)

- Agregados estilos para `.profile-picture-wrapper`
- Agregados estilos para `.profile-picture`
- Agregados efectos hover
- Agregados estilos responsive

#### C. JavaScript (líneas ~490-504)

- Agregada lógica para cargar foto de perfil
- Agregado fallback a avatar por defecto
- Agregado manejo de errores de carga

---

## 🧪 Testing

### Verificar Sidebar Activo

1. Navegar a http://localhost:9000/dashboard/homelab
2. Verificar que "HomeLab VR" en sidebar tiene clase `.active`
3. Verificar que el enlace tiene estilo resaltado

**Resultado esperado:**

```css
.sidebar-link.active {
  background-color: var(--bs-primary);
  color: white;
}
```

### Verificar Foto de Perfil

1. Navegar a /dashboard/homelab
2. Abrir consola del navegador
3. Buscar log: `✅ Foto de perfil actualizada:`
4. Verificar que la imagen se carga correctamente

**Verificación en consola:**

```javascript
// Verificar que la imagen se cargó
document.querySelector("#userProfilePicture img").src;
// Debe mostrar: "http://localhost:3000/uploads/profiles/..."
```

### Verificar Responsive

1. Abrir DevTools (F12)
2. Toggle device toolbar (Ctrl+Shift+M)
3. Probar en:
   - Desktop (1920px)
   - Tablet (768px)
   - Mobile (375px)

**Resultado esperado:**

- Desktop: Layout horizontal, foto 100px
- Mobile: Layout vertical centrado, foto 80px

---

## 🎨 Visual Preview

### Desktop View

```
┌─────────────────────────────────────────────────────────────────┐
│ 🥽 ThePearlOS                                     [v1.0.0-beta] │
├─────────────────────────────────────────────────────────────────┤
│ [Apps: 24] [Usuarios: 12] [Status: ✅] [Uptime: 99.9%]         │
├─────────────────────────────────────────────────────────────────┤
│ ┌────────────────────────────────────────┐  ┌─────────────────┐ │
│ │ Tu Sesión                              │  │ Ayuda           │ │
│ ├────────────────────────────────────────┤  ├─────────────────┤ │
│ │ ┌────┐  Nombre      │ ┌──────────┐    │  │ • Audífonos     │ │
│ │ │ 👤 │  Rol         │ │   🥽     │    │  │ • Iluminación   │ │
│ │ │    │  Usuario     │ │  VR Exp  │    │  │ • Cámara        │ │
│ │ └────┘  Email       │ │ [Entrar] │    │  │ • Chrome/FF     │ │
│ │                     │ └──────────┘    │  └─────────────────┘ │
│ └────────────────────────────────────────┘  ┌─────────────────┐ │
│                                             │ Información     │ │
│                                             ├─────────────────┤ │
│                                             │ Version: 1.0.0  │ │
│                                             │ Repo: GitHub    │ │
│                                             │ [Diagnóstico]   │ │
│                                             └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### Mobile View

```
┌──────────────────────────┐
│ 🥽 ThePearlOS           │
│      [v1.0.0-beta]       │
├──────────────────────────┤
│     [Apps: 24]           │
│     [Usuarios: 12]       │
│     [Status: ✅]         │
│     [Uptime: 99.9%]      │
├──────────────────────────┤
│ Tu Sesión                │
├──────────────────────────┤
│        ┌────┐            │
│        │ 👤 │            │
│        └────┘            │
│     Nombre               │
│     Rol                  │
│     Usuario              │
│     Email                │
│                          │
│       ┌───────┐          │
│       │  🥽   │          │
│       │VR Exp │          │
│       │[Entrar]│         │
│       └───────┘          │
├──────────────────────────┤
│ Ayuda                    │
│ • Audífonos              │
│ • Iluminación            │
├──────────────────────────┤
│ Información              │
│ Version: 1.0.0           │
│ [Diagnóstico]            │
└──────────────────────────┘
```

---

## 🔄 Integración con Backend

### Endpoint Usado

```
GET /routes/user/check_session.php
```

### Response Esperado

```json
{
  "logged": true,
  "user_data": {
    "user_id": 1,
    "first_name": "Juan",
    "last_name": "Pérez",
    "username": "juanperez",
    "email": "juan@example.com",
    "role_id": 2,
    "profile_picture": "/uploads/profiles/user-1/profile.jpg"
  }
}
```

### Construcción de URL de Imagen

```javascript
const backendUrl = "http://localhost:3000"; // o api.roepard.online
const profilePictureUrl = `${backendUrl}${userData.profile_picture}`;
// Resultado: http://localhost:3000/uploads/profiles/user-1/profile.jpg
```

---

## 📊 Checklist de Verificación

- [x] Sidebar resalta "HomeLab VR" cuando estás en `/dashboard/homelab`
- [x] Foto de perfil se muestra en la sección "Tu Sesión"
- [x] Foto de perfil se carga desde backend
- [x] Fallback a avatar por defecto funciona
- [x] Información del usuario (nombre, rol, email) junto a la foto
- [x] Sección "Experiencia VR" junto a la información
- [x] Botón "Entrar a HomeLab" con animaciones
- [x] Efecto hover en foto de perfil
- [x] Responsive design en mobile
- [x] Foto más pequeña en mobile (80px)
- [x] Layout vertical centrado en mobile
- [x] Console logs informativos

---

## 🐛 Troubleshooting

### Problema: Sidebar no resalta HomeLab

**Solución:**

- Limpiar caché del navegador (Ctrl+Shift+R)
- Verificar que estás en la URL exacta: `/dashboard/homelab`

### Problema: Foto de perfil no carga

**Verificación:**

```javascript
// En consola
const userData = await window.AppRouter.get("/routes/user/check_session.php");
console.log("Profile picture:", userData.user_data.profile_picture);
```

**Posibles causas:**

- Backend no retorna `profile_picture`
- Ruta de imagen incorrecta
- CORS bloqueando la imagen

**Solución:**

- Verificar que el endpoint retorna `profile_picture`
- Verificar permisos de carpeta `/uploads/profiles/`
- Verificar configuración CORS del backend

### Problema: Imagen muestra avatar por defecto

**Causa:** La imagen no existe o la ruta es incorrecta

**Verificación:**

```bash
# Verificar que el archivo existe
curl -I http://localhost:3000/uploads/profiles/user-1/profile.jpg
```

---

## 🚀 Próximas Mejoras Sugeridas

### 1. **Upload de Foto Directamente desde HomeLab**

```html
<div class="profile-picture-wrapper">
  <input type="file" id="profilePictureUpload" style="display:none" />
  <button
    class="edit-profile-btn"
    onclick="document.getElementById('profilePictureUpload').click()"
  >
    <i class="bx bx-camera"></i>
  </button>
</div>
```

### 2. **Animación de Carga de Foto**

```css
.profile-picture img {
  opacity: 0;
  transition: opacity 0.5s ease;
}

.profile-picture img.loaded {
  opacity: 1;
}
```

### 3. **Badge de Estado en Foto**

```html
<div class="profile-picture">
  <img src="..." alt="Foto de perfil" />
  <span class="status-badge online"></span>
  <!-- Verde si está online -->
</div>
```

---

**Última actualización:** Noviembre 6, 2025  
**Versión:** 1.1.0  
**Autor:** Roepard Labs Development Team  
**Estado:** ✅ Implementado y Listo para Testing
