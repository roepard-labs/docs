# 🚀 PRUEBA RÁPIDA - HomeLab AR

**Fecha:** 2025-01-22  
**Arquitectura:** Funcional Completa ✅

---

## 📋 CHECKLIST DE VERIFICACIÓN

### ✅ **Paso 1: Verificar Archivos Creados**

```bash
cd /home/jemg/Documents/GitHub/roepard-labs/thepearlo_vr-website

# Verificar estructura de directorios
ls -la layout/ views/ sections/ ui/ modals/ js/ appstore/

# Verificar archivos principales
ls -lh layout/AppLayout.php
ls -lh views/home.view.php
ls -lh js/{main,auth,utils}.js
ls -lh appstore/{apps.json,reader.php,viewer.php}
```

**Resultado esperado:**

```
✅ layout/AppLayout.php (5.8 KB)
✅ views/home.view.php (548 bytes)
✅ sections/ (5 archivos)
✅ ui/ (2 archivos)
✅ modals/auth.modal.php (13 KB)
✅ js/main.js (7.6 KB)
✅ js/auth.js (9.6 KB)
✅ js/utils.js (9.8 KB)
✅ appstore/apps.json
✅ appstore/reader.php
✅ appstore/viewer.php
✅ appstore/apps/homelab-monitor/
```

---

## 🌐 **Paso 2: Probar en el Navegador**

### 1️⃣ **Página Principal**

```
http://localhost/thepearlo_vr-website/
```

**Debe mostrar:**

- ✅ Header con logo y navegación
- ✅ Hero section con título y CTA
- ✅ 4 cards de características
- ✅ 4 estadísticas animadas
- ✅ Sección About
- ✅ Formulario de contacto
- ✅ Footer con links y newsletter
- ✅ Botón de theme toggle (dark/light)
- ✅ Animaciones AOS al hacer scroll

### 2️⃣ **Modal de Autenticación**

**Acciones:**

1. Click en "Ingresar" en el header
2. Debe abrir modal con 2 tabs:
   - Login
   - Registro

**Verificar:**

- ✅ Toggle entre Login/Registro funciona
- ✅ Campos de formulario con validación
- ✅ Botón de "ver contraseña" funciona
- ✅ Links a términos y privacidad

### 3️⃣ **AppStore API**

```bash
# Listar todas las apps
curl http://localhost/thepearlo_vr-website/appstore/reader.php?action=list

# Obtener app específica
curl http://localhost/thepearlo_vr-website/appstore/reader.php?action=get&id=homelab-monitor

# Apps destacadas
curl http://localhost/thepearlo_vr-website/appstore/reader.php?action=featured

# Categorías
curl http://localhost/thepearlo_vr-website/appstore/reader.php?action=categories

# Estadísticas
curl http://localhost/thepearlo_vr-website/appstore/reader.php?action=stats
```

**Resultado esperado:**

```json
{
  "success": true,
  "apps": [...],
  "pagination": {...}
}
```

### 4️⃣ **Visor de Apps**

```
http://localhost/thepearlo_vr-website/appstore/viewer.php?id=homelab-monitor
```

**Debe mostrar:**

- ✅ Header con nombre de la app
- ✅ Botones de acción (recargar, fullscreen, volver)
- ✅ App funcionando en iframe
- ✅ Monitoreo de 6 servidores
- ✅ Estadísticas animadas
- ✅ Progress bars actualizándose
- ✅ Botón "Activar Vista AR"

---

## 🔧 **Paso 3: Verificar JavaScript**

### Abrir DevTools (F12) y verificar:

```javascript
// En la consola del navegador:

// 1. Verificar carga de scripts
console.log("AOS:", typeof AOS); // Debe ser 'object'
console.log("Utils:", typeof Utils); // Debe ser 'object'
console.log("Auth:", typeof Auth); // Debe ser 'object'
console.log("axios:", typeof axios); // Debe ser 'function'

// 2. Verificar configuración
console.log(APP_CONFIG);

// 3. Probar funciones helper
Utils.formatNumber(1234567); // "1,234,567"
Utils.formatDate(new Date()); // "22/01/2025"
Utils.validateEmail("test@example.com"); // true

// 4. Verificar detección de dispositivo
Utils.device.isMobile();
Utils.device.isDesktop();
Utils.browser.supportsWebGL();
```

**Resultado esperado:**

```
✅ AOS: object
✅ Utils: object
✅ Auth: object
✅ axios: function
✅ APP_CONFIG: {app: {...}, api: {...}, ...}
```

---

## 🎨 **Paso 4: Verificar Estilos y Animaciones**

### Theme Toggle

1. Click en el botón de luna/sol en el header
2. Debe cambiar entre modo claro y oscuro
3. El tema debe persistir al recargar

### Animaciones AOS

1. Hacer scroll en la página principal
2. Elementos deben aparecer con animación fade-up
3. Delays escalonados en las cards

### Responsive Design

1. Abrir DevTools (F12)
2. Activar modo responsive
3. Probar en diferentes tamaños:
   - Mobile: 375px
   - Tablet: 768px
   - Desktop: 1920px

**Verificar:**

- ✅ Hero stack vertical en móvil
- ✅ Cards en columnas ajustables
- ✅ Navegación collapse en móvil
- ✅ Footer stack vertical en móvil

---

## 🧪 **Paso 5: Testing de Funcionalidades**

### Formulario de Contacto

1. Llenar el formulario en la sección Contact
2. Click en "Enviar Mensaje"
3. Debe mostrar alerta de éxito (SweetAlert2 o alert)
4. Formulario debe limpiarse

### Newsletter

1. Ingresar email en el footer
2. Click en "Suscribirse"
3. Debe mostrar notificación (Notyf o alert)
4. Input debe limpiarse

### Smooth Scroll

1. Click en links del navbar (#inicio, #caracteristicas, etc)
2. Debe hacer scroll suave a la sección
3. Sin saltos bruscos

### Contadores Animados

1. Hacer scroll hasta la sección Stats
2. Los números deben animarse desde 0 hasta el valor final
3. Animación debe ejecutarse solo una vez

---

## 📊 **Paso 6: Verificar Integración Backend**

### Si tienes el backend corriendo:

```bash
# En otra terminal, iniciar backend
cd /home/jemg/Documents/GitHub/roepard-labs/thepearlo_vr-backend
php -S localhost:3000
```

### Probar autenticación real:

1. Click en "Ingresar" en el header
2. Ingresar credenciales válidas
3. Verificar respuesta en DevTools > Network
4. Si es exitoso:
   - Modal debe cerrarse
   - Header debe mostrar dropdown de usuario
   - Debe aparecer "Cerrar Sesión"

---

## ⚠️ **Problemas Comunes y Soluciones**

### 1. **Error: AppLayout not found**

```bash
# Verificar que el archivo existe
ls -la layout/AppLayout.php

# Verificar permisos
chmod 644 layout/AppLayout.php
```

### 2. **JavaScript no carga**

```bash
# Verificar que los archivos existen
ls -la js/{main,auth,utils}.js

# Verificar en DevTools > Network
# Buscar archivos con status 404
```

### 3. **Estilos no se aplican**

```bash
# Verificar archivos CSS
ls -la css/{variables,base,main}.css

# Verificar que Bootstrap carga
# DevTools > Network > Filtrar por "bootstrap"
```

### 4. **Modal no abre**

```javascript
// En DevTools > Console
// Verificar que Bootstrap está cargado
typeof bootstrap.Modal; // Debe ser 'function'

// Verificar que el modal existe en el DOM
document.getElementById("authModal"); // No debe ser null
```

### 5. **API AppStore no funciona**

```bash
# Verificar permisos del archivo PHP
chmod 755 appstore/reader.php

# Verificar que el JSON existe
cat appstore/apps.json

# Probar directamente
curl http://localhost/thepearlo_vr-website/appstore/reader.php?action=list
```

### 6. **Animaciones AOS no funcionan**

```javascript
// Verificar que AOS está inicializado
console.log(AOS);

// Re-inicializar manualmente
AOS.refresh();
```

---

## 📝 **Checklist Final**

Marca cada item cuando esté funcionando:

### Estructura

- [ ] Todos los archivos creados existen
- [ ] Permisos correctos en archivos PHP
- [ ] No hay errores 404 en DevTools

### Página Principal

- [ ] Header carga correctamente
- [ ] Hero section visible
- [ ] Features cards (4 items)
- [ ] Stats animadas (4 items)
- [ ] About section
- [ ] Contact form
- [ ] Footer con links

### Funcionalidades

- [ ] Modal de auth abre/cierra
- [ ] Theme toggle funciona
- [ ] Smooth scroll funciona
- [ ] Animaciones AOS activas
- [ ] Contadores animados
- [ ] Formularios con validación

### AppStore

- [ ] API reader.php responde
- [ ] Viewer.php carga apps
- [ ] App ejemplo funciona
- [ ] Iframe carga correctamente

### JavaScript

- [ ] main.js carga sin errores
- [ ] auth.js carga sin errores
- [ ] utils.js carga sin errores
- [ ] No hay errores en Console

### Responsive

- [ ] Mobile (375px) OK
- [ ] Tablet (768px) OK
- [ ] Desktop (1920px) OK

---

## 🎉 **¡Arquitectura Funcionando!**

Si todos los checks están marcados, ¡la arquitectura funcional está completamente operativa!

### Próximos pasos sugeridos:

1. **Crear más vistas**

   - Dashboard de usuario
   - Panel de administración
   - Lista de apps en AppStore
   - Perfil de usuario

2. **Desarrollar más apps**

   - AR Server Viewer
   - Network Topology
   - Container Manager
   - Log Viewer AR

3. **Integrar backend real**

   - Conectar auth.js con API
   - Implementar JWT tokens
   - Sincronizar datos de usuario

4. **Optimizar performance**

   - Minificar CSS/JS
   - Lazy loading de imágenes
   - Cache de recursos
   - CDN para librerías

5. **Testing avanzado**
   - Unit tests con Jest
   - E2E tests con Cypress
   - Performance tests
   - Cross-browser testing

---

## 📚 **Recursos Adicionales**

- **Documentación completa:** `/docs/`
- **Arquitectura:** `ARQUITECTURA-FUNCIONAL.md`
- **Quick Start:** `QUICK-START-ARQUITECTURA.md`
- **Implementación:** `IMPLEMENTACION-COMPLETA.md`
- **Este archivo:** `PRUEBA-RAPIDA.md`

---

## 🆘 **¿Necesitas Ayuda?**

Si algo no funciona:

1. Revisa la documentación en `/docs/`
2. Verifica la consola del navegador (F12)
3. Revisa los logs del servidor PHP
4. Consulta las instrucciones en `.github/instructions/homelab.instructions.md`

---

**¡Disfruta tu nueva arquitectura funcional!** 🚀

_Generado por Roepard Labs - HomeLab AR Project_  
_Fecha: 2025-01-22_
