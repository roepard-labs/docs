# 🔐 Header UI con Servicios de Autenticación

## 📋 Resumen

El `header.ui.php` ha sido actualizado para usar los **servicios reutilizables de autenticación** (`SessionService`, `RoleService`, `LogoutService`) en lugar de lógica inline.

## ✅ Cambios Implementados

### 1. **Eliminación de Lógica Inline**

**Antes** ❌:

- Lógica de logout con jQuery/fetch inline
- Confirmación manual con SweetAlert2
- Manejo de estados duplicado

**Después** ✅:

- Usa `LogoutService.logout()` con configuración
- Usa `LogoutService.attachToButton()` para auto-adjuntar
- Estado global sincronizado con `SessionStatus` y `RoleStatus`

### 2. **Integración con SessionService**

El header ahora escucha el evento `sessionChanged`:

```javascript
window.addEventListener("sessionChanged", function (event) {
  const session = event.detail;

  if (session.isAuthenticated) {
    // Mostrar dropdown de usuario
    updateHeaderUI(session, window.RoleStatus);
  } else {
    // Mostrar botón "Identifícate"
    updateHeaderUI(session, null);
  }
});
```

**Beneficios**:

- ✅ Actualización automática al cambiar sesión
- ✅ No necesita polling manual
- ✅ Sincronizado con estado global

### 3. **Integración con RoleService**

El header ahora escucha el evento `roleChanged`:

```javascript
window.addEventListener("roleChanged", function (event) {
  const role = event.detail;

  // Actualizar opciones del menú según rol
  if (role.isAdmin) {
    // Mostrar "Dashboard Admin"
  } else {
    // Mostrar "Mi Dashboard"
  }
});
```

**Beneficios**:

- ✅ Menú dinámico según permisos
- ✅ Detección automática de rol admin
- ✅ Badges de rol en dropdown

### 4. **Integración con LogoutService**

El header ahora usa `LogoutService.attachToButton()`:

```javascript
const logoutBtn = document.getElementById("logoutBtn");
if (logoutBtn && window.LogoutService) {
  window.LogoutService.attachToButton("#logoutBtn", {
    redirectUrl: "/",
  });
}
```

**Beneficios**:

- ✅ Confirmación automática con SweetAlert2
- ✅ Notificaciones con Notyf
- ✅ Limpieza de estados global
- ✅ Redirección configurable

## 🎯 Funcionalidades

### Actualización Dinámica del Header

El header se actualiza automáticamente en estos casos:

1. **Al cargar la página**: Verifica sesión y rol inicial
2. **Después de login**: SessionService dispara `sessionChanged`
3. **Después de cambio de rol**: RoleService dispara `roleChanged`
4. **Después de logout**: LogoutService limpia estados

### Construcción Dinámica del Dropdown

```javascript
function updateHeaderUI(sessionData, roleData) {
  if (sessionData.isAuthenticated) {
    // Construir HTML del dropdown
    const userHTML = `
            <div class="dropdown">
                <button>Usuario: ${user.first_name}</button>
                <ul>
                    ${role.isAdmin ? "Dashboard Admin" : "Mi Dashboard"}
                    ...
                </ul>
            </div>
        `;

    // Reemplazar contenido
    userDropdownContainer.innerHTML = userHTML;

    // Adjuntar LogoutService
    LogoutService.attachToButton("#logoutBtn");
  } else {
    // Mostrar botón "Identifícate"
  }
}
```

## 🔄 Flujo de Actualización

```
Página carga
    ↓
SessionService.check() automático
    ↓
Dispara 'sessionChanged' event
    ↓
Header escucha evento
    ↓
RoleService.check() automático (si autenticado)
    ↓
Dispara 'roleChanged' event
    ↓
Header escucha evento
    ↓
updateHeaderUI(session, role)
    ↓
Dropdown construido dinámicamente
    ↓
LogoutService.attachToButton()
    ↓
Header completamente funcional
```

## 📊 Comparación Antes/Después

### Logout

| Aspecto      | Antes               | Después                           |
| ------------ | ------------------- | --------------------------------- |
| Código       | 50+ líneas inline   | 3 líneas                          |
| Confirmación | SweetAlert2 manual  | LogoutService automático          |
| Notificación | Notyf manual        | LogoutService automático          |
| Limpieza     | No limpiaba estados | Limpia SessionStatus y RoleStatus |
| Reutilizable | ❌ No               | ✅ Sí                             |

### Verificación de Sesión

| Aspecto        | Antes           | Después                    |
| -------------- | --------------- | -------------------------- |
| Método         | PHP `$_SESSION` | SessionService             |
| Actualización  | Solo al cargar  | Automática con eventos     |
| Sincronización | No sincronizado | Estado global sincronizado |
| API calls      | Ninguno         | Automático cada 5 min      |

### Verificación de Rol

| Aspecto         | Antes                      | Después                 |
| --------------- | -------------------------- | ----------------------- |
| Método          | PHP `$_SESSION['role_id']` | RoleService             |
| Permisos        | Hard-coded                 | Sistema de permisos     |
| Actualización   | Solo al cargar             | Automática con eventos  |
| Detección admin | `role_id == 2`             | `RoleService.isAdmin()` |

## 🎨 Estructura del Header

```
header.ui.php
│
├── PHP Session Check (inicial)
│   ├── $isAuthenticated
│   ├── $userName
│   └── $userRole
│
├── HTML Structure
│   ├── Logo
│   ├── Navigation
│   └── User Actions
│       ├── Theme Toggle
│       └── Auth Button/Dropdown (dinámico)
│
└── JavaScript
    ├── Modal Trigger (existente)
    └── Auth Services Integration (NUEVO)
        ├── sessionChanged listener
        ├── roleChanged listener
        ├── updateHeaderUI()
        └── LogoutService.attachToButton()
```

## ✅ Verificación

### Checklist de Testing

- [ ] Header carga correctamente con PHP session
- [ ] SessionService actualiza header después de login
- [ ] RoleService muestra opciones correctas según rol
- [ ] LogoutService cierra sesión con confirmación
- [ ] Botón "Identifícate" abre modal correctamente
- [ ] Dropdown de usuario muestra nombre y rol
- [ ] Redirección a dashboard funciona según rol
- [ ] Sin errores en consola del navegador

### Comandos de Testing

```bash
# Verificar sintaxis PHP
php -l ui/header.ui.php

# Verificar sintaxis JavaScript
node --check composables/sessionCheck.js
node --check composables/roleCheck.js
node --check services/logoutService.js

# Iniciar servidor de desarrollo
php -S localhost:9000 router.php
```

### Escenarios de Prueba

1. **Usuario sin sesión**:

   - Header muestra botón "Identifícate"
   - Click abre modal de autenticación
   - Después de login, header se actualiza automáticamente

2. **Usuario autenticado (role_id = 1)**:

   - Header muestra dropdown con nombre
   - Menú muestra "Mi Dashboard"
   - Logout funciona con confirmación

3. **Usuario admin (role_id = 2)**:
   - Header muestra dropdown con nombre
   - Menú muestra "Dashboard Admin"
   - Badge muestra "Administrador"
   - Logout funciona con confirmación

## 🚀 Beneficios de la Integración

### Para Desarrolladores

- ✅ **Código más limpio**: Menos lógica inline
- ✅ **Reutilizable**: Servicios disponibles en cualquier componente
- ✅ **Mantenible**: Cambios en servicios afectan todo el sistema
- ✅ **Testeable**: Servicios independientes fáciles de probar
- ✅ **Documentado**: Estado global claro y eventos estándar

### Para Usuarios

- ✅ **Actualización automática**: Header se actualiza sin recargar
- ✅ **Feedback claro**: Confirmaciones y notificaciones consistentes
- ✅ **UX coherente**: Mismo comportamiento en toda la app
- ✅ **Sin bugs**: Lógica centralizada reduce errores

## 📚 Recursos Relacionados

- [Servicios de Autenticación - Guía de Uso](/docs/SERVICIOS-AUTH-GUIA.md)
- [SessionService](/composables/sessionCheck.js)
- [RoleService](/composables/roleCheck.js)
- [LogoutService](/services/logoutService.js)
- [AppLayout](/layout/AppLayout.php)

---

**Última actualización**: Noviembre 2025  
**HomeLab AR - Roepard Labs**
