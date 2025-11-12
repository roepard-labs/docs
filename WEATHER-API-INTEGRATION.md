# 🌦️ Weather API Integration - OpenWeatherMap

## 📋 Resumen Ejecutivo

Sistema completo de integración con OpenWeatherMap API para consultar datos meteorológicos en tiempo real. Incluye servicio JavaScript reutilizable, widgets visuales y mini-aplicación completa.

---

## 🏗️ Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────┐
│                    Frontend Components                   │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Widget    │  │   Mini-App   │  │  Custom UI   │  │
│  │ Component   │  │  (Full App)  │  │   Elements   │  │
│  └──────┬──────┘  └──────┬───────┘  └──────┬───────┘  │
│         │                 │                  │          │
│         └─────────────────┼──────────────────┘          │
│                           ▼                             │
│            ┌──────────────────────────────┐             │
│            │    WeatherService Class      │             │
│            │  (weatherCheck.js)           │             │
│            │  - getCurrentWeather()       │             │
│            │  - getMultipleWeather()      │             │
│            │  - Cache Management          │             │
│            └────────────┬─────────────────┘             │
│                         │                               │
│                         ▼                               │
│            ┌──────────────────────────────┐             │
│            │    AppRouter (Axios)         │             │
│            │  (router.js)                 │             │
│            └────────────┬─────────────────┘             │
└─────────────────────────┼───────────────────────────────┘
                          │
                          ▼
           ┌──────────────────────────────┐
           │   OpenWeatherMap API         │
           │   api.openweathermap.org     │
           │   - Current Weather Data     │
           │   - City/Country Search      │
           │   - Multiple Languages       │
           └──────────────────────────────┘
```

---

## 📁 Archivos del Sistema

### 1. **weatherCheck.js** - Servicio Principal

**Ubicación**: `/composables/weatherCheck.js`

**Función**: Cliente JavaScript para consultar OpenWeatherMap API con cache inteligente.

**Características**:

- ✅ Configuración centralizada de API Key y parámetros
- ✅ Sistema de cache de 10 minutos
- ✅ Procesamiento de datos a formato amigable
- ✅ Conversión de unidades (metric/imperial/standard)
- ✅ Soporte multi-idioma (es/en/fr/de/pt)
- ✅ Consultas paralelas de múltiples ciudades
- ✅ Manejo de errores robusto

**Clase Principal**: `WeatherService`

**Métodos Públicos**:

```javascript
// Obtener clima de una ciudad
await WeatherService.getCurrentWeather({
  city: "Manizales",
  country: "CO",
  units: "metric",
  lang: "es",
  useCache: true,
});

// Obtener clima de múltiples ciudades
await WeatherService.getMultipleWeather(cities, commonOptions);

// Limpiar cache
WeatherService.clearCache();
```

**Helpers Globales**:

```javascript
// Clima de ciudad por defecto (Manizales)
await getDefaultWeather();

// Clima de cualquier ciudad
await getWeather("Bogotá", "CO");
```

### 2. **weather-widget.component.php** - Componente Widget

**Ubicación**: `/components/weather-widget.component.php`

**Función**: Widget visual reutilizable para mostrar clima de una ciudad.

**Uso en HTML**:

```html
<!-- Widget con data attributes -->
<div
  id="weather-widget"
  class="weather-widget"
  data-city="Manizales"
  data-country="CO"
  data-units="metric"
></div>

<!-- Incluir estilos y scripts del componente -->
<?php include __DIR__ . '/../components/weather-widget.component.php'; ?>
```

**Uso en JavaScript**:

```javascript
// Crear widget programáticamente
new WeatherWidget("widget-id");
```

**Características**:

- ✅ Auto-inicialización con data attributes
- ✅ Actualización automática cada 10 minutos
- ✅ Botón de refresh manual
- ✅ Estados: loading, content, error
- ✅ Diseño responsive con Bootstrap 5
- ✅ Efectos hover y animaciones

### 3. **weather-app.js** - Mini-Aplicación Completa

**Ubicación**: `/js/weather-app.js`

**Función**: Aplicación completa con múltiples vistas y gestión de ciudades.

**Uso**:

```javascript
// Inicializar aplicación en un container
const app = new WeatherApp("container-id");
```

**Vistas Disponibles**:

1. **Cards View**: Tarjetas con degradado de color según clima
2. **Table View**: Tabla con todos los datos
3. **Compact View**: Lista compacta con info esencial

**Características**:

- ✅ 6 ciudades de Colombia por defecto
- ✅ Agregar ciudades dinámicamente
- ✅ Toggle entre vistas
- ✅ Refresh masivo
- ✅ Colores dinámicos según clima
- ✅ Responsive design

### 4. **weather-demo.view.php** - Página de Demostración

**Ubicación**: `/views/weather-demo.view.php`

**Función**: Vista completa mostrando todas las capacidades del sistema.

**Secciones**:

1. Hero con información del sistema
2. Widgets de 3 ciudades (Manizales, Bogotá, Medellín)
3. Mini-app completa
4. Ejemplos de código
5. Características destacadas
6. Pruebas en consola

**Ruta**: `/weather-demo`

---

## 🔧 Configuración

### API Key de OpenWeatherMap

**Actual** (en `weatherCheck.js`):

```javascript
const WEATHER_CONFIG = {
  API_KEY: "5f6eea57b7cbb427f5362ab9efe5bce3",
  // ...
};
```

**Recomendación para Producción**:
Mover a `.env` y generar con `npm run build:config`:

```env
# En .env
OPENWEATHER_API_KEY=5f6eea57b7cbb427f5362ab9efe5bce3
```

```javascript
// En config.js (generado)
window.ENV_CONFIG = {
  API_URL: "http://localhost:3000",
  BACKEND_URL: "http://localhost:3000",
  OPENWEATHER_API_KEY: "5f6eea57b7cbb427f5362ab9efe5bce3",
};
```

### Variables Configurables

```javascript
const WEATHER_CONFIG = {
  API_KEY: "...", // API Key
  BASE_URL: "https://api.openweathermap.org/data/2.5",
  DEFAULT_CITY: "Manizales", // Ciudad por defecto
  DEFAULT_COUNTRY: "CO", // País por defecto
  CACHE_DURATION: 10 * 60 * 1000, // Cache de 10 minutos
};
```

---

## 📊 Formato de Datos

### Datos Procesados

El servicio procesa los datos crudos de la API a un formato estructurado:

```javascript
{
    // Ubicación
    location: {
        city: 'Manizales',
        country: 'CO',
        coordinates: { lat: 5.0689, lon: -75.5174 },
        timezone: -18000  // Offset en segundos
    },

    // Clima actual
    weather: {
        main: 'Rain',                    // Tipo de clima
        description: 'lluvia ligera',    // Descripción localizada
        icon: '10n',                     // Código de icono
        iconURL: 'https://...',          // URL del icono
        id: 500                          // ID del clima
    },

    // Temperatura
    temperature: {
        current: 10.02,                  // Temperatura actual
        feelsLike: 9.14,                 // Sensación térmica
        min: 10.00,                      // Mínima
        max: 13.26,                      // Máxima
        unit: '°C'                       // Unidad
    },

    // Atmósfera
    atmosphere: {
        pressure: 1019,                  // Presión (hPa)
        humidity: 79,                    // Humedad (%)
        visibility: 10000,               // Visibilidad (metros)
        seaLevel: 1019,                  // Presión nivel del mar
        groundLevel: 798                 // Presión a nivel del suelo
    },

    // Viento
    wind: {
        speed: 1.34,                     // Velocidad
        direction: 300,                  // Dirección (grados)
        directionText: 'NW',             // Dirección cardinal
        gust: 0,                         // Ráfagas
        unit: 'm/s'                      // Unidad
    },

    // Nubes
    clouds: {
        all: 100                         // Cobertura (%)
    },

    // Lluvia (si existe)
    rain: {
        '1h': 0.49,                      // mm última hora
        '3h': 0                          // mm últimas 3 horas
    },

    // Nieve (si existe)
    snow: {
        '1h': 0,
        '3h': 0
    },

    // Sol
    sun: {
        sunrise: Date,                   // Objeto Date
        sunset: Date,                    // Objeto Date
        sunriseTime: '05:54',           // HH:MM
        sunsetTime: '17:50'             // HH:MM
    },

    // Metadata
    metadata: {
        timestamp: Date,                 // Fecha de consulta
        timestampUnix: 1762390893,      // Unix timestamp
        base: 'stations'                // Base de datos
    },

    // Datos originales (por si acaso)
    _raw: { /* datos completos de la API */ }
}
```

---

## 💻 Ejemplos de Uso

### Ejemplo 1: Uso Básico

```javascript
// Obtener clima de ciudad por defecto (Manizales)
const weather = await getDefaultWeather();
console.log(
  `${weather.location.city}: ${weather.temperature.current}${weather.temperature.unit}`
);

// Obtener clima de otra ciudad
const bogota = await getWeather("Bogotá", "CO");
console.log(bogota.weather.description);
```

### Ejemplo 2: Opciones Avanzadas

```javascript
// Con todas las opciones
const paris = await WeatherService.getCurrentWeather({
  city: "Paris",
  country: "FR",
  units: "metric", // 'metric' | 'imperial' | 'standard'
  lang: "es", // 'es' | 'en' | 'fr' | 'de' | 'pt'
  useCache: false, // Forzar consulta nueva
});

console.log("Temperatura:", paris.temperature.current);
console.log("Humedad:", paris.atmosphere.humidity + "%");
console.log("Viento:", paris.wind.speed, paris.wind.unit);
```

### Ejemplo 3: Múltiples Ciudades

```javascript
// Consultar varias ciudades en paralelo
const cities = [
  { city: "Manizales", country: "CO" },
  { city: "Bogotá", country: "CO" },
  { city: "Medellín", country: "CO" },
  { city: "Cali", country: "CO" },
];

const results = await WeatherService.getMultipleWeather(cities, {
  units: "metric",
  lang: "es",
});

results.forEach((data) => {
  console.log(
    `${data.location.city}: ${Math.round(data.temperature.current)}°C - ${
      data.weather.description
    }`
  );
});
```

### Ejemplo 4: Widget en HTML

```html
<!-- Incluir dependencias -->
<script src="../composables/router.js"></script>
<script src="../composables/weatherCheck.js"></script>

<!-- Widget HTML -->
<div
  id="my-weather-widget"
  class="weather-widget"
  data-city="Tokyo"
  data-country="JP"
  data-units="metric"
></div>

<!-- Incluir componente con estilos -->
<?php include __DIR__ . '/../components/weather-widget.component.php'; ?>

<!-- Inicializar -->
<script>
  document.addEventListener("DOMContentLoaded", function () {
    new WeatherWidget("my-weather-widget");
  });
</script>
```

### Ejemplo 5: Mini-App

```html
<!-- Container para la app -->
<div id="weather-app-container"></div>

<!-- Incluir scripts -->
<script src="../composables/router.js"></script>
<script src="../composables/weatherCheck.js"></script>
<script src="../js/weather-app.js"></script>

<!-- Inicializar app -->
<script>
  document.addEventListener("DOMContentLoaded", function () {
    const app = new WeatherApp("weather-app-container");
  });
</script>
```

---

## 🎨 Personalización

### Colores del Widget

```css
/* En components/weather-widget.component.php */
.weather-widget {
  background: linear-gradient(
    135deg,
    var(--bs-primary) 0%,
    var(--bs-info) 100%
  );
}

/* Personalizar colores */
.weather-widget.custom-theme {
  background: linear-gradient(135deg, #ff6b6b 0%, #4ecdc4 100%);
}
```

### Configuración de la Mini-App

```javascript
// En weather-app.js
const WEATHER_APP_CONFIG = {
  // Agregar/quitar ciudades
  cities: [
    { city: "Miami", country: "US", displayName: "Miami" },
    { city: "London", country: "GB", displayName: "Londres" },
  ],

  // Vista por defecto
  defaultView: "cards", // 'cards' | 'table' | 'compact'

  // Colores según clima
  weatherColors: {
    Clear: "#FFD700",
    Rain: "#4682B4",
    Clouds: "#B0C4DE",
  },
};
```

---

## 🚀 Integración en Nuevas Vistas

### Patrón para Agregar Widget a Vista

```php
<?php
// En cualquier vista .view.php
require_once __DIR__ . '/../layout/AppLayout.php';

$pageConfig = [
    'title' => 'Mi Vista con Clima',
    'js' => [
        '../composables/weatherCheck.js'  // ← Incluir servicio
    ]
];

ob_start();
?>

<section class="py-5">
    <div class="container">
        <h1>Mi Página</h1>

        <!-- Widget de clima -->
        <div class="row mt-4">
            <div class="col-md-6">
                <?php include __DIR__ . '/../components/weather-widget.component.php'; ?>
            </div>
        </div>
    </div>
</section>

<?php
$content = ob_get_clean();
AppLayout::render('mi-vista', ['content' => $content], $pageConfig);
?>
```

### Registrar Ruta

```php
// En /index.php
$routes = [
    // ... rutas existentes ...
    '/weather-demo' => 'weather-demo.view.php'
];
```

---

## 🧪 Testing

### Pruebas en Consola del Navegador

1. Abrir `/weather-demo` en el navegador
2. Abrir DevTools (F12) → Consola
3. Ejecutar comandos:

```javascript
// Test 1: Ciudad por defecto
await getDefaultWeather();

// Test 2: Ciudad específica
await getWeather("Paris", "FR");

// Test 3: Múltiples ciudades
await WeatherService.getMultipleWeather([
  { city: "Tokyo", country: "JP" },
  { city: "New York", country: "US" },
  { city: "Sydney", country: "AU" },
]);

// Test 4: Limpiar cache
WeatherService.clearCache();

// Test 5: Verificar cache
const data1 = await getWeather("London", "GB"); // Consulta a API
const data2 = await getWeather("London", "GB"); // Desde cache
```

### Verificar Funcionamiento

**Checklist**:

- [ ] WeatherService se inicializa correctamente
- [ ] Widgets cargan datos al iniciar
- [ ] Mini-app muestra 6 ciudades de Colombia
- [ ] Botón refresh actualiza datos
- [ ] Cache funciona (segunda consulta es instantánea)
- [ ] Error handling funciona (ciudad inexistente)
- [ ] Responsive en móvil

---

## 📚 Referencias

### OpenWeatherMap API Documentation

- **Current Weather**: https://openweathermap.org/current
- **Weather Conditions**: https://openweathermap.org/weather-conditions
- **Weather Icons**: https://openweathermap.org/weather-conditions#Icon-list
- **API Keys**: https://home.openweathermap.org/api_keys

### Códigos de País (ISO 3166)

- `CO` - Colombia
- `US` - United States
- `GB` - United Kingdom
- `FR` - France
- `ES` - Spain
- `DE` - Germany
- [Lista completa](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2)

### Códigos de Idioma

- `es` - Español
- `en` - English
- `fr` - Français
- `de` - Deutsch
- `pt` - Português

---

## 🔒 Seguridad

### Protección de API Key

**⚠️ IMPORTANTE**: En producción, proteger la API Key:

1. **Mover a .env**:

```env
OPENWEATHER_API_KEY=tu_api_key_aqui
```

2. **Generar config.js**:

```bash
npm run build:config
```

3. **Usar en JavaScript**:

```javascript
const API_KEY = window.ENV_CONFIG.OPENWEATHER_API_KEY;
```

### Rate Limiting

OpenWeatherMap free tier permite:

- ✅ 60 llamadas por minuto
- ✅ 1,000,000 llamadas por mes

**Sistema de cache** reduce llamadas significativamente:

- Cache de 10 minutos
- 1 consulta cada 10 min por ciudad

---

## 🐛 Troubleshooting

### Error: "AppRouter no está disponible"

**Solución**: Verificar orden de carga de scripts:

```html
<!-- 1. PRIMERO: router.js -->
<script src="../composables/router.js"></script>

<!-- 2. SEGUNDO: weatherCheck.js -->
<script src="../composables/weatherCheck.js"></script>
```

### Error: "Failed to fetch"

**Causas**:

1. API Key inválido
2. Ciudad no encontrada
3. Problema de red

**Solución**:

```javascript
try {
  const data = await getWeather("InvalidCity", "XX");
} catch (error) {
  console.error("Error:", error.message);
}
```

### Widget no se muestra

**Verificar**:

1. ✅ `id` único en el elemento
2. ✅ Clase `weather-widget` presente
3. ✅ Componente incluido con `<?php include ... ?>`
4. ✅ Scripts cargados correctamente

---

## 🎯 Roadmap

### Mejoras Futuras

- [ ] Pronóstico de 5 días
- [ ] Gráficos de temperatura histórica
- [ ] Alertas meteorológicas
- [ ] Geolocalización automática
- [ ] PWA offline support
- [ ] WebSockets para updates en tiempo real

---

**Última actualización**: Noviembre 2025  
**Versión**: 1.0.0  
**Mantenido por**: Roepard Labs Development Team
