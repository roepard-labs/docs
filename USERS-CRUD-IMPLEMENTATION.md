# 📋 Implementación CRUD de Gestión de Usuarios

## 📋 Resumen Ejecutivo

Se ha implementado el **CRUD completo** para la gestión de usuarios en el dashboard de administración de HomeLab AR, con integración completa con el backend PHP y las siguientes funcionalidades:

✅ **Listar usuarios** con DataTables
✅ **Ver detalles** de usuario en modal
✅ **Editar usuario** en modal
❌ **Eliminar usuario** - No implementado por requerimientos del cliente

---

## 🏗️ Arquitectura

### Frontend

**Archivo principal**: `/js/users.js`

- Módulo JavaScript independiente y reutilizable
- IIFE para evitar contaminación del scope global
- Gestión completa del ciclo de vida CRUD
- Integración con AppRouter (Axios wrapper)

**Vista**: `/pages/users.page.php`

- Vista PHP que se incluye dinámicamente en `dashboard.view.php`
- Tabla HTML vacía que se puebla dinámicamente
- Filtros para búsqueda, estado y rol
- Tarjetas de estadísticas (Total, Activos, Pendientes, Inactivos)

### Backend

**Rutas API REST**:

| Método   | Endpoint                       | Descripción                       |
| -------- | ------------------------------ | --------------------------------- |
| GET/POST | `/routes/admin/list_users.php` | Listado completo de usuarios      |
| POST     | `/routes/admin/det_user.php`   | Detalles de un usuario específico |
| PUT      | `/routes/admin/up_user.php`    | Actualizar información de usuario |

**Arquitectura MVC**:

- **Controladores**: `ListUserController`, `DetUserController`
- **Servicios**: `UserListService`, `UserDetailsService`
- **Modelos**: `UserList`, `UserDetails`
- **Middleware**: `Auth::requireAuth()`, `Auth::checkRole(2)` (solo admin)

---

## 🎯 Funcionalidades Implementadas

### 1. Listar Usuarios (DataTables)

**Características**:

- Tabla dinámica con DataTables
- Paginación, búsqueda y ordenamiento
- Modo oscuro/claro automático
- Renderizado de avatares (foto de perfil o iniciales)
- Badges para roles y estados
- Columnas: ID, Usuario, Email, Rol, Estado, Registro, Acciones

**Flujo**:

```javascript
// 1. Cargar usuarios desde backend
const response = await window.AppRouter.get('/routes/admin/list_users.php');

// 2. Inicializar DataTable con datos
usersDataTable = $('#usersTable').DataTable({
    data: response.data,
    columns: [/* configuración de columnas */]
});

// 3. Renderizar botones de acción en cada fila
{
    render: function(data, type, row) {
        return `
            <button class="view-user-btn" data-user-id="${row.user_id}">
                <i class="bx bx-show"></i>
            </button>
            <button class="edit-user-btn" data-user-id="${row.user_id}">
                <i class="bx bx-edit"></i>
            </button>
        `;
    }
}
```

**Renderizado de Avatares**:

```javascript
const initials = (row.first_name[0] + row.last_name[0]).toUpperCase();
const profilePic =
  row.profile_picture &&
  row.profile_picture !== "/assets/img/default-avatar.png"
    ? `<img src="${window.ENV_CONFIG.BACKEND_URL}${row.profile_picture}" ...>`
    : `<div class="avatar-sm bg-primary">${initials}</div>`;
```

**Badges Dinámicos**:

```javascript
// Roles
const roleColors = {
  1: "info", // user
  2: "primary", // admin
  3: "secondary", // supervisor
};

// Estados
const statusColors = {
  1: "success", // active
  2: "warning", // inactive
  3: "danger", // suspended
  4: "dark", // banned
};
```

### 2. Ver Detalles de Usuario (Modal)

**Funcionalidad**:

- Modal con SweetAlert2
- Información completa del usuario:
  - Foto de perfil o avatar con iniciales
  - Nombre completo y username
  - Email y teléfono
  - Fecha de nacimiento
  - Ubicación (ciudad, país)
  - Género
  - Rol y estado (badges)
  - Fecha de registro
  - Biografía (si existe)
- Botón para editar directamente desde el modal

**Flujo**:

```javascript
async function viewUserDetails(userId) {
  // 1. Obtener detalles del usuario
  const response = await window.AppRouter.post("/routes/admin/det_user.php", {
    user_id: userId,
  });

  // 2. Construir HTML del modal
  const modalHtml = `
        <div class="text-center">
            <img src="${user.profile_picture}" ...>
            <h4>${user.first_name} ${user.last_name}</h4>
            <p>@${user.username}</p>
        </div>
        <div class="row">
            <!-- Información detallada -->
        </div>
    `;

  // 3. Mostrar modal con SweetAlert2
  Swal.fire({
    title: "Detalles del Usuario",
    html: modalHtml,
    confirmButtonText: '<i class="bx bx-edit"></i> Editar Usuario',
  }).then((result) => {
    if (result.isConfirmed) {
      editUser(userId);
    }
  });
}
```

### 3. Editar Usuario (Modal con Formulario)

**Campos Editables**:

- ✅ Nombre
- ✅ Apellido
- ✅ Username
- ✅ Email
- ✅ Teléfono
- ✅ Fecha de nacimiento
- ✅ País
- ✅ Ciudad
- ✅ Género (select: Prefiero no decirlo, Masculino, Femenino, Otro)
- ✅ Rol (select: Usuario, Administrador, Supervisor)
- ✅ Estado (select: Activo, Inactivo, Suspendido, Bloqueado)
- ✅ Biografía (textarea, máx 255 caracteres)

**Flujo**:

```javascript
async function editUser(userId) {
  // 1. Obtener datos actuales del usuario
  const response = await window.AppRouter.post("/routes/admin/det_user.php", {
    user_id: userId,
  });

  // 2. Construir formulario con valores actuales
  const formHtml = `
        <form id="editUserForm">
            <input name="first_name" value="${user.first_name}">
            <input name="last_name" value="${user.last_name}">
            <input name="email" value="${user.email}">
            <!-- ... más campos ... -->
        </form>
    `;

  // 3. Mostrar modal de edición
  Swal.fire({
    title: `Editar Usuario: ${user.first_name} ${user.last_name}`,
    html: formHtml,
    confirmButtonText: '<i class="bx bx-save"></i> Guardar Cambios',
    preConfirm: () => {
      // Validar y recopilar datos del formulario
      const form = document.getElementById("editUserForm");
      const formData = new FormData(form);
      return Object.fromEntries(formData);
    },
  }).then(async (result) => {
    if (result.isConfirmed) {
      await updateUser(result.value);
    }
  });
}
```

**Actualización**:

```javascript
async function updateUser(userData) {
  // 1. Enviar datos al backend (método PUT)
  const response = await window.AppRouter.put("/routes/admin/up_user.php", {
    user_id: userData.user_id,
    first_name: userData.first_name,
    last_name: userData.last_name,
    // ... más campos ...
  });

  // 2. Notificar éxito
  notyf.success("✅ Usuario actualizado exitosamente");

  // 3. Recargar tabla y estadísticas
  await initDataTable();
  await loadUserStats();
}
```

### 4. Filtros de Tabla

**Tipos de Filtros**:

- **Búsqueda general**: Por nombre, email, username, etc.
- **Estado**: Todos, Activos, Inactivos
- **Rol**: Todos, Usuario, Administrador, Supervisor
- **Botón "Limpiar"**: Resetea todos los filtros

**Implementación**:

```javascript
function setupFilters() {
  // Filtro de búsqueda
  $("#searchUser").on("keyup", function () {
    usersDataTable.search(this.value).draw();
  });

  // Filtro de estado
  $("#filterStatus").on("change", function () {
    usersDataTable.column(4).search(this.value).draw();
  });

  // Filtro de rol
  $("#filterRole").on("change", function () {
    usersDataTable.column(3).search(this.value).draw();
  });

  // Limpiar filtros
  $("#clearFilters").on("click", function () {
    $("#searchUser").val("");
    $("#filterStatus").val("");
    $("#filterRole").val("");
    usersDataTable.search("").columns().search("").draw();
  });
}
```

### 5. Estadísticas Dinámicas

**Cálculo Automático**:

```javascript
async function loadUserStats() {
  const response = await window.AppRouter.get("/routes/admin/list_users.php");
  const users = response.data;

  const stats = {
    total: users.length,
    active: users.filter((u) => u.status_id === 1).length,
    pending: users.filter((u) => u.status_id === 2).length,
    inactive: users.filter((u) => u.status_id === 3 || u.status_id === 4)
      .length,
  };

  // Actualizar UI
  document.getElementById("totalUsers").textContent = stats.total;
  document.getElementById("activeUsers").textContent = stats.active;
  document.getElementById("pendingUsers").textContent = stats.pending;
  document.getElementById("inactiveUsers").textContent = stats.inactive;
}
```

---

## 🔧 Dependencias

### JavaScript Libraries

**Core**:

- jQuery 3.7+
- Axios (via AppRouter)
- Bootstrap 5

**UI Components**:

- DataTables (tabla interactiva)
- SweetAlert2 (modales elegantes)
- Notyf (notificaciones toast)
- Boxicons (iconografía)

**Carga en `dashboard.view.php`**:

```php
if ($currentPath === '/dashboard/users') {
    $dashboardPage = 'users.page.php';
    $additionalCss = ['datatables', 'datatablesResponsive'];
    $additionalJs = ['datatables', 'datatablesBS5', 'datatablesResponsive'];
}
```

---

## 🎨 Estilos y Tema

### Modo Oscuro/Claro Automático

**Detección de Tema**:

```javascript
function applyDataTableDarkMode() {
  const isDark =
    document.documentElement.getAttribute("data-bs-theme") === "dark";

  if (isDark) {
    $("#usersTable").addClass("table-dark");
    $(".dataTables_wrapper").addClass("text-light");
  } else {
    $("#usersTable").removeClass("table-dark");
    $(".dataTables_wrapper").removeClass("text-light");
  }
}
```

**Observer de Cambios de Tema**:

```javascript
const themeObserver = new MutationObserver(function (mutations) {
  mutations.forEach(function (mutation) {
    if (mutation.attributeName === "data-bs-theme") {
      applyDataTableDarkMode();
    }
  });
});

themeObserver.observe(document.documentElement, {
  attributes: true,
  attributeFilter: ["data-bs-theme"],
});
```

### CSS Personalizado

**Stats Cards con Hover Effects**:

```css
.stats-card {
  transition: all 0.3s ease;
  border: 1px solid transparent;
}

.stats-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15) !important;
  border-color: var(--bs-primary);
}
```

**DataTable Dark Mode**:

```css
[data-bs-theme="dark"] #usersTable thead th {
  background-color: rgba(255, 255, 255, 0.05) !important;
  color: var(--bs-body-color) !important;
}

[data-bs-theme="dark"] .dataTables_wrapper input {
  background-color: rgba(255, 255, 255, 0.05) !important;
  color: var(--bs-body-color) !important;
}
```

---

## 🔐 Seguridad

### Backend

**Middleware de Autenticación**:

```php
// En list_users.php
Auth::requireAuth(); // Verificar autenticación
Auth::checkAnyRole([1, 2, 3]); // Permitir a todos los roles autenticados

// En det_user.php y up_user.php
Auth::requireAuth();
Status::checkStatus(1); // Usuario activo
Auth::checkRole(2); // Solo administradores (para up_user.php)
```

**Validaciones en Actualización**:

```php
// Validar email único
$sqlCheckEmail = "SELECT user_id FROM users WHERE email = :email AND user_id != :user_id";

// Validar username único
$sqlCheckUsername = "SELECT user_id FROM users WHERE username = :username AND user_id != :user_id";

// Validar longitud de bio
if (strlen($bio) > 255) {
    throw new Exception('Biografía no puede exceder 255 caracteres');
}

// Validar gender_id (1-4)
if ($genderId < 1 || $genderId > 4) {
    throw new Exception('ID de género inválido');
}

// Validar role_id (1-3)
if ($roleId < 1 || $roleId > 3) {
    throw new Exception('ID de rol inválido');
}
```

### Frontend

**Verificación de Dependencias**:

```javascript
function checkDependencies() {
  if (typeof window.AppRouter === "undefined") {
    console.error("❌ AppRouter no está disponible");
    return false;
  }
  if (typeof $ === "undefined") {
    console.error("❌ jQuery no está disponible");
    return false;
  }
  if (typeof $.fn.dataTable === "undefined") {
    console.error("❌ DataTables no está disponible");
    return false;
  }
  return true;
}
```

**Validación de Formularios**:

```javascript
preConfirm: () => {
  const form = document.getElementById("editUserForm");

  // Validar formulario HTML5
  if (!form.checkValidity()) {
    form.reportValidity();
    return false;
  }

  return formData;
};
```

---

## 🧪 Testing

### Testing Manual

**1. Listar Usuarios**:

```
✅ Navegar a http://localhost:9000/dashboard/users
✅ Verificar que la tabla carga con usuarios reales
✅ Verificar paginación funciona
✅ Verificar búsqueda funciona
✅ Verificar ordenamiento de columnas
✅ Verificar avatares se muestran correctamente
✅ Verificar badges de rol y estado
```

**2. Ver Detalles**:

```
✅ Click en botón "Ver" (ojo)
✅ Verificar modal se abre
✅ Verificar todos los datos se muestran correctamente
✅ Verificar foto de perfil o iniciales
✅ Verificar botón "Editar Usuario"
```

**3. Editar Usuario**:

```
✅ Click en botón "Editar" o desde modal de detalles
✅ Verificar formulario se puebla con datos actuales
✅ Modificar varios campos
✅ Click en "Guardar Cambios"
✅ Verificar notificación de éxito
✅ Verificar tabla se recarga con datos actualizados
✅ Verificar estadísticas se actualizan si cambia estado
```

**4. Filtros**:

```
✅ Buscar por nombre, email, username
✅ Filtrar por estado (Activos, Inactivos)
✅ Filtrar por rol (Usuario, Admin, Supervisor)
✅ Combinar múltiples filtros
✅ Click en "Limpiar" resetea todo
```

**5. Modo Oscuro/Claro**:

```
✅ Cambiar tema con toggle
✅ Verificar tabla se adapta
✅ Verificar inputs de filtro se adaptan
✅ Verificar modales se adaptan
✅ Verificar badges mantienen legibilidad
```

### Testing de Console

**Verificar Dependencias**:

```javascript
// En consola del navegador
console.log(
  "AppRouter:",
  typeof window.AppRouter !== "undefined" ? "✅" : "❌"
);
console.log("jQuery:", typeof $ !== "undefined" ? "✅ " + $.fn.jquery : "❌");
console.log(
  "DataTables:",
  typeof $.fn.dataTable !== "undefined" ? "✅ " + $.fn.dataTable.version : "❌"
);
console.log("SweetAlert2:", typeof Swal !== "undefined" ? "✅" : "❌");
console.log("Notyf:", typeof Notyf !== "undefined" ? "✅" : "❌");
```

**Verificar Carga de Datos**:

```javascript
// Verificar respuesta del backend
window.AppRouter.get("/routes/admin/list_users.php").then((response) => {
  console.log("✅ Usuarios cargados:", response.data.length);
  console.log("Ejemplo:", response.data[0]);
});
```

---

## 📊 Estructura de Datos

### Respuesta de `list_users.php`

```json
{
  "success": true,
  "data": [
    {
      "user_id": 4,
      "first_name": "Juan Esteban",
      "last_name": "Manrique Giraldo",
      "username": "thisfeeling",
      "phone": "+573022748413",
      "email": "juane.manriqueg@autonoma.edu.co",
      "profile_picture": "/uploads/profiles/profile_4_1762443120.jpeg",
      "birthdate": "2007-09-10",
      "country": "Colombia",
      "city": "Manizales",
      "gender_id": 2,
      "bio": "Desarrollador full-stack...",
      "status_id": 1,
      "created_at": "2025-05-14 14:35:25",
      "updated_at": "2025-11-06 10:48:14",
      "role_id": 2,
      "gender_name": "Masculino",
      "role_name": "admin",
      "status_name": "active"
    }
  ]
}
```

### Request de `det_user.php`

```json
{
  "user_id": 4
}
```

### Request de `up_user.php`

```json
{
  "user_id": 4,
  "first_name": "Juan Esteban",
  "last_name": "Manrique",
  "email": "nuevo@email.com",
  "phone": "+573022748413",
  "birthdate": "2007-09-10",
  "country": "Colombia",
  "city": "Manizales",
  "gender_id": 2,
  "bio": "Nueva biografía...",
  "role_id": 2,
  "status_id": 1
}
```

---

## 🚀 Próximas Mejoras Sugeridas

### Funcionalidades Adicionales

1. **Crear Usuario**:

   - Modal para agregar nuevo usuario
   - Generación automática de contraseña
   - Envío de email de bienvenida

2. **Exportar Datos**:

   - Exportar tabla a Excel
   - Exportar a PDF con filtros aplicados
   - Exportar a CSV

3. **Acciones en Lote**:

   - Selección múltiple de usuarios
   - Cambiar estado de múltiples usuarios
   - Cambiar rol de múltiples usuarios

4. **Historial de Cambios**:

   - Log de modificaciones por usuario
   - Quién y cuándo modificó cada campo
   - Opción de revertir cambios

5. **Búsqueda Avanzada**:
   - Filtros por fecha de registro
   - Filtros por ubicación
   - Filtros por género
   - Búsqueda por rango de fechas

### Optimizaciones

1. **Paginación del Backend**:

   - Implementar paginación server-side en DataTables
   - Reducir carga inicial de datos
   - Mejorar performance con muchos usuarios

2. **Cache**:

   - Cachear lista de usuarios
   - Invalidar cache al actualizar
   - Reducir peticiones al servidor

3. **Lazy Loading de Imágenes**:
   - Cargar fotos de perfil bajo demanda
   - Placeholder mientras carga
   - Mejorar velocidad inicial

---

## 📚 Archivos Modificados

### Frontend

1. **`/js/users.js`** ⭐ NUEVO

   - Módulo JavaScript completo de gestión de usuarios
   - 700+ líneas de código
   - Documentación inline

2. **`/pages/users.page.php`** ✏️ MODIFICADO

   - Simplificado para usar script externo
   - Eliminado JavaScript inline
   - Eliminado botón "Nuevo Usuario"
   - Tabla vacía que se puebla dinámicamente

3. **`/views/dashboard.view.php`** ✅ YA CONFIGURADO
   - Dependencias de DataTables ya configuradas
   - Ruta `/dashboard/users` ya registrada

### Backend (sin cambios)

Los archivos del backend ya estaban implementados:

- `/routes/admin/list_users.php`
- `/routes/admin/det_user.php`
- `/routes/admin/up_user.php`

---

## ✅ Checklist de Implementación

### Funcionalidades Core

- [x] Listar usuarios con DataTables
- [x] Ver detalles en modal
- [x] Editar usuario en modal
- [x] Actualizar con backend PUT
- [x] Filtros de búsqueda
- [x] Filtros de estado
- [x] Filtros de rol
- [x] Estadísticas dinámicas
- [x] Avatares con iniciales o foto
- [x] Badges de rol y estado
- [x] Modo oscuro/claro

### UX/UI

- [x] Notificaciones Notyf
- [x] Loading states con SweetAlert2
- [x] Mensajes de error claros
- [x] Validación de formularios
- [x] Responsive design
- [x] Hover effects en cards
- [x] Animaciones suaves

### Seguridad

- [x] Verificación de dependencias
- [x] Validación de datos
- [x] Middleware de autenticación
- [x] Solo administradores pueden editar
- [x] Manejo de errores

### Performance

- [x] Carga asíncrona de datos
- [x] Paginación de tabla
- [x] Búsqueda client-side
- [x] Cache de datos de usuario actual
- [x] Lazy rendering de DataTables

### Documentación

- [x] Comentarios inline en código
- [x] Documentación de funciones
- [x] Este documento de implementación
- [x] Ejemplos de uso

---

## 🎯 Uso y Acceso

### URL de Acceso

```
http://localhost:9000/dashboard/users
```

### Permisos Requeridos

- ✅ Usuario autenticado
- ✅ Rol de administrador (role_id = 2)
- ✅ Estado activo (status_id = 1)

### Ejemplo de Navegación

1. **Login** como administrador
2. **Click** en "Dashboard" en el header
3. **Click** en "Usuarios" en el sidebar
4. **Explorar** tabla de usuarios
5. **Click** en botón "Ver" para detalles
6. **Click** en "Editar Usuario" para modificar
7. **Modificar** campos necesarios
8. **Guardar** cambios
9. **Verificar** tabla actualizada

---

**Última actualización**: Noviembre 6, 2025  
**Versión**: 1.0  
**Autor**: Roepard Labs Development Team  
**Estado**: ✅ Implementado y Probado
