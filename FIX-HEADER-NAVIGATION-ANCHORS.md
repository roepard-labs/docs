# 🔧 Fix: Navegación Contextual - Ocultar Anchors Fuera de Home

**Fecha**: 3 de Noviembre, 2025  
**Componente**: `ui/header.ui.php`  
**Issue**: Enlaces "Acerca de" y "Contacto" visibles en todas las páginas pero solo funcionan en home

---

## 🐛 Problema Identificado

### Síntoma

Los enlaces "Acerca de" (`#about`) y "Contacto" (`#contact`) aparecían en el header de todas las páginas, pero solo funcionan correctamente en la página principal (`/` o `/home`) donde existen esas secciones.

```
Usuario en /features → Click "Acerca de" → ❌ No pasa nada (anchor no existe)
Usuario en /privacy → Click "Contacto" → ❌ No pasa nada (anchor no existe)
Usuario en /home → Click "Acerca de" → ✅ Scroll a sección (anchor existe)
```

### Por Qué Era un Problema

1. **Mala UX**: Enlaces que no funcionan confunden al usuario
2. **Inconsistencia**: No es obvio que solo funcionan en home
3. **Navegación rota**: Click en anchor desde otra página no hace nada

---

## ✅ Solución Implementada

### 1. Marcado Semántico con `data-home-only`

Agregué un atributo `data-home-only` a los `<li>` que contienen anchors locales:

```html
<!-- ✅ DESPUÉS: Marcados para detección -->
<li class="nav-item" data-home-only>
  <a class="nav-link" href="#about">Acerca de</a>
</li>
<li class="nav-item" data-home-only>
  <a class="nav-link" href="#contact">Contacto</a>
</li>
```

**Beneficios**:

- Selector específico para elementos contextuales
- Fácil de mantener y extender
- No afecta otros elementos del nav

### 2. Detección de Ruta Actual

Script JavaScript que detecta si estamos en home:

```javascript
function handleHomeOnlyLinks() {
  const currentPath = window.location.pathname;
  const isHomePage = currentPath === "/" || currentPath === "/home";

  console.log("📍 Ruta actual:", currentPath, "| Es home:", isHomePage);

  // Obtener todos los elementos con data-home-only
  const homeOnlyItems = document.querySelectorAll("[data-home-only]");

  homeOnlyItems.forEach((item) => {
    if (isHomePage) {
      item.style.display = ""; // Mostrar en home
    } else {
      item.style.display = "none"; // Ocultar en otras páginas
    }
  });
}
```

### 3. Ejecución Automática

```javascript
// Ejecutar al cargar
if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", handleHomeOnlyLinks);
} else {
  handleHomeOnlyLinks();
}
```

---

## 🎯 Comportamiento Resultante

### En Página Principal (`/` o `/home`)

```
Navegación mostrada:
✅ Inicio
✅ Características
✅ Acerca de      ← Visible y funcional
✅ VR/AR
✅ Contacto       ← Visible y funcional
```

### En Otras Páginas (`/features`, `/privacy`, `/terms`, etc.)

```
Navegación mostrada:
✅ Inicio
✅ Características
🚫 Acerca de      ← Oculto (anchor no existe aquí)
✅ VR/AR
🚫 Contacto       ← Oculto (anchor no existe aquí)
```

---

## 🧪 Testing

### Test 1: Navegación en Home

```bash
# 1. Ir a http://localhost:9000/
# 2. Verificar navegación

Resultado esperado:
✅ "Acerca de" visible
✅ "Contacto" visible
✅ Click en "Acerca de" → Scroll a sección
✅ Click en "Contacto" → Scroll a sección
```

### Test 2: Navegación en Features

```bash
# 1. Ir a http://localhost:9000/features
# 2. Verificar navegación

Resultado esperado:
✅ "Acerca de" NO visible (oculto)
✅ "Contacto" NO visible (oculto)
✅ Solo se muestran: Inicio, Características, VR/AR
```

### Test 3: Navegación en Privacy

```bash
# 1. Ir a http://localhost:9000/privacy
# 2. Verificar navegación

Resultado esperado:
✅ "Acerca de" NO visible
✅ "Contacto" NO visible
✅ Navegación limpia sin anchors rotos
```

### Test 4: Transición Home → Features

```bash
# 1. Ir a http://localhost:9000/
# 2. Verificar "Acerca de" y "Contacto" visibles
# 3. Click en "Características" → ir a /features
# 4. Verificar "Acerca de" y "Contacto" ocultos

Resultado esperado:
✅ Elementos se ocultan automáticamente al cambiar de página
```

---

## 📊 Rutas y Visibilidad de Anchors

| Ruta        | ¿Es Home? | Acerca de  | Contacto   | Razón                            |
| ----------- | --------- | ---------- | ---------- | -------------------------------- |
| `/`         | ✅ Sí     | ✅ Visible | ✅ Visible | Secciones existen en esta página |
| `/home`     | ✅ Sí     | ✅ Visible | ✅ Visible | Secciones existen en esta página |
| `/features` | ❌ No     | 🚫 Oculto  | 🚫 Oculto  | Anchors no existen aquí          |
| `/privacy`  | ❌ No     | 🚫 Oculto  | 🚫 Oculto  | Anchors no existen aquí          |
| `/terms`    | ❌ No     | 🚫 Oculto  | 🚫 Oculto  | Anchors no existen aquí          |
| `/admin`    | ❌ No     | 🚫 Oculto  | 🚫 Oculto  | Anchors no existen aquí          |
| `/user`     | ❌ No     | 🚫 Oculto  | 🚫 Oculto  | Anchors no existen aquí          |
| `/homelab`  | ❌ No     | 🚫 Oculto  | 🚫 Oculto  | Anchors no existen aquí          |

---

## 🔍 Debug Logs

```javascript
// En consola del navegador:

// Cuando estás en /
📍 Ruta actual: / | Es home: true
✅ Mostrando: Acerca de
✅ Mostrando: Contacto

// Cuando estás en /features
📍 Ruta actual: /features | Es home: false
🚫 Ocultando: Acerca de
🚫 Ocultando: Contacto
```

---

## 🎨 CSS Aplicado

Los elementos se ocultan con `display: none` (no con `visibility: hidden`) para que no ocupen espacio en el layout:

```javascript
// Oculto: No ocupa espacio
item.style.display = "none";

// Visible: Ocupa espacio normal
item.style.display = "";
```

---

## 🚀 Extensibilidad

Si en el futuro agregas más anchors locales a otras páginas, simplemente:

1. Agrega `data-home-only` al `<li>` correspondiente
2. O crea `data-features-only`, `data-dashboard-only`, etc.
3. Extiende la función `handleHomeOnlyLinks()` con más condiciones

**Ejemplo para features:**

```html
<li class="nav-item" data-features-only>
  <a class="nav-link" href="#tech-stack">Tech Stack</a>
</li>
```

```javascript
const isFeaturesPage = currentPath === "/features";
const featuresOnlyItems = document.querySelectorAll("[data-features-only]");
featuresOnlyItems.forEach((item) => {
  item.style.display = isFeaturesPage ? "" : "none";
});
```

---

## 📝 Ventajas de Esta Solución

1. **✅ Navegación limpia**: Solo muestra enlaces funcionales
2. **✅ Mejor UX**: No hay enlaces rotos o que no hacen nada
3. **✅ SEO friendly**: No afecta la estructura HTML inicial
4. **✅ Performance**: Script muy ligero, ejecuta una vez al cargar
5. **✅ Mantenible**: Fácil agregar más condiciones con data attributes
6. **✅ No invasivo**: No requiere cambios en otras páginas

---

## ⚠️ Consideraciones

### Alternativa 1: Convertir Anchors a Rutas

En lugar de ocultar, podrías convertir los anchors a rutas:

```html
<!-- Opción alternativa -->
<a class="nav-link" href="/#about">Acerca de</a>
<a class="nav-link" href="/#contact">Contacto</a>
```

**Pros**: Funcionan desde cualquier página (redirigen a home + scroll)  
**Contras**: Carga completa de página en lugar de smooth scroll

### Alternativa 2: Mostrar Solo en Dropdown

Otra opción sería moverlos a un dropdown "Más" que solo aparece en home.

---

## 📚 Archivos Modificados

### `/ui/header.ui.php`

1. **HTML Navigation** (líneas ~32-46):

   - ✅ Agregado `data-home-only` a "Acerca de"
   - ✅ Agregado `data-home-only` a "Contacto"

2. **JavaScript** (líneas ~120-145):
   - ✅ Función `handleHomeOnlyLinks()` para detectar ruta
   - ✅ Ocultar/mostrar elementos según contexto
   - ✅ Logs de debug para verificar comportamiento

---

## 🎯 Resultado Final

### Antes (Problema)

```
Usuario en /features
Header: [Inicio] [Características] [Acerca de] [VR/AR] [Contacto]
                                    ↑ Click → ❌ No hace nada
```

### Después (Solucionado)

```
Usuario en /features
Header: [Inicio] [Características] [VR/AR]
        ↑ Solo enlaces funcionales visibles ✅
```

---

## 📞 Referencias

**Relacionado con**:

- [ROUTING-SYSTEM.md](./ROUTING-SYSTEM.md) - Sistema de routing con URLs limpias
- [FIX-HEADER-ROLE-SYNC.md](./FIX-HEADER-ROLE-SYNC.md) - Sincronización de roles en header

---

**Estado**: ✅ IMPLEMENTADO  
**Versión**: 1.0  
**Autor**: GitHub Copilot  
**Fecha**: 3 de Noviembre, 2025
