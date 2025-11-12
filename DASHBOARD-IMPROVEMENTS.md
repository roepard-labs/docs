# 📊 Dashboard Mejorado - HomeLab AR

## 🎯 Cambios Implementados

### Frontend (`/views/dashboard.view.php`)

#### 1. **Welcome Section Dividida**

- ✅ Dividida en dos columnas (50% cada una)
- ✅ Lado izquierdo: Bienvenida con nombre de usuario
- ✅ Lado derecho: Información de sesión actual (dispositivo, navegador, IP, inicio)

#### 2. **Estadísticas Reales desde Backend**

- ✅ **Total Usuarios**: Muestra total de usuarios del sistema (solo admin)
- ✅ **Sesiones Activas**: Sesiones activas del sistema o del usuario actual
- ✅ **Archivos**: Total de archivos en el sistema o del usuario
- ✅ **Logins (7 días)**: Logins de la última semana (solo admin)

#### 3. **Gráficas con Chart.js**

- ✅ **Sesiones por Día**: Gráfica de línea con sesiones de los últimos 7 días
- ✅ **Distribución por Rol**: Gráfica de dona con usuarios por rol

#### 4. **Acciones Rápidas Actualizadas**

- ✅ **Gestionar Usuarios**: `/dashboard/users`
- ✅ **Configuración**: `/dashboard/settings`
- ✅ **HomeLab VR**: `/homelab` (agregado al routing)
- ✅ **Página Principal**: `/`

#### 5. **Información del Sistema Mejorada**

- ✅ Verificación de backend con `/routes/web/status.php`
- ✅ Botón de diagnóstico del sistema
- ✅ Modal de diagnóstico completo
- ✅ Eliminadas verificaciones obsoletas (Base de Datos, API Backend)

#### 6. **Modal de Diagnóstico**

- ✅ Botón pequeño "Diagnóstico del Sistema"
- ✅ Modal con acordeón de componentes
- ✅ Colores según estado (success, warning, danger)
- ✅ Detalles expandibles por componente
- ✅ Botón de actualizar diagnóstico

### Backend

#### 1. **API de Estadísticas** (`/routes/dashboard/stats.php`)

**Endpoint**: `GET /routes/dashboard/stats.php`

**Respuesta**:

```json
{
  "status": "success",
  "data": {
    "stats": {
      "users": {
        "total": 150,
        "active": 142,
        "inactive": 8,
        "admins": 2
      },
      "sessions": {
        "total": 45,
        "active": 23,
        "user_sessions": 2
      },
      "storage": {
        "total_files": 1250,
        "total_size": 52428800,
        "user_files": 42,
        "user_size": 10485760
      },
      "activity": {
        "logins_today": 15,
        "logins_week": 87,
        "logins_month": 312
      }
    },
    "charts": {
      "users_by_role": [
        { "role_name": "user", "count": 148 },
        { "role_name": "admin", "count": 2 }
      ],
      "sessions_by_day": [
        { "date": "2025-11-01", "count": 12 },
        { "date": "2025-11-02", "count": 15 }
      ],
      "storage_by_user": [
        { "first_name": "Juan", "last_name": "Pérez", "total_size": 10485760 }
      ]
    },
    "role_id": 2
  }
}
```

**Características**:

- ✅ Estadísticas diferenciadas por rol (admin vs usuario normal)
- ✅ Datos para gráficas Chart.js
- ✅ Consultas optimizadas con SQL agregado
- ✅ Manejo de tablas opcionales (user_files)

#### 2. **API de Diagnóstico** (`/routes/dashboard/diagnostic.php`)

**Endpoint**: `GET /routes/dashboard/diagnostic.php`

**Respuesta**:

```json
{
  "status": "success",
  "data": {
    "overall_status": "healthy",
    "timestamp": "2025-11-06 20:30:00",
    "components": {
      "database": {
        "status": "healthy",
        "message": "Conexión a base de datos OK",
        "details": {
          "host": "localhost",
          "database": "homelab_db"
        }
      },
      "sessions": {
        "status": "healthy",
        "message": "Sistema de sesiones activo",
        "details": {
          "session_id": "abc123...",
          "save_path": "/tmp"
        }
      },
      "tables": {
        "status": "healthy",
        "message": "Todas las tablas requeridas existen",
        "details": {
          "tables": ["users", "roles", "status", "user_sessions"]
        }
      },
      "filesystem": {
        "status": "healthy",
        "message": "Permisos de archivos OK",
        "details": {
          "uploads": { "exists": true, "writable": true },
          "logs": { "exists": true, "writable": true }
        }
      },
      "php_extensions": {
        "status": "healthy",
        "message": "Todas las extensiones PHP están cargadas",
        "details": {
          "extensions": ["pdo", "pdo_mysql", "mbstring", "curl", "json"]
        }
      },
      "environment": {
        "status": "healthy",
        "message": "Variables de entorno configuradas",
        "details": {
          "required_vars": ["DB_HOST", "DB_DATABASE", "DB_USERNAME"]
        }
      },
      "system": {
        "status": "healthy",
        "message": "Información del sistema",
        "details": {
          "php_version": "8.4.0",
          "memory_limit": "256M",
          "upload_max_filesize": "50M"
        }
      }
    }
  }
}
```

**Características**:

- ✅ Verificación completa de componentes del sistema
- ✅ Estados: healthy, warning, degraded, error, critical
- ✅ Detalles expandibles por componente
- ✅ Verificación de base de datos, sesiones, tablas, permisos, extensiones PHP
- ✅ Overall status global del sistema

#### 3. **Status Endpoint** (`/routes/web/status.php`)

**Endpoint**: `GET /routes/web/status.php` (ya existía)

**Respuesta**:

```json
{
  "status": "success",
  "message": "API is running",
  "timestamp": "2025-11-06 20:26:25"
}
```

### Routing

#### Ruta Agregada

- ✅ `/homelab` → `homelab.view.php` (HomeLab VR Experience)

### Archivos Modificados

```
thepearlo_vr-website/
├── views/dashboard.view.php          ✅ Modificado (UI + JavaScript)
├── index.php                         ✅ Modificado (agregado /homelab)
└── composables/dashboardCheck.js     ✅ Creado (funciones auxiliares)

thepearlo_vr-backend/
├── routes/dashboard/
│   ├── stats.php                     ✅ Creado
│   └── diagnostic.php                ✅ Creado
└── routes/web/status.php             ✅ Ya existía
```

## 🎨 Visualización

### Welcome Section (50/50)

```
┌─────────────────────────────────────┬─────────────────────────────────────┐
│ 🏠 ¡Bienvenido de nuevo! 👋         │ ✅ Sesión Activa                    │
│ Juan, estás listo para continuar.   │ Dispositivo: Desktop                │
│                                      │ Navegador: Chrome                   │
│                                      │ IP: 192.168.1.100                   │
│                                      │ Inicio: Hace 2h                     │
└─────────────────────────────────────┴─────────────────────────────────────┘
```

### Stats Cards (4 columnas)

```
┌──────────┬──────────┬──────────┬──────────┐
│ 👥 150   │ ⏰ 23    │ 📁 1250  │ 📊 87    │
│ Usuarios │ Sesiones │ Archivos │ Logins   │
│ 142 act. │ 45 total │ 50.0 MB  │ 15 hoy   │
└──────────┴──────────┴──────────┴──────────┘
```

### Gráficas (2 columnas)

```
┌──────────────────────────┬──────────────────────────┐
│ 📈 Sesiones 7 Días       │ 🥧 Usuarios por Rol      │
│                          │                          │
│ [Gráfica de línea]       │ [Gráfica de dona]        │
│                          │                          │
└──────────────────────────┴──────────────────────────┘
```

### Acciones Rápidas + Info Sistema (70/30)

```
┌────────────────────────────────┬──────────────────┐
│ ⚡ Acciones Rápidas            │ ℹ️ Sistema Info   │
│                                 │                  │
│ [👥 Gestionar Usuarios]        │ Backend: Online  │
│ [⚙️ Configuración]             │ Versión: v1.0.0  │
│ [🔲 HomeLab VR]                │                  │
│ [🏠 Página Principal]          │ [🔍 Diagnóstico] │
└────────────────────────────────┴──────────────────┘
```

## 🧪 Testing

### Frontend

```bash
# Navegar al dashboard
http://localhost:9000/dashboard

# Verificar consola (no debe haber errores)
# Verificar estadísticas carguen
# Click en "Diagnóstico del Sistema"
# Verificar modal de diagnóstico
```

### Backend

```bash
# Test stats API
curl http://localhost:3000/routes/dashboard/stats.php \
  -H "Cookie: PHPSESSID=tu_session_id"

# Test diagnostic API
curl http://localhost:3000/routes/dashboard/diagnostic.php \
  -H "Cookie: PHPSESSID=tu_session_id"

# Test status API
curl http://localhost:3000/routes/web/status.php
```

## 📚 Funciones JavaScript Nuevas

### `loadStats()`

Carga estadísticas reales desde `/routes/dashboard/stats.php` y actualiza:

- Total usuarios, sesiones activas, archivos, logins
- Diferencia entre admin y usuario normal
- Carga gráficas Chart.js

### `loadCurrentSession()`

Carga información de la sesión actual:

- Dispositivo, navegador, IP, hora de inicio

### `loadSessionsChart(data)`

Renderiza gráfica de línea con sesiones por día

### `loadRolesChart(data)`

Renderiza gráfica de dona con usuarios por rol

### `runDiagnostic()`

Ejecuta diagnóstico del sistema y muestra resultado en modal

### `renderDiagnostic(diagnostic)`

Renderiza acordeón con componentes del diagnóstico

### `checkBackendStatus()`

Verifica estado del backend con `/routes/web/status.php`

### Utilidades

- `updateElement(id, value)`: Actualizar contenido de elemento
- `formatBytes(bytes)`: Formatear bytes a KB/MB/GB
- `formatRelativeTime(dateString)`: Formatear tiempo relativo (Hace 2h)

## 🔐 Seguridad

### Autenticación

- ✅ Verificación de sesión en todas las APIs
- ✅ Solo usuarios autenticados pueden acceder a stats y diagnostic
- ✅ Diferenciación de datos por rol (admin vs usuario)

### Datos Sensibles

- ✅ No se expone información sensible en diagnostic
- ✅ Paths del servidor se muestran de forma controlada
- ✅ Variables de entorno no se exponen completamente

## 📊 Roles y Permisos

### Administrador (role_id = 2)

- ✅ Ve estadísticas de TODO el sistema
- ✅ Ve gráficas de sesiones y roles
- ✅ Acceso a gestión de usuarios
- ✅ Acceso completo al diagnóstico

### Usuario Normal (role_id = 1)

- ✅ Ve solo SUS estadísticas (archivos, sesiones)
- ✅ No ve gráficas (solo admin)
- ✅ No puede gestionar usuarios
- ✅ Acceso al diagnóstico (información general)

## 🚀 Próximas Mejoras

- [ ] Cache de estadísticas (Redis)
- [ ] WebSockets para actualización en tiempo real
- [ ] Alertas de diagnóstico (email/Slack cuando hay errores)
- [ ] Exportar diagnóstico a PDF
- [ ] Historial de diagnósticos
- [ ] Métricas de performance (CPU, RAM, Disco)

---

**Última actualización**: 6 de Noviembre de 2025  
**Autor**: Roepard Labs Development Team  
**Estado**: ✅ Implementado y Probado
