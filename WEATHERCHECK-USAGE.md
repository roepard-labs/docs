# weatherCheck.js - Guía de Uso

## 📋 Descripción

Servicio simple y reutilizable para integrar la API de OpenWeatherMap en cualquier página del proyecto.

## 🔧 Configuración

- **API Key**: `5f6eea57b7cbb427f5362ab9efe5bce3`
- **Ciudad por defecto**: Manizales, Colombia
- **Caché**: 10 minutos
- **Ubicación**: `/composables/weatherCheck.js`

## 📝 Uso Básico

### 1. Incluir el archivo en tu página

```html
<script src="/composables/weatherCheck.js"></script>
```

### 2. Usar las funciones globales

```javascript
// Obtener clima de Manizales (ciudad por defecto)
const weather = await getDefaultWeather();
console.log("Temperatura:", weather.main.temp + "°C");
console.log("Descripción:", weather.weather.description);

// Obtener clima de otra ciudad
const bogota = await getWeather("Bogotá", "co", {
  units: "metric",
  lang: "es",
});
console.log("Temperatura en Bogotá:", bogota.main.temp + "°C");
```

## 🔥 Ejemplos Prácticos

### Ejemplo 1: Mostrar temperatura en el header

```html
<script src="/composables/weatherCheck.js"></script>
<script>
  document.addEventListener("DOMContentLoaded", async () => {
    try {
      const weather = await getDefaultWeather();
      const tempElement = document.getElementById("current-temp");
      tempElement.textContent = `${Math.round(weather.main.temp)}°C`;
    } catch (error) {
      console.error("Error al obtener clima:", error);
    }
  });
</script>

<div id="current-temp">--°C</div>
```

### Ejemplo 2: Card de clima personalizada

```html
<div id="weather-card" class="card">
  <div class="card-body">
    <h5 class="card-title">Clima en Manizales</h5>
    <p id="temperature">Cargando...</p>
    <p id="description">--</p>
    <p id="humidity">Humedad: --%</p>
  </div>
</div>

<script src="/composables/weatherCheck.js"></script>
<script>
  document.addEventListener("DOMContentLoaded", async () => {
    const weather = await getDefaultWeather();

    document.getElementById("temperature").textContent = `${Math.round(
      weather.main.temp
    )}°C (Sensación: ${Math.round(weather.main.feels_like)}°C)`;

    document.getElementById("description").textContent =
      weather.weather.description;

    document.getElementById(
      "humidity"
    ).textContent = `Humedad: ${weather.main.humidity}%`;
  });
</script>
```

### Ejemplo 3: Comparar clima de varias ciudades

```javascript
const service = new WeatherService();

const cities = [
  { name: "Manizales", country: "co" },
  { name: "Bogotá", country: "co" },
  { name: "Medellín", country: "co" },
  { name: "Cali", country: "co" },
];

const results = await service.getMultipleWeather(cities, {
  units: "metric",
  lang: "es",
});

results.forEach((result) => {
  if (result.success) {
    const data = result.data;
    console.log(
      `${data.name}: ${data.main.temp}°C - ${data.weather.description}`
    );
  } else {
    console.error(`Error en ${result.city}:`, result.error);
  }
});
```

### Ejemplo 4: Ícono de clima dinámico

```html
<div id="weather-icon">
  <i class="bx bx-cloud"></i>
  <span id="temp-display">--°C</span>
</div>

<script src="/composables/weatherCheck.js"></script>
<script>
  async function updateWeatherIcon() {
    const weather = await getDefaultWeather();
    const icon = document.querySelector("#weather-icon i");
    const temp = document.getElementById("temp-display");

    // Mapeo de iconos OpenWeatherMap a Boxicons
    const iconMap = {
      "01d": "bx-sun", // Sol
      "01n": "bx-moon", // Luna
      "02d": "bx-cloud", // Parcialmente nublado
      "02n": "bx-cloud",
      "03d": "bx-cloud", // Nublado
      "03n": "bx-cloud",
      "09d": "bx-cloud-rain", // Lluvia
      "09n": "bx-cloud-rain",
      "10d": "bx-cloud-rain",
      "10n": "bx-cloud-rain",
      "11d": "bx-cloud-lightning", // Tormenta
      "11n": "bx-cloud-lightning",
      "13d": "bx-cloud-snow", // Nieve
      "13n": "bx-cloud-snow",
    };

    const weatherIcon = weather.weather.icon;
    icon.className = `bx ${iconMap[weatherIcon] || "bx-cloud"}`;
    temp.textContent = `${Math.round(weather.main.temp)}°C`;
  }

  document.addEventListener("DOMContentLoaded", updateWeatherIcon);
</script>
```

## 🎯 API del Servicio

### Funciones Globales

```javascript
// Obtener clima de Manizales (ciudad por defecto)
await getDefaultWeather();

// Obtener clima de ciudad específica
await getWeather(city, country, options);
// city: 'Bogotá'
// country: 'co'
// options: { units: 'metric', lang: 'es' }
```

### Clase WeatherService

```javascript
const service = new WeatherService();

// Obtener clima de una ciudad
await service.getCurrentWeather({
  city: "Medellín",
  country: "co",
  units: "metric", // 'metric' | 'imperial' | 'standard'
  lang: "es", // 'es' | 'en' | etc.
});

// Obtener clima de múltiples ciudades
await service.getMultipleWeather(
  [
    { name: "Cali", country: "co" },
    { name: "Cartagena", country: "co" },
  ],
  { units: "metric", lang: "es" }
);
```

## 📦 Estructura de Respuesta

```javascript
{
    coord: { lon: -75.4794, lat: 5.0689 },
    weather: [
        {
            id: 803,
            main: "Clouds",
            description: "nubes",
            icon: "04d"
        }
    ],
    main: {
        temp: 18.5,        // Temperatura actual
        feels_like: 17.8,  // Sensación térmica
        temp_min: 16.2,    // Temperatura mínima
        temp_max: 20.1,    // Temperatura máxima
        pressure: 1013,    // Presión atmosférica
        humidity: 72       // Humedad %
    },
    wind: {
        speed: 2.5,        // Velocidad del viento
        deg: 180           // Dirección en grados
    },
    clouds: { all: 75 },   // Nubosidad %
    dt: 1699308000,        // Timestamp
    name: "Manizales"      // Nombre de la ciudad
}
```

## 💾 Sistema de Caché

El servicio incluye caché automático de 10 minutos para reducir llamadas a la API:

```javascript
// Primera llamada: consulta la API
const weather1 = await getDefaultWeather(); // API request

// Segunda llamada (antes de 10 min): usa caché
const weather2 = await getDefaultWeather(); // Cached response

// Después de 10 minutos: consulta la API nuevamente
```

## 🔒 Seguridad

- La API key está incluida en el código frontend (archivo público)
- OpenWeatherMap permite esto para aplicaciones web
- Para mayor seguridad, considera crear un proxy backend que oculte la API key

## 🌐 Recursos

- [OpenWeatherMap API Documentation](https://openweathermap.org/api)
- [Códigos de iconos del clima](https://openweathermap.org/weather-conditions)
- [Códigos de idioma](https://openweathermap.org/current#multi)

---

**Última actualización**: Noviembre 2025  
**Versión**: 1.0  
**Mantenido por**: Roepard Labs Development Team
