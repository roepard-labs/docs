# 🗺️ Mapa Visual de la Arquitectura

> **Guía visual** para entender cómo fluye el código en HomeLab AR

---

## 🔄 Flujo de Carga de una Vista

```
1. Usuario accede → index.php
                     ↓
2. Router determina → ¿Qué vista cargar?
                     ↓
3. AppLayout.php → Prepara dependencias
     ├── CSS Core (Bootstrap, AOS, Animate)
     ├── CSS de Vista (si existe)
     ├── JS Core (Axios, jQuery, Bootstrap)
     └── JS de Vista (si existe)
                     ↓
4. Renderiza Estructura HTML
     ├── <head> con todos los <link> CSS
     ├── <body> con contenido
     │    ├── header.ui.php (si aplica)
     │    ├── vista.view.php
     │    │    ├── section1.section.php
     │    │    ├── section2.section.php
     │    │    └── section3.section.php
     │    └── footer.ui.php (si aplica)
     └── <scripts> al final
          ├── npm-loader.js (primero)
          ├── config.js
          ├── router.js
          ├── dependencias NPM
          ├── vista.js (si existe)
          └── main.js (último)
                     ↓
5. JavaScript se inicializa
     ├── AOS.init() para animaciones
     ├── Axios configurado para API
     └── Event listeners activos
```

---

## 📦 Flujo de Dependencias NPM

```
npm install paquete
      ↓
package.json actualizado
      ↓
node_modules/paquete instalado
      ↓
Actualizar composables/npm-loader.js
      ↓
      ├── Agregar a NPM_CONFIG.css (si es CSS)
      ├── Agregar a NPM_CONFIG.js (si es JS)
      └── Agregar a NPM_CONFIG.vr (si es VR/AR)
      ↓
Usar en AppLayout.php
      ↓
      ├── Agregar a viewDependencies para vista específica
      └── O agregar a cssCore/jsCore para global
      ↓
Acceder desde HTML/JS
      ↓
<link href="getCSSPath('paquete')">
<script src="getJSPath('paquete')"></script>
```

---

## 🎨 Flujo de Estilos CSS

```
HTML Element
      ↓
      ├──────────────┬──────────────┬────────────────┐
      ↓              ↓              ↓                ↓
variables.css   base.css      main.css      vista.css
(Variables)     (Reset)       (Utilidades)  (Específico)
      ↓              ↓              ↓                ↓
      └──────────────┴──────────────┴────────────────┘
                         ↓
              Estilos finales aplicados
```

### Jerarquía de Especificidad

```
1. variables.css  → Define variables (--color-primary, etc)
2. base.css       → Estilos base (*, html, body, h1-h6, etc)
3. main.css       → Clases utilitarias (.flex-center, .card-custom, etc)
4. vista.css      → Estilos específicos de la vista
5. Inline styles  → Solo en casos excepcionales
```

---

## 🏗️ Anatomía de una Vista

```
┌─────────────────────────────────────────────────┐
│ AppLayout.php                                   │
│ ┌─────────────────────────────────────────────┐ │
│ │ <!DOCTYPE html>                             │ │
│ │ <html>                                      │ │
│ │ <head>                                      │ │
│ │   <!-- CSS Base -->                         │ │
│ │   variables.css                             │ │
│ │   base.css                                  │ │
│ │   main.css                                  │ │
│ │                                             │ │
│ │   <!-- CSS Dependencies -->                 │ │
│ │   bootstrap.css                             │ │
│ │   aos.css                                   │ │
│ │   [dependencias específicas]                │ │
│ │ </head>                                     │ │
│ │ <body>                                      │ │
│ │   ┌───────────────────────────────────────┐ │ │
│ │   │ header.ui.php                         │ │ │
│ │   │ - Logo                                │ │ │
│ │   │ - Navegación                          │ │ │
│ │   │ - Auth buttons                        │ │ │
│ │   └───────────────────────────────────────┘ │ │
│ │                                             │ │
│ │   ┌───────────────────────────────────────┐ │ │
│ │   │ <main id="main-content">              │ │ │
│ │   │   vista.view.php                      │ │ │
│ │   │   ┌─────────────────────────────────┐ │ │ │
│ │   │   │ hero.section.php                │ │ │ │
│ │   │   │ - Título principal              │ │ │ │
│ │   │   │ - Descripción                   │ │ │ │
│ │   │   │ - CTA buttons                   │ │ │ │
│ │   │   └─────────────────────────────────┘ │ │ │
│ │   │   ┌─────────────────────────────────┐ │ │ │
│ │   │   │ features.section.php            │ │ │ │
│ │   │   │ - Cards con características     │ │ │ │
│ │   │   └─────────────────────────────────┘ │ │ │
│ │   │   ┌─────────────────────────────────┐ │ │ │
│ │   │   │ stats.section.php               │ │ │ │
│ │   │   │ - Estadísticas animadas         │ │ │ │
│ │   │   └─────────────────────────────────┘ │ │ │
│ │   │ </main>                               │ │ │
│ │   └───────────────────────────────────────┘ │ │
│ │                                             │ │
│ │   ┌───────────────────────────────────────┐ │ │
│ │   │ footer.ui.php                         │ │ │
│ │   │ - Links                               │ │ │
│ │   │ - Copyright                           │ │ │
│ │   │ - Social media                        │ │ │
│ │   └───────────────────────────────────────┘ │ │
│ │                                             │ │
│ │   <!-- JavaScript -->                       │ │
│ │   npm-loader.js                             │ │
│ │   config.js                                 │ │
│ │   router.js                                 │ │
│ │   [dependencias JS]                         │ │
│ │   vista.js                                  │ │
│ │   main.js                                   │ │
│ │ </body>                                     │ │
│ └─────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

---

## 🏪 Sistema AppStore - Flujo

```
1. Usuario navega a AppStore
           ↓
2. reader.php?action=list
           ↓
   Lee apps.json
           ↓
   Retorna lista de apps
           ↓
3. Frontend muestra catálogo
           ↓
4. Usuario hace click en app
           ↓
5. reader.php?action=get&id=app-id
           ↓
   Lee apps/app-id/manifest.json
           ↓
   Retorna manifest completo
           ↓
6. Abre viewer.php?app=app-id
           ↓
   Carga dependencias del manifest
           ↓
   Inyecta apps/app-id/index.html
           ↓
7. App ejecutándose en iframe/ventana
```

### Estructura de una App

```
appstore/apps/my-app/
├── manifest.json     ← Metadatos y configuración
│   {
│     "id": "my-app",
│     "name": "Mi App",
│     "entry": "index.html",
│     "dependencies": {
│       "npm": ["axios", "sweetalert2"],
│       "vr": ["aframe"]
│     }
│   }
│
├── index.html        ← Punto de entrada
│   <!DOCTYPE html>
│   <html>
│     <a-scene>
│       <!-- Contenido AR/VR -->
│     </a-scene>
│   </html>
│
├── preview.png       ← Imagen de preview (800x450px)
├── icon.svg          ← Icono de la app (256x256px)
└── README.md         ← Documentación (opcional)
```

---

## 🔐 Flujo de Autenticación

```
1. Usuario no autenticado
           ↓
2. Click en "Iniciar Sesión"
           ↓
3. Modal se abre (auth.modal.php)
           ↓
4. Usuario ingresa credenciales
           ↓
5. JavaScript captura submit
           ↓
6. Axios POST a /api/auth/login
           {
             "email": "user@example.com",
             "password": "********"
           }
           ↓
7. Backend valida y retorna JWT
           {
             "success": true,
             "token": "eyJhbGc...",
             "user": {...}
           }
           ↓
8. JavaScript guarda en localStorage
           localStorage.setItem('token', token)
           localStorage.setItem('user', JSON.stringify(user))
           ↓
9. Header se actualiza dinámicamente
           ↓
10. Axios agrega token a todas las peticiones
           axios.defaults.headers.common['Authorization'] = `Bearer ${token}`
```

---

## 🎯 Flujo de Petición API

```
Frontend                      Backend
   ↓                             ↓
1. axios.get('/api/users')
   ↓
2. Axios interceptor agrega token
   headers: {
     'Authorization': 'Bearer eyJhbGc...'
   }
   ↓
3. Request enviado →        → 4. Middleware CORS
                                   ↓
                              5. Middleware Auth
                                   ├─ Verifica token
                                   ├─ Valida usuario
                                   └─ Continúa o rechaza
                                   ↓
                              6. Router dirige a controller
                                   ↓
                              7. Controller procesa
                                   ↓
                              8. Model consulta DB
                                   ↓
                              9. Response JSON
                                   {
                                     "success": true,
                                     "data": [...]
                                   }
                                   ↓
10. Response recibido ←      ← 11. Headers CORS
    ↓
12. JavaScript procesa
    .then(response => {
      // Usar response.data
    })
    .catch(error => {
      // Manejar error
    })
```

---

## 📱 Responsive Flow

```
Device Detection (CSS)
       ↓
       ├─ Mobile (< 768px)
       │    ↓
       │    ├─ Stack vertical
       │    ├─ Full-width cards
       │    ├─ Hamburger menu
       │    └─ Touch interactions
       │
       ├─ Tablet (768px - 992px)
       │    ↓
       │    ├─ 2 columnas
       │    ├─ Sidebar colapsable
       │    └─ Hybrid touch/mouse
       │
       └─ Desktop (> 992px)
            ↓
            ├─ 3-4 columnas
            ├─ Sidebar fijo
            ├─ Hover effects
            └─ Mouse interactions
```

---

## 🎨 Animaciones con AOS

```
HTML Markup
    ↓
<div data-aos="fade-up"           ← Tipo de animación
     data-aos-duration="1000"      ← Duración (ms)
     data-aos-delay="200"          ← Delay (ms)
     data-aos-once="true">         ← Solo una vez
    ↓
AOS Library detecta
    ↓
Scroll Event Listener
    ↓
    ├─ Element en viewport?
    │       ↓ SI
    │       └─ Agrega clase 'aos-animate'
    │              ↓
    │              CSS Transition aplica
    │              ↓
    │              Animación visible
    │
    └─ Element fuera?
            ↓ NO
            └─ Espera...
```

---

## 🔍 Debugging Flow

```
Error en producción
       ↓
1. Abrir DevTools Console
       ↓
2. ¿Error de red?
       ├─ SI → Network Tab
       │        ├─ Ver request/response
       │        ├─ Verificar status code
       │        └─ Revisar headers
       │
       └─ NO → ¿Error de JavaScript?
                ├─ Ver stack trace
                ├─ Identificar archivo:línea
                └─ Revisar código fuente
       ↓
3. ¿Error de CSS?
       ├─ Inspect Element
       ├─ Ver computed styles
       └─ Verificar cascada
       ↓
4. ¿Error de dependencia?
       ├─ Verificar npm-loader.js
       ├─ console.log(window.NPM_CONFIG)
       └─ Revisar orden de carga
       ↓
5. Solucionar y documentar
```

---

## 📊 Performance Optimization Flow

```
Initial Load
    ↓
1. Critical CSS inline
    ├─ variables.css
    ├─ base.css
    └─ main.css
    ↓
2. Defer non-critical JS
    ├─ async para analytics
    └─ defer para UI libraries
    ↓
3. Lazy load images
    ├─ loading="lazy"
    └─ Intersection Observer
    ↓
4. Code splitting
    ├─ Solo JS de vista actual
    └─ Dynamic imports
    ↓
5. Cache estratégico
    ├─ Service Worker
    ├─ localStorage para config
    └─ CDN para assets
    ↓
Fast, Smooth Experience
```

---

## 🎯 Decision Tree: ¿Dónde pongo mi código?

```
¿Qué tipo de código es?
    ↓
    ├─ HTML Structure
    │    ↓
    │    ├─ ¿Es reutilizable?
    │    │    ├─ SI → sections/ o ui/
    │    │    └─ NO → views/
    │    │
    │    └─ ¿Es un modal?
    │         └─ modals/
    │
    ├─ CSS Styles
    │    ↓
    │    ├─ ¿Son variables?
    │    │    └─ css/variables.css
    │    │
    │    ├─ ¿Son estilos base?
    │    │    └─ css/base.css
    │    │
    │    ├─ ¿Son utilidades?
    │    │    └─ css/main.css
    │    │
    │    └─ ¿Son específicos de vista?
    │         └─ css/nombre-vista.css
    │
    ├─ JavaScript Logic
    │    ↓
    │    ├─ ¿Es configuración?
    │    │    └─ composables/
    │    │
    │    ├─ ¿Es específico de vista?
    │    │    └─ js/nombre-vista.js
    │    │
    │    └─ ¿Son utilidades?
    │         └─ js/utils.js
    │
    ├─ Dependencia Externa
    │    ↓
    │    ├─ npm install paquete
    │    └─ Actualizar npm-loader.js
    │
    └─ Aplicación VR/AR
         ↓
         └─ appstore/apps/mi-app/
```

---

## 🔗 Referencias Rápidas

- **Documentación Completa**: [ARQUITECTURA-FUNCIONAL.md](ARQUITECTURA-FUNCIONAL.md)
- **Guía Rápida**: [QUICK-START-ARQUITECTURA.md](QUICK-START-ARQUITECTURA.md)
- **NPM Loader**: `composables/npm-loader.js`
- **Instrucciones IA**: `.github/instructions/homelab.instructions.md`

---

**Proyecto**: HomeLab AR - Roepard Labs  
**Última actualización**: Noviembre 2025
