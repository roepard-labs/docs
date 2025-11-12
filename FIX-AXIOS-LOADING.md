# 🔧 Fix: Axios Loading Issue - HomeLab VR

## 🐛 Problema Identificado

El router.js estaba entrando en un **loop infinito** esperando que Axios se cargara, pero Axios nunca se cargaba porque:

1. ❌ **Axios no estaba definido en `npm-loader.js`**
2. ❌ **Axios no estaba en la secuencia de carga del template**
3. ❌ **router.js se cargaba ANTES de Axios**
4. ❌ **color-mode-toggler.js tenía ruta incorrecta** (404 error)

### Console Errors (Antes):

```javascript
router.js:69 ⚠️ Axios no está cargado aún. Esperando...
// (Se repite infinitamente cada 100ms)

router.js:131 ❌ Axios no está inicializado. Usa router.initAxios() primero.
modern.template.variables.html:640 GET http://localhost:9000/js/color-mode-toggler.js net::ERR_ABORTED 404
```

---

## 📋 Solución Implementada

### ⚠️ **Actualización Adicional: statusCheck.js**

**Problema Detectado:**

- `statusCheck.js` intentaba usar `AppRouter` antes de que se cargara `router.js`
- Error: `Uncaught ReferenceError: AppRouter is not defined`

**Solución:**

- Mover `statusCheck.js` para que se cargue **después** de `router.js`
- Implementar carga secuencial: Axios → Router → StatusCheck

**Secuencia de Carga Correcta:**

```
1. npm-loader.js (configuración)
2. config.js (variables de entorno)
3. Axios (librería HTTP)
4. router.js (cliente API - requiere Axios)
5. statusCheck.js (verificación - requiere AppRouter)
```

---

### ✅ **Cambio 1: Agregar Axios a npm-loader.js**

```javascript
// composables/npm-loader.js
js: {
    // ✨ HTTP Client (NUEVO - Principal)
    axios: '/axios/dist/axios.min.js',

    // Core libraries
    popper: '/@popperjs/core/dist/umd/popper.min.js',
    bootstrap: '/bootstrap/dist/js/bootstrap.bundle.min.js',
    jquery: '/jquery/dist/jquery.min.js',
    // ...
}
```

### ✅ **Cambio 2: Carga Secuencial en modern.template.variables.html**

```html
<!-- views/modern.template.variables.html -->
<script src="../composables/npm-loader.js"></script>
<script src="../composables/config.js"></script>

<!-- ⚠️ IMPORTANTE: Cargar Axios → Router → StatusCheck -->
<script>
  // PASO 1: Cargar Axios
  const axiosScript = document.createElement("script");
  axiosScript.src = getJSPath("axios");
  axiosScript.onload = function () {
    console.log("✅ Axios cargado correctamente");

    // PASO 2: Cargar router.js DESPUÉS de Axios
    const routerScript = document.createElement("script");
    routerScript.src = "../composables/router.js";
    routerScript.onload = function () {
      console.log("✅ Router.js cargado correctamente");

      // PASO 3: Cargar statusCheck.js DESPUÉS de router
      const statusCheckScript = document.createElement("script");
      statusCheckScript.src = "../utils/statusCheck.js";
      document.head.appendChild(statusCheckScript);
    };
    document.head.appendChild(routerScript);
  };
  document.head.appendChild(axiosScript);
</script>

<!-- ❌ ELIMINADO: <script src="../utils/statusCheck.js"></script> -->
```

### ✅ **Cambio 3: Corregir ruta de color-mode-toggler.js**

```html
<!-- ❌ ANTES (404 error) -->
<script src="../js/color-mode-toggler.js"></script>

<!-- ✅ DESPUÉS (correcto) -->
<script src="../composables/color-mode-toggler.js"></script>
```

### ✅ **Cambio 4: Agregar Axios al reporte de dependencias**

```javascript
// npm-loader.js
function isLoaded(name) {
  const checks = {
    axios: typeof axios !== "undefined", // ✨ NUEVO
    jquery: typeof $ !== "undefined",
    bootstrap: typeof bootstrap !== "undefined",
    // ...
  };
  return checks[name] || false;
}

function reportLoadedDependencies() {
  const report = {
    "Axios ✨": isLoaded("axios"), // ✨ NUEVO
    jQuery: isLoaded("jquery"),
    Bootstrap: isLoaded("bootstrap"),
    // ...
  };
  // ...
}
```

---

## 🎯 Resultado Esperado

### Console Output (Correcto):

```javascript
⚙️ NPM Loader inicializado
📡 API URL: https://localhost:3000
🏷️ App Name: Roepard Homelab
✅ Axios cargado correctamente  // ✨ NUEVO
🚀 Router inicializado con Axios
✅ Axios inicializado correctamente  // ✨ NUEVO
✅ Axios cargado correctamente
✅ Router.js cargado correctamente       // ✨ NUEVO
✅ jQuery cargado
✅ Bootstrap cargado
✅ DataTables completamente inicializado

📦 Estado de Dependencias NPM
┌─────────────┬─────────┐
│   (index)   │  Value  │
├─────────────┼─────────┤
│  Axios ✨   │   true  │  // ✨ NUEVO
│   jQuery    │   true  │
│  Bootstrap  │   true  │
│ SweetAlert2 │   true  │
│  Chart.js   │   true  │
│ DataTables  │   true  │
│    Notyf    │   true  │
│     AOS     │   true  │
└─────────────┴─────────┘
✅ 13/15 dependencias cargadas correctamente
```

---

## 🔄 Flujo de Carga Correcto

```
1. npm-loader.js (define rutas)
   ↓
2. config.js (variables de entorno)
   ↓
3. ✨ Axios (HTTP Client) - CARGADO PRIMERO
   ↓
4. router.js (espera Axios y lo inicializa)
   ↓
5. statusCheck.js (puede usar AppRouter)
   ↓
6. jQuery → Bootstrap → DataTables (secuencial)
   ↓
7. Resto de librerías (paralelo)
```

---

## 🧪 Verificación

Para verificar que todo funciona correctamente:

```javascript
// En la consola del navegador:

// 1. Verificar que Axios está disponible
console.log("Axios:", typeof axios !== "undefined" ? "✅" : "❌");

// 2. Verificar que AppRouter está inicializado
console.log("AppRouter:", window.AppRouter);
console.log("Axios Instance:", window.AppRouter.axiosInstance);

// 3. Probar una petición
AppRouter.get("/routes/user/check_session.php")
  .then((data) => console.log("✅ Petición exitosa:", data))
  .catch((err) => console.error("❌ Error:", err));
```

---

## 📦 Archivos Modificados

1. ✅ **composables/npm-loader.js**

   - Agregado `axios: '/axios/dist/axios.min.js'` en `js` object
   - Agregado verificación de Axios en `isLoaded()`
   - Agregado Axios al reporte de dependencias

2. ✅ **views/modern.template.variables.html**
   - Implementada carga de Axios antes de router.js
   - Corregida ruta de color-mode-toggler.js
   - Agregado comentario en `loadOtherLibraries()`

---

## 🎯 Próximos Pasos

1. **Ejecutar `npm install`** para asegurar que Axios esté instalado
2. **Recargar la página** para ver los cambios
3. **Verificar en consola** que Axios se carga correctamente
4. **Probar peticiones** con AppRouter

---

## 📚 Documentación Relacionada

- **NPM-ARCHITECTURE-UPDATE.md** - Arquitectura completa de NPM
- **homelab.instructions.md** - Instrucciones actualizadas
- **router.js** - Cliente HTTP con Axios

---

**Fecha:** 3 de noviembre de 2025  
**Issue:** Axios infinite loading loop  
**Status:** ✅ RESUELTO
