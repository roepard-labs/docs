# 🏗️ Arquitectura de Layouts - HomeLab AR

## 📚 Índice
1. [Visión General](#visión-general)
2. [Jerarquía de Layouts](#jerarquía-de-layouts)
3. [AppLayout - Base del Sistema](#applayout---base-del-sistema)
4. [AdminLayout](#adminlayout)
5. [UserLayout](#userlayout)
6. [Guía de Uso](#guía-de-uso)
7. [Migración desde BaseLayout](#migración-desde-baselayout)

---

## 🎯 Visión General

El sistema de layouts de HomeLab AR está construido con una **arquitectura jerárquica limpia** que facilita:

- ✅ **Reutilización de código**: Componentes compartidos entre todas las vistas
- ✅ **Separación de responsabilidades**: Cada layout tiene un propósito específico
- ✅ **Facilidad de mantenimiento**: Cambios centralizados en AppLayout
- ✅ **Seguridad por capas**: Validación de permisos en cada nivel
- ✅ **Bootstrap 5**: Framework CSS moderno y responsivo

---

## 🌳 Jerarquía de Layouts

```
AppLayout (Base)
├── AdminLayout (Administradores)
│   ├── admin.dashboard.view.php
│   ├── users.view.php
│   └── settings.view.php
│
└── UserLayout (Usuarios)
    ├── user.dashboard.view.php
    └── profile.view.php
```

### 📦 Ubicación de Archivos

```
/var/www/roepard-homelab/
├── layout/
│   └── AppLayout.php          # ⭐ Base principal
├── layouts/
│   ├── AdminLayout.php        # Hereda de AppLayout
│   ├── UserLayout.php         # Hereda de AppLayout
│   └── BaseLayout.php         # ⚠️ OBSOLETO (usar AppLayout)
├── views/
│   ├── admin.dashboard.view.php
│   └── user.dashboard.view.php
├── ui/
│   ├── header.ui.php
│   ├── footer.ui.php
│   └── sidebar.ui.php
└── modals/
    └── auth.modal.php
```

---

## ⭐ AppLayout - Base del Sistema

**Ubicación**: `/layout/AppLayout.php`

### 🔑 Características Principales

1. **Bootstrap 5**: Framework CSS principal
2. **Sistema de Temas**: Dark/Light mode automático
3. **Componentes Modulares**: Header, Footer, Sidebar, Auth Modal
4. **Gestión de Scripts**: Core scripts + custom scripts
5. **Gestión de Estilos**: Core styles + custom styles

### 📋 Métodos Principales

```php
// Renderizar layout completo
AppLayout::render([
    'title' => 'Page Title',
    'content' => '<div>HTML content</div>',
    'scripts' => ['../js/custom.js'],
    'styles' => ['../css/custom.css'],
    'bodyClass' => 'page-home',
    'includeHeader' => true,
    'includeFooter' => true,
    'includeSidebar' => false,
    'includeAuthModal' => true,
    'dataTheme' => 'dark',
    'lang' => 'es'
]);

// Construir contenido con secciones
$content = AppLayout::buildContent([
    '<section class="hero">Hero Content</section>',
    '<section class="features">Features Content</section>'
]);

// Renderizar sección específica
$heroSection = AppLayout::renderSection('hero.section.php', [
    'title' => 'Welcome',
    'subtitle' => 'To HomeLab AR'
]);

// Renderizar componente
$cardComponent = AppLayout::renderComponent('card.component.php', [
    'title' => 'Card Title',
    'content' => 'Card content'
]);
```

### 🎨 Estilos Core Incluidos

AppLayout carga automáticamente:

```html
<!-- CSS Variables & Main Styles -->
variables.css
main.css

<!-- Bootstrap 5 CSS -->
bootstrap.min.css

<!-- Icons -->
boxicons.min.css (basic + animations)

<!-- Animations -->
animate.min.css
aos.css

<!-- UI Components -->
sweetalert2.min.css
notyf.min.css
```

### 📦 Scripts Core Incluidos

```html
<!-- Core Libraries -->
jquery.min.js
popper.min.js
bootstrap.min.js

<!-- Animations -->
aos.js (con inicialización automática)

<!-- UI Components -->
sweetalert2.all.min.js
notyf.min.js

<!-- Sistema de Temas -->
color-mode-toggler.js

<!-- Autenticación Dinámica -->
header-auth.js
```

---

## 👨‍💼 AdminLayout

**Ubicación**: `/layouts/AdminLayout.php`

### 🎯 Propósito

Layout especializado para **paneles de administración** con:

- ✅ Verificación de rol de administrador (role_id = 2)
- ✅ Sidebar de navegación incluido
- ✅ Estilos específicos de dashboard
- ✅ Scripts de gestión de usuarios

### 🔐 Seguridad

```php
private static function checkAdminPermissions() {
    Auth::checkAuth();           // Usuario autenticado
    Status::checkStatus(1);      // Usuario activo
    
    // Solo role_id = 2 (admin)
    if ($_SESSION['role_id'] != 2) {
        header('Location: ../views/home.view.php');
        exit('Acceso denegado');
    }
}
```

### 📝 Uso Básico

```php
<?php
require_once __DIR__ . '/../layouts/AdminLayout.php';

ob_start();
?>
<div class="container-fluid">
    <h1>Admin Dashboard</h1>
    <!-- Contenido del dashboard -->
</div>
<?php
$content = ob_get_clean();

AdminLayout::render([
    'title' => 'Admin Dashboard',
    'content' => $content,
    'activeMenu' => 'dashboard', // Menú activo en sidebar
    'scripts' => ['../js/admin.js']
]);
?>
```

### 🎨 Configuración Por Defecto

```php
[
    'title' => 'Admin Panel',
    'bodyClass' => 'admin-panel has-sidebar',
    'includeSidebar' => true,
    'includeHeader' => true,
    'includeFooter' => true,
    'dataTheme' => 'dark',
    'activeMenu' => 'dashboard',
    'styles' => [
        '../css/dashboard.css',
        '../css/sidebar.css'
    ],
    'scripts' => [
        '../dist/sweetalert2/sweetalert2.all.min.js',
        '../dist/notyf/notyf.min.js',
        '../js/dashboard.js'
    ]
]
```

### 🧩 Método Helper: statsSection()

```php
<?php
$stats = [
    [
        'label' => 'Total Usuarios',
        'value' => '150',
        'icon' => 'user',
        'color' => 'primary'
    ],
    [
        'label' => 'Activos Hoy',
        'value' => '45',
        'icon' => 'trending-up',
        'color' => 'success'
    ]
];

echo AdminLayout::statsSection($stats);
?>
```

---

## 👤 UserLayout

**Ubicación**: `/layouts/UserLayout.php`

### 🎯 Propósito

Layout para **usuarios autenticados no administradores** con:

- ✅ Verificación de autenticación
- ✅ Sin sidebar (interfaz simplificada)
- ✅ Estilos de dashboard de usuario
- ✅ Componentes de perfil

### 🔐 Seguridad

```php
private static function checkUserPermissions() {
    Auth::checkAuth();       // Usuario autenticado
    Status::checkStatus(1);  // Usuario activo
}
```

### 📝 Uso Básico

```php
<?php
require_once __DIR__ . '/../layouts/UserLayout.php';

ob_start();
?>
<div class="container">
    <h1>Mi Dashboard</h1>
    <!-- Contenido del usuario -->
</div>
<?php
$content = ob_get_clean();

UserLayout::render([
    'title' => 'Mi Dashboard',
    'content' => $content,
    'scripts' => ['../js/user.js']
]);
?>
```

### 🎨 Configuración Por Defecto

```php
[
    'title' => 'Mi Panel',
    'bodyClass' => 'user-panel',
    'includeSidebar' => false,
    'includeHeader' => true,
    'includeFooter' => true,
    'dataTheme' => 'dark',
    'styles' => ['../css/dashboard.css'],
    'scripts' => [
        '../dist/sweetalert2/sweetalert2.all.min.js',
        '../dist/notyf/notyf.min.js'
    ]
]
```

### 🧩 Método Helper: profileCard()

```php
<?php
$userData = [
    'first_name' => 'Juan',
    'last_name' => 'Pérez',
    'email' => 'juan@example.com'
];

echo UserLayout::profileCard($userData);
?>
```

---

## 📖 Guía de Uso

### 1️⃣ Vista Simple (sin autenticación)

```php
<?php
require_once __DIR__ . '/../layout/AppLayout.php';

ob_start();
?>
<section class="hero">
    <h1>Bienvenido a HomeLab AR</h1>
</section>
<?php
$content = ob_get_clean();

AppLayout::render([
    'title' => 'Home',
    'content' => $content,
    'bodyClass' => 'page-home',
    'scripts' => ['../js/home.js'],
    'styles' => ['../css/home.css']
]);
?>
```

### 2️⃣ Vista de Administrador

```php
<?php
require_once __DIR__ . '/../layouts/AdminLayout.php';

ob_start();
?>
<div class="container-fluid">
    <div class="row">
        <div class="col-12">
            <h1>Panel de Administración</h1>
        </div>
    </div>
    
    <?php
    $stats = [
        ['label' => 'Usuarios', 'value' => '150', 'icon' => 'user', 'color' => 'primary']
    ];
    echo AdminLayout::statsSection($stats);
    ?>
</div>
<?php
$content = ob_get_clean();

AdminLayout::render([
    'title' => 'Admin Dashboard',
    'content' => $content,
    'activeMenu' => 'dashboard'
]);
?>
```

### 3️⃣ Vista de Usuario

```php
<?php
require_once __DIR__ . '/../layouts/UserLayout.php';

ob_start();
?>
<div class="container py-4">
    <?php
    echo UserLayout::profileCard($_SESSION);
    ?>
    
    <div class="row mt-4">
        <div class="col-md-6">
            <div class="card">
                <div class="card-body">
                    <h5>Mis Proyectos</h5>
                    <!-- Contenido -->
                </div>
            </div>
        </div>
    </div>
</div>
<?php
$content = ob_get_clean();

UserLayout::render([
    'title' => 'Mi Dashboard',
    'content' => $content
]);
?>
```

### 4️⃣ Vista con Componentes Personalizados

```php
<?php
require_once __DIR__ . '/../layout/AppLayout.php';

// Construir contenido con secciones
$content = AppLayout::buildContent([
    // Sección hero
    function() {
        echo AppLayout::renderSection('hero.section.php', [
            'title' => 'HomeLab AR',
            'subtitle' => 'Realidad Aumentada para Educación'
        ]);
    },
    
    // Componente de características
    function() {
        echo AppLayout::renderComponent('features.component.php', [
            'features' => [
                ['title' => 'AR/VR', 'icon' => 'cube'],
                ['title' => 'Educativo', 'icon' => 'book']
            ]
        ]);
    },
    
    // HTML directo
    '<section class="cta">
        <div class="container">
            <h2>Comienza Ahora</h2>
            <a href="#" class="btn btn-primary">Explorar</a>
        </div>
    </section>'
]);

AppLayout::render([
    'title' => 'Home',
    'content' => $content,
    'scripts' => ['../js/home.js'],
    'styles' => ['../css/home.css']
]);
?>
```

---

## 🔄 Migración desde BaseLayout

### ⚠️ BaseLayout está OBSOLETO

Si tienes código usando `BaseLayout`, actualízalo así:

#### ❌ Antes (BaseLayout)

```php
require_once __DIR__ . '/BaseLayout.php';

BaseLayout::render([
    'title' => 'Page Title',
    'content' => $content
]);
```

#### ✅ Después (AppLayout)

```php
require_once __DIR__ . '/../layout/AppLayout.php';

AppLayout::render([
    'title' => 'Page Title',
    'content' => $content
]);
```

### 📋 Checklist de Migración

- [ ] Cambiar `require_once` de `BaseLayout.php` a `AppLayout.php`
- [ ] Actualizar ruta: `/layouts/BaseLayout.php` → `/layout/AppLayout.php`
- [ ] Cambiar clase: `BaseLayout::` → `AppLayout::`
- [ ] Verificar que los estilos carguen Bootstrap 5 (no Halfmoon)
- [ ] Probar autenticación con header dinámico
- [ ] Verificar modal de autenticación funcione
- [ ] Probar cambio de tema dark/light

---

## 🎨 Personalización

### Custom CSS

```php
AppLayout::render([
    'title' => 'My Page',
    'content' => $content,
    'styles' => [
        '../css/custom-theme.css',
        '../css/custom-components.css'
    ]
]);
```

### Custom JavaScript

```php
AppLayout::render([
    'title' => 'My Page',
    'content' => $content,
    'scripts' => [
        '../js/custom-animations.js',
        '../js/custom-interactions.js'
    ]
]);
```

### Custom Body Class

```php
AppLayout::render([
    'title' => 'My Page',
    'content' => $content,
    'bodyClass' => 'page-special gradient-bg'
]);
```

### Custom Theme

```php
AppLayout::render([
    'title' => 'My Page',
    'content' => $content,
    'dataTheme' => 'light' // 'dark' | 'light' | 'auto'
]);
```

### Sin Header/Footer

```php
AppLayout::render([
    'title' => 'Clean Page',
    'content' => $content,
    'includeHeader' => false,
    'includeFooter' => false,
    'includeAuthModal' => false
]);
```

---

## 🧩 Componentes UI

### Header Dinámico

**Ubicación**: `/ui/header.ui.php`

**Características**:
- Logo de HomeLab AR
- Toggle de tema (dark/light)
- Botón de autenticación dinámico:
  - Sin sesión: "Ingresar" (abre modal)
  - Con sesión: Dropdown con nombre de usuario

**Script**: `header-auth.js` (cargado automáticamente)

### Footer

**Ubicación**: `/ui/footer.ui.php`

**Características**:
- Copyright
- Links útiles
- Redes sociales

### Sidebar

**Ubicación**: `/ui/sidebar.ui.php`

**Características**:
- Navegación de administrador
- Menú activo según `activeMenu`
- Solo visible en AdminLayout

### Modal de Autenticación

**Ubicación**: `/modals/auth.modal.php`

**Características**:
- Tabs: Login / Register
- Validación de formularios
- Integración con header-auth.js
- SweetAlert2 para mensajes

---

## 🚀 Best Practices

### ✅ DO

```php
// Usar AppLayout para todas las vistas nuevas
AppLayout::render([...]);

// Usar AdminLayout para paneles de admin
AdminLayout::render([...]);

// Usar UserLayout para dashboards de usuario
UserLayout::render([...]);

// Construir contenido con ob_start/ob_get_clean
ob_start();
?>
<div>HTML content</div>
<?php
$content = ob_get_clean();

// Usar buildContent para secciones complejas
$content = AppLayout::buildContent([...]);
```

### ❌ DON'T

```php
// No usar BaseLayout (obsoleto)
BaseLayout::render([...]); // ❌

// No mezclar HTML directo con echo
echo '<div>';
AppLayout::render([...]);
echo '</div>'; // ❌

// No hardcodear rutas absolutas
require_once '/var/www/roepard-homelab/layout/AppLayout.php'; // ❌
// Usar rutas relativas:
require_once __DIR__ . '/../layout/AppLayout.php'; // ✅

// No omitir verificaciones de seguridad en layouts protegidos
// AdminLayout y UserLayout ya incluyen verificaciones
```

---

## 🔍 Troubleshooting

### Problema: "Class AppLayout not found"

**Solución**: Verificar ruta del require_once

```php
// Desde /views/
require_once __DIR__ . '/../layout/AppLayout.php';

// Desde /pages/
require_once __DIR__ . '/../layout/AppLayout.php';
```

### Problema: "Acceso denegado" en AdminLayout

**Solución**: Verificar rol en base de datos

```sql
SELECT user_id, first_name, role_id FROM users WHERE user_id = 1;
-- role_id debe ser 2 para admin
```

### Problema: Estilos no cargan

**Solución**: Verificar rutas relativas

```php
'styles' => [
    '../css/custom.css' // Correcto desde /views/
]
```

### Problema: Header dinámico no funciona

**Solución**: Verificar que header-auth.js se cargue

```html
<!-- AppLayout lo carga automáticamente -->
<script src="../js/header-auth.js"></script>
```

### Problema: Modal no se abre

**Solución**: Verificar Bootstrap JS y includeAuthModal

```php
AppLayout::render([
    'includeAuthModal' => true // Debe ser true
]);
```

---

## 📚 Resumen

| Layout | Ubicación | Hereda de | Uso | Seguridad |
|--------|-----------|-----------|-----|-----------|
| **AppLayout** | `/layout/AppLayout.php` | - | Base para todas las vistas | - |
| **AdminLayout** | `/layouts/AdminLayout.php` | AppLayout | Paneles de admin | role_id = 2 |
| **UserLayout** | `/layouts/UserLayout.php` | AppLayout | Dashboards de usuario | Autenticado + Activo |
| ~~BaseLayout~~ | `/layouts/BaseLayout.php` | - | ⚠️ OBSOLETO | - |

---

**Última actualización**: Enero 2025  
**Framework CSS**: Bootstrap 5  
**Arquitectura**: MVC con Layouts Jerárquicos  
**Seguridad**: Middleware Auth + Status + Role Validation
