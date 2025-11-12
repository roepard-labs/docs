# 🧭 Navbar Persistente con Breadcrumb Dinámico - HomeLab AR

## 📋 Resumen de Implementación

Se implementó un **navbar persistente** que se muestra en **todas las páginas del dashboard** con un **breadcrumb dinámico** que actualiza automáticamente el título de la página según la ruta actual.

**Fecha de Implementación**: Noviembre 4, 2025

---

## ✅ Cambios Realizados

### 1. **dashboard.view.php** - Navbar Siempre Visible

**Cambio**: El navbar ahora se carga **ANTES** del condicional de páginas, garantizando que esté visible en todas las vistas.

**Antes**:

```php
<?php if ($dashboardPage): ?>
    <!-- Navbar solo en página principal -->
    <?php include __DIR__ . '/../ui/navbar.ui.php'; ?>
    <!-- Contenido -->
<?php endif; ?>
```

**Después**:

```php
<!-- Navbar/Breadcrumb (Siempre visible en todas las páginas) -->
<?php include __DIR__ . '/../ui/navbar.ui.php'; ?>

<?php if ($dashboardPage): ?>
    <!-- Contenido de páginas dinámicas -->
<?php else: ?>
    <!-- Dashboard principal -->
<?php endif; ?>
```

**Resultado**: El navbar ahora aparece en:

- ✅ `/dashboard` - Dashboard principal
- ✅ `/dashboard/users` - Gestión de Usuarios
- ✅ `/dashboard/settings` - Configuración
- ✅ `/dashboard/profile` - Mi Perfil

---

### 2. **navbar.ui.php** - Sistema de Breadcrumb Dinámico

#### 📍 Detección Automática de Página

**Antes**: Usaba `basename($_SERVER['PHP_SELF'], '.php')` (solo detectaba nombre de archivo)

**Después**: Usa `parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH)` (detecta ruta completa)

```php
// Detectar página actual desde la URL
$currentPath = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// Mapear rutas a breadcrumbs y títulos
$pageInfo = [
    '/dashboard' => [
        'breadcrumb' => ['Dashboard'],
        'title' => 'Dashboard Principal',
        'icon' => 'bx-home-alt'
    ],
    '/dashboard/users' => [
        'breadcrumb' => ['Dashboard', 'Usuarios'],
        'title' => 'Gestión de Usuarios',
        'icon' => 'bx-user'
    ],
    '/dashboard/settings' => [
        'breadcrumb' => ['Dashboard', 'Configuración'],
        'title' => 'Configuración del Sistema',
        'icon' => 'bx-cog'
    ],
    '/dashboard/profile' => [
        'breadcrumb' => ['Dashboard', 'Mi Perfil'],
        'title' => 'Mi Perfil de Usuario',
        'icon' => 'bx-user-circle'
    ]
];
```

---

#### 🎨 Nuevo Diseño con Título de Página

**Antes**: Solo breadcrumb simple

```html
<nav aria-label="breadcrumb">
  <ol class="breadcrumb">
    <li>Dashboard</li>
  </ol>
</nav>
```

**Después**: Breadcrumb + Título con icono

```html
<div class="page-header-section">
  <!-- Breadcrumb -->
  <nav aria-label="breadcrumb" class="mb-1">
    <ol class="breadcrumb mb-0">
      <li class="breadcrumb-item">
        <a href="/dashboard">Dashboard</a>
      </li>
      <li class="breadcrumb-item active" id="currentPageBreadcrumb">
        Usuarios
      </li>
    </ol>
  </nav>

  <!-- Page Title -->
  <h5
    class="mb-0 fw-bold d-flex align-items-center gap-2"
    id="currentPageTitle"
  >
    <i class="bx bx-user text-primary"></i>
    <span>Gestión de Usuarios</span>
  </h5>
</div>
```

---

#### 🔄 JavaScript para Actualización Dinámica

**Nuevo Script**: Actualiza breadcrumb automáticamente al navegar entre páginas sin recargar.

```javascript
const pageMapping = {
  "/dashboard": {
    breadcrumb: "Dashboard",
    title: "Dashboard Principal",
    icon: "bx-home-alt",
  },
  "/dashboard/users": {
    breadcrumb: "Usuarios",
    title: "Gestión de Usuarios",
    icon: "bx-user",
  },
  // ...más páginas
};

function updateBreadcrumb() {
  const currentPath = window.location.pathname;
  const pageInfo = pageMapping[currentPath];

  if (!pageInfo) return;

  // Actualizar breadcrumb
  document.getElementById("currentPageBreadcrumb").textContent =
    pageInfo.breadcrumb;

  // Actualizar título con icono
  document.getElementById("currentPageTitle").innerHTML = `
        <i class="bx ${pageInfo.icon} text-primary"></i>
        <span>${pageInfo.title}</span>
    `;
}

// Actualizar al cargar
updateBreadcrumb();

// Escuchar cambios de navegación
window.addEventListener("popstate", updateBreadcrumb);

// Observar cambios en la URL cada 500ms
setInterval(() => {
  if (window.location.pathname !== lastPath) {
    lastPath = window.location.pathname;
    updateBreadcrumb();
  }
}, 500);
```

---

#### 🎨 Estilos Mejorados

**Nuevos Estilos CSS**:

```css
.page-header-section {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.breadcrumb {
  background: none;
  padding: 0;
  margin: 0;
  font-size: 0.85rem;
}

.breadcrumb-item + .breadcrumb-item::before {
  content: "›";
  color: var(--bs-secondary);
}

.breadcrumb-item a {
  color: var(--bs-secondary);
  transition: color 0.2s ease;
}

.breadcrumb-item a:hover {
  color: var(--bs-primary);
}

.breadcrumb-item.active {
  color: var(--bs-body-color);
  font-weight: 500;
}

#currentPageTitle {
  font-size: 1.25rem;
  color: var(--bs-body-color);
}

#currentPageTitle i {
  font-size: 1.5rem;
}
```

---

## 📊 Mapeo de Rutas y Breadcrumbs

| URL                   | Breadcrumb                | Título de Página          | Icono          |
| --------------------- | ------------------------- | ------------------------- | -------------- |
| `/dashboard`          | Dashboard                 | Dashboard Principal       | bx-home-alt    |
| `/dashboard/users`    | Dashboard › Usuarios      | Gestión de Usuarios       | bx-user        |
| `/dashboard/settings` | Dashboard › Configuración | Configuración del Sistema | bx-cog         |
| `/dashboard/profile`  | Dashboard › Mi Perfil     | Mi Perfil de Usuario      | bx-user-circle |

---

## 🎯 Características Implementadas

### ✅ Navbar Persistente

- Se muestra en **todas las páginas** del dashboard
- No desaparece al navegar entre secciones
- Mantiene fecha/hora actualizada en tiempo real

### ✅ Breadcrumb Dinámico

- Detecta automáticamente la página actual desde la URL
- Actualiza el breadcrumb sin recargar la página
- Muestra la jerarquía de navegación (Dashboard › Página)

### ✅ Título de Página con Icono

- Cada página tiene un título descriptivo
- Icono representativo de la sección
- Actualización dinámica al navegar

### ✅ Responsive

- Se adapta a dispositivos móviles
- Botón de menú móvil visible en pantallas pequeñas
- Grid responsive (col-md-7 para breadcrumb, col-md-5 para fecha/hora)

---

## 🔧 Cómo Agregar Nuevas Páginas

### 1. Registrar Ruta en PHP (navbar.ui.php)

```php
$pageInfo = [
    // Rutas existentes...
    '/dashboard/nueva-pagina' => [
        'breadcrumb' => ['Dashboard', 'Nueva Página'],
        'title' => 'Título de la Nueva Página',
        'icon' => 'bx-star'  // Icono de Boxicons
    ]
];
```

### 2. Registrar Ruta en JavaScript (navbar.ui.php)

```javascript
const pageMapping = {
  // Rutas existentes...
  "/dashboard/nueva-pagina": {
    breadcrumb: "Nueva Página",
    title: "Título de la Nueva Página",
    icon: "bx-star",
  },
};
```

### 3. Registrar Ruta en Router (index.php)

```php
$routes = [
    // Rutas existentes...
    '/dashboard/nueva-pagina' => 'dashboard.view.php'
];
```

### 4. Crear Archivo de Página (/pages/nueva-pagina.page.php)

```php
<?php
/**
 * Página: Nueva Página
 * HomeLab AR - Roepard Labs
 */
?>

<div class="row">
    <div class="col-12">
        <h2>Contenido de la nueva página</h2>
    </div>
</div>
```

### 5. Actualizar Detección de Página (dashboard.view.php)

```php
if ($currentPath === '/dashboard/nueva-pagina') {
    $dashboardPage = 'nueva-pagina.page.php';
}
```

---

## 🧪 Testing

### Verificar Navbar Persistente

1. Navegar a `/dashboard` → ✅ Navbar visible
2. Navegar a `/dashboard/users` → ✅ Navbar visible
3. Navegar a `/dashboard/settings` → ✅ Navbar visible
4. Navegar a `/dashboard/profile` → ✅ Navbar visible

### Verificar Breadcrumb Dinámico

1. En `/dashboard` → Breadcrumb: "Dashboard" | Título: "Dashboard Principal"
2. En `/dashboard/users` → Breadcrumb: "Dashboard › Usuarios" | Título: "Gestión de Usuarios"
3. En `/dashboard/settings` → Breadcrumb: "Dashboard › Configuración" | Título: "Configuración del Sistema"
4. En `/dashboard/profile` → Breadcrumb: "Dashboard › Mi Perfil" | Título: "Mi Perfil de Usuario"

### Verificar Actualización Automática

1. Navegar entre páginas usando sidebar
2. Observar que breadcrumb y título se actualizan automáticamente
3. Verificar que el icono correcto aparece en cada página

### Verificar Responsive

1. Abrir DevTools y cambiar a vista móvil
2. Verificar que botón de menú móvil aparece
3. Verificar que navbar se adapta correctamente

---

## 📸 Vista Previa

### Desktop (Navbar Completo)

```
┌─────────────────────────────────────────────────────────────────────────┐
│  ☰  Dashboard › Usuarios                     📅 Lun, 4 Nov 2025        │
│     👤 Gestión de Usuarios                       ⏰ 14:30:45            │
└─────────────────────────────────────────────────────────────────────────┘
```

### Mobile (Navbar Responsive)

```
┌──────────────────────────────┐
│  ☰  Dashboard › Usuarios     │
│     👤 Gestión de Usuarios   │
│                              │
│  📅 Lun, 4 Nov 2025          │
│  ⏰ 14:30:45                 │
└──────────────────────────────┘
```

---

## 🎨 Personalización

### Cambiar Separador del Breadcrumb

En `navbar.ui.php`, CSS:

```css
.breadcrumb-item + .breadcrumb-item::before {
  content: "›"; /* Cambiar a "/", ">", "→", etc. */
  color: var(--bs-secondary);
}
```

### Cambiar Tamaño del Título

En `navbar.ui.php`, CSS:

```css
#currentPageTitle {
  font-size: 1.25rem; /* Cambiar a 1rem, 1.5rem, etc. */
}
```

### Cambiar Colores

```css
.breadcrumb-item a {
  color: var(--bs-secondary); /* Color de links */
}

.breadcrumb-item a:hover {
  color: var(--bs-primary); /* Color al hover */
}
```

---

## 📝 Archivos Modificados

1. **`/views/dashboard.view.php`**

   - Movido `<?php include navbar.ui.php; ?>` fuera del condicional
   - Ahora navbar se carga ANTES de verificar qué página mostrar

2. **`/ui/navbar.ui.php`**
   - Agregado sistema de detección de ruta con `parse_url()`
   - Agregado mapeo de rutas a títulos y breadcrumbs
   - Agregado título de página con icono
   - Agregado script JavaScript para actualización dinámica
   - Mejorados estilos CSS para mejor presentación

---

## 🚀 Próximas Mejoras Sugeridas

1. **Animaciones de Transición**

   - Fade in/out al cambiar breadcrumb
   - Slide animation para título

2. **Historial de Navegación**

   - Botones "Atrás" y "Adelante"
   - Mostrar últimas páginas visitadas

3. **Acciones Rápidas**

   - Botones de acción específicos por página
   - Dropdown con opciones contextuales

4. **Search Bar**

   - Búsqueda global en navbar
   - Acceso rápido a páginas

5. **Notificaciones**
   - Badge de notificaciones en navbar
   - Dropdown con notificaciones recientes

---

## ✅ Checklist de Implementación

- [x] Navbar persistente en todas las páginas
- [x] Breadcrumb dinámico con detección de ruta
- [x] Título de página con icono
- [x] Actualización automática con JavaScript
- [x] Estilos responsive
- [x] Mapeo de rutas en PHP y JavaScript
- [x] Documentación completa
- [x] Sistema fácil de extender para nuevas páginas

---

**Implementado por**: Roepard Labs Development Team  
**Fecha**: Noviembre 4, 2025  
**Versión**: 1.0
