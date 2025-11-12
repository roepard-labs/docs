# 🚀 Release v0.0.0 - Primera Versión

**Fecha de Release**: Noviembre 6, 2025  
**Proyecto**: HomeLab AR - Realidad Aumentada para Homelabs  
**Repositorio**: roepard-labs/thepearlo_vr-website  
**Estado**: ✅ Primera Versión Completa

---

## 📸 Captura del Proyecto

![HomeLab AR v0.0.0](https://github.com/user-attachments/assets/8788fc83-c581-4311-a440-1a9f9a779b94)

_Vista principal de la aplicación HomeLab AR en su primera versión_

---

## 📋 Resumen Ejecutivo

Esta es la **primera versión oficial** de HomeLab AR, una aplicación de realidad aumentada inmersiva que permite a usuarios desplegar y gestionar servicios virtuales de homelab en entornos del mundo real.

### 🎯 Objetivos Alcanzados

- ✅ **Arquitectura Frontend/Backend Separada**: Dos servidores PHP independientes
- ✅ **Sistema de Routing con URLs Limpias**: Sin extensiones .php, SEO-friendly
- ✅ **Sistema de Autenticación Completo**: Login, registro, gestión de sesiones
- ✅ **Dashboard Administrativo**: Panel de control con gestión de usuarios
- ✅ **Experiencia VR/AR**: Integración con A-Frame, AR.js, WebXR
- ✅ **Sistema de Layouts Jerárquico**: AppLayout, AdminLayout, UserLayout
- ✅ **Gestión de Dependencias NPM**: Carga dinámica optimizada

---

## 🏗️ Arquitectura del Sistema

### Frontend (thepearlo_vr-website)

**Ubicación**: `/thepearlo_vr-website/`

**Stack Tecnológico**:

- HTML5, CSS3, JavaScript ES6+ (Modules)
- Bootstrap 5.3+ (Framework CSS principal)
- Axios (HTTP Client principal)
- jQuery 3.7+ (Legacy - solo para DataTables/Bootstrap)
- A-Frame 1.7.1 para VR/AR
- WebXR para experiencias inmersivas
- Three.js 0.181 para 3D avanzado

**Características Principales**:

- Sistema de routing con URLs limpias
- Layout system jerárquico (AppLayout base)
- Componentes UI reutilizables
- Gestión de dependencias vía NPM
- Sistema de carga dinámica de módulos

**Estructura de Carpetas**:

```
/thepearlo_vr-website/
├── assets/           # Recursos multimedia (modelos 3D, sonidos, etc)
├── composables/      # Configuración y utilidades (config.js, router.js)
├── css/              # Estilos CSS modulares (3 archivos base)
├── js/               # JavaScript específico del proyecto
├── layout/           # Sistema de Layouts (AppLayout.php)
├── layouts/          # Layouts especializados (AdminLayout, UserLayout)
├── ui/               # Componentes UI reutilizables
├── modals/           # Modales reutilizables
├── sections/         # Secciones reutilizables
├── views/            # Vistas del sistema de routing
├── pages/            # Páginas dinámicas del dashboard
├── dist/             # Dependencias NPM (node_modules)
├── index.php         # Router principal (punto de entrada)
├── router.php        # Router para servidor PHP built-in
├── 30x.php, 40x.php, 50x.php  # Páginas de error personalizadas
└── nginx.conf        # Configuración Nginx
```

### Backend (thepearlo_vr-backend)

**Ubicación**: `/thepearlo_vr-backend/`

**Stack Tecnológico**:

- PHP 8.4
- MySQL/MariaDB
- Arquitectura MVC estricta
- API REST

**Puertos**:

- **Desarrollo**: `localhost:3000`
- **Producción**: `api.roepard.online`

**Características Principales**:

- Autenticación JWT/Sesiones PHP
- CRUD completo de usuarios
- Sistema de roles (user, admin, supervisor)
- Gestión de sesiones en base de datos
- Middleware de seguridad

**Estructura MVC**:

```
/thepearlo_vr-backend/
├── config/           # Configuración de BD y entorno
├── controllers/      # Controladores (AuthController, etc.)
├── core/             # Core del sistema (db.php, session.php)
├── middleware/       # Middleware de autenticación
├── models/           # Modelos de datos (UserAuth, etc.)
├── routes/           # Rutas API (auth_user.php, etc.)
└── services/         # Servicios de negocio (AuthService, etc.)
```

---

## 🎨 Sistema de Diseño

### CSS Modular (3 Archivos Base)

```
/css/
├── variables.css   # Variables CSS globales (colores, espaciados, breakpoints)
├── base.css        # Reset y estilos base del proyecto
└── main.css        # Estilos principales y utilidades
```

**Características**:

- ✅ 100% compatible con Bootstrap 5
- ✅ Variables CSS personalizables
- ✅ Sistema de temas (dark/light)
- ✅ Reutilizables en cualquier vista HTML/PHP

### Paleta de Colores

```css
:root {
  /* Colores primarios */
  --hm-color-primary: #00ff88;
  --hm-color-secondary: #008866;
  --hm-color-accent: #ffaa00;

  /* Estados */
  --hm-color-success: #00ff88;
  --hm-color-danger: #ff4444;
  --hm-color-warning: #ffaa00;
  --hm-color-info: #0088ff;

  /* Backgrounds VR */
  --vr-background-dark: #1a1a1a;
  --vr-surface-color: #2d2d2d;
  --vr-glow-effect: rgba(0, 255, 136, 0.3);
}
```

---

## 🔐 Sistema de Autenticación

### Flujo de Autenticación

```
Usuario → Modal de Login (home.view.php)
    ↓
Envía credenciales → Backend API (/routes/user/auth_user.php)
    ↓
Backend valida → Crea sesión en BD + PHP Session
    ↓
Respuesta exitosa → Frontend actualiza header dinámico
    ↓
Header muestra dropdown de usuario con opciones:
    - Dashboard (/admin o /user según role_id)
    - HomeLab VR
    - Cerrar Sesión
```

### Sistema de Roles

| Role ID | Role Name  | Descripción    | Dashboard |
| ------- | ---------- | -------------- | --------- |
| 1       | user       | Usuario básico | ❌ No     |
| 2       | admin      | Administrador  | ✅ Sí     |
| 3       | supervisor | Supervisor     | ❌ No     |

### Rutas de Autenticación

- `check_session.php` - Verificación de sesión activa
- `check_role.php` - Verificación de rol y permisos
- `logout_user.php` - Cierre de sesión seguro
- `list_sessions.php` - Listar sesiones activas
- `close_remote_session.php` - Cerrar sesión remota
- `session_history.php` - Historial de sesiones

---

## 🛣️ Sistema de Routing

### URLs Limpias Implementadas

| URL         | Vista                      | Descripción                |
| ----------- | -------------------------- | -------------------------- |
| `/`         | `home.view.php`            | Página principal           |
| `/home`     | `home.view.php`            | Alias de home              |
| `/features` | `features.view.php`        | Características detalladas |
| `/privacy`  | `privacy.view.php`         | Política de privacidad     |
| `/terms`    | `terms.view.php`           | Términos y condiciones     |
| `/admin`    | `admin.dashboard.view.php` | Dashboard administrador    |
| `/user`     | `user.dashboard.view.php`  | Dashboard usuario          |

### Arquitectura de Routing

```
Usuario → /features
    ↓
Nginx → try_files (no existe archivo)
    ↓
index.php (Router Principal)
    ↓
Busca en array $routes['/features']
    ↓
Carga /views/features.view.php
    ↓
Vista llama AppLayout::render()
    ↓
Respuesta HTML completa
```

**Beneficios**:

- ✅ URLs amigables sin .php
- ✅ SEO optimizado
- ✅ Trailing slashes eliminados automáticamente
- ✅ Preservación de query strings
- ✅ Páginas de error personalizadas (30x, 40x, 50x)

---

## 🧩 Sistema de Componentes

### Componentes UI Reutilizables (`/ui/`)

- **header.ui.php**: Header dinámico con autenticación
- **footer.ui.php**: Footer con enlaces del sitio
- **navbar.ui.php**: Navegación principal
- **sidebar.ui.php**: Sidebar para dashboard admin

### Modales (`/modals/`)

- **authModal.php**: Modal de autenticación (login/registro)
- **confirmModal.php**: Modal de confirmación genérico

### Secciones Reutilizables (`/sections/`)

- **hero.section.php**: Hero section para home
- **features.section.php**: Features section
- **stats.section.php**: Estadísticas
- **about.section.php**: Sobre nosotros
- **contact.section.php**: Contacto

---

## 📦 Gestión de Dependencias NPM

### Librerías Principales

**Core:**

- jQuery 3.7.1
- Bootstrap 5.3+
- Popper.js
- Axios (HTTP Client)

**VR/AR:**

- A-Frame 1.7.1
- AR.js 3.4.7
- Three.js 0.181
- WebXR Polyfill

**UI/UX:**

- SweetAlert2 (alertas)
- Notyf (notificaciones toast)
- DataTables (tablas interactivas)
- Chart.js (gráficos)
- AOS (Animate On Scroll)
- Animate.css

**Formularios:**

- TomSelect (selects avanzados)
- Flatpickr (date picker)
- FilePond (file upload)

### Sistema de Carga Dinámica

```javascript
// composables/npm-loader.js
// Genera rutas dinámicas a node_modules/

// composables/config.js (generado automáticamente)
window.APP_CONFIG = {
  API_URL: "http://localhost:3000", // o api.roepard.online
  BACKEND_URL: "http://localhost:3000",
};

// composables/router.js
// Cliente HTTP con Axios para comunicación con backend
window.AppRouter.get("/endpoint");
window.AppRouter.post("/endpoint", data);
```

---

## 🥽 Experiencia VR/AR

### Componentes A-Frame Personalizados

- **gaze-activator**: Activación por mirada
- **floating-menu**: Menús flotantes 3D
- **surface-detector**: Detección de superficies
- **item-deployer**: Despliegue de elementos virtuales

### Configuración VR

```html
<a-scene
  vr-mode-ui="enabled: true"
  embedded
  stats="false"
  inspector="url: https://cdn.aframe.io/releases/1.7.1/aframe-inspector.min.js"
>
  <!-- Componentes VR -->
  <a-entity gaze-activator surface-detector item-deployer></a-entity>
</a-scene>
```

---

## 🔧 Configuración de Entorno

### Variables de Entorno (.env)

**Frontend:**

```env
API_URL=http://localhost:3000
BACKEND_URL=http://localhost:3000
```

**Backend:**

```env
DB_CONNECTION=mysql
DB_HOST=localhost
DB_DATABASE=homelab_db
DB_USERNAME=username
DB_PASSWORD=password
DB_PORT=3306
DB_CHARSET=utf8mb4

CORS_ALLOWED_ORIGINS=http://localhost:9000
SESSION_COOKIE_DOMAIN=localhost
```

### Puertos de Desarrollo

- **Frontend**: `http://localhost:9000`
- **Backend**: `http://localhost:3000`

---

## 📊 Métricas del Proyecto

### Líneas de Código (Estimado)

| Componente    | Archivos | LOC (aprox) |
| ------------- | -------- | ----------- |
| Frontend PHP  | 50+      | 5,000+      |
| Frontend JS   | 30+      | 3,000+      |
| Frontend CSS  | 15+      | 2,000+      |
| Backend PHP   | 40+      | 4,000+      |
| Documentación | 80+      | 15,000+     |
| **TOTAL**     | **215+** | **29,000+** |

### Dependencias

- **NPM Packages**: 50+ librerías
- **PHP Composer**: Arquitectura custom sin Composer
- **Assets**: Modelos 3D, sonidos, iconos, fuentes

---

## 🧪 Testing

### Testing Manual Implementado

**Rutas del Frontend:**

```bash
# Servidor de desarrollo
php -S localhost:9000 router.php

# Probar rutas
curl -I http://localhost:9000/
curl -I http://localhost:9000/features
curl -I http://localhost:9000/privacy
curl -I http://localhost:9000/404-test  # Debe mostrar 40x.php
```

**API del Backend:**

```bash
# Check session
curl http://localhost:3000/routes/user/check_session.php

# Login
curl -X POST http://localhost:3000/routes/user/auth_user.php \
  -d "username=admin@example.com&password=password"
```

---

## 📚 Documentación Generada

Se creó documentación técnica completa en `/docs/`:

### Arquitectura

- `ARQUITECTURA-FUNCIONAL.md` - Arquitectura completa del proyecto
- `QUICK-START-ARQUITECTURA.md` - Guía rápida de 5 minutos
- `MAPA-VISUAL-ARQUITECTURA.md` - Diagramas de flujo
- `ROUTING-SYSTEM.md` - Sistema de routing con URLs limpias
- `ERROR-PAGES.md` - Sistema de páginas de error

### Fixes y Soluciones

- `FIX-DATATABLES-USERS-PAGE.md` - Fix de carga de DataTables
- `FIX-SESSION-RELOAD.md` - Fix de sesiones entre frontend/backend
- `FIX-LOGOUT-SESSION-DB-SYNC.md` - Sincronización logout con BD
- `FIX-HEADER-LOGIN.md` - Header dinámico con auth

### Guías de Desarrollo

- `desarrollo.md` - Guía técnica de desarrollo
- `api.md` - Documentación completa de APIs
- `componentes.md` - Documentación de componentes VR/AR
- `guia-estilos.md` - Guía de diseño visual

---

## 🚀 Despliegue

### Entornos

**Desarrollo:**

- Frontend: `http://localhost:9000`
- Backend: `http://localhost:3000`

**Producción (Previsto):**

- Frontend: `https://website.roepard.online`
- Backend: `https://api.roepard.online`

### Requisitos del Servidor

**Software:**

- Ubuntu 22.04 LTS
- Nginx 1.18+
- PHP 8.4 con extensiones: mysql, curl, gd, mbstring, xml, zip
- MariaDB 10.6+
- Node.js 18+ (para build de NPM)
- Certbot (SSL/HTTPS - requerido para WebXR)

**Hardware Mínimo:**

- 2 vCPUs
- 4GB RAM
- 20GB SSD

---

## 🔒 Seguridad Implementada

### Medidas de Seguridad

- ✅ Validación y sanitización de entrada
- ✅ Prepared statements para SQL
- ✅ CSRF protection en formularios
- ✅ Rate limiting en APIs (previsto)
- ✅ Headers de seguridad HTTP
- ✅ Sesiones seguras con httpOnly
- ✅ HTTPS obligatorio para WebXR
- ✅ CORS configurado correctamente
- ✅ Middleware de autenticación y roles

---

## 🎯 Casos de Uso Principales

1. **Autenticación de Usuario**: Login/registro con email, validación de formularios
2. **Navegación en Entorno VR**: Despliegue de elementos virtuales con A-Frame
3. **Detección de Superficies AR**: Detección automática de superficies con WebXR
4. **Gestión de Sesión**: Sesiones en BD, cierre remoto, historial
5. **Administración de Usuarios**: Dashboard admin con CRUD completo
6. **Experiencia Inmersiva**: Integración VR/AR con componentes personalizados

---

## 🐛 Issues Conocidos

### Resueltos en v0.0.0

- ✅ DataTables no cargaba en páginas dinámicas del dashboard
- ✅ Sesiones no sincronizaban entre frontend/backend separados
- ✅ Bucles infinitos en sistema de routing
- ✅ Chart.js CSS 404 error
- ✅ Header no actualizaba después de login

### Por Resolver (Backlog)

- ⚠️ Optimización de carga de modelos 3D pesados
- ⚠️ Implementación de cache de rutas
- ⚠️ Sistema de middleware completo
- ⚠️ Tests automatizados (PHPUnit, Jest)

---

## 🗓️ Próximas Funcionalidades (Roadmap)

### v0.1.0 (Próximo)

- Sistema de gestión de archivos (Files Manager)
- Dashboard de estadísticas con Chart.js
- Perfil de usuario editable
- Sistema de notificaciones en tiempo real

### v0.2.0

- WebSocket para comunicación en tiempo real
- Experiencia multiplayer VR
- Sistema de permisos granulares
- API pública documentada con Swagger

### v1.0.0 (Producción)

- Aplicación AppStore completa
- Deploy automatizado con CI/CD
- Monitoreo y logging avanzado
- Tests de cobertura >80%

---

## 📝 Changelog Completo

**Full Changelog**: https://github.com/roepard-labs/thepearlo_vr-website/commits/v0.0.0

### Commits Principales

```
- Initial commit: Estructura base del proyecto
- Implementación sistema de routing con URLs limpias
- Sistema de layouts jerárquico (AppLayout, AdminLayout, UserLayout)
- Autenticación completa con JWT y sesiones PHP
- Dashboard administrativo con DataTables
- Integración VR/AR con A-Frame y WebXR
- Sistema de componentes reutilizables
- Gestión de dependencias NPM
- Documentación técnica completa
- Páginas de error personalizadas (30x, 40x, 50x)
- Fix: DataTables loading en páginas dinámicas
- Fix: Sesiones frontend/backend sincronizadas
- Fix: Bucles infinitos en routing
- Fix: Header dinámico con autenticación
```

---

## 👥 Equipo de Desarrollo

**Roepard Labs Development Team**

- Arquitectura del sistema
- Desarrollo frontend y backend
- Diseño UI/UX
- Experiencia VR/AR
- Documentación técnica

---

## 📞 Contacto y Soporte

**Repositorio**: https://github.com/roepard-labs/thepearlo_vr-website

**Issues**: https://github.com/roepard-labs/thepearlo_vr-website/issues

**Wiki**: https://github.com/roepard-labs/thepearlo_vr-website/wiki

---

## 📄 Licencia

Este proyecto es parte de un proyecto piloto para la UAM (Universidad Autónoma Metropolitana).

Todos los derechos reservados - Roepard Labs © 2025

---

## 🙏 Agradecimientos

- **A-Frame Community** - Framework VR/AR
- **Bootstrap Team** - Framework CSS
- **jQuery Foundation** - Librería JavaScript legacy
- **UAM** - Apoyo al proyecto piloto

---

**Versión**: v0.0.0  
**Fecha de Release**: Noviembre 6, 2025  
**Estado**: ✅ Primera Versión Completa  
**Próximo Release**: v0.1.0 (previsto para Diciembre 2025)

---

_Este documento es un registro temporal de la primera versión oficial de HomeLab AR._
