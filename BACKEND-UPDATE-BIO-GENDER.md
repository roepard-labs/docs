# 📋 Actualización Backend - Bio y Género

## ✅ Cambios Realizados

### 📁 Archivos Actualizados

#### 1. `/routes/user/user_data.php` ⭐

**Cambios:**

- ✅ Agregada consulta JOIN a tabla `genders` para obtener `gender_name`
- ✅ Agregado campo `bio` en respuesta
- ✅ Agregado campo `gender_id` en respuesta
- ✅ Agregado campo `gender_name` en respuesta

**Nueva Respuesta JSON:**

```json
{
  "status": "success",
  "data": {
    "user_id": 4,
    "username": "thisfeeling",
    "bio": "Desarrollador full-stack...",
    "gender_id": 2,
    "gender_name": "Masculino",
    ...
  }
}
```

---

#### 2. `/routes/profile/det_user.php` 🆕

**Archivo Nuevo - Endpoint Completo de Perfil**

**Propósito:**

- Obtener perfil completo del usuario actual
- Incluye datos personales, género y redes sociales
- JOIN de 3 tablas: `users`, `genders`, `user_social`

**Endpoint:** `GET /routes/profile/det_user.php`

**Respuesta JSON:**

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
    "created_at": "2025-05-14 19:35:25",
    "updated_at": "2025-11-06 04:24:46"
  }
}
```

**Características:**

- ✅ Middleware: `Auth::checkAuth()` + `Status::checkStatus(1)`
- ✅ Solo usuarios autenticados y activos
- ✅ JOIN automático a `genders` y `user_social`
- ✅ Datos completos de redes sociales incluidos
- ✅ Nombres de rol y estado traducidos

---

#### 3. `/routes/profile/up_user.php` 🆕

**Archivo Nuevo - Actualización de Perfil**

**Propósito:**

- Actualizar perfil completo del usuario actual
- Actualización en 2 tablas: `users` y `user_social`
- Validación de datos y transacciones BD

**Endpoint:** `PUT /routes/profile/up_user.php`

**Body JSON:**

```json
{
  "first_name": "Juan Esteban",
  "last_name": "Manrique",
  "phone": "+573022748413",
  "bio": "Nueva biografía (máx 255 caracteres)",
  "gender_id": 2,
  "birthdate": "2007-09-10",
  "country": "Colombia",
  "city": "Manizales",
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

**Respuesta JSON:**

```json
{
  "status": "success",
  "message": "Perfil actualizado exitosamente",
  "data": {
    "user_id": 4,
    "updated_fields": [
      "first_name",
      "last_name",
      "phone",
      "bio",
      "gender_id",
      "birthdate",
      "country",
      "city",
      "social"
    ],
    "total_updates": 9
  }
}
```

**Características:**

- ✅ Transacción BD (rollback en caso de error)
- ✅ Validación longitud bio (máx 255 caracteres)
- ✅ Validación `gender_id` entre 1-4
- ✅ UPSERT en `user_social` (UPDATE o INSERT)
- ✅ Campos opcionales (solo actualiza lo enviado)
- ✅ Actualiza `updated_at` automáticamente

**Validaciones:**

```php
// Bio máximo 255 caracteres
if (strlen($bio) > 255) {
    return error 400
}

// Gender ID entre 1-4
if ($genderId < 1 || $genderId > 4) {
    return error 400
}
```

---

#### 4. `/models/UserDetails.php` ⭐

**Cambios:**

- ✅ Query actualizada con JOIN a `genders` y `user_social`
- ✅ Retorna `gender_name`, `bio` y todos los campos sociales

**Antes:**

```php
SELECT * FROM users WHERE user_id = :user_id
```

**Después:**

```php
SELECT
    u.*,
    g.gender_name,
    s.github_username,
    s.linkedin_username,
    s.twitter_username,
    s.discord_tag,
    s.personal_website,
    s.show_social_public
FROM users u
LEFT JOIN genders g ON u.gender_id = g.gender_id
LEFT JOIN user_social s ON u.user_id = s.user_id
WHERE u.user_id = :user_id
```

---

#### 5. `/services/UserListService.php` ⭐

**Cambios:**

- ✅ Query actualizada con JOIN a `genders`, `roles` y `status`
- ✅ Retorna `gender_name`, `role_name`, `status_name` y `bio`

**Antes:**

```php
SELECT * FROM users
```

**Después:**

```php
SELECT
    u.*,
    g.gender_name,
    r.role_name,
    s.status_name
FROM users u
LEFT JOIN genders g ON u.gender_id = g.gender_id
LEFT JOIN roles r ON u.role_id = r.role_id
LEFT JOIN status s ON u.status_id = s.status_id
ORDER BY u.created_at DESC
```

---

#### 6. `/models/UserList.php` ⭐

**Cambios:**

- ✅ Query `getAllUsers()` actualizada con JOIN a `genders`, `roles` y `status`
- ✅ Agregados campos: `bio`, `gender_id`, `gender_name`, `role_name`, `status_name`

**Antes:**

```php
SELECT
    u.user_id,
    u.username,
    u.email,
    ...
FROM users u
JOIN roles r ON u.role_id = r.role_id
ORDER BY u.user_id DESC
```

**Después:**

```php
SELECT
    u.user_id,
    u.username,
    u.email,
    u.phone,
    u.country,
    u.city,
    u.first_name,
    u.last_name,
    u.bio,
    u.gender_id,
    g.gender_name,
    u.status_id,
    s.status_name,
    r.role_id,
    r.role_name,
    u.created_at,
    u.updated_at,
    u.birthdate,
    u.profile_picture
FROM users u
JOIN roles r ON u.role_id = r.role_id
JOIN status s ON u.status_id = s.status_id
LEFT JOIN genders g ON u.gender_id = g.gender_id
ORDER BY u.user_id DESC
```

---

## 📊 Resumen de Endpoints

| Endpoint                          | Método | Propósito             | Campos Nuevos                                 |
| --------------------------------- | ------ | --------------------- | --------------------------------------------- |
| `/routes/user/user_data.php`      | GET    | Datos básicos usuario | `bio`, `gender_id`, `gender_name`             |
| `/routes/profile/det_user.php` 🆕 | GET    | Perfil completo       | `bio`, `gender_id`, `gender_name`, `social{}` |
| `/routes/profile/up_user.php` 🆕  | PUT    | Actualizar perfil     | Acepta `bio`, `gender_id`, `social{}`         |
| `/routes/admin/det_user.php`      | POST   | Admin ver usuario     | `bio`, `gender_name`, `social{}`              |
| `/routes/admin/list_users.php`    | GET    | Admin listar usuarios | `bio`, `gender_name`                          |

---

## 🔄 Flujo de Datos

### **Consulta de Perfil**

```
Frontend → GET /routes/profile/det_user.php
              ↓
    Middleware: Auth + Status
              ↓
    Query JOIN: users + genders + user_social
              ↓
    Respuesta JSON con datos completos
```

### **Actualización de Perfil**

```
Frontend → PUT /routes/profile/up_user.php + JSON body
              ↓
    Middleware: Auth + Status
              ↓
    Validaciones: bio (255), gender_id (1-4)
              ↓
    BEGIN TRANSACTION
        ↓
    UPDATE users (bio, gender_id, etc)
        ↓
    UPSERT user_social (github, linkedin, etc)
        ↓
    COMMIT TRANSACTION
              ↓
    Respuesta JSON con campos actualizados
```

---

## 🧪 Testing

### **1. Test de user_data.php**

```bash
curl -X GET http://localhost:3000/routes/user/user_data.php \
  -H "Cookie: ROEPARDSESSID=your_session_id"
```

**Verificar respuesta incluye:**

- ✅ `bio`
- ✅ `gender_id`
- ✅ `gender_name`

---

### **2. Test de det_user.php (Profile)**

```bash
curl -X GET http://localhost:3000/routes/profile/det_user.php \
  -H "Cookie: ROEPARDSESSID=your_session_id"
```

**Verificar respuesta incluye:**

- ✅ `bio`
- ✅ `gender_id`, `gender_name`
- ✅ `social` (objeto con 6 campos)
- ✅ `full_name`

---

### **3. Test de up_user.php (Update Profile)**

```bash
curl -X PUT http://localhost:3000/routes/profile/up_user.php \
  -H "Cookie: ROEPARDSESSID=your_session_id" \
  -H "Content-Type: application/json" \
  -d '{
    "bio": "Nueva biografía de prueba",
    "gender_id": 2,
    "social": {
      "github_username": "test_user",
      "show_social_public": true
    }
  }'
```

**Verificar respuesta:**

- ✅ `status: "success"`
- ✅ `updated_fields` contiene ["bio", "gender_id", "social"]

---

### **4. Test de list_users.php (Admin)**

```bash
curl -X GET http://localhost:3000/routes/admin/list_users.php \
  -H "Cookie: ROEPARDSESSID=admin_session_id"
```

**Verificar cada usuario incluye:**

- ✅ `bio`
- ✅ `gender_name`
- ✅ `role_name`
- ✅ `status_name`

---

## 🛠️ Integración Frontend

### **Obtener datos de perfil**

```javascript
// Usar endpoint de profile para datos completos
const profileData = await window.AppRouter.get("/routes/profile/det_user.php");

console.log(profileData.data.bio); // "Desarrollador full-stack..."
console.log(profileData.data.gender_name); // "Masculino"
console.log(profileData.data.social.github_username); // "thisfeeling"
```

### **Actualizar perfil**

```javascript
const updateData = {
  bio: document.getElementById("bioTextarea").value,
  gender_id: parseInt(document.getElementById("genderSelect").value),
  social: {
    github_username: document.getElementById("githubInput").value,
    linkedin_username: document.getElementById("linkedinInput").value,
    twitter_username: document.getElementById("twitterInput").value,
    discord_tag: document.getElementById("discordInput").value,
    personal_website: document.getElementById("websiteInput").value,
    show_social_public: document.getElementById("showPublicCheck").checked,
  },
};

const response = await window.AppRouter.put(
  "/routes/profile/up_user.php",
  updateData
);

if (response.status === "success") {
  notyf.success("Perfil actualizado exitosamente");
  console.log("Campos actualizados:", response.data.updated_fields);
}
```

---

## 📝 Notas Importantes

### **Migración de BD Requerida**

⚠️ **CRÍTICO**: Ejecutar `migration_add_gender_bio_social.sql` ANTES de usar estos endpoints.

```bash
mysql -u thisfeeling -p homelab < migration_add_gender_bio_social.sql
```

### **Validaciones Frontend**

```javascript
// Bio máximo 255 caracteres
if (bio.length > 255) {
  notyf.error("La biografía no puede exceder 255 caracteres");
  return;
}

// Gender ID entre 1-4
const validGenders = [1, 2, 3, 4];
if (!validGenders.includes(gender_id)) {
  notyf.error("Género inválido");
  return;
}
```

### **Manejo de Errores**

```javascript
try {
  const response = await window.AppRouter.put(
    "/routes/profile/up_user.php",
    data
  );

  if (response.status === "success") {
    // Actualización exitosa
  } else {
    // Error del servidor
    notyf.error(response.message);
  }
} catch (error) {
  // Error de red o sintaxis
  notyf.error("Error al actualizar perfil");
  console.error(error);
}
```

---

## ✅ Checklist de Implementación

### Backend

- [x] Migración SQL ejecutada
- [x] `user_data.php` actualizado
- [x] `det_user.php` (profile) creado
- [x] `up_user.php` (profile) creado
- [x] `UserDetails.php` actualizado
- [x] `UserListService.php` actualizado
- [x] `UserList.php` (modelo) actualizado

### Frontend (Pendiente)

- [ ] Actualizar `profile.page.php` para usar nuevos endpoints
- [ ] Agregar selector de género con 4 opciones
- [ ] Agregar textarea de biografía con contador (255 chars)
- [ ] Agregar inputs de redes sociales
- [ ] Agregar toggle "Mostrar redes públicamente"
- [ ] Implementar validación de longitud bio
- [ ] Implementar guardado con `up_user.php`
- [ ] Cargar datos con `det_user.php`

---

## 🚀 Próximos Pasos

1. **Ejecutar migración SQL** en BD de desarrollo y producción
2. **Testing de endpoints** con curl o Postman
3. **Actualizar frontend** para usar nuevos campos
4. **Sincronizar datos** de usuarios existentes
5. **Deploy a producción** cuando esté probado

---

**Última actualización:** 2025-11-06  
**Desarrollado por:** Roepard Labs  
**Proyecto:** HomeLab AR
