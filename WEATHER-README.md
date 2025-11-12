# 🌦️ Weather API System - Quick Start

Sistema completo de integración con OpenWeatherMap API para HomeLab VR.

## 🚀 Inicio Rápido

### 1. Ver Demo Completa

```
http://localhost:9000/weather-demo
```

### 2. Usar en JavaScript (Consola)

```javascript
// Clima de Manizales (ciudad por defecto)
await getDefaultWeather();

// Clima de cualquier ciudad
await getWeather("Bogotá", "CO");
await getWeather("Paris", "FR");

// Múltiples ciudades en paralelo
await WeatherService.getMultipleWeather([
  { city: "Tokyo", country: "JP" },
  { city: "London", country: "GB" },
]);
```

### 3. Agregar Widget a tu Vista

```php
<?php
// En tu vista .view.php
$pageConfig = [
    'js' => ['../composables/weatherCheck.js']
];

ob_start();
?>

<div class="container">
    <!-- Widget de clima -->
    <?php include __DIR__ . '/../components/weather-widget.component.php'; ?>
</div>

<?php
$content = ob_get_clean();
AppLayout::render('mi-vista', ['content' => $content], $pageConfig);
?>
```

### 4. Agregar Mini-App Completa

```html
<!-- Container -->
<div id="weather-app-container"></div>

<!-- Scripts -->
<script src="../composables/weatherCheck.js"></script>
<script src="../js/weather-app.js"></script>

<!-- Inicializar -->
<script>
  document.addEventListener("DOMContentLoaded", function () {
    new WeatherApp("weather-app-container");
  });
</script>
```

## 📁 Archivos del Sistema

```
/composables/
  └── weatherCheck.js        # Servicio principal (WeatherService)

/components/
  └── weather-widget.component.php  # Widget reutilizable

/js/
  └── weather-app.js         # Mini-app completa

/views/
  └── weather-demo.view.php  # Página de demostración
```

## 🔧 Configuración

### API Key Actual

```javascript
// En weatherCheck.js
API_KEY: "5f6eea57b7cbb427f5362ab9efe5bce3";
```

### Para Producción

Mover a `.env`:

```env
OPENWEATHER_API_KEY=5f6eea57b7cbb427f5362ab9efe5bce3
```

Ejecutar:

```bash
npm run build:config
```

## 📚 Documentación Completa

Ver: `/docs/WEATHER-API-INTEGRATION.md`

## 🎯 Características

✅ Cache inteligente (10 minutos)  
✅ Multi-idioma (ES, EN, FR, DE, PT)  
✅ Unidades configurables (metric/imperial)  
✅ Widget responsive con Bootstrap 5  
✅ Mini-app con 3 vistas diferentes  
✅ Consultas paralelas optimizadas  
✅ Manejo robusto de errores

## 🌐 API Reference

### WeatherService

```javascript
// Método principal
WeatherService.getCurrentWeather({
  city: "Manizales", // Nombre ciudad
  country: "CO", // Código país (ISO 3166)
  units: "metric", // 'metric'|'imperial'|'standard'
  lang: "es", // 'es'|'en'|'fr'|'de'|'pt'
  useCache: true, // Usar cache
});

// Múltiples ciudades
WeatherService.getMultipleWeather(cities, options);

// Limpiar cache
WeatherService.clearCache();
```

### Helpers Globales

```javascript
getDefaultWeather(); // Clima de Manizales
getWeather(city, country); // Clima de cualquier ciudad
```

## 📦 Formato de Respuesta

```javascript
{
    location: { city, country, coordinates, timezone },
    weather: { main, description, icon, iconURL },
    temperature: { current, feelsLike, min, max, unit },
    atmosphere: { pressure, humidity, visibility },
    wind: { speed, direction, directionText, gust, unit },
    clouds: { all },
    rain: { '1h', '3h' },
    sun: { sunrise, sunset, sunriseTime, sunsetTime },
    metadata: { timestamp, timestampUnix }
}
```

## 🐛 Troubleshooting

**Error: "AppRouter no está disponible"**  
→ Cargar `router.js` antes de `weatherCheck.js`

**Widget no se muestra**  
→ Verificar que componente esté incluido: `<?php include ... ?>`

**Ciudad no encontrada**  
→ Verificar código de país (ISO 3166): CO, US, GB, FR, etc.

---

**Autor**: Roepard Labs  
**Versión**: 1.0.0  
**Fecha**: Noviembre 2025
