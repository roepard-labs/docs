# 📚 Guía de Uso: Servicios de Autenticación Reutilizables

## 🎯 Servicios Disponibles

Estos servicios están disponibles globalmente en `window` y se inicializan automáticamente:

1. **SessionService** - Verificación de sesión activa
2. **RoleService** - Verificación de rol y permisos
3. **LogoutService** - Cierre de sesión

## 📖 Ejemplos de Uso

### 1️⃣ SessionService - Verificación de Sesión

#### Verificar si hay sesión activa

```javascript
// Auto-ejecuta al cargar la página
// Escuchar cambios de sesión
window.addEventListener("sessionChanged", function (event) {
  const session = event.detail;

  if (session.isAuthenticated) {
    console.log("Usuario autenticado:", session.userData);
    console.log("Nombre:", session.userData.first_name);
    console.log("Email:", session.userData.email);
  } else {
    console.log("No hay sesión activa");
  }
});

// Verificar manualmente
const session = await SessionService.check();
if (session.isAuthenticated) {
  console.log("Sesión válida");
}

// Obtener datos del usuario
const user = SessionService.getUser();
console.log("Usuario actual:", user);

// Verificar estado de autenticación
if (SessionService.isAuthenticated()) {
  // Mostrar contenido para usuarios autenticados
  document.getElementById("userContent").style.display = "block";
}
```

#### Actualizar UI según sesión

```html
<div id="loginButton" style="display: none;">
  <button onclick="openLoginModal()">Iniciar Sesión</button>
</div>

<div id="userInfo" style="display: none;">
  <span id="userName"></span>
  <button onclick="LogoutService.logout()">Cerrar Sesión</button>
</div>

<script>
  window.addEventListener("sessionChanged", function (event) {
    const session = event.detail;

    if (session.isAuthenticated) {
      // Mostrar info de usuario
      document.getElementById("userName").textContent =
        session.userData.first_name;
      document.getElementById("userInfo").style.display = "block";
      document.getElementById("loginButton").style.display = "none";
    } else {
      // Mostrar botón de login
      document.getElementById("loginButton").style.display = "block";
      document.getElementById("userInfo").style.display = "none";
    }
  });
</script>
```

### 2️⃣ RoleService - Verificación de Rol y Permisos

#### Verificar rol del usuario

```javascript
// Auto-ejecuta después de verificar sesión
// Escuchar cambios de rol
window.addEventListener("roleChanged", function (event) {
  const role = event.detail;

  console.log("Rol:", role.roleName);
  console.log("Es admin:", role.isAdmin);
  console.log("Permisos:", role.permissions);
});

// Verificar manualmente
const role = await RoleService.check();
console.log("Rol del usuario:", role.roleName);

// Verificar si es admin
if (RoleService.isAdmin()) {
  console.log("Usuario es administrador");
  // Mostrar panel de admin
}

// Verificar permisos específicos
if (RoleService.hasPermission("dashboard")) {
  // Permitir acceso al dashboard
}

if (RoleService.hasPermission("write")) {
  // Mostrar botón de editar
}

// Obtener información del rol
console.log("Role ID:", RoleService.getRoleId());
console.log("Role Name:", RoleService.getRoleName());
console.log("Can Access Dashboard:", RoleService.canAccessDashboard());
```

#### Redirigir según rol

```javascript
// Redirigir automáticamente según el rol
RoleService.redirectByRole();

// O con rutas personalizadas
RoleService.redirectByRole({
  admin: "/admin/dashboard",
  user: "/user/profile",
  supervisor: "/supervisor/panel",
  default: "/home",
});
```

#### Mostrar contenido según permisos

```html
<div id="adminPanel" style="display: none;">
  <h2>Panel de Administración</h2>
</div>

<div id="userContent" style="display: none;">
  <h2>Contenido de Usuario</h2>
</div>

<button id="editButton" style="display: none;">Editar</button>

<script>
  window.addEventListener("roleChanged", function (event) {
    const role = event.detail;

    // Mostrar panel según rol
    if (role.isAdmin) {
      document.getElementById("adminPanel").style.display = "block";
    }

    // Mostrar botones según permisos
    if (role.permissions.includes("write")) {
      document.getElementById("editButton").style.display = "block";
    }
  });
</script>
```

### 3️⃣ LogoutService - Cierre de Sesión

#### Logout con confirmación (por defecto)

```javascript
// Botón de logout con confirmación y notificación
document
  .getElementById("logoutBtn")
  .addEventListener("click", async function (e) {
    e.preventDefault();
    await LogoutService.logout();
    // Muestra confirmación → cierra sesión → notifica → redirige a /
  });

// Logout con opciones personalizadas
await LogoutService.logout({
  confirm: true, // Mostrar confirmación
  notification: true, // Mostrar notificación
  redirect: true, // Redirigir después
  redirectUrl: "/login", // URL personalizada
});
```

#### Logout sin confirmación

```javascript
// Logout directo sin preguntar
await LogoutService.logout({ confirm: false });
```

#### Logout silencioso

```javascript
// Sin confirmación, sin notificación
await LogoutService.logoutSilent("/login");
```

#### Auto-adjuntar a botones

```html
<!-- El servicio auto-detecta estos selectores -->
<button id="logoutBtn">Cerrar Sesión</button>
<button class="logout-btn">Salir</button>
<button data-logout>Logout</button>

<!-- O adjuntar manualmente -->
<button id="customLogout">Mi Botón</button>

<script>
  LogoutService.attachToButton("#customLogout", {
    redirectUrl: "/goodbye",
  });
</script>
```

## 🔄 Flujo Completo de Ejemplo

```html
<!DOCTYPE html>
<html>
  <head>
    <title>Mi Aplicación</title>
  </head>
  <body>
    <!-- Contenido para usuarios NO autenticados -->
    <div id="guestContent">
      <h1>Bienvenido</h1>
      <button onclick="showLogin()">Iniciar Sesión</button>
    </div>

    <!-- Contenido para usuarios autenticados -->
    <div id="userContent" style="display: none;">
      <h1>Hola, <span id="userName"></span>!</h1>
      <p>Rol: <span id="userRole"></span></p>
      <button id="logoutBtn">Cerrar Sesión</button>
    </div>

    <!-- Panel solo para administradores -->
    <div id="adminPanel" style="display: none;">
      <h2>Panel de Administración</h2>
      <button onclick="manageUsers()">Gestionar Usuarios</button>
    </div>

    <script>
      // Script se ejecuta automáticamente al cargar

      // Escuchar cambios de sesión
      window.addEventListener("sessionChanged", function (event) {
        const session = event.detail;

        if (session.checking) {
          console.log("Verificando sesión...");
          return;
        }

        if (session.isAuthenticated) {
          // Usuario autenticado
          document.getElementById("guestContent").style.display = "none";
          document.getElementById("userContent").style.display = "block";
          document.getElementById("userName").textContent =
            session.userData.first_name;
        } else {
          // Usuario no autenticado
          document.getElementById("guestContent").style.display = "block";
          document.getElementById("userContent").style.display = "none";
        }
      });

      // Escuchar cambios de rol
      window.addEventListener("roleChanged", function (event) {
        const role = event.detail;

        if (role.checking) {
          return;
        }

        // Mostrar rol
        document.getElementById("userRole").textContent =
          role.roleName || "Usuario";

        // Mostrar panel de admin si es admin
        if (role.isAdmin) {
          document.getElementById("adminPanel").style.display = "block";
        }
      });

      // Funciones auxiliares
      function showLogin() {
        // Abrir modal de login
        document.getElementById("authModal").style.display = "block";
      }

      function manageUsers() {
        if (RoleService.hasPermission("admin")) {
          window.location.href = "/admin/users";
        } else {
          alert("No tienes permisos para esta acción");
        }
      }
    </script>
  </body>
</html>
```

## 🎨 Ejemplo con PHP

```php
<?php
// El servicio funciona del lado del cliente (JavaScript)
// Pero puedes usar PHP para renderizar estado inicial
?>

<!DOCTYPE html>
<html>
<body>
    <div id="app">
        <!-- El contenido se actualizará con JavaScript -->
    </div>

    <script>
    // Esperar a que los servicios estén listos
    window.addEventListener('sessionChanged', function(event) {
        const session = event.detail;

        if (session.isAuthenticated) {
            // Cargar contenido dinámicamente
            fetch('/api/user/dashboard', {
                credentials: 'include'
            })
            .then(response => response.json())
            .then(data => {
                document.getElementById('app').innerHTML = data.html;
            });
        }
    });
    </script>
</body>
</html>
```

## 🔧 Estados Globales Disponibles

```javascript
// Estado de sesión
window.SessionStatus = {
  isAuthenticated: false,
  checking: true,
  lastCheck: null,
  userData: null,
  error: null,
};

// Estado de rol
window.RoleStatus = {
  checking: true,
  lastCheck: null,
  roleId: null,
  roleName: null,
  isAdmin: false,
  canAccessDashboard: false,
  permissions: [],
  error: null,
};
```

## 📊 Eventos Disponibles

```javascript
// Evento de cambio de sesión
window.addEventListener("sessionChanged", function (event) {
  console.log("Sesión cambió:", event.detail);
});

// Evento de cambio de rol
window.addEventListener("roleChanged", function (event) {
  console.log("Rol cambió:", event.detail);
});

// Evento de cambio de estado del backend
window.addEventListener("backendStatusChanged", function (event) {
  console.log("Backend estado:", event.detail);
});
```

## ✅ Checklist de Implementación

- [ ] Incluir servicios en `AppLayout.php` (ya incluidos automáticamente)
- [ ] Esperar eventos `sessionChanged` y `roleChanged` para actualizar UI
- [ ] Usar `LogoutService.logout()` en botones de cierre de sesión
- [ ] Verificar permisos con `RoleService.hasPermission()` antes de acciones
- [ ] No confiar solo en JavaScript - validar también en backend

## 🚀 Buenas Prácticas

1. **Siempre validar en backend**: JavaScript puede ser manipulado
2. **Escuchar eventos**: No hacer polling manual
3. **Usar estados globales**: `SessionStatus` y `RoleStatus` están sincronizados
4. **Manejar errores**: Verificar `error` en los estados
5. **Auto-inicialización**: Los servicios se ejecutan automáticamente

## 🎯 Casos de Uso Comunes

### Proteger una página

```javascript
window.addEventListener("sessionChanged", function (event) {
  if (!event.detail.isAuthenticated && !event.detail.checking) {
    // Redirigir a login si no está autenticado
    window.location.href = "/login";
  }
});
```

### Mostrar contenido según permisos

```javascript
window.addEventListener("roleChanged", function (event) {
  const role = event.detail;

  // Mostrar u ocultar elementos según permisos
  document.querySelectorAll("[data-permission]").forEach((element) => {
    const requiredPermission = element.dataset.permission;
    element.style.display = role.permissions.includes(requiredPermission)
      ? "block"
      : "none";
  });
});
```

### Personalizar UI según usuario

```javascript
window.addEventListener("sessionChanged", function (event) {
  if (event.detail.isAuthenticated) {
    const user = event.detail.userData;

    // Personalizar saludo
    document.getElementById(
      "greeting"
    ).textContent = `Hola, ${user.first_name}!`;

    // Cargar preferencias del usuario
    loadUserPreferences(user.user_id);
  }
});
```

---

**Última actualización**: Noviembre 2025  
**HomeLab AR - Roepard Labs**
