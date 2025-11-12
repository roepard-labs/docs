# 🥽 ThePearlOS - HomeLab VR Dashboard Page

## 📋 Resumen de Implementación

Se ha creado una nueva página en el dashboard para **ThePearlOS**, el sistema operativo virtual de HomeLab VR, con un diseño profesional, escalable y preparado para integración con backend.

---

## 🎯 Características Implementadas

### 1. **Navegación en Sidebar**

- ✅ Agregado enlace "HomeLab VR" en sidebar desktop
- ✅ Agregado enlace en sidebar mobile (offcanvas)
- ✅ Separadores visuales para mejor organización
- ✅ Icono: `bx-glasses` (gafas VR)
- ✅ Ruta: `/dashboard/homelab`

### 2. **Header de la Página**

- ✅ Logo con icono de gafas VR
- ✅ Título: **ThePearlOS** con gradiente
- ✅ Subtítulo: "Sistema Operativo Virtual - HomeLab VR"
- ✅ Badge de versión: v1.0.0-beta
- ✅ Animación hover con elevación

### 3. **Estadísticas del Sistema**

Cuatro tarjetas con información:

| Métrica                | Icono             | Descripción                               |
| ---------------------- | ----------------- | ----------------------------------------- |
| **Apps**               | `bx-grid-alt`     | Cantidad total de aplicaciones instaladas |
| **Usuarios Activos**   | `bx-user`         | Usuarios conectados al sistema            |
| **Status del Sistema** | `bx-check-shield` | Estado operativo de ThePearlOS            |
| **Uptime**             | `bx-time`         | Tiempo de actividad del sistema           |

**Características:**

- Gradientes únicos por tarjeta
- Animación hover con elevación
- Carga asíncrona de datos desde backend
- Spinners mientras carga

### 4. **Sección "Tu Sesión"**

Muestra información del usuario actual:

- **Nombre completo**: Cargado desde backend
- **Rol**: Badge con color según rol (Admin rojo, Usuario azul)
- **Usuario**: @username
- **Email**: Correo electrónico

### 5. **Botón "Entrar a HomeLab"**

- ✅ Diseño atractivo con icono animado
- ✅ Animación con Anime.js (pulso continuo)
- ✅ Efecto de brillo al hover
- ✅ Animación de rotación al hacer clic
- ✅ Redirige a `/homelab` (experiencia VR completa)

### 6. **Sección "Ayuda y Recomendaciones"**

Lista de recomendaciones:

- Usar audífonos
- Buena iluminación
- Permitir acceso a cámara/sensores
- Navegador compatible (Chrome/Firefox)

### 7. **Sección "Información"**

Detalles del sistema:

- **Versión**: 1.0.0-beta
- **Repositorio**: Link a GitHub con logo
  - URL: https://github.com/roepard-labs/thepearlo_vr-appstore
  - Icono: `bxl-github`
- **Última actualización**: Nov 2025
- **Botón de diagnóstico**: Verifica compatibilidad del navegador

---

## 📁 Archivos Modificados

### 1. `/ui/sidebar.ui.php`

**Cambios realizados:**

```php
<!-- Agregado después del Dashboard Principal -->
<!-- Divider -->
<li>
    <hr class="sidebar-divider my-3">
</li>

<!-- HomeLab VR OS -->
<li class="nav-item">
    <a href="/dashboard/homelab" class="nav-link sidebar-link" data-page="homelab"
        title="ThePearlOS - HomeLab VR">
        <i class="bx bx-glasses me-3"></i>
        <span class="sidebar-text">HomeLab VR</span>
    </a>
</li>
```

**También en sidebar móvil:**

```php
<!-- HomeLab VR OS -->
<li class="nav-item">
    <a href="/dashboard/homelab" class="nav-link sidebar-link">
        <i class="bx bx-glasses me-3"></i>
        <span>HomeLab VR</span>
    </a>
</li>
```

### 2. `/views/dashboard.view.php`

**Cambios realizados:**

```php
} elseif ($currentPath === '/dashboard/homelab') {
    $dashboardPage = 'homelab.page.php';
    // Dependencias específicas para ThePearlOS
    $additionalCss = [];
    $additionalJs = ['anime']; // Para animaciones
}
```

### 3. `/index.php`

**Cambios realizados:**

```php
$routes = [
    // ... rutas existentes ...
    '/dashboard/homelab' => 'dashboard.view.php'
];
```

### 4. `/pages/homelab.page.php` ✨ (NUEVO)

**Archivo creado con:**

- HTML completo de la página
- Estilos CSS inline con diseño moderno
- JavaScript para cargar datos y animaciones
- Sistema modular y escalable

---

## 🎨 Diseño y Estilos

### Paleta de Colores (Gradientes)

```css
/* Tarjetas de estadísticas */
.bg-gradient-1: #667eea → #764ba2 (Morado)
.bg-gradient-2: #f093fb → #f5576c (Rosa)
.bg-gradient-3: #4facfe → #00f2fe (Azul)
.bg-gradient-4: #43e97b → #38f9d7 (Verde)

/* Título ThePearlOS */
gradient-text: var(--bs-primary) → var(--bs-info)

/* Botón Enter HomeLab */
background: var(--bs-primary) → var(--bs-info)
box-shadow: 0 8px 20px rgba(primary, 0.4)
```

### Animaciones Implementadas

1. **Fade In de Página**

   - Transición suave al cargar

2. **Hover en Tarjetas**

   - `transform: translateY(-5px)`
   - `box-shadow` elevado

3. **Pulso del Icono HomeLab**

   - Anime.js: `scale: [1, 1.1, 1]`
   - `rotate: [0, 5, -5, 0]`
   - Loop infinito

4. **Botón Enter HomeLab**

   - Efecto de brillo horizontal al hover
   - Animación de rotación 360° al clic
   - Elevación con sombra

5. **AOS (Animate On Scroll)**
   - `data-aos="fade-up"` en tarjetas
   - `data-aos-delay` escalonado (100, 200, 300, 400ms)

---

## 🔧 Integración con Backend

### Endpoints Utilizados

#### 1. **Sesión del Usuario**

```javascript
GET /routes/user/check_session.php

Response:
{
    "logged": true,
    "user_data": {
        "user_id": 1,
        "first_name": "Juan",
        "last_name": "Pérez",
        "username": "juanperez",
        "email": "juan@example.com",
        "role_id": 2
    }
}
```

#### 2. **Estadísticas del Sistema**

```javascript
GET /routes/admin/get_dashboard_stats.php

Response:
{
    "status": "success",
    "stats": {
        "active_sessions": 5,
        "total_users": 150,
        // ... otras métricas
    }
}
```

### Preparado para Escalar

#### Endpoints Futuros (Backend TODO)

```javascript
// 1. Obtener apps instaladas
GET /routes/homelab/get_apps.php
Response: { "total_apps": 24, "apps": [...] }

// 2. Obtener usuarios activos
GET /routes/homelab/get_active_users.php
Response: { "active_users": 12, "users": [...] }

// 3. Status del sistema
GET /routes/homelab/get_system_status.php
Response: {
    "status": "operational",
    "uptime": "99.9%",
    "last_check": "2025-11-06 10:30:00"
}

// 4. Diagnóstico completo
POST /routes/homelab/run_diagnostic.php
Response: {
    "webxr_support": true,
    "camera_access": true,
    "webgl_support": true,
    // ... más checks
}
```

---

## 🧪 Funcionalidad JavaScript

### Funciones Principales

#### 1. `loadUserSession()`

- Carga datos del usuario desde backend
- Actualiza información en la sección "Tu Sesión"
- Maneja errores y estados de carga

#### 2. `loadSystemStats()`

- Obtiene estadísticas del sistema
- Actualiza contadores de apps y usuarios activos
- Usa datos de ejemplo mientras backend no esté listo

#### 3. `animateHomelabIcon()`

- Anima el icono de gafas VR con Anime.js
- Pulso continuo (scale + rotate)
- Loop infinito

#### 4. `runDiagnostic()`

- Verifica compatibilidad del navegador
- Checks incluidos:
  - WebXR Support
  - Camera Access
  - WebGL
  - LocalStorage
  - SessionStorage
- Muestra resultados en modal SweetAlert2

### Event Listeners

```javascript
// Botón de diagnóstico
document
  .getElementById("diagnosticBtn")
  .addEventListener("click", runDiagnostic);

// Botón Enter HomeLab (con animación)
document
  .getElementById("enterHomelabBtn")
  .addEventListener("click", function (e) {
    e.preventDefault();
    // Anima icono → Navega a /homelab
  });
```

---

## 📱 Responsive Design

### Breakpoints

- **Desktop** (≥1200px): Layout completo de 2 columnas (8-4)
- **Tablet** (768px-1199px): Layout apilado
- **Mobile** (≤767px):
  - Header centrado
  - Iconos más pequeños
  - Botones full-width

### Ajustes Mobile

```css
@media (max-width: 767.98px) {
  .homelab-header {
    text-align: center;
  }
  .stat-icon-os {
    width: 50px;
    height: 50px;
  }
  .homelab-icon-large {
    width: 80px;
    height: 80px;
  }
}
```

---

## ✅ Checklist de Implementación

- [x] Agregar enlace en sidebar desktop
- [x] Agregar enlace en sidebar mobile
- [x] Crear ruta en `index.php`
- [x] Configurar dependencias en `dashboard.view.php`
- [x] Crear `homelab.page.php` con diseño completo
- [x] Implementar estadísticas del sistema (4 cards)
- [x] Implementar sección "Tu Sesión"
- [x] Implementar botón "Entrar a HomeLab" con animaciones
- [x] Implementar sección "Ayuda y Recomendaciones"
- [x] Implementar sección "Información" con link a GitHub
- [x] Implementar botón de diagnóstico
- [x] Agregar animaciones con Anime.js
- [x] Agregar animaciones AOS
- [x] Responsive design completo
- [x] Integración con backend (endpoints preparados)
- [x] Manejo de errores y estados de carga

---

## 🚀 Testing

### Probar la Página

1. **Iniciar servidor de desarrollo:**

   ```bash
   cd /path/to/thepearlo_vr-website
   php -S localhost:9000 router.php
   ```

2. **Navegar a:**

   ```
   http://localhost:9000/dashboard/homelab
   ```

3. **Verificar:**
   - ✅ Sidebar muestra "HomeLab VR" con icono de gafas
   - ✅ Página carga correctamente
   - ✅ Header muestra "ThePearlOS" con diseño atractivo
   - ✅ 4 tarjetas de estadísticas visibles
   - ✅ Spinners mientras carga datos
   - ✅ Información de sesión se actualiza
   - ✅ Icono VR tiene animación de pulso
   - ✅ Botón "Entrar a HomeLab" con hover effect
   - ✅ Sección de ayuda visible
   - ✅ Link a GitHub funciona
   - ✅ Botón diagnóstico abre modal con checks
   - ✅ Responsive funciona en móvil

### Testing de Animaciones

```javascript
// En consola del navegador
console.log("Anime.js:", typeof anime !== "undefined" ? "✅" : "❌");
console.log("AOS:", typeof AOS !== "undefined" ? "✅" : "❌");
```

### Testing de Backend

```javascript
// Verificar que AppRouter funciona
window.AppRouter.get("/routes/user/check_session.php")
  .then((data) => console.log("✅ Sesión:", data))
  .catch((err) => console.error("❌ Error:", err));
```

---

## 📊 Estructura de Datos

### User Session Data

```javascript
{
    first_name: "Juan",
    last_name: "Pérez",
    username: "juanperez",
    email: "juan@example.com",
    role_id: 2
}
```

### System Stats Data

```javascript
{
    total_apps: 24,
    active_users: 12,
    system_status: "operational",
    uptime: "99.9%"
}
```

### Diagnostic Results

```javascript
{
    webxr_support: true,
    camera_access: true,
    webgl: true,
    localStorage: true,
    sessionStorage: true
}
```

---

## 🎯 Próximos Pasos (Backend)

### 1. **Endpoint de Apps**

```php
// /routes/homelab/get_apps.php
// Retornar apps desde thepearlo_vr-appstore
```

### 2. **Endpoint de Usuarios Activos**

```php
// /routes/homelab/get_active_users.php
// Contar sesiones activas con last_activity reciente
```

### 3. **Endpoint de System Status**

```php
// /routes/homelab/get_system_status.php
// Verificar servicios: BD, API, VR Server
```

### 4. **Endpoint de Diagnóstico**

```php
// /routes/homelab/run_diagnostic.php
// Verificar compatibilidad del cliente
// Retornar recomendaciones personalizadas
```

---

## 📚 Dependencias

### CSS

- Bootstrap 5 (framework principal)
- Boxicons (iconos)
- AOS (Animate On Scroll)
- Estilos custom inline

### JavaScript

- Axios (vía AppRouter)
- Anime.js (animaciones)
- SweetAlert2 (modales)
- AOS (scroll animations)

### Backend

- PHP 8.4
- API REST (thepearlo_vr-backend)
- MySQL/MariaDB

---

## 🎨 Customización

### Cambiar Colores de Gradientes

```css
/* En homelab.page.php, sección <style> */
.bg-gradient-1 {
  background: linear-gradient(135deg, #TU_COLOR_1 0%, #TU_COLOR_2 100%);
}
```

### Cambiar Icono Principal

```html
<!-- En homelab.page.php -->
<i class="bx bx-glasses"></i>
<!-- Cambiar por otro icono de Boxicons -->
```

### Agregar Nuevas Estadísticas

```html
<!-- Duplicar estructura de stat-card-os -->
<div class="col-12 col-sm-6 col-xl-3">
  <div class="stat-card-os h-100 p-4">
    <!-- Tu contenido -->
  </div>
</div>
```

---

## 🐛 Troubleshooting

### Problema: Animaciones no funcionan

**Solución:** Verificar que Anime.js esté cargado

```javascript
if (typeof anime === "undefined") {
  console.error("❌ Anime.js no está cargado");
}
```

### Problema: Datos no cargan

**Solución:** Verificar que backend esté corriendo y CORS configurado

```bash
# Verificar backend
curl -I http://localhost:3000/routes/user/check_session.php
```

### Problema: Sidebar no muestra HomeLab

**Solución:** Limpiar caché del navegador (Ctrl+Shift+R)

---

## 📞 Soporte

Para dudas o mejoras:

1. Consultar documentación en `/docs/`
2. Revisar código en `/pages/homelab.page.php`
3. Contactar al equipo de desarrollo

---

**Última actualización:** Noviembre 6, 2025  
**Versión:** 1.0.0-beta  
**Autor:** Roepard Labs Development Team  
**Estado:** ✅ Implementado y Listo para Testing
