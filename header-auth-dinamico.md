# 🎯 Sistema de Autenticación Dinámica del Header

## 📋 Visión General

Sistema inteligente que cambia el botón del header según el estado de sesión del usuario. Cuando el usuario está autenticado, muestra un dropdown con su nombre y opciones personalizadas según su rol (admin/user).

---

## ✨ Características Implementadas

### 🔹 **Estado No Autenticado**
```
┌────────────────────────┐
│  [🔐 Ingresar]        │  ← Botón con gradiente aqua
└────────────────────────┘
```
- Botón "Ingresar" con gradiente
- Abre modal de autenticación
- Animación de hover con efecto onda

### 🔹 **Estado Autenticado**
```
┌─────────────────────────────┐
│  👤 Juan Pérez ▼           │  ← Dropdown con nombre
├─────────────────────────────┤
│  👤 Juan Pérez             │  ← Header del dropdown
├─────────────────────────────┤
│  📊 Dashboard Admin        │  ← Dashboard según rol
│  🎮 HomeLab VR             │  ← Link a VR
├─────────────────────────────┤
│  🚪 Cerrar Sesión          │  ← Logout con confirmación
└─────────────────────────────┘
```

---

## 🏗️ Arquitectura del Sistema

### 📦 **Archivos Creados/Modificados**

#### 1. `/js/header-auth.js` ✨ **NUEVO**
Script principal que maneja toda la lógica de autenticación dinámica.

**Funciones principales:**
```javascript
// Verificar sesión al cargar
checkUserSession()

// Actualizar header con info de usuario
updateHeaderWithUserInfo(userData)

// Mostrar botón de login
showLoginButton()

// Cerrar sesión
logoutUser()

// Refrescar después de login
refreshHeaderAfterLogin()
```

#### 2. `/api/routes/check_session.php` 🔄 **ACTUALIZADO**
Endpoint que verifica sesión y devuelve datos del usuario.

**Respuesta JSON:**
```json
{
    "status": "success",
    "message": "Sesión válida y usuario activo",
    "logged": true,
    "user_data": {
        "user_id": 1,
        "first_name": "Juan",
        "last_name": "Pérez",
        "email": "juan@example.com",
        "role_id": 2
    }
}
```

#### 3. `/ui/header.ui.php` 🔄 **ACTUALIZADO**
Ahora incluye un contenedor dinámico `.header-auth-container` que se modifica con JavaScript.

```html
<div class="header-auth-container">
    <!-- Contenido dinámico -->
</div>
```

#### 4. `/modals/auth.modal.php` 🔄 **ACTUALIZADO**
Modal actualizado para llamar a `refreshHeaderAfterLogin()` después del login exitoso.

#### 5. `/views/home.view.php` 🔄 **ACTUALIZADO**
Incluye el script `header-auth.js` en las librerías.

---

## 🔄 Flujo de Funcionamiento

### **1. Carga de Página**
```
Usuario carga home.view.php
        ↓
DOMContentLoaded event
        ↓
checkUserSession() se ejecuta
        ↓
Fetch a check_session.php
        ↓
    ┌───┴───┐
    │       │
Sesión  No sesión
válida    activa
    │       │
    ↓       ↓
Update  Mostrar
Header   Login
          Button
```

### **2. Login Exitoso**
```
Usuario completa login en modal
        ↓
auth_user.php responde success
        ↓
SweetAlert muestra "¡Bienvenido!"
        ↓
refreshHeaderAfterLogin()
        ↓
checkUserSession()
        ↓
updateHeaderWithUserInfo(userData)
        ↓
Header muestra dropdown con nombre
```

### **3. Logout**
```
Usuario click en "Cerrar Sesión"
        ↓
SweetAlert confirmación
        ↓
Usuario confirma
        ↓
Fetch a logout_user.php
        ↓
Sesión destruida en servidor
        ↓
SweetAlert "¡Hasta pronto!"
        ↓
Redirect a home.view.php
```

---

## 🎨 Diferencias por Rol

### **Usuario Normal (role_id = 1)**
```javascript
Dashboard URL: "../views/user.dashboard.view.php"
Dashboard Label: "Mi Dashboard"
```

**Dropdown Options:**
```
👤 Juan Pérez
─────────────
📊 Mi Dashboard
🎮 HomeLab VR
─────────────
🚪 Cerrar Sesión
```

### **Administrador (role_id = 2)**
```javascript
Dashboard URL: "../views/admin.dashboard.view.php"
Dashboard Label: "Dashboard Admin"
```

**Dropdown Options:**
```
👤 Juan Pérez (Admin)
─────────────────────
📊 Dashboard Admin
🎮 HomeLab VR
─────────────────────
🚪 Cerrar Sesión
```

---

## 🎯 Detalles Técnicos

### **1. Verificación de Sesión**

**Endpoint:** `GET /api/routes/check_session.php`

**Headers:**
```javascript
{
    'Content-Type': 'application/json'
}
```

**Respuesta Exitosa (200):**
```json
{
    "status": "success",
    "message": "Sesión válida y usuario activo",
    "logged": true,
    "user_data": {
        "user_id": 1,
        "first_name": "Juan",
        "last_name": "Pérez",
        "email": "juan@example.com",
        "role_id": 2
    }
}
```

**Respuesta Error (401/403):**
```json
{
    "status": "error",
    "message": "No autenticado",
    "logged": false
}
```

### **2. Cierre de Sesión**

**Endpoint:** `POST /api/routes/logout_user.php`

**Headers:**
```javascript
{
    'Content-Type': 'application/json'
}
```

**Respuesta Exitosa (200):**
```json
{
    "status": "success",
    "message": "Sesión cerrada correctamente"
}
```

---

## 🎨 Estilos CSS Aplicados

### **Botón de Usuario**
```css
.btn-user-dropdown {
    background: linear-gradient(135deg, #00b4d8, #0096c7);
    color: white;
    border: none;
    padding: 0.625rem 1.5rem;
    font-weight: 600;
    box-shadow: 0 4px 15px rgba(0, 180, 216, 0.3);
    transition: all 0.3s ease;
}

.btn-user-dropdown:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(0, 180, 216, 0.4);
}
```

### **Dropdown Menu**
```css
.user-dropdown-menu {
    min-width: 200px;
    border: 1px solid var(--hl-border-dark);
    box-shadow: var(--hl-shadow-xl);
    background: var(--hl-bg-dark-secondary);
    backdrop-filter: blur(10px);
    animation: slideDown 0.3s ease-out;
}
```

### **Items del Dropdown**
```css
.user-dropdown-menu .dropdown-item {
    padding: 0.75rem 1.25rem;
    border-radius: 0.375rem;
    margin: 0.25rem 0.5rem;
    transition: all 0.3s ease;
}

.user-dropdown-menu .dropdown-item:hover {
    background: rgba(0, 180, 216, 0.15);
    color: var(--hl-primary);
    transform: translateX(5px);
}
```

### **Animaciones**
```css
@keyframes slideDown {
    from {
        opacity: 0;
        transform: translateY(-10px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}
```

---

## 📱 Responsive Design

### **Desktop (> 768px)**
- Dropdown con tamaño completo
- Padding generoso
- Animaciones fluidas
- Iconos visibles

### **Mobile (< 768px)**
```css
.btn-user-dropdown {
    padding: 0.5rem 1rem;
    font-size: 0.9rem;
}

.user-dropdown-menu {
    min-width: 180px;
}
```

---

## 🔧 Integración con Otras Vistas

### **Para agregar en otras vistas:**

**1. Incluir el script:**
```html
<!-- Antes de cerrar </body> -->
<script src="../js/header-auth.js"></script>
```

**2. Asegurar que el header incluye el contenedor:**
```php
<?php include __DIR__ . '/../ui/header.ui.php'; ?>
```

**3. Verificar que Bootstrap 5 está cargado:**
```html
<script src="../dist/bootstrap/js/bootstrap.min.js"></script>
```

---

## ✅ Testing

### **1. Test de Sesión No Activa**
```bash
# Abrir navegador en modo incógnito
# Ir a: http://localhost:3000/views/home.view.php
# Verificar: Debe mostrar botón "Ingresar"
# Click en botón: Debe abrir modal de autenticación
```

### **2. Test de Login**
```bash
# Completar formulario de login con credenciales válidas
# Click en "Iniciar Sesión"
# Verificar: Modal se cierra
# Verificar: Botón cambia a dropdown con nombre del usuario
# Verificar: Dropdown muestra opciones correctas según rol
```

### **3. Test de Dropdown**
```bash
# Con sesión activa
# Click en nombre de usuario
# Verificar: Dropdown se despliega con animación
# Hover sobre opciones: Verificar animación de desplazamiento
# Click en "Dashboard": Debe redirigir a dashboard correcto
# Click en "HomeLab VR": Debe redirigir a homelab.php
```

### **4. Test de Logout**
```bash
# Con sesión activa
# Click en nombre de usuario
# Click en "Cerrar Sesión"
# Verificar: SweetAlert de confirmación
# Click en "Sí, salir"
# Verificar: SweetAlert "¡Hasta pronto!"
# Verificar: Redirección a home
# Verificar: Botón vuelve a ser "Ingresar"
```

### **5. Test de Roles**
```bash
# Login como usuario normal (role_id = 1)
# Verificar: Dropdown muestra "Mi Dashboard"
# Verificar: Link va a user.dashboard.view.php

# Login como admin (role_id = 2)
# Verificar: Dropdown muestra "Dashboard Admin"
# Verificar: Link va a admin.dashboard.view.php
```

---

## 🐛 Troubleshooting

### **Problema: Botón no cambia después del login**

**Solución:**
```javascript
// Verificar que header-auth.js está cargado
console.log(typeof checkUserSession); // Debe ser "function"

// Verificar que la función se ejecuta
checkUserSession();

// Verificar respuesta del servidor
fetch('../api/routes/check_session.php')
    .then(r => r.json())
    .then(d => console.log(d));
```

### **Problema: Dropdown no se despliega**

**Solución:**
```javascript
// Verificar que Bootstrap 5 está cargado
console.log(typeof bootstrap); // Debe ser "object"

// Verificar que el botón tiene los atributos correctos
const btn = document.querySelector('[data-bs-toggle="dropdown"]');
console.log(btn); // Debe existir
```

### **Problema: Error 401 en check_session.php**

**Solución:**
```php
// Verificar que la sesión está iniciada
session_start();
print_r($_SESSION); // Debe tener datos de usuario

// Verificar que las variables de sesión existen
echo isset($_SESSION['user_id']) ? 'OK' : 'No existe';
```

### **Problema: Logout no funciona**

**Solución:**
```javascript
// Verificar endpoint
fetch('../api/routes/logout_user.php', {method: 'POST'})
    .then(r => r.json())
    .then(d => console.log(d));

// Verificar que SweetAlert está cargado
console.log(typeof Swal); // Debe ser "function"
```

---

## 🚀 Mejoras Futuras

### **1. Avatar del Usuario**
```javascript
// Agregar imagen de perfil
<img src="${userData.avatar_url}" 
     class="rounded-circle me-2" 
     width="32" height="32">
<span class="user-name">${fullName}</span>
```

### **2. Notificaciones en Dropdown**
```javascript
// Badge con número de notificaciones
<span class="badge bg-danger ms-2">${userData.notifications_count}</span>
```

### **3. Indicador de Rol**
```javascript
// Mostrar badge de rol
${userData.role_id === 2 ? '<span class="badge bg-primary ms-2">Admin</span>' : ''}
```

### **4. Último Acceso**
```javascript
// Mostrar fecha de último acceso
<li class="dropdown-header text-muted small">
    Último acceso: ${formatDate(userData.last_login)}
</li>
```

### **5. Cambio Rápido de Tema**
```javascript
// Toggle de dark/light mode en dropdown
<li>
    <a class="dropdown-item" href="#" onclick="toggleTheme()">
        <i class="bx bx-moon me-2"></i> Cambiar Tema
    </a>
</li>
```

---

## 📚 Referencias de API

### **Endpoints Utilizados:**

| Endpoint | Método | Propósito | Autenticación |
|----------|--------|-----------|---------------|
| `/api/routes/check_session.php` | GET | Verificar sesión | No requerida |
| `/api/routes/auth_user.php` | POST | Login | No requerida |
| `/api/routes/logout_user.php` | POST | Logout | No requerida |

### **Variables de Sesión:**

| Variable | Tipo | Descripción |
|----------|------|-------------|
| `$_SESSION['user_id']` | int | ID del usuario |
| `$_SESSION['first_name']` | string | Nombre |
| `$_SESSION['last_name']` | string | Apellido |
| `$_SESSION['email']` | string | Email |
| `$_SESSION['role_id']` | int | Rol (1=user, 2=admin) |

---

## 🎯 Casos de Uso

### **Caso 1: Usuario nuevo visita el sitio**
1. Usuario entra a `home.view.php`
2. `checkUserSession()` detecta: no hay sesión
3. Muestra botón "Ingresar"
4. Usuario hace login
5. Header se actualiza con su nombre
6. Puede acceder a su dashboard

### **Caso 2: Usuario con sesión activa navega**
1. Usuario entra a `home.view.php` (ya logueado previamente)
2. `checkUserSession()` detecta: sesión válida
3. Muestra dropdown con nombre del usuario
4. Usuario puede navegar a dashboard o cerrar sesión

### **Caso 3: Admin necesita acceder al panel**
1. Admin hace login
2. Sistema detecta `role_id = 2`
3. Dropdown muestra "Dashboard Admin"
4. Click lleva a `admin.dashboard.view.php`

### **Caso 4: Usuario cierra sesión**
1. Usuario click en dropdown
2. Click en "Cerrar Sesión"
3. Confirma en SweetAlert
4. Sesión se destruye
5. Header vuelve a mostrar "Ingresar"

---

**¡Sistema de autenticación dinámica completamente funcional! 🚀**

## 📊 Diagrama de Componentes

```
┌─────────────────────────────────────────────────────────┐
│                     home.view.php                       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │            header.ui.php (Include)               │  │
│  │  ┌────────────────────────────────────────────┐ │  │
│  │  │    .header-auth-container (Dinámico)      │ │  │
│  │  │                                            │ │  │
│  │  │  No Auth:  [🔐 Ingresar]                  │ │  │
│  │  │                                            │ │  │
│  │  │  Auth:     👤 Juan Pérez ▼                │ │  │
│  │  │            ├─ Dashboard                    │ │  │
│  │  │            ├─ HomeLab VR                   │ │  │
│  │  │            └─ Cerrar Sesión                │ │  │
│  │  └────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │       auth.modal.php (Login/Register)           │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │         <script src="header-auth.js">           │  │
│  │                                                  │  │
│  │  • checkUserSession()                           │  │
│  │  • updateHeaderWithUserInfo()                   │  │
│  │  • logoutUser()                                 │  │
│  │  • refreshHeaderAfterLogin()                    │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                        ↓
                        ↓ Fetch API
                        ↓
┌─────────────────────────────────────────────────────────┐
│                  Backend API (PHP)                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  GET /api/routes/check_session.php                     │
│  → Verifica sesión activa                              │
│  → Retorna datos del usuario                           │
│                                                         │
│  POST /api/routes/auth_user.php                        │
│  → Autentica usuario                                   │
│  → Crea sesión PHP                                     │
│                                                         │
│  POST /api/routes/logout_user.php                      │
│  → Destruye sesión                                     │
│  → Limpia cookies                                      │
│                                                         │
└─────────────────────────────────────────────────────────┘
```
