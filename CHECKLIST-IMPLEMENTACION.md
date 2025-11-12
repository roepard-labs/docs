# ✅ Checklist de Implementación - Arquitectura Funcional

> **Guía paso a paso** para implementar la arquitectura documentada

**Proyecto**: HomeLab AR - Roepard Labs  
**Fecha**: Noviembre 2025

---

## 📋 Fase 1: Estructura Base

### 1.1 Directorios Principales

```bash
# Crear estructura de directorios
mkdir -p thepearlo_vr-website/{composables,css,views,sections,ui,modals,layout,js,appstore/apps}
```

- [ ] Directorio `composables/` creado
- [ ] Directorio `css/` creado
- [ ] Directorio `views/` creado
- [ ] Directorio `sections/` creado
- [ ] Directorio `ui/` creado
- [ ] Directorio `modals/` creado
- [ ] Directorio `layout/` creado
- [ ] Directorio `js/` creado
- [ ] Directorio `appstore/` y `appstore/apps/` creados

---

## 📦 Fase 2: Sistema de Dependencias

### 2.1 Dependencias NPM

```bash
# Instalar dependencias
npm install bootstrap@5 aos animate.css boxicons
npm install axios jquery sweetalert2 chart.js
npm install datatables.net datatables.net-bs5
npm install glightbox notyf tippy.js
npm install tom-select flatpickr filepond
npm install aframe three ar.js webvr-polyfill
```

- [ ] Bootstrap 5 instalado
- [ ] AOS instalado
- [ ] Animate.css instalado
- [ ] Axios instalado
- [ ] jQuery instalado
- [ ] SweetAlert2 instalado
- [ ] Chart.js instalado
- [ ] DataTables instalado
- [ ] Librerías VR/AR instaladas

### 2.2 NPM Loader

- [ ] Crear `composables/npm-loader.js`
- [ ] Configurar `NPM_CONFIG.css`
- [ ] Configurar `NPM_CONFIG.js`
- [ ] Configurar `NPM_CONFIG.vr`
- [ ] Implementar funciones helper (getCSSPath, getJSPath, getVRPath)
- [ ] Implementar carga dinámica (loadCSS, loadJS)
- [ ] Verificar exportación global (`window.NPM_CONFIG`)

### 2.3 Config y Router

- [ ] Crear `composables/config.js` con configuración global
- [ ] Crear `composables/router.js` con cliente Axios
- [ ] Configurar URLs del backend (dev/prod)
- [ ] Implementar interceptores de Axios

---

## 🎨 Fase 3: Sistema CSS

### 3.1 Variables CSS

Crear `css/variables.css` con:

- [ ] Colores primarios y secundarios
- [ ] Espaciados (xs, sm, md, lg, xl, xxl)
- [ ] Tipografía (font-family, font-size)
- [ ] Sombras (shadow-sm, shadow-md, shadow-lg)
- [ ] Border radius (radius-sm, radius-md, radius-lg)
- [ ] Transiciones (transition-fast, transition-base, transition-slow)
- [ ] Breakpoints (sm, md, lg, xl, xxl)
- [ ] Dark mode override

### 3.2 Base CSS

Crear `css/base.css` con:

- [ ] Reset básico (`*, html, body`)
- [ ] Tipografía base (h1-h6, p, a)
- [ ] Imágenes responsive
- [ ] Código y pre
- [ ] Botones base
- [ ] Focus visible
- [ ] Scroll personalizado

### 3.3 Main CSS

Crear `css/main.css` con:

- [ ] Utilidades de espaciado extra (.p-xxl, .m-xxl)
- [ ] Gradientes (.gradient-primary, .gradient-overlay)
- [ ] Sombras personalizadas (.shadow-custom-\*)
- [ ] Display utilities (.full-height, .flex-center)
- [ ] Card mejorado (.card-custom)
- [ ] Hero section (.hero-section, .hero-content)
- [ ] Stats counter (.stat-number)
- [ ] Animaciones (@keyframes pulse-glow, spin)
- [ ] Text utilities (.text-gradient)
- [ ] Backdrop blur (.backdrop-blur)
- [ ] Sticky header (.sticky-header)

---

## 📐 Fase 4: Layout Principal

### 4.1 AppLayout.php

Crear `layout/AppLayout.php` con:

- [ ] Clase `AppLayout`
- [ ] Propiedades estáticas: `$cssCore`, `$jsCore`, `$viewDependencies`
- [ ] Método `render($view, $data, $config)`
- [ ] Método `renderCssLinks($cssArray)`
- [ ] Método `renderJsScripts($jsArray)`
- [ ] Método `includeView($view, $data)`
- [ ] Método `includeComponent($component, $data)`
- [ ] Estructura HTML5 completa
- [ ] Meta tags (charset, viewport, description)
- [ ] Favicon
- [ ] CSS base (variables, base, main)
- [ ] CSS dependencies
- [ ] Header/Footer condicionales
- [ ] Scripts en orden correcto

### 4.2 Configuración de Dependencias por Vista

En `AppLayout.php`, configurar `$viewDependencies`:

- [ ] Vista `home`: glightbox, chart, anime
- [ ] Vista `homelab`: aframe, three (VR/AR)
- [ ] Vista `dashboard`: datatables, datatablesBS5, datatablesResponsive
- [ ] Vista `auth`: sweetalert2
- [ ] Agregar según necesidad

---

## 🖼️ Fase 5: Componentes UI

### 5.1 Header

Crear `ui/header.ui.php` con:

- [ ] Logo del proyecto
- [ ] Navegación principal
- [ ] Botones de autenticación (dinámicos)
- [ ] Toggle de dark mode
- [ ] Responsive (hamburger menu en móvil)
- [ ] Estilos en `css/header.css`

### 5.2 Footer

Crear `ui/footer.ui.php` con:

- [ ] Links útiles
- [ ] Copyright
- [ ] Social media
- [ ] Newsletter (opcional)
- [ ] Estilos en `css/footer.css`

### 5.3 Navbar

Crear `ui/navbar.ui.php` con:

- [ ] Navegación secundaria
- [ ] Breadcrumbs (opcional)
- [ ] Search bar (opcional)

### 5.4 Sidebar

Crear `ui/sidebar.ui.php` con:

- [ ] Navegación de dashboard
- [ ] User info
- [ ] Menu items con iconos
- [ ] Colapsable en móvil
- [ ] Estilos en `css/sidebar.css`

---

## 🏠 Fase 6: Vista Home

### 6.1 Vista Principal

Crear `views/home.view.php`:

- [ ] Include de sections en orden
- [ ] hero.section.php
- [ ] features.section.php
- [ ] stats.section.php
- [ ] about.section.php
- [ ] contact.section.php

### 6.2 Hero Section

Crear `sections/hero.section.php`:

- [ ] Título principal con `data-aos="fade-right"`
- [ ] Descripción
- [ ] CTA buttons (Comenzar, Conoce Más)
- [ ] Imagen/ilustración con `data-aos="fade-left"`
- [ ] Scroll indicator
- [ ] Gradient background
- [ ] Estilos inline o en `css/home.css`

### 6.3 Features Section

Crear `sections/features.section.php`:

- [ ] Array de features (PHP)
- [ ] Título de sección con `data-aos="fade-up"`
- [ ] Grid de cards (col-md-6 col-lg-3)
- [ ] Cada card con icono Boxicons
- [ ] Delays incrementales (0, 200, 400, 600)
- [ ] Hover effects con `.card-custom`

### 6.4 Stats Section

Crear `sections/stats.section.php`:

- [ ] Array de stats (PHP)
- [ ] Background alternativo (bg-light)
- [ ] Stats con `data-aos="zoom-in"`
- [ ] Números con clase `.stat-number`
- [ ] Atributo `data-count` para animación
- [ ] JavaScript para CountUp.js (opcional)

### 6.5 About Section

Crear `sections/about.section.php`:

- [ ] Información del proyecto
- [ ] Imágenes/video
- [ ] Animaciones AOS
- [ ] Call to action

### 6.6 Contact Section

Crear `sections/contact.section.php`:

- [ ] Formulario de contacto
- [ ] Información de contacto
- [ ] Mapa (opcional)
- [ ] Validación con JavaScript

### 6.7 JavaScript de Home

Crear `js/home.js`:

- [ ] Inicialización de AOS
- [ ] Peticiones Axios para stats
- [ ] Animación de números (anime.js)
- [ ] Smooth scroll
- [ ] Manejo de errores con SweetAlert2

---

## 🪟 Fase 7: Modales

### 7.1 Modal de Autenticación

Crear `modals/auth.modal.php`:

- [ ] Estructura de modal Bootstrap 5
- [ ] Tabs para Login/Register
- [ ] Formulario de login
- [ ] Formulario de registro
- [ ] Validación frontend
- [ ] Integración con `js/auth.js`
- [ ] Estilos en `css/auth.css`

---

## ⚙️ Fase 8: JavaScript

### 8.1 Main.js

Crear `js/main.js`:

- [ ] DOMContentLoaded event
- [ ] Inicialización de Bootstrap tooltips
- [ ] Inicialización de Bootstrap popovers
- [ ] Theme toggler
- [ ] Global error handler

### 8.2 Auth.js

Crear `js/auth.js`:

- [ ] Funciones de login
- [ ] Funciones de logout
- [ ] Funciones de registro
- [ ] Gestión de JWT en localStorage
- [ ] Actualización de header dinámico
- [ ] Interceptores Axios

### 8.3 Utils.js

Crear `js/utils.js`:

- [ ] Funciones helper
- [ ] Formateo de fechas
- [ ] Formateo de números
- [ ] Validaciones comunes
- [ ] Debounce/throttle

---

## 🏪 Fase 9: Sistema AppStore

### 9.1 Estructura Base

- [ ] Crear `appstore/apps.json` (índice)
- [ ] Crear `appstore/reader.php` (API)
- [ ] Crear `appstore/viewer.php` (visor)
- [ ] Crear directorio ejemplo: `appstore/apps/ejemplo/`

### 9.2 Índice de Apps

Crear `appstore/apps.json`:

- [ ] Versión del índice
- [ ] Fecha de última actualización
- [ ] Array de aplicaciones
- [ ] Cada app con: id, name, version, description, author
- [ ] Metadatos: category, tags, icon, preview
- [ ] URLs: manifestUrl, appUrl
- [ ] Flags: featured, requiresAuth, vrCompatible, arCompatible
- [ ] Estadísticas: downloads, rating

### 9.3 Reader API

Crear `appstore/reader.php`:

- [ ] Clase `AppStoreReader`
- [ ] Método `getAllApps()`
- [ ] Método `getApp($appId)`
- [ ] Método `searchApps($query)`
- [ ] Método `getByCategory($category)`
- [ ] Método `getFeaturedApps()`
- [ ] Respuestas JSON consistentes
- [ ] Manejo de errores
- [ ] Headers CORS

### 9.4 Viewer

Crear `appstore/viewer.php`:

- [ ] Lectura de parámetro `?app=id`
- [ ] Carga de manifest.json
- [ ] Estructura HTML base
- [ ] Carga de dependencias de la app
- [ ] Inyección de index.html de la app
- [ ] Variables globales (APP_MANIFEST, APP_ID, APP_PATH)

### 9.5 Aplicación de Ejemplo

Crear `appstore/apps/docker-manager/`:

- [ ] `manifest.json` con metadatos completos
- [ ] `index.html` con contenido de la app
- [ ] `preview.png` (800x450px)
- [ ] `icon.svg` (256x256px)
- [ ] `README.md` (opcional)

Estructura de `manifest.json`:

- [ ] id, name, version, description
- [ ] author (name, email, url)
- [ ] entry (index.html)
- [ ] permissions (array)
- [ ] dependencies (npm, vr)
- [ ] config (apiEndpoint, etc)
- [ ] ui (fullscreen, darkMode, orientation)
- [ ] metadata (category, tags, license, repository)

### 9.6 JavaScript del AppStore

Crear `js/appstore.js`:

- [ ] Función `loadApp(appId)`
- [ ] Función `searchApps(query)`
- [ ] Función `getApps()`
- [ ] Función `getFeaturedApps()`
- [ ] Renderizado de catálogo
- [ ] Filtros por categoría
- [ ] Search en tiempo real

---

## 🎨 Fase 10: Estilos Específicos

### 10.1 Por Vista

- [ ] `css/home.css` - Estilos específicos de home
- [ ] `css/homelab.css` - Estilos para vista VR/AR
- [ ] `css/dashboard.css` - Estilos de dashboard
- [ ] `css/auth.css` - Estilos de autenticación

### 10.2 Por Componente

- [ ] `css/header.css` - Header específico
- [ ] `css/footer.css` - Footer específico
- [ ] `css/sidebar.css` - Sidebar específico
- [ ] `css/users.css` - Gestión de usuarios

---

## 🧪 Fase 11: Testing

### 11.1 Dependencias

- [ ] Verificar carga de npm-loader.js
- [ ] Verificar todas las rutas de getCSSPath()
- [ ] Verificar todas las rutas de getJSPath()
- [ ] Verificar todas las rutas de getVRPath()
- [ ] Verificar orden de carga de scripts

### 11.2 CSS

- [ ] Verificar variables CSS aplicadas
- [ ] Verificar estilos base
- [ ] Verificar utilidades de main.css
- [ ] Verificar responsive design
- [ ] Verificar dark mode
- [ ] Verificar animaciones AOS

### 11.3 PHP

- [ ] Verificar AppLayout::render() funciona
- [ ] Verificar carga de vistas
- [ ] Verificar inclusión de sections
- [ ] Verificar inclusión de UI components
- [ ] Verificar paso de datos

### 11.4 JavaScript

- [ ] Verificar main.js se ejecuta
- [ ] Verificar Axios funciona
- [ ] Verificar autenticación
- [ ] Verificar SweetAlert2
- [ ] Verificar DataTables (si aplica)
- [ ] Verificar Chart.js (si aplica)

### 11.5 AppStore

- [ ] Verificar reader.php?action=list
- [ ] Verificar reader.php?action=get&id=app
- [ ] Verificar reader.php?action=search&q=query
- [ ] Verificar viewer.php?app=id
- [ ] Verificar carga de manifest
- [ ] Verificar ejecución de app

### 11.6 Navegadores

- [ ] Chrome/Edge (última versión)
- [ ] Firefox (última versión)
- [ ] Safari (última versión)
- [ ] Mobile Safari (iOS)
- [ ] Chrome Mobile (Android)

### 11.7 Performance

- [ ] Lighthouse score > 90
- [ ] First Contentful Paint < 1.5s
- [ ] Time to Interactive < 3s
- [ ] CSS minificado
- [ ] JavaScript minificado
- [ ] Imágenes optimizadas
- [ ] Lazy loading activado

---

## 📚 Fase 12: Documentación

### 12.1 Código

- [ ] Comentarios en funciones complejas
- [ ] PHPDoc en métodos públicos
- [ ] JSDoc en funciones públicas
- [ ] README en appstore/apps/

### 12.2 Usuario

- [ ] Actualizar README.md principal
- [ ] Crear CHANGELOG.md
- [ ] Crear guía de instalación
- [ ] Crear guía de uso

---

## 🚀 Fase 13: Deployment

### 13.1 Preparación

- [ ] Variables de entorno configuradas
- [ ] Archivos `.env` creados
- [ ] `.gitignore` actualizado
- [ ] `package.json` completo

### 13.2 Build

- [ ] `npm install` en producción
- [ ] `npm run build` (si aplica)
- [ ] Verificar permisos de archivos
- [ ] Verificar rutas absolutas/relativas

### 13.3 Dokploy

- [ ] Crear proyecto en Dokploy
- [ ] Configurar variables de entorno
- [ ] Configurar build commands
- [ ] Configurar dominio
- [ ] Deploy inicial
- [ ] Verificar funcionamiento

---

## ✅ Checklist Final

### Funcionalidad

- [ ] Home page carga correctamente
- [ ] Animaciones AOS funcionan
- [ ] Navegación funciona
- [ ] Autenticación funciona
- [ ] API backend responde
- [ ] AppStore funciona
- [ ] Responsive en todos los dispositivos
- [ ] Dark mode funciona

### Calidad

- [ ] No hay errores en consola
- [ ] No hay warnings de dependencias
- [ ] Código es legible
- [ ] Nombres son descriptivos
- [ ] Comentarios donde son necesarios
- [ ] Sin código duplicado

### Performance

- [ ] Carga rápida (< 3s)
- [ ] No hay layout shifts
- [ ] Imágenes optimizadas
- [ ] CSS y JS minificados
- [ ] Cache configurado

### Seguridad

- [ ] HTTPS configurado
- [ ] CORS configurado
- [ ] JWT implementado
- [ ] Inputs validados
- [ ] XSS prevenido
- [ ] SQL injection prevenido

### Documentación

- [ ] README actualizado
- [ ] Arquitectura documentada
- [ ] APIs documentadas
- [ ] Ejemplos de uso incluidos

---

## 🎉 ¡Completado!

Una vez todos los checkboxes están marcados:

1. ✅ Arquitectura implementada
2. ✅ Testing completado
3. ✅ Documentación actualizada
4. ✅ Deployment exitoso

**¡El proyecto está listo para producción!**

---

**Proyecto**: HomeLab AR - Roepard Labs  
**Última actualización**: Noviembre 2025
