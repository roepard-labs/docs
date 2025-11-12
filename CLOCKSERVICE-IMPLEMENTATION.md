# 🕐 ClockService - Servicio de Reloj Centralizado

## 📋 Resumen

Se ha extraído la lógica del widget de reloj de `navbar.ui.php` a un servicio centralizado y reutilizable en `clockCheck.js`, siguiendo el mismo patrón arquitectónico que `weatherCheck.js` y `statusCheck.js`.

---

## 🎯 Objetivo

Crear un servicio modular y reutilizable para gestionar la visualización de fecha y hora en tiempo real, eliminando código duplicado y facilitando su uso en diferentes componentes del sistema.

---

## 📁 Archivos Modificados

### 1. `/composables/clockCheck.js` - **NUEVO SERVICIO**

**Características principales:**

```javascript
// Configuración centralizada
const CLOCK_CONFIG = {
  DATE_OPTIONS: {
    weekday: "short",
    day: "numeric",
    month: "short",
    year: "numeric",
  },
  TIME_OPTIONS: {
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
    hour12: false,
  },
  LOCALE: "es-ES",
  UPDATE_INTERVAL: 1000, // 1 segundo
};
```

**Clase ClockService:**

- ✅ `start()` - Inicia actualización automática cada segundo
- ✅ `stop()` - Detiene actualización automática
- ✅ `getCurrentDateTime()` - Obtiene fecha/hora actual sin auto-actualización
- ✅ `formatDate(date)` - Formatea cualquier fecha
- ✅ `updateConfig(newConfig)` - Actualiza configuración en tiempo real
- ✅ `getStatus()` - Obtiene estado del servicio

**Sistema de Eventos:**

```javascript
// Evento disparado cada segundo
window.addEventListener("clockUpdated", function (event) {
  const { date, time, timestamp } = event.detail;
  console.log("Nueva hora:", date, time);
});
```

**Helpers Globales:**

```javascript
// Funciones de utilidad
window.getCurrentDateTime(); // Obtiene fecha/hora actual
window.formatDateTime(new Date()); // Formatea fecha específica
window.ClockService.start(); // Inicia servicio
window.ClockService.stop(); // Detiene servicio
```

### 2. `/ui/navbar.ui.php` - Simplificado

**❌ ANTES** (lógica inline):

```javascript
function updateDateTime() {
  const now = new Date();
  const dateOptions = {
    weekday: "short",
    day: "numeric",
    month: "short",
    year: "numeric",
  };
  const dateStr = now.toLocaleDateString("es-ES", dateOptions);
  const timeStr = now.toLocaleTimeString("es-ES", {
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
  });

  const dateElement = document.getElementById("currentDate");
  const timeElement = document.getElementById("currentTime");

  if (dateElement) dateElement.textContent = dateStr;
  if (timeElement) timeElement.textContent = timeStr;
}

updateDateTime();
setInterval(updateDateTime, 1000);
```

**✅ DESPUÉS** (usando ClockService):

```html
<!-- Clock Service -->
<script src="../composables/clockCheck.js"></script>

<script>
  (function () {
    "use strict";

    // Escuchar evento de actualización del reloj
    window.addEventListener("clockUpdated", function (event) {
      const { date, time } = event.detail;

      const dateElement = document.getElementById("currentDate");
      const timeElement = document.getElementById("currentTime");

      if (dateElement) dateElement.textContent = date;
      if (timeElement) timeElement.textContent = time;
    });

    // Inicialización inmediata con datos actuales
    document.addEventListener("DOMContentLoaded", function () {
      const currentDateTime = window.ClockService.getCurrentDateTime();

      const dateElement = document.getElementById("currentDate");
      const timeElement = document.getElementById("currentTime");

      if (dateElement) dateElement.textContent = currentDateTime.date;
      if (timeElement) timeElement.textContent = currentDateTime.time;
    });
  })();
</script>
```

**Beneficios de la refactorización:**

- ✅ Código más limpio y modular
- ✅ Lógica centralizada y reutilizable
- ✅ Sistema de eventos para reactividad
- ✅ Fácil de mantener y testear
- ✅ Consistencia con otros servicios (weather, status)

### 3. `/layout/AppLayout.php` - Carga Automática

Se agregó la carga automática de `clockCheck.js` en el orden correcto:

```php
<!-- Backend Status Check -->
<script src="/composables/statusCheck.js"></script>

<!-- Clock Service (Date & Time) -->
<script src="/composables/clockCheck.js"></script>

<!-- Session & Role Services -->
<script src="/composables/sessionCheck.js"></script>
<script src="/composables/roleCheck.js"></script>
<script src="/services/logoutService.js"></script>
```

**Ventajas:**

- ✅ Carga automática en todas las vistas que usen AppLayout
- ✅ Disponible globalmente como `window.ClockService`
- ✅ Auto-inicio cuando el DOM está listo
- ✅ Orden de carga correcto (después de statusCheck, antes de session)

---

## 🚀 Uso del Servicio

### Uso Básico (Auto-Inicio)

El servicio se inicia automáticamente al cargar la página:

```javascript
// No necesitas hacer nada, el servicio ya está corriendo
// Los eventos 'clockUpdated' se disparan cada segundo
```

### Uso Avanzado

```javascript
// Obtener fecha/hora actual sin esperar al siguiente segundo
const { date, time, timestamp } = window.getCurrentDateTime();
console.log("Fecha:", date); // "Lun, 5 Nov 2025"
console.log("Hora:", time); // "14:30:45"

// Formatear una fecha específica
const birthday = new Date("2025-12-25");
const formatted = window.formatDateTime(birthday);
console.log("Navidad:", formatted.date, formatted.time);

// Detener el reloj si es necesario
window.ClockService.stop();

// Reiniciar el reloj
window.ClockService.start();

// Cambiar a formato 12 horas
window.ClockService.updateConfig({
  TIME_OPTIONS: {
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
    hour12: true,
  },
});

// Obtener estado del servicio
const status = window.ClockService.getStatus();
console.log("¿Está corriendo?", status.isRunning);
console.log("Hora actual:", status.currentDateTime);
```

### Integración en Componentes

**Ejemplo 1: Widget de Reloj Simple**

```html
<div id="simple-clock">
  <span id="time-display"></span>
</div>

<script>
  window.addEventListener("clockUpdated", function (event) {
    document.getElementById("time-display").textContent = event.detail.time;
  });
</script>
```

**Ejemplo 2: Badge con Timestamp**

```html
<span class="badge bg-primary" id="last-update">
  Última actualización: --:--:--
</span>

<script>
  window.addEventListener("clockUpdated", function (event) {
    const badge = document.getElementById("last-update");
    badge.textContent = `Última actualización: ${event.detail.time}`;
  });
</script>
```

**Ejemplo 3: Múltiples Formatos Simultáneos**

```html
<div class="clock-widget">
  <div id="clock-date"></div>
  <div id="clock-time"></div>
  <div id="clock-timestamp"></div>
</div>

<script>
  window.addEventListener("clockUpdated", function (event) {
    const { date, time, timestamp } = event.detail;

    document.getElementById("clock-date").textContent = date;
    document.getElementById("clock-time").textContent = time;
    document.getElementById(
      "clock-timestamp"
    ).textContent = `Unix: ${timestamp}`;
  });
</script>
```

---

## 🔄 Patrón Arquitectónico Consistente

Este servicio sigue el mismo patrón que otros servicios del sistema:

### 1. **StatusCheck.js** - Estado del Backend

```javascript
window.BackendStatus = { isConnected, message, checking };
window.addEventListener("backendStatusChanged", handler);
```

### 2. **WeatherCheck.js** - Datos Meteorológicos

```javascript
window.WeatherService = { getCurrentWeather(), getMultipleWeather() };
window.getDefaultWeather() // Helper
window.getWeather(city, country) // Helper
```

### 3. **ClockCheck.js** - Fecha y Hora (NUEVO)

```javascript
window.ClockService = { start(), stop(), getCurrentDateTime() };
window.getCurrentDateTime() // Helper
window.formatDateTime(date) // Helper
window.addEventListener('clockUpdated', handler);
```

**Consistencia en el patrón:**

- ✅ Clase principal con métodos públicos
- ✅ Instancia global en `window`
- ✅ Sistema de eventos personalizados
- ✅ Helpers globales para acceso rápido
- ✅ Configuración centralizada
- ✅ Auto-documentación con logs
- ✅ Ejemplos de uso en comentarios

---

## 📊 Comparativa: Antes vs Después

### Código en navbar.ui.php

| Métrica          | Antes      | Después    | Mejora   |
| ---------------- | ---------- | ---------- | -------- |
| Líneas de código | ~35 líneas | ~15 líneas | **-57%** |
| Lógica inline    | Sí         | No         | **✅**   |
| Reutilizable     | No         | Sí         | **✅**   |
| Testing          | Difícil    | Fácil      | **✅**   |
| Mantenibilidad   | Baja       | Alta       | **✅**   |

### Funcionalidades

| Característica            | Antes | Después |
| ------------------------- | ----- | ------- |
| Actualización automática  | ✅    | ✅      |
| Formato español           | ✅    | ✅      |
| Control start/stop        | ❌    | ✅      |
| Sistema de eventos        | ❌    | ✅      |
| Formateo de fechas custom | ❌    | ✅      |
| Cambio de configuración   | ❌    | ✅      |
| Estado del servicio       | ❌    | ✅      |
| Helpers globales          | ❌    | ✅      |

---

## 🧪 Testing

### Test Manual

```javascript
// En la consola del navegador:

// 1. Verificar que el servicio esté corriendo
console.log(window.ClockService.getStatus());
// Output: { isRunning: true, currentDateTime: {...}, config: {...} }

// 2. Obtener hora actual
console.log(window.getCurrentDateTime());
// Output: { date: "Lun, 5 Nov 2025", time: "14:30:45", timestamp: 1730822445000 }

// 3. Formatear fecha específica
console.log(window.formatDateTime("2025-01-01"));
// Output: { date: "Mié, 1 Ene 2025", time: "00:00:00", timestamp: 1735689600000 }

// 4. Escuchar eventos
window.addEventListener("clockUpdated", (e) =>
  console.log("Tick:", e.detail.time)
);
// Output cada segundo: "Tick: 14:30:46", "Tick: 14:30:47", ...

// 5. Detener y reiniciar
window.ClockService.stop(); // Los eventos dejan de dispararse
window.ClockService.start(); // Los eventos se reanudan
```

### Test de Integración

```bash
# Verificar carga correcta en el navegador
1. Abrir http://localhost:9000/dashboard
2. Abrir DevTools → Console
3. Buscar: "✅ ClockService configurado y listo para usar"
4. Verificar: widget de fecha/hora se actualiza cada segundo
5. Ejecutar: window.ClockService.getStatus()
6. Verificar: isRunning = true
```

---

## 🎨 Personalización

### Cambiar Formato de Fecha

```javascript
// Formato largo: "Lunes, 5 de Noviembre de 2025"
window.ClockService.updateConfig({
  DATE_OPTIONS: {
    weekday: "long",
    day: "numeric",
    month: "long",
    year: "numeric",
  },
});

// Formato corto: "05/11/2025"
window.ClockService.updateConfig({
  DATE_OPTIONS: {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
  },
});
```

### Cambiar Formato de Hora

```javascript
// Formato 12 horas con AM/PM
window.ClockService.updateConfig({
  TIME_OPTIONS: {
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
    hour12: true,
  },
});

// Solo hora y minutos (sin segundos)
window.ClockService.updateConfig({
  TIME_OPTIONS: {
    hour: "2-digit",
    minute: "2-digit",
  },
});
```

### Cambiar Idioma

```javascript
// Inglés
window.ClockService.updateConfig({
  LOCALE: "en-US",
});

// Francés
window.ClockService.updateConfig({
  LOCALE: "fr-FR",
});

// Portugués
window.ClockService.updateConfig({
  LOCALE: "pt-BR",
});
```

---

## 🔧 Solución de Problemas

### Problema: El reloj no se actualiza

**Verificar:**

```javascript
// ¿Está corriendo el servicio?
console.log(window.ClockService.getStatus().isRunning);

// Si no está corriendo, iniciarlo
window.ClockService.start();
```

### Problema: Los eventos no se disparan

**Verificar:**

```javascript
// Verificar que el listener esté registrado DESPUÉS de cargar clockCheck.js
document.addEventListener("DOMContentLoaded", function () {
  window.addEventListener("clockUpdated", function (event) {
    console.log("Evento recibido:", event.detail);
  });
});
```

### Problema: Formato incorrecto

**Verificar configuración:**

```javascript
const config = window.ClockService.getStatus().config;
console.log("Configuración actual:", config);

// Restaurar configuración por defecto
window.ClockService.updateConfig({
  LOCALE: "es-ES",
  DATE_OPTIONS: {
    weekday: "short",
    day: "numeric",
    month: "short",
    year: "numeric",
  },
  TIME_OPTIONS: {
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
    hour12: false,
  },
});
```

---

## 📚 Próximos Pasos Sugeridos

1. **Agregar Zona Horaria**

   - Soportar múltiples zonas horarias
   - Convertir entre zonas horarias
   - Detectar zona horaria del navegador

2. **Formateo Relativo**

   - "Hace 5 minutos"
   - "En 2 horas"
   - Integración con Day.js para fechas relativas

3. **Countdown/Timer**

   - Modo countdown para eventos
   - Timer para tareas
   - Alarmas y notificaciones

4. **Performance**
   - Optimización para múltiples instancias
   - Throttling de eventos si hay muchos listeners
   - Lazy loading si no se usa

---

## ✅ Checklist de Migración

- [x] Crear `/composables/clockCheck.js` con ClockService
- [x] Implementar clase ClockService con métodos core
- [x] Agregar sistema de eventos `clockUpdated`
- [x] Crear helpers globales `getCurrentDateTime()` y `formatDateTime()`
- [x] Migrar lógica de `navbar.ui.php` a usar ClockService
- [x] Actualizar `AppLayout.php` para cargar clockCheck.js
- [x] Probar funcionamiento en navegador
- [x] Documentar uso y ejemplos
- [ ] Testing en diferentes navegadores
- [ ] Testing en móviles
- [ ] Performance profiling

---

## 📞 Soporte

Para dudas sobre ClockService:

1. Revisar documentación en este archivo
2. Verificar logs en consola del navegador
3. Consultar ejemplos en los comentarios de `clockCheck.js`
4. Revisar implementación en `navbar.ui.php` como referencia

---

**Última actualización**: Noviembre 2025  
**Versión del servicio**: 1.0.0  
**Mantenido por**: Roepard Labs Development Team
