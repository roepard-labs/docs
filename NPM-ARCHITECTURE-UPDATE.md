# 📦 NPM Architecture Update - HomeLab VR

## 🎯 Resumen de Cambios

Se ha actualizado la arquitectura del proyecto para reflejar correctamente la separación entre frontend y backend, así como la gestión moderna de dependencias con NPM.

---

## 🏗️ Arquitectura Actualizada

### Frontend (thepearlo_vr-website)

- **Aplicación web** con PHP para renderizado de vistas
- **Gestión de dependencias** vía NPM
- **Sistema de carga dinámica** de módulos desde `node_modules/`
- **Comunicación con backend** vía API REST usando Axios

### Backend (thepearlo_vr-backend) - Repositorio Separado

- **API REST independiente** en PHP 8.4
- **Accesible en:**
  - Desarrollo: `localhost:3000`
  - Producción: `api.roepard.online`
- **Arquitectura MVC** estricta
- **Base de datos** MySQL 10.6

---

## 📦 Sistema de Gestión de Dependencias

### Antes (Obsoleto)

```
/dist/                    # Librerías descargadas manualmente
├── bootstrap/
├── jquery/
├── aframe/
└── ...
```

### Ahora (NPM)

```
/node_modules/            # Dependencias instaladas con npm
├── bootstrap/
├── axios/
├── aframe/
└── ...

/composables/
├── npm-loader.js         # Generador dinámico de rutas
├── config.js             # Config auto-generada desde .env
└── router.js             # Cliente HTTP con Axios
```

### Comandos NPM

```bash
# Instalar dependencias
npm install

# Generar configuración desde .env
npm run build:config

# Build completo (install + config)
npm run build

# Desarrollo rápido
npm run dev
```

---

## 🔧 Router.js Mejorado

### Cambios Principales

1. **Axios como HTTP Client principal** (reemplaza Fetch API)
2. **jQuery como dependencia legacy** (solo para DataTables/Bootstrap)
3. **Métodos HTTP completos**: GET, POST, PUT, PATCH, DELETE
4. **Upload de archivos** con progress tracking
5. **Peticiones paralelas** con `AppRouter.all()`
6. **Interceptores** para logging y manejo de errores
7. **Manejo centralizado de errores** con códigos HTTP

### Uso del Nuevo Router

```javascript
// ✅ RECOMENDADO: Axios con async/await
const data = await AppRouter.get("/routes/user/check_session.php");

const login = await AppRouter.post("/routes/user/auth_user.php", {
  username: "user@example.com",
  password: "password123",
});

// ⚠️ LEGACY: jQuery AJAX (solo para código antiguo)
$.ajax({
  url: window.AppRouter.buildURL("/routes/user/auth_user.php"),
  method: "POST",
  data: credentials,
});
```

---

## 🎨 CSS Reutilizable

### Arquitectura de 3 Archivos

```
/css/
├── variables.css   # Variables CSS globales (colores, espaciado, fuentes)
├── base.css        # Reset CSS y estilos base del proyecto
└── main.css        # Estilos principales y utilidades
```

**Características:**

- ✅ 100% compatible con Bootstrap 5
- ✅ Variables CSS personalizables (`--primary-color`, etc.)
- ✅ Reutilizables en cualquier vista HTML/PHP
- ✅ Sistema de temas dark/light

---

## 📂 Estructura de Carpetas Actualizada

```
/thepearlo_vr-website/            # Frontend
├── composables/                  # 🔧 Configuración y utilidades
│   ├── config.js                 # Config generada desde .env (API URLs)
│   ├── npm-loader.js             # Cargador dinámico de NPM modules
│   ├── router.js                 # Cliente HTTP con Axios ✨
│   └── color-mode-toggler.js     # Toggle dark/light theme
├── css/                          # 🎨 Estilos (solo 3 archivos)
│   ├── variables.css
│   ├── base.css
│   └── main.css
├── layout/                       # ⭐ Sistema de Layouts
│   └── AppLayout.php             # Layout base
├── layouts/                      # Layouts especializados
│   ├── AdminLayout.php           # Para administradores
│   └── UserLayout.php            # Para usuarios autenticados
├── ui/                           # 🧩 Componentes UI reutilizables
│   ├── header.ui.php
│   ├── footer.ui.php
│   ├── navbar.ui.php
│   └── sidebar.ui.php
├── modals/                       # Modales reutilizables
│   ├── authModal.php
│   └── confirmModal.php
├── sections/                     # 📄 Secciones reutilizables
│   └── about.section.php
├── views/                        # 📄 Plantillas PHP/HTML
├── node_modules/                 # Dependencias NPM (generado)
├── package.json                  # Gestión de dependencias
└── .env                          # Variables de entorno

/thepearlo_vr-backend/            # Backend API (separado)
├── controllers/                  # Controladores MVC
├── models/                       # Modelos de datos
├── services/                     # Servicios de negocio
├── routes/                       # Rutas API
│   ├── user/                     # Rutas de usuario
│   │   ├── auth_user.php
│   │   ├── check_session.php
│   │   └── logout_user.php
│   └── admin/                    # Rutas de admin
│       ├── list_users.php
│       └── update_user.php
└── config/                       # Configuración de BD
```

---

## 📚 Dependencias Agregadas/Actualizadas

### Nuevas Dependencias

```json
{
  "axios": "^1.7.9" // ✨ HTTP Client principal
}
```

### Dependencias Existentes (Confirmadas)

```json
{
  "bootstrap": "^5.3.8",
  "jquery": "^3.7.1", // Legacy (DataTables/Bootstrap)
  "aframe": "^1.7.1", // VR/AR Framework
  "three": "^0.181.0", // 3D Graphics
  "sweetalert2": "^11.26.3", // Alertas
  "notyf": "^3.10.0", // Notificaciones
  "chart.js": "^4.5.1", // Gráficos
  "datatables.net": "^2.3.4" // Tablas
}
```

---

## 🔄 Flujo de Comunicación Frontend-Backend

```
┌─────────────────────────────────┐
│  Frontend (localhost:9000)      │
│  thepearlo_vr-website           │
│                                 │
│  ┌─────────────────────────┐   │
│  │ AppRouter (Axios)       │   │
│  │ - GET, POST, PUT, etc   │   │
│  │ - Upload files          │   │
│  │ - Error handling        │   │
│  └──────────┬──────────────┘   │
└─────────────┼──────────────────┘
              │
              │ HTTP Requests
              │ (Axios)
              ↓
┌─────────────────────────────────┐
│  Backend API (localhost:3000)   │
│  thepearlo_vr-backend           │
│                                 │
│  ┌─────────────────────────┐   │
│  │ Routes (PHP)            │   │
│  │ /routes/user/           │   │
│  │ /routes/admin/          │   │
│  └──────────┬──────────────┘   │
│             ↓                   │
│  ┌─────────────────────────┐   │
│  │ Controllers & Services  │   │
│  └──────────┬──────────────┘   │
│             ↓                   │
│  ┌─────────────────────────┐   │
│  │ Models & Database       │   │
│  └─────────────────────────┘   │
└─────────────────────────────────┘
```

---

## ✅ Checklist de Actualización

- [x] Separar claramente frontend y backend en las instrucciones
- [x] Actualizar descripción de arquitectura
- [x] Agregar Axios como dependencia principal
- [x] Reescribir router.js con Axios completo
- [x] Marcar jQuery como legacy
- [x] Documentar sistema de carga NPM
- [x] Actualizar estructura de carpetas
- [x] Documentar 3 archivos CSS reutilizables
- [x] Agregar ejemplos de uso del nuevo router
- [x] Actualizar README.md con nueva arquitectura
- [x] Incluir guía de Quick Start

---

## 📖 Próximos Pasos

1. **Migrar código legacy** de jQuery AJAX a Axios
2. **Documentar componentes UI** en `/ui` y `/sections`
3. **Crear guía de layouts** (AppLayout, AdminLayout, UserLayout)
4. **Optimizar carga de dependencias NPM** (lazy loading)
5. **Testing** de peticiones HTTP con Axios

---

## 📚 Documentación Relacionada

- **README.md** - Documentación principal actualizada
- **homelab.instructions.md** - Instrucciones completas para IA
- **LAYOUTS-ARQUITECTURA.md** - Sistema de layouts
- **api.md** - Documentación de API del backend

---

**Fecha de actualización:** 3 de noviembre de 2025  
**Versión:** 2.0.0  
**Autor:** Roepard Labs Development Team
