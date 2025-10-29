# 🎨 Sistema de Layouts y Componentes - HomeLab AR

## 📋 Índice
1. [Introducción](#introducción)
2. [Paleta de Colores](#paleta-de-colores)
3. [Estructura del Sistema](#estructura-del-sistema)
4. [Layouts](#layouts)
5. [UI Components](#ui-components)
6. [Sections](#sections)
7. [Ejemplos de Uso](#ejemplos-de-uso)
8. [CSS Optimizado](#css-optimizado)

---

## 🎯 Introducción

Sistema modular y escalable basado en **Halfmoon CSS** con paleta de colores azul/aqua. 
Arquitectura limpia que separa responsabilidades y facilita el mantenimiento.

### Características Principales
- ✅ **Modular**: Componentes reutilizables e independientes
- ✅ **Escalable**: Fácil de extender y mantener
- ✅ **Responsive**: Optimizado para todos los dispositivos
- ✅ **Accesible**: Siguiendo estándares WCAG
- ✅ **Performante**: CSS optimizado y carga condicional

---

## 🎨 Paleta de Colores

### Colores Primarios - Azul Aqua
```css
--hl-primary: #00b4d8;           /* Aqua brillante */
--hl-primary-dark: #0096c7;      /* Aqua oscuro */
--hl-primary-light: #48cae4;     /* Aqua claro */
--hl-primary-pale: #90e0ef;      /* Aqua pálido */
--hl-primary-ghost: #caf0f8;     /* Aqua fantasma */
```

### Colores Secundarios
```css
--hl-secondary: #023e8a;         /* Azul profundo */
--hl-secondary-dark: #03045e;    /* Azul marino */
--hl-secondary-light: #0077b6;   /* Azul medio */
```

### Colores de Estado
```css
--hl-success: #06d6a0;           /* Verde aqua */
--hl-danger: #ef476f;            /* Rojo coral */
--hl-warning: #ffd60a;           /* Amarillo */
--hl-info: #00b4d8;              /* Info = Primary */
```

### Uso en HTML
```html
<button style="background: var(--hl-primary); color: white;">
    Botón Primario
</button>

<div style="border: 2px solid var(--hl-primary); border-radius: var(--hl-radius-lg);">
    Card con borde aqua
</div>
```

---

## 🏗️ Estructura del Sistema

```
/roepard-homelab/
├── layouts/
│   ├── BaseLayout.php       # Layout base (padre)
│   ├── AdminLayout.php      # Layout de administrador
│   └── UserLayout.php       # Layout de usuario
├── ui/
│   ├── header.ui.php        # Header global
│   ├── footer.ui.php        # Footer global
│   ├── sidebar.ui.php       # Sidebar (admin)
│   └── navbar.ui.php        # Navbar alternativo
├── sections/
│   ├── hero.section.php     # Sección hero
│   ├── features.section.php # Características
│   ├── stats.section.php    # Estadísticas
│   └── ...                  # Más secciones
├── css/
│   ├── variables.css        # Variables globales
│   ├── main.css             # Estilos principales
│   ├── dashboard.css        # Dashboard específico
│   └── ...                  # Más estilos
└── views/
    └── *.view.php           # Vistas finales
```

---

## 📦 Layouts

### BaseLayout.php
Layout base que todos los demás extienden.

#### Métodos Principales

**`BaseLayout::render($options)`**
```php
BaseLayout::render([
    'title' => 'Título de la Página',
    'content' => '<h1>Contenido HTML</h1>',
    'scripts' => ['../js/custom.js'],
    'styles' => ['../css/custom.css'],
    'bodyClass' => 'page-home',
    'includeHeader' => true,
    'includeFooter' => true,
    'includeSidebar' => false,
    'dataTheme' => 'dark', // 'dark' | 'light'
    'lang' => 'es'
]);
```

**`BaseLayout::buildContent($sections)`**
```php
$content = BaseLayout::buildContent([
    __DIR__ . '/../sections/hero.section.php',
    __DIR__ . '/../sections/features.section.php',
    function() {
        echo '<div class="custom-section">Contenido dinámico</div>';
    }
]);
```

### AdminLayout.php
Extiende BaseLayout con funcionalidades de administrador.

#### Características
- ✅ Verificación automática de permisos (middleware Auth + Status)
- ✅ Validación de rol_id = 2 (admin)
- ✅ Sidebar incluido por defecto
- ✅ Scripts y estilos de dashboard precargados

#### Uso
```php
<?php
session_start();
require_once __DIR__ . '/../layouts/AdminLayout.php';

$content = AdminLayout::buildContent([
    function() {
        echo AdminLayout::statsSection([
            [
                'label' => 'Usuarios',
                'value' => '150',
                'icon' => 'user',
                'color' => 'primary'
            ]
        ]);
    },
    __DIR__ . '/../sections/custom.section.php'
]);

AdminLayout::render([
    'title' => 'Admin Dashboard',
    'content' => $content,
    'activeMenu' => 'dashboard' // Para highlight en sidebar
]);
```

### UserLayout.php
Extiende BaseLayout para usuarios normales.

#### Características
- ✅ Verificación de autenticación (no requiere rol admin)
- ✅ Sin sidebar por defecto
- ✅ Interface simplificada

#### Uso
```php
<?php
session_start();
require_once __DIR__ . '/../layouts/UserLayout.php';

$userData = $_SESSION; // Datos del usuario

$content = UserLayout::buildContent([
    function() use ($userData) {
        echo UserLayout::profileCard($userData);
    },
    __DIR__ . '/../sections/stats.section.php'
]);

UserLayout::render([
    'title' => 'Mi Panel',
    'content' => $content
]);
```

---

## 🧩 UI Components

### header.ui.php
Header global con navegación adaptativa.

#### Características
- ✅ Navegación responsive (móvil y desktop)
- ✅ Toggle de tema claro/oscuro
- ✅ Dropdown de usuario autenticado
- ✅ Botón de login para visitantes
- ✅ Highlight automático del menú activo

#### Personalización
El header detecta automáticamente:
- Si hay sesión activa (`$_SESSION['logged_in']`)
- Rol del usuario (`$_SESSION['role_id']`)
- Muestra/oculta opciones según permisos

### footer.ui.php
Footer moderno con información y enlaces.

#### Secciones
- **Brand**: Logo y redes sociales
- **Navegación**: Enlaces principales
- **Recursos**: Documentación y guías
- **Contacto**: Información de contacto

### sidebar.ui.php
Sidebar para panel de administración.

#### Variable Global
```php
$GLOBALS['activeMenu'] = 'dashboard'; // Para highlight del menú activo
```

---

## 📐 Sections

### hero.section.php
Sección hero con CTA.

#### Variables
```php
$title = 'Título principal';
$subtitle = 'Subtítulo descriptivo';
$ctaText = 'Texto del botón';
$ctaLink = '../views/auth.view.php';

include __DIR__ . '/hero.section.php';
```

### features.section.php
Grid de características.

#### Variables
```php
$features = [
    [
        'icon' => 'cube',
        'title' => 'Realidad Aumentada',
        'description' => 'Visualiza en AR',
        'color' => 'primary' // primary|success|danger|warning|info
    ],
    // ... más features
];

include __DIR__ . '/features.section.php';
```

### stats.section.php
Sección de estadísticas.

#### Variables
```php
$stats = [
    [
        'value' => '500+',
        'label' => 'Usuarios Activos',
        'icon' => 'user',
        'color' => 'primary'
    ],
    // ... más stats
];

include __DIR__ . '/stats.section.php';
```

---

## 💡 Ejemplos de Uso

### Ejemplo 1: Página Pública Simple
```php
<?php
// public-page.view.php
session_start();
require_once __DIR__ . '/../layouts/BaseLayout.php';

$content = '<div class="container py-5">
    <h1>Página Pública</h1>
    <p>Contenido accesible sin autenticación</p>
</div>';

BaseLayout::render([
    'title' => 'Página Pública',
    'content' => $content
]);
```

### Ejemplo 2: Dashboard de Admin con Secciones
```php
<?php
// admin.dashboard.view.php
session_start();
require_once __DIR__ . '/../layouts/AdminLayout.php';

// Obtener datos de la BD
$userCount = 150;
$projectCount = 45;

// Crear sección de estadísticas
$statsHtml = AdminLayout::statsSection([
    ['label' => 'Usuarios', 'value' => $userCount, 'icon' => 'user', 'color' => 'primary'],
    ['label' => 'Proyectos', 'value' => $projectCount, 'icon' => 'cube', 'color' => 'success']
]);

// Construir contenido completo
$content = BaseLayout::buildContent([
    function() use ($statsHtml) {
        echo $statsHtml;
    },
    __DIR__ . '/../sections/custom-admin-section.php'
]);

AdminLayout::render([
    'title' => 'Dashboard Admin',
    'content' => $content,
    'activeMenu' => 'dashboard'
]);
```

### Ejemplo 3: Landing Page con Hero + Features
```php
<?php
// landing.view.php
session_start();
require_once __DIR__ . '/../layouts/BaseLayout.php';

// Configurar hero
$title = 'Bienvenido a HomeLab AR';
$subtitle = 'La mejor plataforma de AR';
$ctaText = 'Comenzar Ahora';
$ctaLink = '../views/auth.view.php';

// Configurar features
$features = [
    [
        'icon' => 'cube',
        'title' => 'AR Inmersivo',
        'description' => 'Experiencia AR de última generación',
        'color' => 'primary'
    ],
    [
        'icon' => 'shield',
        'title' => 'Seguro',
        'description' => 'Máxima seguridad garantizada',
        'color' => 'success'
    ]
];

// Construir contenido
$content = BaseLayout::buildContent([
    __DIR__ . '/../sections/hero.section.php',
    __DIR__ . '/../sections/features.section.php'
]);

BaseLayout::render([
    'title' => 'Landing Page',
    'content' => $content,
    'styles' => [
        '../css/main.css',
        '../dist/aos/aos.css'
    ],
    'scripts' => [
        '../dist/aos/aos.js'
    ]
]);
```

---

## 🎨 CSS Optimizado

### main.css
Archivo principal con estilos globales optimizados.

#### Incluye
- ✅ Reset y normalize
- ✅ Variables de Halfmoon
- ✅ Utility classes
- ✅ Componentes base (buttons, cards, forms)
- ✅ Animaciones
- ✅ Responsive breakpoints

### Orden de Carga Recomendado
```html
<!-- 1. Variables globales -->
<link rel="stylesheet" href="../css/variables.css">

<!-- 2. Framework base -->
<link rel="stylesheet" href="../dist/halfmoon/css/halfmoon.min.css">

<!-- 3. Iconos -->
<link rel="stylesheet" href="../dist/boxicons/fonts/basic/boxicons.min.css">

<!-- 4. Estilos principales -->
<link rel="stylesheet" href="../css/main.css">

<!-- 5. Estilos específicos de página -->
<link rel="stylesheet" href="../css/dashboard.css">
```

---

## 🚀 Ventajas del Sistema

### ✅ Modularidad
Cada componente es independiente y reutilizable.

### ✅ Escalabilidad
Fácil agregar nuevos layouts, sections y components.

### ✅ Mantenibilidad
Código limpio y bien organizado.

### ✅ Consistencia
Diseño uniforme en toda la aplicación.

### ✅ Performance
Carga condicional de recursos.

### ✅ Seguridad
Validación de permisos integrada en layouts.

---

## 📚 Próximos Pasos

1. Crear más sections reutilizables
2. Implementar sistema de notificaciones
3. Agregar más variantes de UI components
4. Optimizar carga de assets con lazy loading
5. Implementar service workers para PWA

---

**Creado con ❤️ para HomeLab AR**
