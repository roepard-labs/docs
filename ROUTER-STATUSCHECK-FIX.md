# ✅ Solución: AppRouter no estaba disponible para statusCheck.js

**Fecha**: 3 de noviembre de 2025  
**Problema**: `Uncaught ReferenceError: AppRouter is not defined`  
**Causa**: Orden de carga incorrecto de scripts

---

## 🔍 Diagnóstico

### Error Original

```
statusCheck.js:1 Uncaught ReferenceError: AppRouter is not defined
    at statusCheck.js:1:1
```

### Flujo de Carga Problemático

```
1. npm-loader.js      ✅ Se carga
2. config.js          ✅ Se carga
3. statusCheck.js     ❌ Se ejecuta (AppRouter no existe aún)
4. Axios              ⏳ Se carga asíncronamente
5. router.js          ⏳ Define AppRouter después
```

**Problema**: `statusCheck.js` se ejecutaba **antes** de que `AppRouter` fuera definido por `router.js`.

---

## ✅ Solución Implementada

### Orden de Carga Correcto

```
1. npm-loader.js      ✅ Configuración de rutas NPM
2. config.js          ✅ Variables de entorno
3. Axios              ✅ Librería HTTP (carga sincrónica)
   ↓ onload callback
4. router.js          ✅ Define window.AppRouter
   ↓ onload callback
5. statusCheck.js     ✅ Usa AppRouter (ya está disponible)
```

### Cambio Implementado

**Archivo**: `/views/modern.template.variables.html`

**ANTES (❌ Incorrecto)**:

```html
<script>
  const axiosScript = document.createElement("script");
  axiosScript.src = getJSPath("axios");
  axiosScript.onload = function () {
    const routerScript = document.createElement("script");
    routerScript.src = "../composables/router.js";
    document.head.appendChild(routerScript);
  };
  document.head.appendChild(axiosScript);
</script>

<script src="../utils/statusCheck.js"></script>
<!-- ❌ Se ejecuta demasiado pronto -->
```

**DESPUÉS (✅ Correcto)**:

```html
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

---

## 🧪 Verificación

### Consola Esperada (Orden Correcto)

```
⚙️ NPM Loader inicializado
⚙️ Configuración cargada desde .env
✅ Axios cargado correctamente          // ✅ 1. Axios primero
🚀 Router inicializado con Axios        // ✅ 2. Router después
✅ Axios inicializado correctamente
✅ Router (Axios) configurado y listo
✅ Router.js cargado correctamente      // ✅ 3. Confirmación
📤 GET: /routes/web/status.php          // ✅ 4. statusCheck funciona
```

### Test de Funcionamiento

```javascript
// En la consola del navegador
console.log(typeof AppRouter); // ✅ Debe retornar "object"
console.log(AppRouter); // ✅ Debe mostrar instancia de Router
AppRouter.get("/routes/web/status.php"); // ✅ Debe funcionar sin errores
```

---

## 📋 Archivos Modificados

1. **`views/modern.template.variables.html`**

   - Implementada carga secuencial con callbacks
   - Eliminado `<script src="../utils/statusCheck.js">` del head
   - statusCheck.js ahora se carga dinámicamente después de router.js

2. **`docs/FIX-AXIOS-LOADING.md`**
   - Actualizada documentación con secuencia correcta
   - Agregada sección sobre statusCheck.js

---

## 🎯 Resultado

✅ **AppRouter ahora está disponible cuando statusCheck.js se ejecuta**  
✅ **No más errores de `ReferenceError`**  
✅ **Flujo de carga garantizado: Axios → Router → StatusCheck**  
✅ **Peticiones HTTP funcionan correctamente**

---

## 🔍 Lección Aprendida

**Regla de Oro**: Cuando un script depende de una librería global:

1. ❌ **NO** cargarlo con `<script src="...">` en el head
2. ✅ **SÍ** cargarlo dinámicamente en el callback `onload` de la dependencia
3. ✅ **SÍ** usar carga secuencial con callbacks encadenados

**Patrón de Carga Dependiente**:

```javascript
// Patrón correcto para dependencias
loadLibraryA().onload(() => {
  loadLibraryB().onload(() => {
    loadScriptThatNeedsBoth();
  });
});
```

---

**Estado**: ✅ **RESUELTO** - AppRouter funciona correctamente  
**Documentado por**: GitHub Copilot  
**Verificado**: Consola del navegador muestra carga correcta
