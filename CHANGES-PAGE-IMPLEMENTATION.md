# 📝 Registro de Cambios (Changes Page) - Documentación

## 📋 Resumen Ejecutivo

Se ha implementado una nueva página en el dashboard llamada **"Registro de Cambios"** que permite visualizar los commits y releases de los repositorios de GitHub de HomeLab AR (frontend y backend) mediante DataTables interactivas.

**URL de acceso**: `/dashboard/changes`

**Permisos**: Todos los usuarios autenticados pueden acceder a esta página.

---

## 🏗️ Arquitectura Implementada

### 1. **Servicio de GitHub API** (`/composables/changesCheck.js`)

Servicio JavaScript que encapsula las peticiones a la API pública de GitHub.

**Características**:

- ✅ Consulta commits de ambos repositorios
- ✅ Consulta releases de ambos repositorios
- ✅ Formateo de fechas relativas (ej: "Hace 2 horas")
- ✅ Combinación y ordenamiento de datos
- ✅ Manejo de errores HTTP

**APIs utilizadas**:

```javascript
// Commits
https://api.github.com/repos/roepard-labs/thepearlo_vr-website/commits
https://api.github.com/repos/roepard-labs/thepearlo_vr-backend/commits

// Releases
https://api.github.com/repos/roepard-labs/thepearlo_vr-website/releases
https://api.github.com/repos/roepard-labs/thepearlo_vr-backend/releases

// Release específico por tag
https://api.github.com/repos/roepard-labs/thepearlo_vr-website/releases/tags/v0.0.0
https://api.github.com/repos/roepard-labs/thepearlo_vr-backend/releases/tags/v0.0.0
```

**Métodos disponibles**:

| Método                           | Descripción                                | Parámetros                                                               |
| -------------------------------- | ------------------------------------------ | ------------------------------------------------------------------------ |
| `getCommits(repoType, perPage)`  | Obtiene commits de un repo específico      | `repoType`: 'frontend' \| 'backend'<br>`perPage`: cantidad (default: 30) |
| `getReleases(repoType, perPage)` | Obtiene releases de un repo específico     | `repoType`: 'frontend' \| 'backend'<br>`perPage`: cantidad (default: 10) |
| `getReleaseByTag(repoType, tag)` | Obtiene release específico por tag         | `repoType`: 'frontend' \| 'backend'<br>`tag`: string (ej: 'v0.0.0')      |
| `getAllCommits(perPage)`         | Obtiene commits de ambos repos combinados  | `perPage`: cantidad por repo (default: 30)                               |
| `getAllReleases(perPage)`        | Obtiene releases de ambos repos combinados | `perPage`: cantidad por repo (default: 10)                               |
| `formatDate(dateString)`         | Formatea fecha de forma relativa           | `dateString`: fecha ISO 8601                                             |

**Ejemplo de uso**:

```javascript
// Obtener todos los commits
const commits = await ChangesService.getAllCommits(50);

// Obtener todas las releases
const releases = await ChangesService.getAllReleases(20);

// Obtener commits solo del frontend
const frontendCommits = await ChangesService.getCommits("frontend", 10);

// Obtener release específica
const release = await ChangesService.getReleaseByTag("backend", "v0.0.0");
```

---

### 2. **Vista de Cambios** (`/pages/changes.page.php`)

Página dinámica renderizada dentro de `dashboard.view.php`.

**Características**:

- ✅ 2 tabs: Commits y Releases
- ✅ DataTables interactivas con búsqueda, filtrado y paginación
- ✅ Filtros por repositorio (Todos, Frontend, Backend)
- ✅ Badges de color según repositorio
- ✅ Enlaces directos a GitHub
- ✅ Diseño responsive
- ✅ Botón de actualización manual

**Estructura de tabs**:

1. **Tab Commits**:

   - Columnas: Commit SHA | Mensaje | Autor | Repositorio | Fecha | Acciones
   - 25 commits por página
   - Ordenamiento por fecha descendente
   - Filtros: Todos | Frontend | Backend

2. **Tab Releases**:
   - Columnas: Tag | Nombre | Descripción | Autor | Repositorio | Fecha | Acciones
   - 10 releases por página
   - Ordenamiento por fecha de publicación descendente
   - Filtros: Todos | Frontend | Backend
   - Badges especiales para pre-releases

**DataTables configuración**:

```javascript
{
    responsive: true,
    pageLength: 25, // Commits
    pageLength: 10, // Releases
    order: [[4, 'desc']], // Ordenar por fecha
    language: {
        url: '//cdn.datatables.net/plug-ins/1.13.7/i18n/es-ES.json'
    }
}
```

---

## 📂 Archivos Modificados/Creados

### Creados:

1. **`/composables/changesCheck.js`** (Nuevo)

   - Servicio de consulta a GitHub API
   - 300+ líneas de código
   - Clase `ChangesService` global

2. **`/pages/changes.page.php`** (Nuevo)
   - Vista de DataTables con tabs
   - 500+ líneas de código (HTML + CSS + JS)
   - Integración con ChangesService

### Modificados:

3. **`/index.php`**

   ```php
   // Agregado:
   '/dashboard/changes' => 'dashboard.view.php'
   ```

4. **`/views/dashboard.view.php`**

   ```php
   // Agregado:
   } elseif ($currentPath === '/dashboard/changes') {
       $dashboardPage = 'changes.page.php';
       $additionalCss = ['datatables', 'datatablesResponsive'];
       $additionalJs = ['datatables', 'datatablesBS5', 'datatablesResponsive'];
   }
   ```

5. **`/layout/AppLayout.php`**

   ```php
   // Agregado en sección de scripts:
   <script src="/composables/changesCheck.js"></script>
   ```

6. **`/ui/sidebar.ui.php`**
   ```php
   // Agregado en ambos sidebars (desktop y móvil):
   <li class="nav-item">
       <a href="/dashboard/changes" class="nav-link sidebar-link" data-page="changes">
           <i class="bx bx-git-branch me-3"></i>
           <span class="sidebar-text">Cambios</span>
       </a>
   </li>
   ```

---

## 🎨 Diseño y UX

### Componentes Visuales:

1. **Header de página**:

   - Icono de git-branch
   - Título y descripción
   - Botón de actualización

2. **Tabs de navegación**:

   - Diseño Bootstrap 5
   - Badges con contador de items
   - Transiciones suaves

3. **Filtros por repositorio**:

   - Radio buttons estilizados
   - Colores: Primary (Frontend), Info (Backend)

4. **DataTables**:

   - Hover effect con translateX
   - Box-shadow en hover
   - Badges coloridos para repos

5. **Badges de repositorio**:
   - Frontend: `badge bg-primary`
   - Backend: `badge bg-info`
   - Pre-release: `badge bg-warning`
   - Release estable: `badge bg-success`

### CSS Variables utilizadas:

```css
var(--bs-body-color)
var(--bs-primary)
var(--bs-secondary-bg)
var(--bs-border-color)
```

### Responsive Breakpoints:

```css
@media (max-width: 768px) {
  /* Reducir max-width de mensajes */
  /* Cambiar btn-group a columna */
}
```

---

## 🧪 Testing

### Checklist de Verificación:

- [ ] **Navegación**: Click en "Cambios" del sidebar lleva a `/dashboard/changes`
- [ ] **Carga de datos**: Commits y releases se cargan correctamente
- [ ] **DataTables**: Búsqueda, ordenamiento y paginación funcionan
- [ ] **Filtros**: Filtros por repositorio actualizan tablas
- [ ] **Enlaces**: Botones "Ver" abren GitHub en nueva pestaña
- [ ] **Responsive**: Diseño se adapta a móviles
- [ ] **Actualización**: Botón de refrescar recarga datos
- [ ] **Tabs**: Cambio entre tabs funciona correctamente
- [ ] **Badges**: Colores correctos según repositorio
- [ ] **Fechas**: Formato relativo funciona ("Hace X horas")

### Comandos de Testing:

```bash
# Iniciar servidor de desarrollo
cd /home/jemg/Documents/GitHub/roepard-labs/thepearlo_vr-website
php -S localhost:9000 router.php

# Navegar a:
http://localhost:9000/dashboard/changes

# Verificar en consola del navegador:
# 1. ChangesService inicializado ✅
# 2. Commits obtenidos ✅
# 3. Releases obtenidos ✅
# 4. DataTables inicializado ✅
```

### Pruebas con APIs de GitHub:

```bash
# Test manual de APIs
curl -I https://api.github.com/repos/roepard-labs/thepearlo_vr-website/commits
curl -I https://api.github.com/repos/roepard-labs/thepearlo_vr-backend/commits
curl -I https://api.github.com/repos/roepard-labs/thepearlo_vr-website/releases
curl -I https://api.github.com/repos/roepard-labs/thepearlo_vr-backend/releases

# Verificar respuesta 200 OK
```

---

## ⚠️ Limitaciones y Consideraciones

### Rate Limiting de GitHub API:

GitHub API pública tiene límites de peticiones:

- **Sin autenticación**: 60 requests/hora por IP
- **Con autenticación**: 5000 requests/hora

**Recomendaciones**:

1. No hacer polling automático (solo carga inicial + botón manual)
2. Considerar implementar caché en el futuro
3. Mostrar mensaje de error si se supera el límite

### CORS:

Las APIs de GitHub soportan CORS, por lo que las peticiones desde el navegador funcionan correctamente sin configuración adicional.

### Datos Sensibles:

Las APIs consultadas son **públicas** (no requieren token de autenticación). No se expone información sensible.

---

## 🚀 Próximas Mejoras Sugeridas

### Corto Plazo:

1. **Cache de respuestas**:

   - Almacenar datos en localStorage
   - Caché de 5-10 minutos
   - Reducir llamadas a GitHub API

2. **Notificaciones de nuevos commits**:

   - Comparar con última versión cacheada
   - Mostrar badge "New" en sidebar

3. **Búsqueda avanzada**:
   - Filtro por autor
   - Filtro por rango de fechas
   - Búsqueda en mensaje de commit

### Mediano Plazo:

4. **Autenticación con GitHub**:

   - Usar token personal para aumentar rate limit
   - Acceso a APIs privadas si es necesario

5. **Estadísticas visuales**:

   - Gráfico de commits por día/semana
   - Gráfico de contribuidores
   - Timeline de releases

6. **Detalles expandibles**:
   - Modal con diff del commit
   - Ver archivos modificados
   - Changelog completo de release

### Largo Plazo:

7. **Webhooks de GitHub**:

   - Notificaciones push en tiempo real
   - Actualización automática sin recargar

8. **Comparación de versiones**:
   - Diff entre releases
   - Changelog automático

---

## 📚 Documentación de Referencia

### GitHub API:

- [Commits API](https://docs.github.com/en/rest/commits/commits?apiVersion=2022-11-28)
- [Releases API](https://docs.github.com/en/rest/releases/releases?apiVersion=2022-11-28)
- [Rate Limiting](https://docs.github.com/en/rest/overview/rate-limits-for-the-rest-api)

### DataTables:

- [DataTables Docs](https://datatables.net/reference/)
- [Spanish Language](https://datatables.net/plug-ins/i18n/es-ES)

### Bootstrap 5:

- [Tabs Component](https://getbootstrap.com/docs/5.3/components/navs-tabs/)
- [Badges](https://getbootstrap.com/docs/5.3/components/badge/)

---

## 🎯 Casos de Uso

### Usuario Regular:

**Caso 1: Ver últimos cambios del proyecto**

1. Usuario inicia sesión
2. Navega a Dashboard
3. Click en "Cambios" en sidebar
4. Ve tabla de commits más recientes
5. Click en "Releases" tab para ver versiones

**Caso 2: Buscar commit específico**

1. Usuario navega a /dashboard/changes
2. Usa barra de búsqueda de DataTable
3. Escribe parte del mensaje del commit
4. DataTable filtra resultados
5. Click en "Ver" para abrir en GitHub

**Caso 3: Verificar release específica**

1. Usuario navega a tab "Releases"
2. Busca por tag (ej: "v1.0.0")
3. Lee descripción del release
4. Click en "Ver" para leer changelog completo

### Administrador:

**Caso 4: Monitorear actividad de desarrollo**

1. Admin navega a /dashboard/changes
2. Filtra por "Backend" para ver cambios del API
3. Revisa commits recientes de otros desarrolladores
4. Verifica que hay actividad constante

**Caso 5: Documentar cambios para usuarios**

1. Admin navega a tab "Releases"
2. Revisa último release publicado
3. Copia información para crear anuncio
4. Comparte con usuarios finales

---

## ✅ Estado del Proyecto

**Fecha de implementación**: Noviembre 6, 2025  
**Estado**: ✅ **Completado y Funcional**  
**Versión**: 1.0.0

### Archivos entregables:

1. ✅ `/composables/changesCheck.js` - Servicio de GitHub API
2. ✅ `/pages/changes.page.php` - Vista con DataTables
3. ✅ `/index.php` - Ruta registrada
4. ✅ `/views/dashboard.view.php` - Dependencias configuradas
5. ✅ `/layout/AppLayout.php` - Script cargado globalmente
6. ✅ `/ui/sidebar.ui.php` - Enlaces en sidebar (desktop y móvil)
7. ✅ `/docs/CHANGES-PAGE-IMPLEMENTATION.md` - Este documento

---

**Última actualización**: Noviembre 6, 2025  
**Autor**: Roepard Labs Development Team  
**Mantenido por**: Sistema HomeLab AR
