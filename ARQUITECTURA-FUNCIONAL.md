# 🏗️ Arquitectura Funcional - HomeLab AR

> **Filosofía**: Código limpio, legible y funcional. La simplicidad es elegancia.  
> **Objetivo**: Estructura escalable sin complejidad innecesaria.  
> **Fecha**: Noviembre 2025

---

## 📋 Tabla de Contenidos

1. [Principios de Diseño](#principios-de-diseño)
2. [Estructura de Archivos](#estructura-de-archivos)
3. [Sistema de Dependencias](#sistema-de-dependencias)
4. [Sistema CSS (3 Archivos Base)](#sistema-css)
5. [Carga de Vistas con PHP](#carga-de-vistas-con-php)
6. [Componentes Reutilizables](#componentes-reutilizables)
7. [Vista Home con Sections](#vista-home-con-sections)
8. [AppStore: Lectura de Aplicaciones](#appstore-lectura-de-aplicaciones)
9. [Ejemplos de Uso](#ejemplos-de-uso)

---

## 🎯 Principios de Diseño

### 1. **Programación Funcional Humana**

```
✅ Código entendible a primera vista
✅ Nombres descriptivos y claros
✅ Separación de responsabilidades
✅ Reutilización inteligente
✅ Documentación inline donde sea necesario
```

### 2. **PHP sobre JavaScript para Estructura**

```
✅ PHP: Carga de vistas, componentes, layouts
✅ JavaScript: Interactividad y lógica del cliente
❌ Evitar: JavaScript para inyectar HTML (difícil de mantener)
```

### 3. **Dependencias Centralizadas**

```
✅ Una sola fuente de verdad: npm-loader.js
✅ Variables globales accesibles
✅ Carga dinámica cuando sea necesario
```

---

## 📁 Estructura de Archivos

```
thepearlo_vr-website/
│
├── 📦 node_modules/          # Dependencias NPM (no tocar)
│
├── 📝 composables/            # Lógica reutilizable
│   ├── npm-loader.js         # ⭐ Cargador de dependencias
│   ├── config.js             # Configuración global
│   └── router.js             # Cliente HTTP (Axios)
│
├── 🎨 css/                    # ⭐ SOLO 3 ARCHIVOS BASE
│   ├── variables.css         # Variables CSS globales
│   ├── base.css              # Reset y estilos base
│   └── main.css              # Estilos principales
│
├── 🖼️ views/                  # Vistas principales (PHP)
│   ├── home.view.php         # ⭐ Vista principal del sitio
│   ├── homelab.view.php      # Vista VR/AR
│   ├── auth.view.php         # Autenticación
│   ├── user.dashboard.view.php
│   └── admin.dashboard.view.php
│
├── 🧩 sections/               # Secciones reutilizables (PHP)
│   ├── hero.section.php      # Sección hero con AOS
│   ├── features.section.php  # Características
│   ├── stats.section.php     # Estadísticas animadas
│   ├── about.section.php     # Acerca de
│   └── contact.section.php   # Contacto
│
├── 🔧 ui/                     # Componentes UI (PHP)
│   ├── header.ui.php         # Header con navegación
│   ├── navbar.ui.php         # Barra de navegación
│   ├── sidebar.ui.php        # Sidebar para dashboards
│   └── footer.ui.php         # Footer del sitio
│
├── 🪟 modals/                 # Modales (PHP)
│   ├── auth.modal.php        # Modal de autenticación
│   └── ...
│
├── 📐 layout/                 # Layouts base (PHP)
│   └── AppLayout.php         # ⭐ Layout principal
│
├── 📄 pages/                  # Páginas SPA (HTML puro)
│   ├── dashboard.html        # Dashboard de usuario
│   ├── stats.html            # Estadísticas
│   └── settings.html         # Configuración
│
├── ⚙️ js/                     # JavaScript modular
│   ├── main.js               # Inicialización principal
│   ├── auth.js               # Lógica de autenticación
│   ├── home.js               # Interactividad de home
│   ├── homelab.js            # Lógica VR/AR
│   └── utils.js              # Utilidades compartidas
│
├── 🏪 appstore/               # ⭐ Sistema AppStore
│   ├── apps.json             # Lista de aplicaciones
│   ├── reader.php            # Lector de aplicaciones
│   └── apps/                 # Aplicaciones individuales
│       ├── app1/
│       │   ├── manifest.json
│       │   ├── index.html
│       │   └── preview.png
│       └── app2/
│
└── 📚 docs/                   # Documentación
    └── ARQUITECTURA-FUNCIONAL.md
```

---

## 🔧 Sistema de Dependencias

### **npm-loader.js** - Centro de Control

```javascript
// composables/npm-loader.js
const NPM_CONFIG = {
  basePath: "../node_modules",

  css: {
    bootstrap: "/bootstrap/dist/css/bootstrap.min.css",
    aos: "/aos/dist/aos.css",
    animate: "/animate.css/animate.min.css",
    sweetalert2: "/sweetalert2/dist/sweetalert2.min.css",
    // ... más
  },

  js: {
    axios: "/axios/dist/axios.min.js",
    bootstrap: "/bootstrap/dist/js/bootstrap.bundle.min.js",
    jquery: "/jquery/dist/jquery.min.js",
    aos: "/aos/dist/aos.js",
    sweetalert2: "/sweetalert2/dist/sweetalert2.all.min.js",
    // ... más
  },

  vr: {
    aframe: "/aframe/dist/aframe-master.min.js",
    three: "/three/build/three.module.js",
    // ... más
  },
};

// Funciones globales
window.getCSSPath = (name) => NPM_CONFIG.basePath + NPM_CONFIG.css[name];
window.getJSPath = (name) => NPM_CONFIG.basePath + NPM_CONFIG.js[name];
window.getVRPath = (name) => NPM_CONFIG.basePath + NPM_CONFIG.vr[name];
```

### **Uso en PHP**

```php
<?php
// layout/AppLayout.php
class AppLayout {
    // Dependencias CSS que SIEMPRE se cargan
    private static $coreCss = [
        'bootstrap',    // Framework CSS
        'aos',          // Animaciones on scroll
        'animate'       // Animaciones CSS
    ];

    // Dependencias JS que SIEMPRE se cargan
    private static $coreJs = [
        'axios',        // HTTP Client (principal)
        'jquery',       // Solo para DataTables/Bootstrap
        'bootstrap',    // Framework JS
        'aos'           // Animaciones
    ];

    /**
     * Renderiza las etiquetas <link> de CSS
     */
    public static function renderCssLinks($additionalCss = []) {
        $allCss = array_merge(self::$coreCss, $additionalCss);

        echo '<!-- CSS Dependencies -->' . PHP_EOL;
        foreach ($allCss as $cssName) {
            echo sprintf(
                '<link rel="stylesheet" href="<?php echo getCSSPath(\'%s\'); ?>">' . PHP_EOL,
                $cssName
            );
        }
    }

    /**
     * Renderiza las etiquetas <script> de JS
     */
    public static function renderJsScripts($additionalJs = []) {
        $allJs = array_merge(self::$coreJs, $additionalJs);

        echo '<!-- JavaScript Dependencies -->' . PHP_EOL;
        foreach ($allJs as $jsName) {
            echo sprintf(
                '<script src="<?php echo getJSPath(\'%s\'); ?>"></script>' . PHP_EOL,
                $jsName
            );
        }
    }
}
?>
```

---

## 🎨 Sistema CSS (3 Archivos Base)

### **1. variables.css** - Variables Globales

```css
/**
 * Variables CSS Globales
 * HomeLab AR - Roepard Labs
 * Compatible con Bootstrap 5
 */

:root {
  /* 🎨 Colores Primarios */
  --color-primary: #0088ff;
  --color-primary-dark: #0066cc;
  --color-primary-light: #33a3ff;

  --color-secondary: #6c757d;
  --color-success: #28a745;
  --color-danger: #dc3545;
  --color-warning: #ffc107;
  --color-info: #17a2b8;

  /* 🌓 Dark Mode */
  --color-dark-bg: #1a1a1a;
  --color-dark-surface: #2d2d2d;
  --color-dark-text: #e0e0e0;

  /* 📐 Espaciados */
  --spacing-xs: 0.25rem; /* 4px */
  --spacing-sm: 0.5rem; /* 8px */
  --spacing-md: 1rem; /* 16px */
  --spacing-lg: 1.5rem; /* 24px */
  --spacing-xl: 2rem; /* 32px */
  --spacing-xxl: 3rem; /* 48px */

  /* 🔤 Tipografía */
  --font-family-base: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
    sans-serif;
  --font-family-heading: "Inter", var(--font-family-base);
  --font-family-mono: "JetBrains Mono", "Fira Code", monospace;

  --font-size-xs: 0.75rem; /* 12px */
  --font-size-sm: 0.875rem; /* 14px */
  --font-size-base: 1rem; /* 16px */
  --font-size-lg: 1.125rem; /* 18px */
  --font-size-xl: 1.25rem; /* 20px */
  --font-size-2xl: 1.5rem; /* 24px */
  --font-size-3xl: 2rem; /* 32px */

  /* 🎭 Sombras */
  --shadow-sm: 0 2px 4px rgba(0, 0, 0, 0.1);
  --shadow-md: 0 4px 8px rgba(0, 0, 0, 0.15);
  --shadow-lg: 0 8px 16px rgba(0, 0, 0, 0.2);
  --shadow-xl: 0 12px 24px rgba(0, 0, 0, 0.25);

  /* 🎯 Border Radius */
  --radius-sm: 0.25rem; /* 4px */
  --radius-md: 0.5rem; /* 8px */
  --radius-lg: 1rem; /* 16px */
  --radius-xl: 1.5rem; /* 24px */
  --radius-full: 9999px;

  /* ⚡ Transiciones */
  --transition-fast: 150ms ease-in-out;
  --transition-base: 300ms ease-in-out;
  --transition-slow: 500ms ease-in-out;

  /* 📱 Breakpoints (para referencia en JS) */
  --breakpoint-sm: 576px;
  --breakpoint-md: 768px;
  --breakpoint-lg: 992px;
  --breakpoint-xl: 1200px;
  --breakpoint-xxl: 1400px;
}

/* Dark Mode Override */
[data-bs-theme="dark"] {
  --color-primary: #33a3ff;
  --color-primary-dark: #0088ff;
}
```

### **2. base.css** - Reset y Base

```css
/**
 * Estilos Base y Reset
 * HomeLab AR - Roepard Labs
 */

/* Reset básico */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

html {
  font-size: 16px;
  scroll-behavior: smooth;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

body {
  font-family: var(--font-family-base);
  font-size: var(--font-size-base);
  line-height: 1.6;
  color: var(--bs-body-color);
  background-color: var(--bs-body-bg);
  overflow-x: hidden;
}

/* Tipografía base */
h1,
h2,
h3,
h4,
h5,
h6 {
  font-family: var(--font-family-heading);
  font-weight: 700;
  line-height: 1.2;
  margin-bottom: var(--spacing-md);
}

a {
  color: var(--color-primary);
  text-decoration: none;
  transition: color var(--transition-fast);
}

a:hover {
  color: var(--color-primary-dark);
}

/* Imágenes responsive por defecto */
img {
  max-width: 100%;
  height: auto;
  display: block;
}

/* Código */
code,
pre {
  font-family: var(--font-family-mono);
  font-size: 0.9em;
}

/* Botones base (complementa Bootstrap) */
.btn {
  transition: all var(--transition-base);
  font-weight: 500;
}

/* Focus visible para accesibilidad */
:focus-visible {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}

/* Scroll personalizado */
::-webkit-scrollbar {
  width: 10px;
  height: 10px;
}

::-webkit-scrollbar-track {
  background: var(--bs-secondary-bg);
}

::-webkit-scrollbar-thumb {
  background: var(--color-primary);
  border-radius: var(--radius-full);
}

::-webkit-scrollbar-thumb:hover {
  background: var(--color-primary-dark);
}
```

### **3. main.css** - Utilidades y Componentes

```css
/**
 * Estilos Principales y Utilidades
 * HomeLab AR - Roepard Labs
 */

/* 🎯 Utilidades de Espaciado Extra */
.p-xxl {
  padding: var(--spacing-xxl) !important;
}
.m-xxl {
  margin: var(--spacing-xxl) !important;
}
.py-xxl {
  padding-top: var(--spacing-xxl) !important;
  padding-bottom: var(--spacing-xxl) !important;
}

/* 🎨 Gradientes */
.gradient-primary {
  background: linear-gradient(
    135deg,
    var(--color-primary),
    var(--color-primary-dark)
  );
}

.gradient-overlay {
  position: relative;
}

.gradient-overlay::before {
  content: "";
  position: absolute;
  inset: 0;
  background: linear-gradient(180deg, rgba(0, 0, 0, 0.4), rgba(0, 0, 0, 0.8));
  z-index: 1;
}

/* 🎭 Sombras */
.shadow-custom-sm {
  box-shadow: var(--shadow-sm);
}
.shadow-custom-md {
  box-shadow: var(--shadow-md);
}
.shadow-custom-lg {
  box-shadow: var(--shadow-lg);
}
.shadow-custom-xl {
  box-shadow: var(--shadow-xl);
}

/* 📱 Display Utilities */
.full-height {
  min-height: 100vh;
}
.flex-center {
  display: flex;
  align-items: center;
  justify-content: center;
}

/* 🎯 Componentes Personalizados */

/* Card mejorado */
.card-custom {
  border: none;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-md);
  transition: transform var(--transition-base), box-shadow var(--transition-base);
}

.card-custom:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-lg);
}

/* Hero Section */
.hero-section {
  min-height: 100vh;
  display: flex;
  align-items: center;
  position: relative;
  overflow: hidden;
}

.hero-content {
  position: relative;
  z-index: 10;
}

/* Stats Counter */
.stat-number {
  font-size: var(--font-size-3xl);
  font-weight: 700;
  color: var(--color-primary);
}

/* Animación de pulso */
@keyframes pulse-glow {
  0%,
  100% {
    box-shadow: 0 0 20px var(--color-primary);
  }
  50% {
    box-shadow: 0 0 40px var(--color-primary);
  }
}

.pulse-glow {
  animation: pulse-glow 2s ease-in-out infinite;
}

/* Loading Spinner Custom */
.spinner-custom {
  width: 40px;
  height: 40px;
  border: 4px solid var(--bs-secondary-bg);
  border-top-color: var(--color-primary);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

/* Text Utilities */
.text-gradient {
  background: linear-gradient(
    135deg,
    var(--color-primary),
    var(--color-primary-light)
  );
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

/* Backdrop Blur */
.backdrop-blur {
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
}

/* Sticky Header Helper */
.sticky-header {
  position: sticky;
  top: 0;
  z-index: 1000;
  background: var(--bs-body-bg);
  box-shadow: var(--shadow-sm);
}
```

---

## 🏗️ Carga de Vistas con PHP

### **AppLayout.php** - Layout Principal

```php
<?php
/**
 * AppLayout - Layout Principal
 * HomeLab AR - Roepard Labs
 *
 * Este layout maneja la estructura HTML base y la carga de dependencias
 */

class AppLayout {

    // ===================================
    // CONFIGURACIÓN DE DEPENDENCIAS
    // ===================================

    /**
     * CSS Core (siempre se cargan)
     */
    private static $cssCore = ['bootstrap', 'aos', 'animate'];

    /**
     * JS Core (siempre se cargan)
     */
    private static $jsCore = ['axios', 'jquery', 'bootstrap', 'aos'];

    /**
     * Mapeo de vistas a sus dependencias
     */
    private static $viewDependencies = [
        'home' => [
            'css' => ['glightbox'],
            'js' => ['glightbox', 'chart', 'anime']
        ],
        'homelab' => [
            'css' => [],
            'js' => ['aframe', 'three'] // VR/AR
        ],
        'dashboard' => [
            'css' => ['datatables', 'datatablesResponsive'],
            'js' => ['datatables', 'datatablesBS5', 'datatablesResponsive']
        ]
    ];

    // ===================================
    // MÉTODOS PRINCIPALES
    // ===================================

    /**
     * Renderiza el layout completo
     *
     * @param string $view Nombre de la vista
     * @param array $data Datos para la vista
     * @param array $config Configuración adicional
     */
    public static function render($view, $data = [], $config = []) {
        // Configuración por defecto
        $config = array_merge([
            'title' => 'HomeLab AR',
            'description' => 'Realidad Aumentada para Homelab',
            'includeHeader' => true,
            'includeFooter' => true,
            'bodyClass' => '',
            'additionalCss' => [],
            'additionalJs' => []
        ], $config);

        // Obtener dependencias de la vista
        $viewDeps = self::$viewDependencies[$view] ?? ['css' => [], 'js' => []];

        // Combinar dependencias
        $allCss = array_merge(
            self::$cssCore,
            $viewDeps['css'],
            $config['additionalCss']
        );

        $allJs = array_merge(
            self::$jsCore,
            $viewDeps['js'],
            $config['additionalJs']
        );

        // Extraer datos para usar en la vista
        extract($data);

        // Iniciar buffer
        ob_start();
        ?>
<!DOCTYPE html>
<html lang="es" data-bs-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="<?php echo htmlspecialchars($config['description']); ?>">
    <title><?php echo htmlspecialchars($config['title']); ?></title>

    <!-- Favicon -->
    <link rel="icon" type="image/png" href="/assets/favicon.png">

    <!-- CSS Base del Proyecto -->
    <link rel="stylesheet" href="/css/variables.css">
    <link rel="stylesheet" href="/css/base.css">
    <link rel="stylesheet" href="/css/main.css">

    <!-- CSS Dependencies -->
    <?php self::renderCssLinks($allCss); ?>

    <!-- CSS Específico de la Vista -->
    <?php if (file_exists(__DIR__ . "/../css/{$view}.css")): ?>
    <link rel="stylesheet" href="/css/<?php echo $view; ?>.css">
    <?php endif; ?>
</head>
<body class="<?php echo htmlspecialchars($config['bodyClass']); ?>">

    <?php if ($config['includeHeader']): ?>
        <?php self::includeComponent('ui/header.ui.php', $data); ?>
    <?php endif; ?>

    <main id="main-content">
        <?php self::includeView($view, $data); ?>
    </main>

    <?php if ($config['includeFooter']): ?>
        <?php self::includeComponent('ui/footer.ui.php', $data); ?>
    <?php endif; ?>

    <!-- NPM Loader (SIEMPRE primero) -->
    <script src="/composables/npm-loader.js"></script>

    <!-- Config & Router -->
    <script src="/composables/config.js"></script>
    <script src="/composables/router.js"></script>

    <!-- JavaScript Dependencies -->
    <?php self::renderJsScripts($allJs); ?>

    <!-- JavaScript Específico de la Vista -->
    <?php if (file_exists(__DIR__ . "/../js/{$view}.js")): ?>
    <script src="/js/<?php echo $view; ?>.js"></script>
    <?php endif; ?>

    <!-- Main App JS -->
    <script src="/js/main.js"></script>
</body>
</html>
        <?php
        return ob_get_clean();
    }

    // ===================================
    // MÉTODOS AUXILIARES
    // ===================================

    /**
     * Renderiza links CSS
     */
    private static function renderCssLinks($cssArray) {
        echo "<!-- CSS Dependencies -->\n";
        foreach ($cssArray as $cssName) {
            echo "<link rel=\"stylesheet\" href=\"<?php echo getCSSPath('{$cssName}'); ?>\">\n";
        }
    }

    /**
     * Renderiza scripts JS
     */
    private static function renderJsScripts($jsArray) {
        echo "<!-- JavaScript Dependencies -->\n";
        foreach ($jsArray as $jsName) {
            echo "<script src=\"<?php echo getJSPath('{$jsName}'); ?>\"></script>\n";
        }
    }

    /**
     * Incluye una vista
     */
    private static function includeView($view, $data) {
        $viewPath = __DIR__ . "/../views/{$view}.view.php";
        if (file_exists($viewPath)) {
            extract($data);
            include $viewPath;
        } else {
            echo "<!-- Vista no encontrada: {$view} -->";
        }
    }

    /**
     * Incluye un componente
     */
    private static function includeComponent($component, $data = []) {
        $componentPath = __DIR__ . "/../{$component}";
        if (file_exists($componentPath)) {
            extract($data);
            include $componentPath;
        }
    }
}
?>
```

---

## 🏠 Vista Home con Sections

### **home.view.php**

```php
<?php
/**
 * Vista: Home
 * Página principal del sitio con secciones animadas
 */
?>

<!-- Hero Section -->
<?php include __DIR__ . '/../sections/hero.section.php'; ?>

<!-- Features Section -->
<?php include __DIR__ . '/../sections/features.section.php'; ?>

<!-- Stats Section -->
<?php include __DIR__ . '/../sections/stats.section.php'; ?>

<!-- About Section -->
<?php include __DIR__ . '/../sections/about.section.php'; ?>

<!-- Contact Section -->
<?php include __DIR__ . '/../sections/contact.section.php'; ?>
```

### **sections/hero.section.php**

```php
<?php
/**
 * Sección: Hero
 * Sección principal con animaciones AOS
 */
?>

<section class="hero-section gradient-primary" id="hero">
    <div class="container">
        <div class="row align-items-center">
            <div class="col-lg-6" data-aos="fade-right" data-aos-duration="1000">
                <h1 class="display-2 fw-bold text-white mb-4">
                    Bienvenido a <span class="text-gradient">HomeLab AR</span>
                </h1>
                <p class="lead text-white-50 mb-4">
                    Despliega y gestiona servicios virtuales en realidad aumentada.
                    La próxima generación de homelab está aquí.
                </p>
                <div class="d-flex gap-3">
                    <a href="/homelab" class="btn btn-light btn-lg">
                        <i class="bx bx-rocket"></i> Comenzar Ahora
                    </a>
                    <a href="#features" class="btn btn-outline-light btn-lg">
                        <i class="bx bx-info-circle"></i> Conoce Más
                    </a>
                </div>
            </div>
            <div class="col-lg-6" data-aos="fade-left" data-aos-duration="1000" data-aos-delay="200">
                <div class="hero-image-wrapper">
                    <img src="/assets/images/hero-illustration.svg"
                         alt="HomeLab AR Illustration"
                         class="img-fluid animate__animated animate__pulse animate__infinite">
                </div>
            </div>
        </div>
    </div>

    <!-- Scroll Indicator -->
    <div class="scroll-indicator" data-aos="fade-up" data-aos-delay="1000">
        <a href="#features" class="text-white">
            <i class="bx bx-chevron-down bx-fade-down"></i>
        </a>
    </div>
</section>

<style>
.scroll-indicator {
    position: absolute;
    bottom: 2rem;
    left: 50%;
    transform: translateX(-50%);
    font-size: 2rem;
}
</style>
```

### **sections/features.section.php**

```php
<?php
/**
 * Sección: Features
 * Características principales con cards animadas
 */

$features = [
    [
        'icon' => 'bx-cube',
        'title' => 'Realidad Aumentada',
        'description' => 'Visualiza tu homelab en 3D con tecnología WebXR',
        'delay' => 0
    ],
    [
        'icon' => 'bx-server',
        'title' => 'Gestión de Servicios',
        'description' => 'Controla Docker, VMs y contenedores en tiempo real',
        'delay' => 200
    ],
    [
        'icon' => 'bx-lock-alt',
        'title' => 'Seguridad Avanzada',
        'description' => 'Autenticación JWT y encriptación end-to-end',
        'delay' => 400
    ],
    [
        'icon' => 'bx-chart',
        'title' => 'Analytics en Vivo',
        'description' => 'Monitorea rendimiento con dashboards interactivos',
        'delay' => 600
    ]
];
?>

<section class="py-xxl" id="features">
    <div class="container">
        <div class="text-center mb-5" data-aos="fade-up">
            <h2 class="display-4 fw-bold mb-3">Características Poderosas</h2>
            <p class="lead text-muted">Todo lo que necesitas para tu homelab del futuro</p>
        </div>

        <div class="row g-4">
            <?php foreach ($features as $feature): ?>
            <div class="col-md-6 col-lg-3"
                 data-aos="fade-up"
                 data-aos-delay="<?php echo $feature['delay']; ?>">
                <div class="card card-custom h-100 text-center p-4">
                    <div class="feature-icon mb-3 mx-auto">
                        <i class="bx <?php echo $feature['icon']; ?> bx-lg text-primary"></i>
                    </div>
                    <h5 class="card-title fw-bold"><?php echo $feature['title']; ?></h5>
                    <p class="card-text text-muted"><?php echo $feature['description']; ?></p>
                </div>
            </div>
            <?php endforeach; ?>
        </div>
    </div>
</section>
```

### **sections/stats.section.php**

```php
<?php
/**
 * Sección: Stats
 * Estadísticas animadas con CountUp.js
 */

$stats = [
    ['number' => 1200, 'label' => 'Usuarios Activos', 'suffix' => '+'],
    ['number' => 50, 'label' => 'Aplicaciones Desplegadas', 'suffix' => '+'],
    ['number' => 99.9, 'label' => 'Uptime', 'suffix' => '%'],
    ['number' => 24, 'label' => 'Soporte', 'suffix' => '/7']
];
?>

<section class="py-xxl bg-light" id="stats">
    <div class="container">
        <div class="row g-4 text-center">
            <?php foreach ($stats as $index => $stat): ?>
            <div class="col-6 col-md-3"
                 data-aos="zoom-in"
                 data-aos-delay="<?php echo $index * 100; ?>">
                <div class="stat-item">
                    <div class="stat-number" data-count="<?php echo $stat['number']; ?>">
                        0<?php echo $stat['suffix']; ?>
                    </div>
                    <div class="stat-label text-muted"><?php echo $stat['label']; ?></div>
                </div>
            </div>
            <?php endforeach; ?>
        </div>
    </div>
</section>
```

---

## 🏪 AppStore: Lectura de Aplicaciones

### **Estructura de AppStore**

```
thepearlo_vr-appstore/
│
├── apps.json                 # Índice de aplicaciones
├── reader.php                # API para leer aplicaciones
├── viewer.php                # Visor de aplicaciones
│
└── apps/                     # Aplicaciones individuales
    ├── docker-manager/
    │   ├── manifest.json     # Metadatos
    │   ├── index.html        # App principal
    │   ├── preview.png       # Preview image
    │   ├── icon.svg          # Icono
    │   └── README.md
    │
    ├── prometheus-dashboard/
    │   ├── manifest.json
    │   ├── index.html
    │   ├── preview.png
    │   └── icon.svg
    │
    └── portainer-ar/
        ├── manifest.json
        ├── index.html
        ├── preview.png
        └── icon.svg
```

### **apps.json** - Índice de Aplicaciones

```json
{
  "version": "1.0.0",
  "lastUpdate": "2025-11-03T00:00:00Z",
  "apps": [
    {
      "id": "docker-manager",
      "name": "Docker Manager AR",
      "version": "1.2.0",
      "description": "Gestiona contenedores Docker en realidad aumentada",
      "author": "Roepard Labs",
      "category": "containers",
      "tags": ["docker", "containers", "management"],
      "icon": "/apps/docker-manager/icon.svg",
      "preview": "/apps/docker-manager/preview.png",
      "manifestUrl": "/apps/docker-manager/manifest.json",
      "appUrl": "/apps/docker-manager/index.html",
      "featured": true,
      "downloads": 1547,
      "rating": 4.8,
      "requiresAuth": true,
      "vrCompatible": true,
      "arCompatible": true
    },
    {
      "id": "prometheus-dashboard",
      "name": "Prometheus Dashboard",
      "version": "2.0.1",
      "description": "Visualiza métricas de Prometheus en 3D",
      "author": "Roepard Labs",
      "category": "monitoring",
      "tags": ["prometheus", "metrics", "monitoring"],
      "icon": "/apps/prometheus-dashboard/icon.svg",
      "preview": "/apps/prometheus-dashboard/preview.png",
      "manifestUrl": "/apps/prometheus-dashboard/manifest.json",
      "appUrl": "/apps/prometheus-dashboard/index.html",
      "featured": false,
      "downloads": 892,
      "rating": 4.6,
      "requiresAuth": true,
      "vrCompatible": true,
      "arCompatible": false
    }
  ]
}
```

### **manifest.json** - Ejemplo de Aplicación

```json
{
  "id": "docker-manager",
  "name": "Docker Manager AR",
  "version": "1.2.0",
  "description": "Gestiona contenedores Docker en realidad aumentada",
  "author": {
    "name": "Roepard Labs",
    "email": "dev@roepard.online",
    "url": "https://roepard.online"
  },
  "entry": "index.html",
  "icon": "icon.svg",
  "preview": "preview.png",

  "permissions": [
    "docker.read",
    "docker.start",
    "docker.stop",
    "docker.restart"
  ],

  "dependencies": {
    "npm": ["axios", "sweetalert2", "chart"],
    "vr": ["aframe", "three"]
  },

  "config": {
    "apiEndpoint": "${BACKEND_URL}/docker",
    "refreshInterval": 5000,
    "maxContainers": 50
  },

  "ui": {
    "fullscreen": true,
    "darkMode": true,
    "orientation": "landscape"
  },

  "metadata": {
    "category": "containers",
    "tags": ["docker", "containers", "management"],
    "license": "MIT",
    "repository": "https://github.com/roepard-labs/docker-manager-ar",
    "changelog": "CHANGELOG.md"
  }
}
```

### **reader.php** - API para Leer Aplicaciones

```php
<?php
/**
 * AppStore Reader API
 * Lee y devuelve aplicaciones disponibles
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

class AppStoreReader {

    private $appsPath = __DIR__ . '/apps';
    private $indexFile = __DIR__ . '/apps.json';

    /**
     * Obtener lista de todas las aplicaciones
     */
    public function getAllApps() {
        if (!file_exists($this->indexFile)) {
            return $this->error('Index file not found');
        }

        $data = json_decode(file_get_contents($this->indexFile), true);
        return $this->success($data['apps']);
    }

    /**
     * Obtener aplicación específica por ID
     */
    public function getApp($appId) {
        $manifestPath = $this->appsPath . '/' . $appId . '/manifest.json';

        if (!file_exists($manifestPath)) {
            return $this->error('App not found', 404);
        }

        $manifest = json_decode(file_get_contents($manifestPath), true);
        return $this->success($manifest);
    }

    /**
     * Buscar aplicaciones
     */
    public function searchApps($query) {
        $allApps = $this->getAllApps();

        if (!$allApps['success']) {
            return $allApps;
        }

        $results = array_filter($allApps['data'], function($app) use ($query) {
            $searchableText = strtolower(
                $app['name'] . ' ' .
                $app['description'] . ' ' .
                implode(' ', $app['tags'])
            );
            return strpos($searchableText, strtolower($query)) !== false;
        });

        return $this->success(array_values($results));
    }

    /**
     * Filtrar por categoría
     */
    public function getByCategory($category) {
        $allApps = $this->getAllApps();

        if (!$allApps['success']) {
            return $allApps;
        }

        $results = array_filter($allApps['data'], function($app) use ($category) {
            return $app['category'] === $category;
        });

        return $this->success(array_values($results));
    }

    /**
     * Obtener aplicaciones destacadas
     */
    public function getFeaturedApps() {
        $allApps = $this->getAllApps();

        if (!$allApps['success']) {
            return $allApps;
        }

        $results = array_filter($allApps['data'], function($app) {
            return $app['featured'] === true;
        });

        return $this->success(array_values($results));
    }

    /**
     * Respuesta exitosa
     */
    private function success($data) {
        return [
            'success' => true,
            'data' => $data,
            'timestamp' => time()
        ];
    }

    /**
     * Respuesta de error
     */
    private function error($message, $code = 400) {
        http_response_code($code);
        return [
            'success' => false,
            'error' => $message,
            'timestamp' => time()
        ];
    }
}

// ===================================
// ROUTER
// ===================================

$reader = new AppStoreReader();
$action = $_GET['action'] ?? 'list';

switch ($action) {
    case 'list':
        echo json_encode($reader->getAllApps());
        break;

    case 'get':
        $appId = $_GET['id'] ?? null;
        if (!$appId) {
            echo json_encode($reader->error('App ID required'));
            break;
        }
        echo json_encode($reader->getApp($appId));
        break;

    case 'search':
        $query = $_GET['q'] ?? '';
        echo json_encode($reader->searchApps($query));
        break;

    case 'category':
        $category = $_GET['cat'] ?? '';
        echo json_encode($reader->getByCategory($category));
        break;

    case 'featured':
        echo json_encode($reader->getFeaturedApps());
        break;

    default:
        echo json_encode($reader->error('Invalid action'));
}
?>
```

### **viewer.php** - Visor de Aplicaciones

```php
<?php
/**
 * App Viewer
 * Carga y ejecuta aplicaciones del AppStore
 */

$appId = $_GET['app'] ?? null;

if (!$appId) {
    die('App ID required');
}

$appPath = __DIR__ . '/apps/' . $appId;
$manifestPath = $appPath . '/manifest.json';

if (!file_exists($manifestPath)) {
    die('App not found');
}

$manifest = json_decode(file_get_contents($manifestPath), true);
$appHtml = $appPath . '/' . $manifest['entry'];

if (!file_exists($appHtml)) {
    die('App entry file not found');
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo htmlspecialchars($manifest['name']); ?></title>

    <!-- CSS Base -->
    <link rel="stylesheet" href="../../css/variables.css">
    <link rel="stylesheet" href="../../css/base.css">
    <link rel="stylesheet" href="../../css/main.css">

    <!-- NPM Loader -->
    <script src="../../composables/npm-loader.js"></script>

    <!-- Cargar dependencias de la app -->
    <?php if (!empty($manifest['dependencies']['npm'])): ?>
        <?php foreach ($manifest['dependencies']['npm'] as $dep): ?>
    <script src="<?php echo "getCSSPath('{$dep}')"; ?>"></script>
    <script src="<?php echo "getJSPath('{$dep}')"; ?>"></script>
        <?php endforeach; ?>
    <?php endif; ?>

    <?php if (!empty($manifest['dependencies']['vr'])): ?>
        <?php foreach ($manifest['dependencies']['vr'] as $dep): ?>
    <script src="<?php echo "getVRPath('{$dep}')"; ?>"></script>
        <?php endforeach; ?>
    <?php endif; ?>
</head>
<body>
    <div id="app-container" data-app-id="<?php echo htmlspecialchars($appId); ?>">
        <?php include $appHtml; ?>
    </div>

    <script>
        // Configuración de la app
        window.APP_MANIFEST = <?php echo json_encode($manifest); ?>;
        window.APP_ID = '<?php echo $appId; ?>';
        window.APP_PATH = '/appstore/apps/<?php echo $appId; ?>/';
    </script>
</body>
</html>
```

---

## 📖 Ejemplos de Uso

### **Ejemplo 1: Crear una nueva vista**

```php
<?php
// views/new-page.view.php

// Datos que queremos pasar
$data = [
    'pageTitle' => 'Mi Nueva Página',
    'items' => [1, 2, 3, 4, 5]
];

// Configuración
$config = [
    'title' => 'Nueva Página - HomeLab AR',
    'description' => 'Descripción de mi página',
    'additionalCss' => ['sweetalert2'],
    'additionalJs' => ['sweetalert2', 'chart']
];

// Renderizar
echo AppLayout::render('new-page', $data, $config);
?>
```

### **Ejemplo 2: Usar dependencias en JavaScript**

```javascript
// js/home.js

// Inicializar AOS (ya cargado por AppLayout)
document.addEventListener("DOMContentLoaded", function () {
  AOS.init({
    duration: 800,
    once: true,
    offset: 100,
  });

  // Usar Axios para peticiones
  axios
    .get(`${window.API_URL}/stats`)
    .then((response) => {
      updateStats(response.data);
    })
    .catch((error) => {
      // Usar SweetAlert2 para errores
      Swal.fire({
        icon: "error",
        title: "Error",
        text: "No se pudieron cargar las estadísticas",
      });
    });
});

function updateStats(data) {
  // Animar números con anime.js
  anime({
    targets: ".stat-number",
    innerHTML: [0, data.count],
    easing: "easeInOutExpo",
    round: 1,
    duration: 2000,
  });
}
```

### **Ejemplo 3: Cargar app del AppStore**

```javascript
// js/appstore.js

async function loadApp(appId) {
  try {
    // Obtener manifest
    const response = await axios.get(
      `/appstore/reader.php?action=get&id=${appId}`
    );

    if (!response.data.success) {
      throw new Error(response.data.error);
    }

    const manifest = response.data.data;

    // Abrir app en iframe o nueva ventana
    window.open(`/appstore/viewer.php?app=${appId}`, "_blank");
  } catch (error) {
    console.error("Error loading app:", error);
    Swal.fire({
      icon: "error",
      title: "Error al cargar aplicación",
      text: error.message,
    });
  }
}

// Buscar apps
async function searchApps(query) {
  const response = await axios.get(
    `/appstore/reader.php?action=search&q=${query}`
  );
  return response.data.data;
}
```

### **Ejemplo 4: Crear sección con animaciones**

```php
<?php
// sections/custom.section.php
?>

<section class="py-xxl" id="custom-section">
    <div class="container">
        <div class="row">
            <div class="col-lg-6" data-aos="fade-right">
                <h2 class="display-4 fw-bold mb-4">Título de Sección</h2>
                <p class="lead text-muted">
                    Descripción de la sección con animación.
                </p>
            </div>
            <div class="col-lg-6" data-aos="fade-left" data-aos-delay="200">
                <div class="card card-custom">
                    <div class="card-body">
                        <p>Contenido de la card</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>
```

---

## 🎯 Resumen de Buenas Prácticas

### ✅ **HACER**

1. **Usar PHP para estructura** - Cargar componentes con `include`
2. **Centralizar dependencias** - Todo en `npm-loader.js`
3. **CSS modular** - Solo 3 archivos base + específicos de vista
4. **Nombres descriptivos** - Que expliquen su función
5. **Comentarios útiles** - Solo donde agreguen valor
6. **Validar datos** - Siempre sanitizar inputs
7. **Manejar errores** - Feedback claro al usuario

### ❌ **EVITAR**

1. **JavaScript para HTML** - No usar `innerHTML` para estructura
2. **CSS inline** - Usar clases reutilizables
3. **Dependencias duplicadas** - Verificar antes de agregar
4. **Hardcodear URLs** - Usar variables de configuración
5. **Archivos gigantes** - Dividir en componentes lógicos
6. **Comentarios obvios** - Si el código es claro, no comentes
7. **Magic numbers** - Usar variables con nombres claros

---

## 🚀 Próximos Pasos

1. **Implementar estructura base** siguiendo este documento
2. **Crear vistas ejemplo** (home, dashboard, appstore)
3. **Desarrollar componentes UI** reutilizables
4. **Integrar sistema AppStore** con aplicaciones de ejemplo
5. **Configurar Dokploy** para deployment
6. **Testing y optimización** de performance

---

## 📝 Notas Finales

Esta arquitectura está diseñada para ser:

- **Entendible**: Cualquier desarrollador puede leerla
- **Escalable**: Fácil de extender con nuevas features
- **Mantenible**: Cambios localizados, bajo impacto
- **Performante**: Carga solo lo necesario
- **Educativa**: Perfecta para aprendizaje

**Documentado por**: GitHub Copilot  
**Proyecto**: HomeLab AR - Roepard Labs  
**Fecha**: Noviembre 2025  
**Versión**: 1.0.0

---
