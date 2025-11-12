# 🔧 FIX: Error de Inicialización de AppRouter en Profile

## 🔴 Problema

Al cargar `/dashboard/profile`, los scripts se ejecutaban antes de que Axios estuviera completamente inicializado en `AppRouter`, causando errores:

```
❌ Axios no está inicializado. Usa router.initAxios() primero.
❌ Error al cargar datos del usuario: Axios no inicializado
❌ Error al obtener sesiones: Axios no inicializado
```

## 🔍 Causa Raíz

El script de `profile.page.php` se ejecutaba inmediatamente al cargar, pero `AppRouter` necesita tiempo para:

1. Cargar Axios desde NPM
2. Inicializar la instancia de Axios con configuración
3. Estar completamente listo para peticiones

**Orden de carga**:

```
1. profile.page.php carga → init() ejecuta inmediatamente ❌
2. router.js carga → Axios no está disponible aún
3. Axios finalmente carga → pero ya es tarde
```

## ✅ Solución Implementada

### 1. Sistema de Espera en profile.page.php

Agregado función `waitForAppRouter()` que espera hasta 10 segundos:

```javascript
async function waitForAppRouter() {
  let attempts = 0;
  const maxAttempts = 20; // 10 segundos máximo

  while (attempts < maxAttempts) {
    if (
      window.AppRouter &&
      typeof window.AppRouter.isReady === "function" &&
      window.AppRouter.isReady()
    ) {
      console.log("✅ AppRouter está listo para usar");
      return true;
    }

    console.log(
      `⏳ Esperando a AppRouter... Intento ${attempts + 1}/${maxAttempts}`
    );
    await new Promise((resolve) => setTimeout(resolve, 500));
    attempts++;
  }

  return false;
}
```

### 2. Inicialización Mejorada

```javascript
async function init() {
  console.log("🚀 Inicializando perfil...");

  // ESPERAR a que AppRouter esté disponible
  const isReady = await waitForAppRouter();

  if (!isReady) {
    console.error("❌ No se pudo inicializar el perfil");
    notyf.error("Error al cargar el perfil. Por favor, recarga la página.");
    return;
  }

  // Ahora sí, cargar datos
  await loadUserData();
  await loadActiveSessions();
  initSessionEvents();
}
```

### 3. Verificaciones en loadUserData()

```javascript
async function loadUserData() {
  // Verificar que AppRouter esté disponible
  if (!window.AppRouter || !window.AppRouter.isReady()) {
    console.warn("⏳ AppRouter no está listo, esperando...");
    await new Promise((resolve) => setTimeout(resolve, 500));
    return loadUserData(); // Reintentar recursivamente
  }

  const response = await window.AppRouter.get("/routes/user/user_data.php");
  // ...
}
```

### 4. Verificaciones en loadActiveSessions()

```javascript
async function loadActiveSessions() {
  // Verificar que AppRouter esté disponible
  if (!window.AppRouter || !window.AppRouter.isReady()) {
    console.warn("⏳ AppRouter no está listo para sesiones, esperando...");
    await new Promise((resolve) => setTimeout(resolve, 500));
    return loadActiveSessions(); // Reintentar recursivamente
  }

  activeSessions = await window.SessionsService.getActiveSessions();
  // ...
}
```

### 5. Validaciones en sessions.js

```javascript
async getActiveSessions() {
    // Verificar que AppRouter esté disponible
    if (!window.AppRouter) {
        throw new Error('AppRouter no está disponible');
    }

    if (typeof window.AppRouter.isReady === 'function' &&
        !window.AppRouter.isReady()) {
        throw new Error('AppRouter no está inicializado');
    }

    const response = await window.AppRouter.get('/routes/user/list_sessions.php');
    // ...
}
```

## 📊 Flujo Corregido

```
Usuario → /dashboard/profile
            ↓
[1] profile.page.php carga
            ↓
[2] init() ejecuta
            ↓
[3] waitForAppRouter() espera...
    ⏳ Intento 1/20
    ⏳ Intento 2/20
            ↓
[4] router.js carga Axios
            ↓
[5] AppRouter.isReady() → true ✅
            ↓
[6] waitForAppRouter() retorna true
            ↓
[7] loadUserData() ejecuta
    - Verifica AppRouter.isReady() ✅
    - GET /routes/user/user_data.php ✅
            ↓
[8] loadActiveSessions() ejecuta
    - Verifica AppRouter.isReady() ✅
    - GET /routes/user/list_sessions.php ✅
            ↓
✅ Perfil cargado sin errores
```

## 🧪 Testing

### Verificar que funciona:

1. Abrir DevTools (F12) → Console
2. Navegar a `/dashboard/profile`
3. Ver logs:

**Esperado**:

```
🚀 Inicializando perfil...
⏳ Esperando a AppRouter... Intento 1/20
⏳ Esperando a AppRouter... Intento 2/20
✅ AppRouter está listo para usar
📊 Cargando datos del usuario...
✅ Datos del usuario cargados: {...}
🔐 Cargando sesiones activas...
✅ Sesiones activas cargadas: 1
✅ Perfil inicializado completamente
```

**NO debe aparecer**:

```
❌ Axios no está inicializado
❌ Error al cargar datos del usuario: Axios no inicializado
```

### Casos de Borde

**Si Axios nunca carga (timeout)**:

```
⏳ Esperando a AppRouter... Intento 20/20
❌ Timeout esperando a AppRouter
❌ No se pudo inicializar el perfil: AppRouter no disponible
🔔 Notyf: "Error al cargar el perfil. Por favor, recarga la página."
```

## 📝 Archivos Modificados

- ✅ `/pages/profile.page.php` - Agregado waitForAppRouter() y verificaciones
- ✅ `/js/sessions.js` - Agregado validaciones en getActiveSessions()

## 🎯 Beneficios

1. **No más errores de inicialización**: El código espera a que AppRouter esté listo
2. **Experiencia de usuario mejorada**: Loading states claros
3. **Manejo de errores robusto**: Timeout después de 10 segundos
4. **Debugging más fácil**: Logs claros de cada intento
5. **Graceful degradation**: Notifica al usuario si hay problemas

## 🚀 Próximos Pasos

Si el problema persiste:

1. **Verificar orden de carga de scripts en AppLayout.php**:

   - router.js debe cargar ANTES de sessions.js
   - Axios debe estar en jsCore

2. **Verificar npm build**:

   ```bash
   npm run build:config
   ```

3. **Limpiar caché del navegador**:
   - Ctrl + Shift + R (hard reload)

---

**Fix aplicado**: Noviembre 5, 2025  
**Archivos modificados**: 2  
**Estado**: ✅ Resuelto
