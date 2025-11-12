# 🎯 Integración Completa del Perfil con Backend

## 📋 Resumen de Implementación

Se ha completado la integración del perfil de usuario con los endpoints del backend, permitiendo cargar y actualizar datos completos incluyendo biografía, género y redes sociales.

**Fecha**: Noviembre 6, 2025  
**Endpoints utilizados**:

- GET `/routes/profile/det_user.php` - Obtener perfil completo
- PUT `/routes/profile/up_user.php` - Actualizar perfil

---

## 🔄 Cambios Realizados en `/pages/profile.page.php`

### 1. **Reorganización de Tabs** ✅

**Antes** (5 tabs):

```
Personal | Sesiones | Contacto | Social | Preferencias
```

**Después** (4 tabs):

```
Personal | Contacto | Social | Sesiones
```

**Eliminado**: Tab de "Preferencias" completo (no se usa en la funcionalidad actual)

---

### 2. **Tab Personal - Información Completa** 🆕

**Campos agregados**:

- ✅ **Nombre** (`first_name`) - Editable
- ✅ **Apellido** (`last_name`) - Editable
- ✅ **Biografía** (`bio`) - Textarea con contador de caracteres (0/255)
- ✅ **Género** (`gender_id`) - Select con 4 opciones:
  - 1: Prefiero no decirlo (default)
  - 2: Masculino
  - 3: Femenino
  - 4: Otro
- ✅ **Fecha de Nacimiento** (`birthdate`) - Date picker
- ✅ **País** (`country`) - Text input
- ✅ **Ciudad** (`city`) - Text input

**Form ID**: `personalForm`

**Ejemplo de datos**:

```json
{
  "first_name": "Juan Esteban",
  "last_name": "Manrique Giraldo",
  "bio": "Desarrollador full-stack apasionado por la realidad aumentada...",
  "gender_id": 2,
  "birthdate": "2007-09-10",
  "country": "Colombia",
  "city": "Manizales"
}
```

---

### 3. **Tab Contacto - Información de Contacto** 🆕

**Campos**:

- ✅ **Email** (`email`) - Readonly (no se puede cambiar desde perfil)
- ✅ **Teléfono** (`phone`) - Editable
- ✅ **Username** (`username`) - Readonly (no se puede cambiar)

**Form ID**: `contactForm`

**Ejemplo de datos**:

```json
{
  "email": "juane.manriqueg@autonoma.edu.co",
  "phone": "+573022748413",
  "username": "thisfeeling"
}
```

---

### 4. **Tab Social - Redes Sociales** 🆕

**Campos agregados**:

- ✅ **GitHub** (`github_username`) - Username de GitHub
- ✅ **LinkedIn** (`linkedin_username`) - Username de LinkedIn
- ✅ **Twitter/X** (`twitter_username`) - Username de Twitter
- ✅ **Discord** (`discord_tag`) - Tag completo (usuario#1234)
- ✅ **Sitio Web** (`personal_website`) - URL completa
- ✅ **Visibilidad** (`show_social_public`) - Checkbox para mostrar públicamente

**Form ID**: `socialForm`

**Ejemplo de datos**:

```json
{
  "social": {
    "github_username": "thisfeeling",
    "linkedin_username": "juanemanriqueg",
    "twitter_username": "thisfeeling_dev",
    "discord_tag": "thisfeeling#1234",
    "personal_website": "https://juanmanrique.dev",
    "show_social_public": true
  }
}
```

---

### 5. **Tab Sesiones - Sin Cambios** ✅

Mantiene la funcionalidad existente:

- Lista de sesiones activas
- Estadísticas (última actividad, dispositivos conectados)
- Botón para cerrar todas las sesiones
- Gestión individual de sesiones

---

## 🔧 Funciones JavaScript Implementadas

### 1. **loadUserData()** - Cargar Perfil Completo

```javascript
async function loadUserData() {
  const response = await window.AppRouter.get("/routes/profile/det_user.php");

  if (response && response.status === "success") {
    currentUserData = response.data;
    updateProfileUI(currentUserData);
    fillFormData(currentUserData);
  }
}
```

**Endpoint**: `GET /routes/profile/det_user.php`

**Respuesta esperada**:

```json
{
  "status": "success",
  "message": "Perfil del usuario obtenido exitosamente",
  "data": {
    "user_id": 4,
    "username": "thisfeeling",
    "email": "juane.manriqueg@autonoma.edu.co",
    "first_name": "Juan Esteban",
    "last_name": "Manrique Giraldo",
    "full_name": "Juan Esteban Manrique Giraldo",
    "phone": "+573022748413",
    "bio": "Desarrollador full-stack...",
    "gender_id": 2,
    "gender_name": "Masculino",
    "birthdate": "2007-09-10",
    "country": "Colombia",
    "city": "Manizales",
    "role_id": 2,
    "role_name": "admin",
    "status_id": 1,
    "status_name": "active",
    "profile_picture": "user_4.png",
    "social": {
      "github_username": "thisfeeling",
      "linkedin_username": "juanemanriqueg",
      "twitter_username": "thisfeeling_dev",
      "discord_tag": "thisfeeling#1234",
      "personal_website": "https://juanmanrique.dev",
      "show_social_public": true
    },
    "created_at": "2025-05-14 14:35:25",
    "updated_at": "2025-11-06 07:01:02"
  }
}
```

---

### 2. **fillFormData(userData)** - Llenar Formularios

```javascript
function fillFormData(userData) {
  // Tab Personal
  document.getElementById("firstName").value = userData.first_name || "";
  document.getElementById("lastName").value = userData.last_name || "";
  document.getElementById("bio").value = userData.bio || "";
  document.getElementById("gender").value = userData.gender_id || 1;
  document.getElementById("birthdate").value = userData.birthdate || "";
  document.getElementById("country").value = userData.country || "";
  document.getElementById("city").value = userData.city || "";
  updateBioCounter();

  // Tab Contacto
  document.getElementById("email").value = userData.email || "";
  document.getElementById("phone").value = userData.phone || "";
  document.getElementById("username").value = userData.username || "";

  // Tab Social
  if (userData.social) {
    document.getElementById("github").value =
      userData.social.github_username || "";
    document.getElementById("linkedin").value =
      userData.social.linkedin_username || "";
    document.getElementById("twitter").value =
      userData.social.twitter_username || "";
    document.getElementById("discord").value =
      userData.social.discord_tag || "";
    document.getElementById("website").value =
      userData.social.personal_website || "";
    document.getElementById("showSocialPublic").checked =
      userData.social.show_social_public || false;
  }
}
```

**Funcionalidad**: Llena automáticamente todos los formularios con los datos del usuario al cargar la página.

---

### 3. **updateBioCounter()** - Contador de Caracteres

```javascript
function updateBioCounter() {
  const bioInput = document.getElementById("bio");
  const bioCounter = document.getElementById("bioCounter");
  if (bioInput && bioCounter) {
    bioCounter.textContent = bioInput.value.length;
  }
}

// Event listener para actualizar en tiempo real
bioInput.addEventListener("input", updateBioCounter);
```

**Visual**: `<span id="bioCounter">0</span>/255 caracteres`

---

### 4. **Guardar Perfil - Botón Funcional** 💾

```javascript
document
  .getElementById("saveProfile")
  ?.addEventListener("click", async function () {
    const saveBtn = this;
    saveBtn.disabled = true;
    saveBtn.innerHTML =
      '<i class="bx bx-loader-alt bx-spin me-1"></i>Guardando...';

    try {
      // Recopilar datos de todos los formularios
      const profileData = {
        // Datos personales
        first_name: document.getElementById("firstName").value.trim(),
        last_name: document.getElementById("lastName").value.trim(),
        bio: document.getElementById("bio").value.trim(),
        gender_id: parseInt(document.getElementById("gender").value),
        birthdate: document.getElementById("birthdate").value,
        country: document.getElementById("country").value.trim(),
        city: document.getElementById("city").value.trim(),

        // Contacto
        phone: document.getElementById("phone").value.trim(),

        // Redes sociales
        social: {
          github_username: document.getElementById("github").value.trim(),
          linkedin_username: document.getElementById("linkedin").value.trim(),
          twitter_username: document.getElementById("twitter").value.trim(),
          discord_tag: document.getElementById("discord").value.trim(),
          personal_website: document.getElementById("website").value.trim(),
          show_social_public:
            document.getElementById("showSocialPublic").checked,
        },
      };

      console.log("📤 Enviando datos al backend:", profileData);

      // Enviar al backend
      const response = await window.AppRouter.put(
        "/routes/profile/up_user.php",
        profileData
      );

      if (response && response.status === "success") {
        notyf.success({
          message: `Perfil actualizado correctamente. ${response.data.total_updates} campo(s) modificado(s).`,
          duration: 5000,
        });

        // Recargar datos del perfil
        await loadUserData();

        // Actualizar header si cambió el nombre
        if (
          response.data.updated_fields.includes("first_name") ||
          response.data.updated_fields.includes("last_name")
        ) {
          console.log("🔄 Nombre actualizado, recargando header...");
        }
      }
    } catch (error) {
      console.error("❌ Error al guardar perfil:", error);

      let errorMessage = "Error al guardar los cambios";
      if (
        error.response &&
        error.response.data &&
        error.response.data.message
      ) {
        errorMessage = error.response.data.message;
      }

      notyf.error({
        message: errorMessage,
        duration: 5000,
      });
    } finally {
      // Restaurar botón
      saveBtn.disabled = false;
      saveBtn.innerHTML = '<i class="bx bx-save me-1"></i>Guardar Cambios';
    }
  });
```

**Endpoint**: `PUT /routes/profile/up_user.php`

**Body enviado**:

```json
{
  "first_name": "Juan Esteban",
  "last_name": "Manrique Giraldo",
  "bio": "Nueva biografía actualizada",
  "gender_id": 2,
  "birthdate": "2007-09-10",
  "country": "Colombia",
  "city": "Manizales",
  "phone": "+573022748413",
  "social": {
    "github_username": "thisfeeling",
    "linkedin_username": "juanemanriqueg",
    "twitter_username": "thisfeeling_dev",
    "discord_tag": "thisfeeling#1234",
    "personal_website": "https://juanmanrique.dev",
    "show_social_public": true
  }
}
```

**Respuesta esperada**:

```json
{
  "status": "success",
  "message": "Perfil actualizado exitosamente",
  "data": {
    "user_id": 4,
    "updated_fields": ["first_name", "bio", "phone", "social"],
    "total_updates": 4
  }
}
```

---

## 🎨 Características UX Implementadas

### 1. **Loading States** ⏳

- Botón "Guardar Cambios" muestra spinner mientras guarda
- Botón se deshabilita durante el proceso
- Texto cambia a "Guardando..."

### 2. **Notificaciones** 🔔

- **Éxito**: Muestra cantidad de campos actualizados
- **Error**: Muestra mensaje específico del backend
- Duración: 5 segundos

### 3. **Contador de Caracteres** 📝

- Actualización en tiempo real para el campo bio
- Visual: "123/255 caracteres"
- Validación: maxlength="255" en textarea

### 4. **Campos Readonly** 🔒

- Email no se puede editar (requiere verificación)
- Username no se puede editar (identificador único)
- Visual: disabled + texto explicativo debajo

### 5. **Validaciones de Formulario** ✔️

- Bio: Máximo 255 caracteres
- Gender_id: Debe ser entre 1 y 4
- Birthdate: Date picker con formato YYYY-MM-DD
- Phone: Campo de teléfono con placeholder de ejemplo
- Redes sociales: Todos los campos opcionales

---

## 🔄 Flujo Completo de Actualización

```
Usuario abre /dashboard (profile tab)
        ↓
init() se ejecuta al cargar
        ↓
waitForAppRouter() verifica que AppRouter esté disponible
        ↓
loadUserData() llama a GET /routes/profile/det_user.php
        ↓
Backend responde con perfil completo (bio, gender, social)
        ↓
fillFormData() llena todos los formularios
        ↓
updateProfileUI() actualiza header y stats
        ↓
✅ Usuario ve sus datos cargados

Usuario modifica campos y presiona "Guardar Cambios"
        ↓
Recopilar datos de todos los formularios (personal, contacto, social)
        ↓
PUT /routes/profile/up_user.php con todos los datos
        ↓
Backend valida y actualiza en transacción (users + user_social)
        ↓
Backend responde con campos actualizados
        ↓
Notificación de éxito con cantidad de cambios
        ↓
loadUserData() recarga datos actualizados
        ↓
✅ Formularios se actualizan con datos del backend
```

---

## 📊 Datos de Prueba

### Usuario de Ejemplo (thisfeeling - user_id: 4)

```json
{
  "user_id": 4,
  "username": "thisfeeling",
  "email": "juane.manriqueg@autonoma.edu.co",
  "first_name": "Juan Esteban",
  "last_name": "Manrique Giraldo",
  "full_name": "Juan Esteban Manrique Giraldo",
  "phone": "+573022748413",
  "bio": "Desarrollador full-stack apasionado por la realidad aumentada y la tecnología inmersiva. Administrador de HomeLab AR desde 2024.",
  "gender_id": 2,
  "gender_name": "Masculino",
  "birthdate": "2007-09-10",
  "country": "Colombia",
  "city": "Manizales",
  "role_id": 2,
  "role_name": "admin",
  "status_id": 1,
  "status_name": "active",
  "profile_picture": "user_4.png",
  "social": {
    "github_username": "thisfeeling",
    "linkedin_username": "juanemanriqueg",
    "twitter_username": "thisfeeling_dev",
    "discord_tag": "thisfeeling#1234",
    "personal_website": "https://juanmanrique.dev",
    "show_social_public": true
  },
  "created_at": "2025-05-14 14:35:25",
  "updated_at": "2025-11-06 07:01:02"
}
```

---

## 🧪 Testing

### 1. **Cargar Perfil**

```bash
curl -X GET http://localhost:3000/routes/profile/det_user.php \
  -H "Content-Type: application/json" \
  -b "PHPSESSID=tu_session_id"
```

### 2. **Actualizar Perfil**

```bash
curl -X PUT http://localhost:3000/routes/profile/up_user.php \
  -H "Content-Type: application/json" \
  -b "PHPSESSID=tu_session_id" \
  -d '{
    "first_name": "Juan Esteban",
    "bio": "Nueva biografía de prueba",
    "gender_id": 2,
    "phone": "+573022748413",
    "social": {
      "github_username": "thisfeeling",
      "show_social_public": true
    }
  }'
```

### 3. **Validaciones a Probar**

- ✅ Bio con más de 255 caracteres (debe dar error)
- ✅ Gender_id fuera de rango 1-4 (debe dar error)
- ✅ Actualizar solo algunos campos (debe funcionar)
- ✅ Actualizar solo social (debe funcionar)
- ✅ Dejar campos vacíos (debe mantener valores anteriores)

---

## ⚠️ Consideraciones Importantes

### 1. **Campos No Editables desde Perfil**

- ❌ **Email**: Requiere verificación y proceso especial
- ❌ **Username**: Identificador único, no se puede cambiar
- ✅ Otros campos son editables libremente

### 2. **Validaciones Backend**

- Bio: Máximo 255 caracteres (validado en backend)
- Gender_id: Debe estar entre 1 y 4 (validado en backend)
- Transacciones: Updates a `users` y `user_social` son atómicos

### 3. **Seguridad**

- Middleware de autenticación en ambos endpoints
- Solo el usuario puede editar su propio perfil
- CORS configurado con `withCredentials: true`

### 4. **Performance**

- Single request para cargar perfil completo (JOIN en BD)
- Single request para actualizar todos los datos (transacción)
- Recarga automática después de guardar

---

## 📝 Checklist de Implementación

- ✅ Tab Personal con todos los campos (7 campos)
- ✅ Tab Contacto con email, phone, username (3 campos)
- ✅ Tab Social con redes sociales (6 campos)
- ✅ Tab Sesiones sin cambios (mantiene funcionalidad)
- ✅ Eliminado tab Preferencias completo
- ✅ Función loadUserData() con det_user.php
- ✅ Función fillFormData() para llenar formularios
- ✅ Contador de caracteres para bio (0/255)
- ✅ Botón "Guardar Cambios" funcional con up_user.php
- ✅ Loading states (spinner + disabled)
- ✅ Notificaciones de éxito y error (Notyf)
- ✅ Recarga automática de datos después de guardar
- ✅ Validaciones de campos en frontend y backend
- ✅ Campos readonly (email, username)
- ✅ Select de género con 4 opciones
- ✅ Checkbox para visibilidad de social

---

## 🚀 Próximos Pasos Sugeridos

### 1. **Upload de Foto de Perfil**

- Endpoint: `POST /routes/profile/upload_picture.php`
- FilePond para upload elegante
- Crop de imagen antes de subir

### 2. **Validación de Email Secundario**

- Agregar campo email_secondary editable
- Proceso de verificación con código

### 3. **Cambio de Password**

- Modal para cambiar contraseña
- Requiere password actual
- Validación de fortaleza

### 4. **Historial de Cambios**

- Registro de modificaciones al perfil
- Quién, qué y cuándo cambió

### 5. **Preview de Perfil Público**

- Vista previa de cómo se ve el perfil para otros
- Toggle de visibilidad de campos

---

## 📚 Documentación Relacionada

- **[BACKEND-UPDATE-BIO-GENDER.md](BACKEND-UPDATE-BIO-GENDER.md)** - Documentación completa de endpoints
- **[SESSION-MANAGER-SYSTEM.md](SESSION-MANAGER-SYSTEM.md)** - Sistema de gestión de sesiones
- **[ARQUITECTURA-FUNCIONAL.md](ARQUITECTURA-FUNCIONAL.md)** - Arquitectura general del proyecto

---

**Última actualización**: Noviembre 6, 2025  
**Autor**: Roepard Labs Development Team  
**Estado**: ✅ Implementación Completa
