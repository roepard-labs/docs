# 🚀 Quick Start - Arquitectura HomeLab AR

> **Guía rápida** de la estructura funcional del proyecto

---

## 📂 Estructura de Directorios

```
thepearlo_vr-website/
│
├── composables/              # Lógica reutilizable
│   ├── npm-loader.js        # ⭐ Centro de dependencias
│   ├── config.js            # Configuración global
│   └── router.js            # Cliente HTTP (Axios)
│
├── css/                      # ⭐ SOLO 3 ARCHIVOS
│   ├── variables.css        # Variables CSS
│   ├── base.css             # Estilos base
│   └── main.css             # Utilidades
│
├── views/                    # Vistas PHP
│   ├── home.view.php        # Vista principal
│   ├── homelab.view.php     # Vista VR/AR
│   └── ...
│
├── sections/                 # Secciones reutilizables
│   ├── hero.section.php
│   ├── features.section.php
│   └── ...
│
├── ui/                       # Componentes UI
│   ├── header.ui.php
│   ├── footer.ui.php
│   └── ...
│
├── layout/                   # Layouts base
│   └── AppLayout.php        # ⭐ Layout principal
│
├── js/                       # JavaScript modular
│   ├── main.js
│   ├── auth.js
│   └── ...
│
└── appstore/                 # ⭐ Sistema AppStore
    ├── apps.json
    ├── reader.php
    └── apps/
```

---

## 🎯 Principios Clave

### 1. PHP para Estructura, JS para Interactividad

```php
<!-- ✅ CORRECTO: PHP carga componentes -->
<?php include __DIR__ . '/sections/hero.section.php'; ?>
```

```javascript
// ❌ INCORRECTO: No usar JS para inyectar HTML
document.body.innerHTML = "<div>...</div>";
```

### 2. Dependencias Centralizadas

**Todo viene de `npm-loader.js`**:

```javascript
// Obtener rutas
getCSSPath("bootstrap"); // → '../node_modules/bootstrap/...'
getJSPath("axios"); // → '../node_modules/axios/...'
getVRPath("aframe"); // → '../node_modules/aframe/...'
```

### 3. CSS Modular (Solo 3 Base)

```html
<!-- Siempre cargar estos 3 -->
<link rel="stylesheet" href="/css/variables.css" />
<link rel="stylesheet" href="/css/base.css" />
<link rel="stylesheet" href="/css/main.css" />

<!-- Luego específicos de vista -->
<link rel="stylesheet" href="/css/home.css" />
```

---

## 🏗️ Crear una Nueva Vista

### Paso 1: Crear archivo de vista

```php
<?php
// views/my-page.view.php
?>

<!-- Hero Section -->
<?php include __DIR__ . '/../sections/hero.section.php'; ?>

<!-- Custom Content -->
<section class="py-5">
    <div class="container">
        <h2>Mi Contenido</h2>
    </div>
</section>
```

### Paso 2: Usar AppLayout para renderizar

```php
<?php
// index.php o router

require_once 'layout/AppLayout.php';

$data = [
    'pageTitle' => 'Mi Página'
];

$config = [
    'title' => 'Mi Página - HomeLab AR',
    'additionalCss' => ['aos'],
    'additionalJs' => ['aos', 'sweetalert2']
];

echo AppLayout::render('my-page', $data, $config);
?>
```

### Paso 3: Crear JS específico (opcional)

```javascript
// js/my-page.js

document.addEventListener("DOMContentLoaded", function () {
  // Ya tienes acceso a todas las dependencias cargadas
  AOS.init();

  // Usar Axios para peticiones
  axios.get("/api/data").then((response) => console.log(response.data));
});
```

---

## 🧩 Crear una Section Reutilizable

```php
<?php
// sections/my-section.section.php

$items = [
    ['title' => 'Item 1', 'icon' => 'bx-star'],
    ['title' => 'Item 2', 'icon' => 'bx-heart']
];
?>

<section class="py-5" id="my-section">
    <div class="container">
        <h2 class="text-center mb-5" data-aos="fade-up">
            Mi Sección
        </h2>

        <div class="row g-4">
            <?php foreach ($items as $index => $item): ?>
            <div class="col-md-6"
                 data-aos="fade-up"
                 data-aos-delay="<?php echo $index * 100; ?>">
                <div class="card card-custom">
                    <div class="card-body">
                        <i class="bx <?php echo $item['icon']; ?> bx-lg text-primary"></i>
                        <h5><?php echo $item['title']; ?></h5>
                    </div>
                </div>
            </div>
            <?php endforeach; ?>
        </div>
    </div>
</section>
```

---

## 🏪 Sistema AppStore

### Estructura de una App

```
appstore/apps/my-app/
├── manifest.json    # Metadatos
├── index.html       # App principal
├── preview.png      # Preview
└── icon.svg         # Icono
```

### manifest.json

```json
{
  "id": "my-app",
  "name": "Mi Aplicación",
  "version": "1.0.0",
  "entry": "index.html",
  "dependencies": {
    "npm": ["axios", "sweetalert2"],
    "vr": ["aframe"]
  }
}
```

### Cargar App desde JS

```javascript
// Obtener lista de apps
async function getApps() {
  const response = await axios.get("/appstore/reader.php?action=list");
  return response.data.data;
}

// Cargar app específica
async function loadApp(appId) {
  window.open(`/appstore/viewer.php?app=${appId}`, "_blank");
}

// Buscar apps
async function searchApps(query) {
  const response = await axios.get(
    `/appstore/reader.php?action=search&q=${query}`
  );
  return response.data.data;
}
```

---

## 🎨 Usar Variables CSS

```css
/* Usa las variables definidas en variables.css */

.my-component {
  color: var(--color-primary);
  padding: var(--spacing-lg);
  border-radius: var(--radius-md);
  box-shadow: var(--shadow-md);
  transition: all var(--transition-base);
}

.my-component:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-lg);
}
```

---

## 📦 Dependencias Disponibles

### CSS

- `bootstrap` - Framework CSS
- `aos` - Animaciones on scroll
- `animate` - Animaciones CSS
- `sweetalert2` - Alertas modernas
- `datatables` - Tablas interactivas
- `glightbox` - Lightbox
- `notyf` - Notificaciones

### JavaScript

- `axios` - HTTP Client (principal)
- `jquery` - Solo para DataTables/Bootstrap
- `bootstrap` - Framework JS
- `aos` - Animaciones
- `sweetalert2` - Alertas
- `chart` - Gráficos
- `datatables` - Tablas
- `anime` - Animaciones avanzadas

### VR/AR

- `aframe` - Framework VR/AR
- `three` - 3D avanzado
- `arjs` - AR.js

---

## ✅ Checklist de Buenas Prácticas

- [ ] ¿Usaste PHP para cargar componentes?
- [ ] ¿Las dependencias vienen de npm-loader.js?
- [ ] ¿Usaste las 3 CSS base?
- [ ] ¿Los nombres son descriptivos?
- [ ] ¿Evitaste JavaScript para inyectar HTML?
- [ ] ¿Validaste los datos de entrada?
- [ ] ¿Agregaste animaciones AOS donde corresponde?
- [ ] ¿El código es legible a primera vista?

---

## 🔗 Referencias

- **Arquitectura Completa**: `/docs/ARQUITECTURA-FUNCIONAL.md`
- **Instrucciones de Desarrollo**: `.github/instructions/homelab.instructions.md`
- **NPM Loader**: `composables/npm-loader.js`

---

**Proyecto**: HomeLab AR - Roepard Labs  
**Fecha**: Noviembre 2025
