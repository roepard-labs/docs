# 🔧 Fix: AppLayout Core Libraries y Console.log Visible

## 📋 Resumen de Cambios

**Fecha**: Noviembre 2025  
**Problema 1**: Texto de `console.log()` visible en todas las páginas  
**Problema 2**: SweetAlert2 no disponible en `/features`, botón de estado da error  
**Solución**: Agregar librerías esenciales al Core y remover console.log mal ubicado

---

## 🐛 Problema 1: Console.log Visible

### Síntoma

En todas las páginas aparece el siguiente texto visible:

```
console.log('🔐 Inicializando Auth Modal con jQuery...');
```

### Causa

**Archivo**: `/modals/auth.modal.php` línea 264

```php
</script>

<!-- Comentario -->
console.log('🔐 Inicializando Auth Modal con jQuery...');  ❌ FUERA del <script>

<style>
```

El `console.log` está **fuera de las etiquetas `<script>`**, por lo que el navegador lo muestra como texto HTML en lugar de ejecutarlo como JavaScript.

### Solución

Removido el `console.log` que estaba fuera del `<script>`:

```php
</script>

<!--
    NOTA: El script de autenticación se ha movido a /js/auth-modal.js
    Este archivo se carga en AppLayout.php después de jQuery para evitar errores de dependencias
-->

<style>
```

**Archivo modificado**: `/thepearlo_vr-website/modals/auth.modal.php`

---

## 🐛 Problema 2: SweetAlert2 No Disponible en /features

### Síntoma

Al hacer click en el botón de estado del backend en páginas como `/features`:

```javascript
Uncaught ReferenceError: Swal is not defined
    at HTMLDivElement.<anonymous> (footer.ui.php:237)
```

### Causa

**Código en footer.ui.php** (línea 237):

```javascript
backendStatus.addEventListener("click", function () {
  Swal.fire({
    // ❌ Swal no está cargado en /features
    title: "✅ Backend Conectado",
    // ...
  });
});
```

**AppLayout.php anterior**:

```php
// Solo home tenía SweetAlert2
private static $viewDependencies = [
    'home' => [
        'js' => ['sweetalert2']  // ✅ Solo en home
    ],
    'features' => [
        'js' => []  // ❌ Sin sweetalert2
    ]
];
```

El botón de estado del backend está en **footer.ui.php**, que se carga en **todas las páginas**, pero SweetAlert2 solo estaba disponible en `/home`.

### Solución

Mover **SweetAlert2, Notyf, Tippy** y otras librerías esenciales al **Core** para que estén disponibles en todas las páginas.

---

## ✅ Cambios Implementados

### 1. AppLayout.php - Core CSS

**Antes**:

```php
private static $cssCore = ['bootstrap', 'boxicons', 'aos', 'animate'];
```

**Después**:

```php
/**
 * CSS Core (siempre se cargan)
 * Incluye librerías esenciales usadas en todo el proyecto
 */
private static $cssCore = [
    'bootstrap',   // Framework CSS principal
    'boxicons',    // Iconos
    'aos',         // Animate on Scroll
    'animate',     // Animaciones CSS
    'sweetalert2', // Alertas bonitas ✅ NUEVO
    'notyf',       // Notificaciones toast ✅ NUEVO
    'tippy'        // Tooltips avanzados ✅ NUEVO
];
```

### 2. AppLayout.php - Core JS

**Antes**:

```php
private static $jsCore = ['axios', 'jquery', 'bootstrap', 'aos'];
```

**Después**:

```php
/**
 * JS Core (siempre se cargan)
 * Incluye librerías esenciales usadas en todo el proyecto
 */
private static $jsCore = [
    'axios',       // HTTP Client (para API) ✅ Ya existía
    'jquery',      // DOM manipulation (legacy) ✅ Ya existía
    'popper',      // Requerido por Bootstrap tooltips ✅ NUEVO
    'bootstrap',   // Framework JS principal ✅ Ya existía
    'aos',         // Animate on Scroll ✅ Ya existía
    'sweetalert2', // Alertas bonitas ✅ NUEVO
    'notyf',       // Notificaciones toast ✅ NUEVO
    'tippy'        // Tooltips avanzados ✅ NUEVO
];
```

### 3. AppLayout.php - Mapeo CSS

Agregado Tippy al mapeo:

```php
private static $cssMap = [
    // ... existentes
    'tippy' => '/node_modules/tippy.js/dist/tippy.css',  // ✅ NUEVO
];
```

### 4. AppLayout.php - Mapeo JS

Agregado Tippy al mapeo:

```php
private static $jsMap = [
    // ... existentes
    'tippy' => '/node_modules/tippy.js/dist/tippy-bundle.umd.min.js',  // ✅ NUEVO
];
```

### 5. AppLayout.php - Limpiar Dependencias de Vistas

**Antes**:

```php
private static $viewDependencies = [
    'home' => [
        'css' => ['glightbox', 'sweetalert2'],  // ❌ Duplicado
        'js' => ['glightbox', 'chart', 'anime', 'sweetalert2']  // ❌ Duplicado
    ],
    'auth' => [
        'css' => ['sweetalert2'],  // ❌ Duplicado
        'js' => ['sweetalert2']  // ❌ Duplicado
    ]
];
```

**Después**:

```php
/**
 * Mapeo de vistas a sus dependencias ADICIONALES
 * (las dependencias core ya están cargadas globalmente)
 */
private static $viewDependencies = [
    'home' => [
        'css' => ['glightbox'],
        'js' => ['glightbox', 'chart', 'anime']
    ],
    'homelab' => [
        'css' => [],
        'js' => [] // VR/AR dependencies loaded separately
    ],
    'dashboard' => [
        'css' => ['datatables', 'datatablesResponsive'],
        'js' => ['datatables', 'datatablesBS5', 'datatablesResponsive']
    ],
    'features' => [
        'css' => [],
        'js' => [] // ✅ Solo usa dependencias core
    ],
    'privacy' => [
        'css' => [],
        'js' => [] // ✅ Solo usa dependencias core
    ],
    'terms' => [
        'css' => [],
        'js' => [] // ✅ Solo usa dependencias core
    ]
];
```

### 6. auth.modal.php - Remover Console.log

Eliminado console.log que estaba fuera del `<script>` tag.

---

## 📊 Impacto de los Cambios

### Librerías Ahora Disponibles Globalmente

| Librería        | Antes         | Después              | Uso                                |
| --------------- | ------------- | -------------------- | ---------------------------------- |
| **SweetAlert2** | Solo en home  | ✅ Todas las páginas | Alertas bonitas, modales elegantes |
| **Notyf**       | Solo en home  | ✅ Todas las páginas | Notificaciones toast               |
| **Tippy.js**    | No disponible | ✅ Todas las páginas | Tooltips avanzados                 |
| **Popper.js**   | No cargado    | ✅ Todas las páginas | Base para tooltips de Bootstrap    |
| Axios           | ✅ Ya global  | ✅ Todas las páginas | HTTP Client                        |
| jQuery          | ✅ Ya global  | ✅ Todas las páginas | DOM manipulation                   |
| Bootstrap       | ✅ Ya global  | ✅ Todas las páginas | Framework CSS/JS                   |

### Componentes que Ahora Funcionan en Todas las Páginas

1. **Botón de Estado del Backend** (footer.ui.php):

   ```javascript
   // ✅ Ahora funciona en /features, /privacy, /terms
   Swal.fire({
     title: "✅ Backend Conectado",
     icon: "success",
     // ...
   });
   ```

2. **Notificaciones Toast**:

   ```javascript
   // ✅ Disponible en todas las páginas
   const notyf = new Notyf();
   notyf.success("¡Operación exitosa!");
   ```

3. **Tooltips Avanzados**:
   ```javascript
   // ✅ Disponible en todas las páginas
   tippy("[data-tippy-content]", {
     placement: "top",
     animation: "scale",
   });
   ```

---

## 🧪 Testing

### Test 1: Verificar Console.log No Visible

**Pasos**:

1. Abrir cualquier página: `/`, `/features`, `/privacy`
2. Verificar que NO aparece el texto: `console.log('🔐 Inicializando Auth Modal con jQuery...');`

**Resultado Esperado**: ✅ Texto no visible

### Test 2: Verificar SweetAlert2 en /features

**Pasos**:

1. Abrir `/features`
2. Scroll hasta el footer
3. Click en el botón de estado del backend (círculo con "Conectado"/"Desconectado")

**Resultado Esperado**:
✅ Modal de SweetAlert2 aparece con información del backend
✅ No hay error `Swal is not defined` en console

### Test 3: Verificar Librerías Cargadas

**Pasos**:

1. Abrir cualquier página
2. Abrir DevTools → Console
3. Ejecutar:
   ```javascript
   console.log("Swal:", typeof Swal);
   console.log("Notyf:", typeof Notyf);
   console.log("tippy:", typeof tippy);
   console.log("axios:", typeof axios);
   console.log("jQuery:", typeof $);
   console.log("Bootstrap:", typeof bootstrap);
   ```

**Resultado Esperado**:

```
Swal: function
Notyf: function
tippy: function
axios: function
jQuery: function
Bootstrap: object
```

### Test 4: Verificar Performance

**Pasos**:

1. Abrir DevTools → Network
2. Reload página
3. Verificar tiempo de carga

**Resultado Esperado**:

- ✅ Carga de librerías core: ~500-800ms (aceptable)
- ✅ Total time: < 2 segundos
- ✅ No hay errores 404

---

## 📦 Archivos Modificados

| Archivo                  | Cambios                                 | Líneas  |
| ------------------------ | --------------------------------------- | ------- |
| `/layout/AppLayout.php`  | Actualizado Core CSS/JS, agregado Tippy | 13-48   |
| `/layout/AppLayout.php`  | Actualizado mapeo CSS                   | 191-199 |
| `/layout/AppLayout.php`  | Actualizado mapeo JS                    | 204-217 |
| `/layout/AppLayout.php`  | Actualizado dependencias vistas         | 33-53   |
| `/modals/auth.modal.php` | Removido console.log visible            | 264     |

---

## 🎯 Beneficios

### Para Usuarios

- ✅ Botón de estado funciona en todas las páginas
- ✅ Alertas y notificaciones consistentes en todo el sitio
- ✅ No hay texto extraño visible

### Para Desarrolladores

- ✅ No necesitas agregar SweetAlert2/Notyf manualmente en cada vista
- ✅ Código más DRY (Don't Repeat Yourself)
- ✅ Menos errores de "librería no encontrada"
- ✅ Tooltips avanzados disponibles en todo el proyecto

### Para Performance

- ⚠️ Impacto: +150KB (~100KB gzipped) en carga inicial
- ✅ Pero eliminamos carga condicional y duplicados
- ✅ Browser cache ayuda en navegaciones subsecuentes
- ✅ Mejor que cargar/descargar librerías por página

---

## 💡 Buenas Prácticas Aplicadas

### 1. Core vs. View Dependencies

```php
// ✅ CORRECTO: Librerías usadas en múltiples vistas van al Core
private static $cssCore = ['bootstrap', 'sweetalert2', 'notyf'];

// ✅ CORRECTO: Librerías específicas van a viewDependencies
private static $viewDependencies = [
    'dashboard' => [
        'js' => ['datatables']  // Solo dashboard usa DataTables
    ]
];
```

### 2. Evitar Duplicados

```php
// ❌ INCORRECTO: Duplicar en Core y viewDependencies
private static $jsCore = ['sweetalert2'];
private static $viewDependencies = [
    'home' => ['js' => ['sweetalert2']]  // ❌ Ya está en Core
];

// ✅ CORRECTO: Solo en Core
private static $jsCore = ['sweetalert2'];
private static $viewDependencies = [
    'home' => ['js' => []]  // ✅ Usa Core
];
```

### 3. Documentar Propósito

```php
/**
 * CSS Core (siempre se cargan)
 * Incluye librerías esenciales usadas en todo el proyecto
 */
private static $cssCore = [
    'bootstrap',   // Framework CSS principal
    'sweetalert2', // Alertas bonitas - usado en footer y modales
];
```

---

## 🔮 Próximos Pasos

### Opcional: Lazy Loading para Librerías Grandes

Si en el futuro el bundle crece demasiado, considerar:

```javascript
// Cargar DataTables solo cuando se necesite
async function loadDataTables() {
  if (typeof $.fn.dataTable !== "undefined") return;

  await Promise.all([
    loadScript("/node_modules/datatables.net/js/dataTables.min.js"),
    loadCSS(
      "/node_modules/datatables.net-bs5/css/dataTables.bootstrap5.min.css"
    ),
  ]);
}

// Uso:
if (document.querySelector(".data-table")) {
  await loadDataTables();
  $(".data-table").DataTable();
}
```

### Monitoreo de Performance

Agregar métricas para detectar si el bundle crece mucho:

```javascript
// En main.js
window.addEventListener("load", () => {
  const perfData = performance.getEntriesByType("navigation")[0];
  console.log(
    "⏱️ Load time:",
    perfData.loadEventEnd - perfData.fetchStart,
    "ms"
  );

  // Si > 3000ms, considerar optimizaciones
});
```

---

## 📚 Referencias

- [SweetAlert2 Docs](https://sweetalert2.github.io/)
- [Notyf Docs](https://carlosroso.com/notyf/)
- [Tippy.js Docs](https://atomiks.github.io/tippyjs/)
- [Bootstrap Tooltips](https://getbootstrap.com/docs/5.3/components/tooltips/)
- [Web Performance Best Practices](https://web.dev/performance/)

---

**Documentado por**: Roepard Labs Development Team  
**Fecha**: Noviembre 2025  
**Versión**: 1.0  
**Estado**: ✅ Implementado y testeado
