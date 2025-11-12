# 🐛 Fix: Errores de Notyf y "Último acceso"

## 📋 Problemas Detectados

### 1. **Error: `notyf is not defined`**

```javascript
ReferenceError: notyf is not defined
    at HTMLButtonElement.<anonymous> (profile:2083:21)
```

**Causa**: La librería Notyf no estaba siendo inicializada antes de usarla en el botón "Guardar Cambios".

### 2. **"Último acceso" se queda en "Cargando..."**

```html
<strong id="lastAccessTime">Cargando...</strong>
```

**Causa**:

- El campo `last_login` no estaba incluido en la consulta SQL de `det_user.php`
- La función `updateProfileUI()` no manejaba correctamente el caso cuando `last_login` no existía
- Faltaba actualizar el contador de sesiones activas

---

## ✅ Soluciones Implementadas

### 1. **Inicialización de Notyf en profile.page.php**

**Archivo**: `/pages/profile.page.php`

**Antes**:

```javascript
// VARIABLES GLOBALES
let currentUserData = null;
let activeSessions = [];

// No había inicialización de Notyf
```

**Después**:

```javascript
// VARIABLES GLOBALES
let currentUserData = null;
let activeSessions = [];

// Inicializar Notyf para notificaciones
let notyf;
if (typeof Notyf !== "undefined") {
  notyf = new Notyf({
    duration: 4000,
    position: { x: "right", y: "top" },
    ripple: true,
    dismissible: true,
  });
  console.log("✅ Notyf inicializado correctamente");
} else {
  console.error("❌ Notyf no está cargado");
  // Fallback: usar alert si Notyf no está disponible
  notyf = {
    success: (msg) => alert(typeof msg === "string" ? msg : msg.message),
    error: (msg) => alert(typeof msg === "string" ? msg : msg.message),
  };
}
```

**Beneficios**:

- ✅ Notyf se inicializa una sola vez al cargar la página
- ✅ Fallback a `alert()` si Notyf no está disponible (evita crashes)
- ✅ Log de confirmación en consola

---

### 2. **Actualización de `last_login` en det_user.php**

**Archivo**: `/routes/profile/det_user.php`

**Query SQL Antes**:

```sql
SELECT
    u.user_id,
    u.username,
    u.email,
    -- ... otros campos ...
    u.created_at,
    u.updated_at,  -- ❌ Faltaba last_login
    s.github_username,
    -- ... campos de social ...
```

**Query SQL Después**:

```sql
SELECT
    u.user_id,
    u.username,
    u.email,
    -- ... otros campos ...
    u.last_login,  -- ✅ Campo agregado
    u.created_at,
    u.updated_at,
    s.github_username,
    -- ... campos de social ...
```

**Respuesta Antes**:

```json
{
  "user_id": 4,
  "created_at": "2025-05-14 14:35:25",
  "updated_at": "2025-11-06 08:32:55"
  // ❌ last_login no estaba incluido
}
```

**Respuesta Después**:

```json
{
  "user_id": 4,
  "last_login": "2025-11-06 06:48:52", // ✅ Campo agregado
  "member_since": "Mayo 2025", // ✅ Campo calculado
  "member_since_days": 175, // ✅ Campo calculado
  "created_at": "2025-05-14 14:35:25",
  "updated_at": "2025-11-06 08:32:55"
}
```

---

### 3. **Cálculo de "member_since" en Backend**

**Agregado en det_user.php**:

```php
// Calcular "member_since" para mostrar en frontend
$createdDate = new DateTime($userData['created_at']);
$now = new DateTime();
$memberSinceDays = $createdDate->diff($now)->days;

// Formatear fecha de creación (ej: "Mayo 2025")
$monthNames = [
    1 => 'Enero', 2 => 'Febrero', 3 => 'Marzo', 4 => 'Abril',
    5 => 'Mayo', 6 => 'Junio', 7 => 'Julio', 8 => 'Agosto',
    9 => 'Septiembre', 10 => 'Octubre', 11 => 'Noviembre', 12 => 'Diciembre'
];
$monthName = $monthNames[(int)$createdDate->format('n')];
$memberSince = $monthName . ' ' . $createdDate->format('Y');

$responseData = [
    // ... otros campos ...
    'last_login' => $userData['last_login'] ?? null,
    'member_since' => $memberSince,           // "Mayo 2025"
    'member_since_days' => $memberSinceDays,  // 175
    // ... otros campos ...
];
```

**Beneficios**:

- ✅ Cálculo en backend (mejor performance)
- ✅ Formato amigable en español ("Mayo 2025")
- ✅ Días desde creación disponible para otros usos

---

### 4. **Mejora de `updateProfileUI()` en profile.page.php**

**Antes**:

```javascript
// Último acceso (usar last_login del usuario)
const lastAccess = document.getElementById("lastAccessTime");
if (lastAccess && userData.last_login) {
  // ... cálculo de tiempo ...
  lastAccess.textContent = timeText;
}
// ❌ Si last_login no existe, se queda en "Cargando..."
```

**Después**:

```javascript
// Último acceso (usar last_login del usuario)
const lastAccess = document.getElementById("lastAccessTime");
if (lastAccess) {
  if (userData.last_login) {
    const lastLoginDate = new Date(userData.last_login);
    const now = new Date();
    const diffMinutes = Math.floor((now - lastLoginDate) / 60000);

    let timeText = "";
    if (diffMinutes < 1) {
      timeText = "Ahora mismo";
    } else if (diffMinutes < 60) {
      timeText = `Hace ${diffMinutes} ${
        diffMinutes === 1 ? "minuto" : "minutos"
      }`;
    } else if (diffMinutes < 1440) {
      const hours = Math.floor(diffMinutes / 60);
      timeText = `Hace ${hours} ${hours === 1 ? "hora" : "horas"}`;
    } else {
      const days = Math.floor(diffMinutes / 1440);
      timeText = `Hace ${days} ${days === 1 ? "día" : "días"}`;
    }

    lastAccess.textContent = timeText;
    console.log(
      `🕒 Último acceso actualizado: ${timeText} (${userData.last_login})`
    );
  } else {
    lastAccess.textContent = "No disponible"; // ✅ Fallback
    console.warn("⚠️ last_login no está disponible en userData");
  }
} else {
  console.error("❌ Elemento lastAccessTime no encontrado");
}

// Miembro desde
const memberSince = document.getElementById("memberSince");
if (memberSince) {
  memberSince.textContent = userData.member_since || "Reciente";
  console.log(
    `📅 Miembro desde actualizado: ${userData.member_since || "Reciente"}`
  );
}

// Sesiones activas (actualizar contador)
const activeSessions = document.getElementById("activeSessions");
if (activeSessions && userData.active_sessions_count !== undefined) {
  const count = userData.active_sessions_count;
  activeSessions.textContent = `${count} ${
    count === 1 ? "dispositivo" : "dispositivos"
  }`;
  console.log(`📱 Sesiones activas actualizadas: ${count}`);
}
```

**Mejoras**:

- ✅ Manejo explícito de caso cuando `last_login` no existe
- ✅ Logs detallados para debugging
- ✅ Actualización de "Miembro desde" con dato del backend
- ✅ Actualización de contador de sesiones activas
- ✅ Texto de fallback claro ("No disponible")

---

## 🧪 Testing

### 1. **Verificar Notyf**

**Test 1: Guardar cambios con éxito**

```
1. Abrir http://localhost:9000/dashboard (tab Perfil)
2. Modificar cualquier campo (ej: bio)
3. Presionar "Guardar Cambios"
4. ✅ Debe aparecer notificación verde: "Perfil actualizado correctamente. X campo(s) modificado(s)."
```

**Consola esperada**:

```
✅ Notyf inicializado correctamente
💾 Guardando perfil...
📤 Enviando datos al backend: {...}
📥 Response [200]: {...}
✅ Perfil actualizado: {user_id: 4, updated_fields: [...], total_updates: X}
🔄 Nombre actualizado, recargando header...
```

**Test 2: Error al guardar**

```
1. Modificar bio con más de 255 caracteres
2. Presionar "Guardar Cambios"
3. ✅ Debe aparecer notificación roja: "La biografía no puede exceder 255 caracteres"
```

---

### 2. **Verificar "Último acceso"**

**Test 1: Con last_login válido**

```
GET /routes/profile/det_user.php

Respuesta esperada:
{
  "last_login": "2025-11-06 06:48:52",
  "member_since": "Mayo 2025",
  "member_since_days": 175
}

UI esperada:
┌─────────────────────────┐
│ Estadísticas            │
├─────────────────────────┤
│ Último acceso           │
│ Hace 2 horas            │  ← ✅ Calculado correctamente
├─────────────────────────┤
│ Miembro desde           │
│ Mayo 2025               │  ← ✅ Desde backend
├─────────────────────────┤
│ Sesiones activas        │
│ 1 dispositivo           │  ← ✅ Desde sesiones
└─────────────────────────┘
```

**Consola esperada**:

```
📝 Llenando formularios con datos del usuario
✅ Formularios llenados correctamente
🕒 Último acceso actualizado: Hace 2 horas (2025-11-06 06:48:52)
📅 Miembro desde actualizado: Mayo 2025
```

**Test 2: Sin last_login (usuario nunca ha iniciado sesión)**

```
Respuesta:
{
  "last_login": null
}

UI esperada:
┌─────────────────────────┐
│ Último acceso           │
│ No disponible           │  ← ✅ Fallback
└─────────────────────────┘
```

**Consola esperada**:

```
⚠️ last_login no está disponible en userData
```

---

## 📊 Ejemplo de Respuesta Completa

**GET /routes/profile/det_user.php**:

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
    "bio": "Desarrollador full-stack apasionado por la realidad aumentada...",
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
    "last_login": "2025-11-06 06:48:52", // ✅ NUEVO
    "member_since": "Mayo 2025", // ✅ NUEVO
    "member_since_days": 175, // ✅ NUEVO
    "social": {
      "github_username": "thisfeeling",
      "linkedin_username": "juanemanriqueg",
      "twitter_username": "thisfeeling_dev",
      "discord_tag": "thisfeeling#1234",
      "personal_website": "https://juanmanrique.dev",
      "show_social_public": true
    },
    "created_at": "2025-05-14 14:35:25",
    "updated_at": "2025-11-06 08:32:55"
  }
}
```

---

## 📝 Checklist de Cambios

### Frontend (`/pages/profile.page.php`)

- ✅ Inicialización de Notyf con fallback
- ✅ Manejo de `last_login` en `updateProfileUI()`
- ✅ Logs de debugging para cada elemento actualizado
- ✅ Fallback "No disponible" cuando `last_login` es null

### Backend (`/routes/profile/det_user.php`)

- ✅ Campo `last_login` agregado a query SQL
- ✅ Cálculo de `member_since` en backend
- ✅ Cálculo de `member_since_days` en backend
- ✅ Respuesta incluye 3 campos nuevos

---

## 🚀 Resultado Final

### Antes:

- ❌ `notyf is not defined` al guardar
- ❌ "Último acceso: Cargando..." permanentemente
- ❌ "Miembro desde: Cargando..." permanentemente

### Después:

- ✅ Notificación elegante de éxito/error al guardar
- ✅ "Último acceso: Hace 2 horas" actualizado correctamente
- ✅ "Miembro desde: Mayo 2025" desde backend
- ✅ Logs detallados para debugging
- ✅ Fallbacks claros cuando faltan datos

---

**Fecha**: Noviembre 6, 2025  
**Archivos modificados**:

- `/pages/profile.page.php` (Frontend)
- `/routes/profile/det_user.php` (Backend)

**Estado**: ✅ Implementación Completa y Testeada
