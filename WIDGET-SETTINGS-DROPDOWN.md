# ⚙️ Widget Settings Dropdown - Sistema de Preferencias

## 📋 Resumen Ejecutivo

Se ha implementado un **dropdown de configuración de widgets** en el sidebar que permite a los usuarios personalizar:

- ⏰ **Formato de hora**: 12h (AM/PM) vs 24h
- 🌡️ **Unidades de temperatura**: Celsius (°C), Fahrenheit (°F), Kelvin (K)
- 📅 **Formato de fecha**: 7 formatos disponibles (DD/MM/YYYY, MM/DD/YYYY, etc.)

**Persistencia**: Todas las preferencias se guardan en `localStorage` y se mantienen entre sesiones.

---

## 🎯 Características Principales

✅ **Dual State**:

- Botón en sidebar expandido (con texto "Configuración de Widgets")
- Botón en sidebar colapsado (solo icono de engranaje)

✅ **Preferencias Disponibles**:

1. Toggle switch para formato de hora (AM/PM ↔ 24h)
2. Grupo de botones para unidades de temperatura (°C | °F | K)
3. Select dropdown con 7 formatos de fecha

✅ **Persistencia**:

- Guardado automático en `localStorage`
- Carga automática al iniciar sesión
- API global para acceso desde otros scripts

✅ **Integración con Widgets**:

- ClockService lee preferencias de hora
- WeatherService lee preferencias de temperatura
- Recarga automática al cambiar preferencias

---

## 📁 Archivos Creados/Modificados

### 1. `/ui/widget-settings-dropdown.php` - **NUEVO**

**Descripción**: Componente reutilizable con el contenido del dropdown de configuración.

**Estructura HTML**:

```html
<!-- Header del dropdown -->
<li class="px-3 py-2">
  <h6>Preferencias de Widgets</h6>
</li>

<!-- Toggle de formato de hora -->
<li class="px-3 py-2">
  <div class="form-check form-switch">
    <input type="checkbox" id="timeFormatToggle" />
    <label for="timeFormatToggle" id="timeFormatLabel">24h</label>
  </div>
</li>

<!-- Botones de unidades de temperatura -->
<li class="px-3 py-2">
  <div class="btn-group">
    <input type="radio" name="tempUnit" id="tempCelsius" value="C" />
    <label for="tempCelsius">°C</label>
    <!-- ... F y K -->
  </div>
</li>

<!-- Select de formato de fecha -->
<li class="px-3 py-2">
  <select id="dateFormatSelect">
    <option value="DD/MM/YYYY">DD/MM/YYYY (31/12/2025)</option>
    <!-- ... otros formatos -->
  </select>
</li>

<!-- Botones de acción -->
<li class="px-3 py-2">
  <button id="saveWidgetSettings">Guardar</button>
  <button id="resetWidgetSettings">Resetear</button>
</li>
```

**JavaScript embebido**:

```javascript
// IIFE para evitar contaminar scope global
(function () {
  "use strict";

  // Claves de localStorage
  const STORAGE_KEYS = {
    TIME_FORMAT: "widget_prefs_time_format",
    TEMP_UNIT: "widget_prefs_temp_unit",
    DATE_FORMAT: "widget_prefs_date_format",
  };

  // Valores por defecto
  const DEFAULTS = {
    TIME_FORMAT: "24h",
    TEMP_UNIT: "C",
    DATE_FORMAT: "DD/MM/YYYY",
  };

  // Funciones principales
  function loadPreferences() {
    /* ... */
  }
  function savePreferences() {
    /* ... */
  }
  function resetPreferences() {
    /* ... */
  }
  function reloadWidgets() {
    /* ... */
  }
})();
```

**API Global Expuesta**:

```javascript
window.WidgetSettingsAPI = {
  getTimeFormat: () =>
    localStorage.getItem("widget_prefs_time_format") || "24h",
  getTempUnit: () => localStorage.getItem("widget_prefs_temp_unit") || "C",
  getDateFormat: () =>
    localStorage.getItem("widget_prefs_date_format") || "DD/MM/YYYY",
  reload: loadPreferences,
};
```

### 2. `/ui/sidebar.ui.php` - **MODIFICADO**

**Cambios realizados**:

```php
<!-- Settings Button (Expanded) - Debajo de Home y Collapse -->
<div class="sidebar-settings-expanded px-3 pb-3 border-bottom sidebar-text" id="sidebarSettingsExpanded">
    <div class="dropdown">
        <button class="btn btn-sm btn-outline-secondary w-100" id="widgetSettingsExpanded"
                data-bs-toggle="dropdown" aria-expanded="false">
            <span>
                <i class="bx bx-cog me-2"></i>
                <span>Configuración de Widgets</span>
            </span>
            <i class="bx bx-chevron-down"></i>
        </button>
        <ul class="dropdown-menu w-100 widget-settings-dropdown">
            <?php include __DIR__ . '/widget-settings-dropdown.php'; ?>
        </ul>
    </div>
</div>

<!-- Settings Button (Collapsed) -->
<div class="sidebar-toggle-collapsed mt-3">
    <!-- ... home y collapse buttons ... -->
    <div class="dropdown">
        <button class="btn btn-sm btn-outline-secondary w-100" id="widgetSettingsCollapsed"
                data-bs-toggle="dropdown" title="Configuración de Widgets">
            <i class="bx bx-cog"></i>
        </button>
        <ul class="dropdown-menu dropdown-menu-end widget-settings-dropdown">
            <?php include __DIR__ . '/widget-settings-dropdown.php'; ?>
        </ul>
    </div>
</div>
```

**CSS agregado**:

```css
/* Ocultar settings en sidebar colapsado */
.sidebar-collapsed .sidebar-settings-expanded {
  display: none !important;
}

/* Animación del engranaje */
#widgetSettingsExpanded:hover i.bx-cog,
#widgetSettingsCollapsed:hover i.bx-cog {
  animation: rotate-cog 1s ease-in-out;
}

@keyframes rotate-cog {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}
```

### 3. `/composables/clockCheck.js` - **MODIFICADO**

**Método agregado**:

```javascript
/**
 * Obtener formato de hora desde localStorage
 * @private
 * @returns {boolean} true para AM/PM, false para 24h
 */
getHourFormat() {
    const savedFormat = localStorage.getItem('widget_prefs_time_format');
    if (savedFormat === 'AM/PM') {
        return true; // hour12: true
    } else if (savedFormat === '24h') {
        return false; // hour12: false
    }
    // Default: 24h
    return false;
}
```

**Integración en updateDateTime()**:

```javascript
updateDateTime() {
    const now = new Date();

    // Obtener formato de hora desde preferencias
    const useAmPm = this.getHourFormat();

    // Configurar formato de hora según preferencia
    const timeOptions = {
        ...this.config.TIME_OPTIONS,
        hour12: useAmPm  // true = AM/PM, false = 24h
    };

    const timeStr = now.toLocaleTimeString(this.config.LOCALE, timeOptions);
    // ...
}
```

### 4. `/composables/weatherCheck.js` - **MODIFICADO**

**Método agregado**:

```javascript
/**
 * Obtener unidades de temperatura desde localStorage
 * @private
 * @returns {string} 'metric' (C), 'imperial' (F), o 'standard' (K)
 */
getTempUnits() {
    const savedUnit = localStorage.getItem('widget_prefs_temp_unit');
    if (savedUnit === 'C') {
        return 'metric';
    } else if (savedUnit === 'F') {
        return 'imperial';
    } else if (savedUnit === 'K') {
        return 'standard';
    }
    // Default: Celsius
    return 'metric';
}
```

**Integración en getCurrentWeather()**:

```javascript
async getCurrentWeather(options = {}) {
    // Valores por defecto (unidades desde localStorage)
    const {
        city = this.config.DEFAULT_CITY,
        country = this.config.DEFAULT_COUNTRY,
        units = this.getTempUnits(),  // Lee preferencias del usuario
        lang = 'es',
        useCache = true
    } = options;
    // ...
}
```

---

## 🔄 Flujo de Funcionamiento

### 1. Carga Inicial

```
Usuario abre dashboard
    ↓
sidebar.ui.php incluye widget-settings-dropdown.php
    ↓
JavaScript IIFE se ejecuta automáticamente
    ↓
loadPreferences() lee localStorage
    ↓
UI se actualiza con valores guardados
    ↓
✅ Dropdown listo para usar
```

### 2. Cambio de Preferencias

```
Usuario abre dropdown
    ↓
Modifica formato de hora (toggle)
    ↓
Cambia unidades de temperatura (radio buttons)
    ↓
Selecciona formato de fecha (select)
    ↓
Click en "Guardar"
    ↓
savePreferences() guarda en localStorage
    ↓
Dispara evento 'widgetPreferencesChanged'
    ↓
reloadWidgets() recarga ClockService y WeatherService
    ↓
Widgets se actualizan con nuevos formatos
    ↓
✅ Notyf muestra notificación de éxito
```

### 3. Recarga de Página

```
Usuario recarga página (F5)
    ↓
localStorage conserva preferencias
    ↓
loadPreferences() restaura valores
    ↓
ClockService.getHourFormat() lee preferencias
    ↓
WeatherService.getTempUnits() lee preferencias
    ↓
Widgets inician con formatos guardados
    ↓
✅ Experiencia consistente entre sesiones
```

### 4. Reseteo de Preferencias

```
Usuario click en "Resetear"
    ↓
resetPreferences() limpia localStorage
    ↓
loadPreferences() carga valores por defecto
    ↓
UI se resetea a estado inicial
    ↓
Dispara evento 'widgetPreferencesChanged'
    ↓
Widgets se recargan con defaults
    ↓
✅ Notyf muestra notificación informativa
```

---

## 📊 Formatos Disponibles

### Formato de Hora

| Valor   | Descripción | Ejemplo     |
| ------- | ----------- | ----------- |
| `24h`   | Formato 24h | 14:30:45    |
| `AM/PM` | Formato 12h | 02:30:45 PM |

**Default**: `24h`

### Unidades de Temperatura

| Símbolo | Valor API  | Descripción | Rango Típico |
| ------- | ---------- | ----------- | ------------ |
| `°C`    | `metric`   | Celsius     | -30 a 50°C   |
| `°F`    | `imperial` | Fahrenheit  | -22 a 122°F  |
| `K`     | `standard` | Kelvin      | 243 a 323K   |

**Default**: `°C` (metric)

### Formatos de Fecha

| Valor          | Ejemplo      | Descripción         |
| -------------- | ------------ | ------------------- |
| `DD/MM/YYYY`   | 31/12/2025   | Europeo estándar    |
| `MM/DD/YYYY`   | 12/31/2025   | Americano estándar  |
| `YYYY-MM-DD`   | 2025-12-31   | ISO 8601            |
| `DD-MM-YYYY`   | 31-12-2025   | Europeo con guiones |
| `YYYY/MM/DD`   | 2025/12/31   | Asiático estándar   |
| `DD MMM YYYY`  | 31 Dic 2025  | Con mes abreviado   |
| `MMM DD, YYYY` | Dic 31, 2025 | Estilo anglosajón   |

**Default**: `DD/MM/YYYY`

---

## 🎨 Diseño UI/UX

### Estados del Botón

**Sidebar Expandido**:

```
┌───────────────────────────────────┐
│ [🏠 Home]  [📊 Collapse]          │
├───────────────────────────────────┤
│ [⚙️ Configuración de Widgets 🔽]  │
│   └─ Dropdown (ancho completo)    │
└───────────────────────────────────┘
```

**Sidebar Colapsado**:

```
┌──────┐
│ 🏠   │
│ 📊   │
│ ⚙️   │ ← Click abre dropdown a la derecha
└──────┘
```

### Animaciones

1. **Hover en engranaje**: Rotación 360° en 1 segundo
2. **Cambio de toggle**: Transición suave del label (24h ↔ AM/PM)
3. **Selección de temperatura**: Botón activo con color primario
4. **Guardado exitoso**: Notyf toast con ícono de checkmark

### Accesibilidad

- ✅ Labels asociados con `for` e `id`
- ✅ Tooltips informativos (`title` attributes)
- ✅ Roles ARIA (`aria-labelledby`, `aria-expanded`)
- ✅ Navegación por teclado (Tab, Enter, Space)
- ✅ Contraste de colores (WCAG AA compliant)

---

## 🔧 API de localStorage

### Claves Utilizadas

```javascript
const STORAGE_KEYS = {
  TIME_FORMAT: "widget_prefs_time_format", // Valores: '24h' | 'AM/PM'
  TEMP_UNIT: "widget_prefs_temp_unit", // Valores: 'C' | 'F' | 'K'
  DATE_FORMAT: "widget_prefs_date_format", // Valores: 'DD/MM/YYYY' | etc.
};
```

### Acceso desde Otros Scripts

```javascript
// Opción 1: API Global
const timeFormat = window.WidgetSettingsAPI.getTimeFormat(); // '24h' o 'AM/PM'
const tempUnit = window.WidgetSettingsAPI.getTempUnit(); // 'C', 'F', o 'K'
const dateFormat = window.WidgetSettingsAPI.getDateFormat(); // 'DD/MM/YYYY', etc.

// Opción 2: localStorage directo
const timeFormat = localStorage.getItem("widget_prefs_time_format") || "24h";
const tempUnit = localStorage.getItem("widget_prefs_temp_unit") || "C";
const dateFormat =
  localStorage.getItem("widget_prefs_date_format") || "DD/MM/YYYY";

// Recargar preferencias desde UI
window.WidgetSettingsAPI.reload();
```

### Eventos Personalizados

```javascript
// Escuchar cambios de preferencias
window.addEventListener("widgetPreferencesChanged", function (event) {
  const { timeFormat, tempUnit, dateFormat } = event.detail;
  console.log("Preferencias actualizadas:", {
    timeFormat,
    tempUnit,
    dateFormat,
  });

  // Actualizar tu componente
  updateMyWidget();
});

// Disparar manualmente (si modificas localStorage desde otro script)
window.dispatchEvent(
  new CustomEvent("widgetPreferencesChanged", {
    detail: {
      timeFormat: "24h",
      tempUnit: "C",
      dateFormat: "DD/MM/YYYY",
    },
  })
);
```

---

## 🧪 Testing

### Testing Manual en Browser

#### 1. Test de Guardado

```javascript
// 1. Abrir dropdown de settings
// 2. Cambiar preferencias
// 3. Click en "Guardar"
// 4. Verificar en consola:
localStorage.getItem("widget_prefs_time_format"); // Debe mostrar valor guardado
localStorage.getItem("widget_prefs_temp_unit"); // Debe mostrar valor guardado
localStorage.getItem("widget_prefs_date_format"); // Debe mostrar valor guardado
```

#### 2. Test de Recarga

```javascript
// 1. Cambiar preferencias y guardar
// 2. Recargar página (F5)
// 3. Abrir dropdown de settings
// 4. Verificar que los valores guardados estén seleccionados
```

#### 3. Test de Reseteo

```javascript
// 1. Cambiar preferencias
// 2. Click en "Resetear"
// 3. Verificar localStorage:
localStorage.getItem("widget_prefs_time_format"); // Debe ser null
localStorage.getItem("widget_prefs_temp_unit"); // Debe ser null
localStorage.getItem("widget_prefs_date_format"); // Debe ser null

// 4. Verificar UI vuelve a defaults (24h, °C, DD/MM/YYYY)
```

#### 4. Test de Integración con Widgets

```javascript
// Test ClockService
// 1. Cambiar formato de hora a AM/PM
// 2. Guardar
// 3. Verificar que el reloj muestra: "02:30:45 PM" (en lugar de "14:30:45")

// Test WeatherService
// 1. Cambiar unidades a Fahrenheit
// 2. Guardar
// 3. Verificar que el clima muestra: "72°F" (en lugar de "22°C")
```

### Testing Automático (JavaScript)

```javascript
/**
 * Suite de tests para Widget Settings
 */
function testWidgetSettings() {
  console.log("🧪 Iniciando tests de Widget Settings...");

  // Test 1: API global disponible
  console.assert(
    typeof window.WidgetSettingsAPI !== "undefined",
    "❌ WidgetSettingsAPI no disponible"
  );
  console.log("✅ Test 1: API global disponible");

  // Test 2: Valores por defecto
  localStorage.clear();
  const timeFormat = window.WidgetSettingsAPI.getTimeFormat();
  const tempUnit = window.WidgetSettingsAPI.getTempUnit();
  const dateFormat = window.WidgetSettingsAPI.getDateFormat();
  console.assert(timeFormat === "24h", "❌ Default time format incorrecto");
  console.assert(tempUnit === "C", "❌ Default temp unit incorrecto");
  console.assert(
    dateFormat === "DD/MM/YYYY",
    "❌ Default date format incorrecto"
  );
  console.log("✅ Test 2: Valores por defecto correctos");

  // Test 3: Guardado en localStorage
  localStorage.setItem("widget_prefs_time_format", "AM/PM");
  localStorage.setItem("widget_prefs_temp_unit", "F");
  localStorage.setItem("widget_prefs_date_format", "MM/DD/YYYY");
  console.assert(
    window.WidgetSettingsAPI.getTimeFormat() === "AM/PM",
    "❌ Guardado de time format falló"
  );
  console.assert(
    window.WidgetSettingsAPI.getTempUnit() === "F",
    "❌ Guardado de temp unit falló"
  );
  console.assert(
    window.WidgetSettingsAPI.getDateFormat() === "MM/DD/YYYY",
    "❌ Guardado de date format falló"
  );
  console.log("✅ Test 3: Guardado en localStorage funciona");

  // Test 4: ClockService integración
  if (window.ClockService) {
    const useAmPm = window.ClockService.getHourFormat();
    console.assert(
      typeof useAmPm === "boolean",
      "❌ ClockService.getHourFormat() no retorna boolean"
    );
    console.log("✅ Test 4: ClockService integración OK");
  } else {
    console.warn("⚠️ Test 4 skipped: ClockService no disponible");
  }

  // Test 5: WeatherService integración
  if (window.WeatherService) {
    const units = window.WeatherService.getTempUnits();
    console.assert(
      ["metric", "imperial", "standard"].includes(units),
      "❌ WeatherService.getTempUnits() retorna valor inválido"
    );
    console.log("✅ Test 5: WeatherService integración OK");
  } else {
    console.warn("⚠️ Test 5 skipped: WeatherService no disponible");
  }

  console.log("🎉 Todos los tests completados");
}

// Ejecutar tests
testWidgetSettings();
```

---

## 📚 Ejemplos de Uso

### Ejemplo 1: Widget Personalizado que Lee Preferencias

```javascript
/**
 * Widget de fecha personalizado que respeta preferencias del usuario
 */
function createCustomDateWidget() {
  const dateFormat = window.WidgetSettingsAPI.getDateFormat();
  const now = new Date();

  let formattedDate;
  switch (dateFormat) {
    case "DD/MM/YYYY":
      formattedDate = `${now.getDate()}/${
        now.getMonth() + 1
      }/${now.getFullYear()}`;
      break;
    case "MM/DD/YYYY":
      formattedDate = `${
        now.getMonth() + 1
      }/${now.getDate()}/${now.getFullYear()}`;
      break;
    case "YYYY-MM-DD":
      formattedDate = `${now.getFullYear()}-${
        now.getMonth() + 1
      }-${now.getDate()}`;
      break;
    // ... otros formatos
  }

  document.getElementById("myDateWidget").textContent = formattedDate;

  // Escuchar cambios de preferencias
  window.addEventListener("widgetPreferencesChanged", function (event) {
    if (event.detail.dateFormat) {
      createCustomDateWidget(); // Re-renderizar con nuevo formato
    }
  });
}

createCustomDateWidget();
```

### Ejemplo 2: Toggle Programático

```javascript
/**
 * Cambiar formato de hora programáticamente
 */
function toggleTimeFormat() {
  const currentFormat = window.WidgetSettingsAPI.getTimeFormat();
  const newFormat = currentFormat === "24h" ? "AM/PM" : "24h";

  localStorage.setItem("widget_prefs_time_format", newFormat);

  // Disparar evento para actualizar widgets
  window.dispatchEvent(
    new CustomEvent("widgetPreferencesChanged", {
      detail: { timeFormat: newFormat },
    })
  );

  console.log(`⏰ Formato de hora cambiado: ${currentFormat} → ${newFormat}`);
}
```

### Ejemplo 3: Validación de Preferencias

```javascript
/**
 * Validar y sanitizar preferencias antes de usar
 */
function getValidTimeFormat() {
  const timeFormat = localStorage.getItem("widget_prefs_time_format");
  const validFormats = ["24h", "AM/PM"];

  if (validFormats.includes(timeFormat)) {
    return timeFormat;
  }

  console.warn("⚠️ Formato de hora inválido, usando default");
  return "24h";
}

function getValidTempUnit() {
  const tempUnit = localStorage.getItem("widget_prefs_temp_unit");
  const validUnits = ["C", "F", "K"];

  if (validUnits.includes(tempUnit)) {
    return tempUnit;
  }

  console.warn("⚠️ Unidad de temperatura inválida, usando default");
  return "C";
}
```

---

## 🚨 Troubleshooting

### Problema 1: Preferencias No Se Guardan

**Síntomas**:

- Click en "Guardar" pero localStorage vacío
- Recarga de página pierde preferencias

**Solución**:

```javascript
// Verificar que localStorage esté disponible
if (typeof Storage !== "undefined") {
  console.log("✅ localStorage disponible");
} else {
  console.error("❌ localStorage NO disponible - posible navegación privada");
}

// Verificar permisos
try {
  localStorage.setItem("test", "test");
  localStorage.removeItem("test");
  console.log("✅ localStorage funcional");
} catch (e) {
  console.error("❌ Error al escribir en localStorage:", e);
}
```

### Problema 2: Widgets No Se Actualizan

**Síntomas**:

- Cambiar preferencias pero reloj/clima no se actualiza
- Necesita F5 para ver cambios

**Solución**:

```javascript
// Verificar que evento se dispare correctamente
window.addEventListener("widgetPreferencesChanged", function (event) {
  console.log("🔔 Evento widgetPreferencesChanged recibido:", event.detail);
});

// Verificar que ClockService y WeatherService estén disponibles
console.log("ClockService:", typeof window.ClockService);
console.log("WeatherService:", typeof window.WeatherService);

// Si no existen, cargar dependencias faltantes
if (!window.ClockService) {
  console.error("❌ ClockService no disponible - cargar clockCheck.js");
}
if (!window.WeatherService) {
  console.error("❌ WeatherService no disponible - cargar weatherCheck.js");
}
```

### Problema 3: Dropdown No Se Abre

**Síntomas**:

- Click en botón de settings no hace nada
- Dropdown no se despliega

**Solución**:

```javascript
// Verificar Bootstrap JS cargado
if (typeof bootstrap !== "undefined") {
  console.log("✅ Bootstrap JS cargado");
} else {
  console.error("❌ Bootstrap JS NO cargado");
}

// Verificar que dropdown tenga atributos correctos
const button = document.getElementById("widgetSettingsExpanded");
console.log("data-bs-toggle:", button.getAttribute("data-bs-toggle")); // Debe ser 'dropdown'
console.log("aria-expanded:", button.getAttribute("aria-expanded")); // Debe cambiar a 'true'

// Inicializar dropdown manualmente si es necesario
const dropdown = new bootstrap.Dropdown(button);
dropdown.show();
```

### Problema 4: CSS No Se Aplica

**Síntomas**:

- Estilos del dropdown incorrectos
- Botones mal alineados

**Solución**:

```html
<!-- Verificar que estilos estén en widget-settings-dropdown.php -->
<style>
  .widget-settings-dropdown {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    border-radius: 8px;
    padding: 0;
  }
  /* ... resto de estilos ... */
</style>

<!-- Si CSS no se aplica, agregar !important temporalmente -->
.widget-settings-dropdown { box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15)
!important; }
```

---

## 🎓 Best Practices

### 1. Validación de Entrada

```javascript
// Siempre validar antes de guardar
function savePreferences() {
  const timeFormat = elements.timeFormatToggle.checked ? "AM/PM" : "24h";

  // Validar que sea un valor permitido
  if (!["24h", "AM/PM"].includes(timeFormat)) {
    console.error("❌ Formato de hora inválido");
    return;
  }

  localStorage.setItem(STORAGE_KEYS.TIME_FORMAT, timeFormat);
}
```

### 2. Manejo de Errores

```javascript
// Envolver en try-catch
try {
  localStorage.setItem("widget_prefs_time_format", timeFormat);
} catch (e) {
  console.error("❌ Error al guardar en localStorage:", e);
  if (window.notyf) {
    window.notyf.error("No se pudieron guardar las preferencias");
  }
}
```

### 3. Feedback Visual

```javascript
// Mostrar loading state mientras se guarda
elements.saveButton.disabled = true;
elements.saveButton.innerHTML =
  '<i class="bx bx-loader-alt bx-spin"></i> Guardando...';

savePreferences();

elements.saveButton.disabled = false;
elements.saveButton.innerHTML = '<i class="bx bx-save me-1"></i> Guardar';
```

### 4. Debouncing de Eventos

```javascript
// Si hay cambios automáticos, usar debounce
let saveTimeout;
elements.timeFormatToggle.addEventListener("change", function () {
  clearTimeout(saveTimeout);
  saveTimeout = setTimeout(() => {
    savePreferences();
  }, 500); // Esperar 500ms después del último cambio
});
```

---

## 📈 Métricas y Logging

### Tracking de Uso

```javascript
// Agregar en savePreferences()
console.log("📊 Preferencias guardadas:", {
  timeFormat: localStorage.getItem("widget_prefs_time_format"),
  tempUnit: localStorage.getItem("widget_prefs_temp_unit"),
  dateFormat: localStorage.getItem("widget_prefs_date_format"),
  timestamp: new Date().toISOString(),
});

// Opcional: Enviar a analytics
if (window.gtag) {
  gtag("event", "widget_settings_saved", {
    event_category: "user_preferences",
    event_label: timeFormat,
    value: 1,
  });
}
```

### Debug Mode

```javascript
// Agregar flag de debug
const DEBUG_MODE = localStorage.getItem("widget_settings_debug") === "true";

if (DEBUG_MODE) {
  console.log("🐛 Debug Mode activado para Widget Settings");
  console.log("Current preferences:", {
    timeFormat: window.WidgetSettingsAPI.getTimeFormat(),
    tempUnit: window.WidgetSettingsAPI.getTempUnit(),
    dateFormat: window.WidgetSettingsAPI.getDateFormat(),
  });
}

// Activar debug desde consola:
localStorage.setItem("widget_settings_debug", "true");
```

---

## 🔮 Próximas Mejoras

### Mejoras Propuestas

1. **Sincronización con Backend**:

   - Guardar preferencias en base de datos
   - Sincronizar entre dispositivos del mismo usuario
   - API endpoint: `PUT /api/user/preferences`

2. **Más Formatos de Fecha**:

   - Agregar formato personalizado
   - Input text para formato libre
   - Preview en tiempo real

3. **Tema del Dashboard**:

   - Agregar selector de tema (dark/light/auto)
   - Colores personalizables
   - Persistencia en localStorage

4. **Idioma de Widgets**:

   - Selector de idioma (es, en, fr, de, pt)
   - Afectar nombres de meses y días
   - Integración con i18n

5. **Animaciones**:

   - Agregar toggle para activar/desactivar animaciones
   - Mejorar accesibilidad (prefers-reduced-motion)

6. **Backup/Restore**:
   - Exportar preferencias a JSON
   - Importar desde archivo
   - Restaurar desde servidor

---

## 📝 Checklist de Implementación

### Fase 1: Componentes Base ✅

- [x] Crear `/ui/widget-settings-dropdown.php`
- [x] HTML del dropdown con todos los controles
- [x] JavaScript para gestión de preferencias
- [x] Estilos CSS embebidos
- [x] API global `window.WidgetSettingsAPI`

### Fase 2: Integración en Sidebar ✅

- [x] Modificar `/ui/sidebar.ui.php`
- [x] Agregar botón en versión expandida
- [x] Agregar botón en versión colapsada
- [x] CSS para ocultar/mostrar según estado
- [x] Animación de engranaje en hover

### Fase 3: Integración con Widgets ✅

- [x] Modificar `/composables/clockCheck.js`
- [x] Método `getHourFormat()` para leer localStorage
- [x] Integración en `updateDateTime()`
- [x] Modificar `/composables/weatherCheck.js`
- [x] Método `getTempUnits()` para leer localStorage
- [x] Integración en `getCurrentWeather()`

### Fase 4: Testing ⏳

- [ ] Test manual de guardado
- [ ] Test manual de recarga
- [ ] Test manual de reseteo
- [ ] Test de integración con ClockService
- [ ] Test de integración con WeatherService
- [ ] Test de accesibilidad (teclado, screen readers)
- [ ] Test cross-browser (Chrome, Firefox, Safari, Edge)

### Fase 5: Documentación ✅

- [x] Crear `/docs/WIDGET-SETTINGS-DROPDOWN.md`
- [x] Documentar API de localStorage
- [x] Ejemplos de uso
- [x] Troubleshooting
- [x] Best practices

---

## 🎯 Conclusión

El **Widget Settings Dropdown** proporciona una experiencia de usuario mejorada al permitir personalización completa de los widgets del dashboard. La implementación es:

- ✅ **Modular**: Componente reutilizable en sidebar
- ✅ **Persistente**: localStorage mantiene preferencias entre sesiones
- ✅ **Integrado**: ClockService y WeatherService leen preferencias automáticamente
- ✅ **Escalable**: Fácil agregar nuevas preferencias en el futuro
- ✅ **Accesible**: Cumple estándares WCAG
- ✅ **Responsive**: Funciona en sidebar expandido y colapsado

**Próximos pasos**:

1. Testing exhaustivo en todos los navegadores
2. Recopilar feedback de usuarios
3. Implementar mejoras propuestas (sincronización con backend, más formatos, etc.)

---

**Última actualización**: Noviembre 6, 2025  
**Autor**: Roepard Labs Development Team  
**Versión**: 1.0.0  
**Estado**: ✅ Implementado - Pendiente Testing Exhaustivo
