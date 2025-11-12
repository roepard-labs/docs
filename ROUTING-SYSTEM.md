# Sistema de Routing con URLs Limpias

**HomeLab AR - Roepard Labs**  
**Fecha**: 2025-11-03  
**Versión**: 1.0.0

## 📋 Resumen

Se ha implementado un sistema de routing completo con URLs limpias para el frontend de HomeLab AR. El sistema permite acceder a diferentes páginas usando rutas amigables sin extensiones `.php` o `.html`.

## 🎯 Rutas Implementadas

| URL         | Vista                      | Descripción                  |
| ----------- | -------------------------- | ---------------------------- |
| `/`         | `home.view.php`            | Página principal             |
| `/home`     | `home.view.php`            | Alias de home                |
| `/features` | `features.view.php`        | Características del producto |
| `/privacy`  | `privacy.view.php`         | Política de privacidad       |
| `/terms`    | `terms.view.php`           | Términos y condiciones       |
| `/admin`    | `admin.dashboard.view.php` | Dashboard de administración  |
| `/user`     | `user.dashboard.view.php`  | Dashboard de usuario         |

## 🔧 Arquitectura

### 1. Router Principal (`index.php`)

El archivo `index.php` actúa como router central:

```php
// Obtener URI limpia
$request_uri = $_SERVER['REQUEST_URI'];
$uri = strtok($request_uri, '?'); // Sin query string
$uri = rtrim($uri, '/'); // Sin trailing slash
$uri = $uri ?: '/'; // Raíz por defecto

// Mapeo de rutas
$routes = [
    '/' => 'home.view.php',
    '/features' => 'features.view.php',
    '/privacy' => 'privacy.view.php',
    '/terms' => 'terms.view.php',
    // ...
];

// Cargar vista o retornar 404
if (isset($routes[$uri])) {
    require_once __DIR__ . '/views/' . $routes[$uri];
    exit;
}

http_response_code(404);
exit;
```

### 2. Configuración Nginx

El archivo `nginx.conf` maneja las URLs limpias:

```nginx
location / {
    try_files $uri $uri/ /index.php?$query_string;
}
```

**Comportamiento:**

- Si existe un archivo estático → servir directamente
- Si no existe → pasar a `index.php` (router)
- Si el router no encuentra la ruta → 404 → nginx muestra `40x.php`

### 3. Estructura de Vistas

Todas las vistas siguen el mismo patrón:

```php
<?php
require_once __DIR__ . '/../layout/AppLayout.php';

// Configuración de la página
$pageConfig = [
    'title' => 'Título - HomeLab AR',
    'description' => 'Descripción SEO',
    'keywords' => 'keywords, seo',
    'css' => [],
    'js' => []
];

// Capturar contenido HTML
ob_start();
?>

<!-- Contenido HTML aquí -->
<section class="py-5">
    <!-- ... -->
</section>

<?php
$content = ob_get_clean();

// Renderizar con AppLayout
AppLayout::render('nombre-vista', ['content' => $content], $pageConfig);
?>
```

## ✅ Características del Sistema

### 1. URLs Limpias

- ✅ Sin extensiones `.php` o `.html`
- ✅ Sin parámetros GET innecesarios
- ✅ URLs amigables para SEO
- ✅ Trailing slashes opcionales

### 2. Manejo de Errores

- ✅ 404 personalizado para rutas inexistentes
- ✅ Nginx redirige a páginas de error (`30x.php`, `40x.php`, `50x.php`)
- ✅ Verificación de existencia de archivos de vista

### 3. Compatibilidad

- ✅ Query strings preservados (`?id=123`)
- ✅ Archivos estáticos servidos directamente
- ✅ Compatible con sistema de layouts (AppLayout)
- ✅ Sesiones PHP preservadas

### 4. SEO Optimizado

- ✅ Meta tags personalizables por página
- ✅ URLs semánticas y descriptivas
- ✅ Canonical URLs configurables
- ✅ Open Graph tags incluidos

## 📄 Páginas Creadas

### 1. Features (`/features`)

- **Descripción**: Página detallada de características
- **Características**:
  - 6 tarjetas de features con iconos
  - Animaciones AOS
  - Efectos hover 3D
  - Diseño responsive
  - Íconos Boxicons
  - Gradientes Bootstrap 5

### 2. Privacy (`/privacy`)

- **Descripción**: Política de privacidad completa
- **Secciones**:
  1. Introducción
  2. Información que recopilamos
  3. Uso de la información
  4. Protección de datos
  5. Cookies
  6. Derechos del usuario
  7. Contacto
  8. Actualizaciones

### 3. Terms (`/terms`)

- **Descripción**: Términos y condiciones de uso
- **Secciones**:
  1. Aceptación de términos
  2. Descripción del servicio
  3. Registro y cuenta
  4. Uso aceptable
  5. Propiedad intelectual
  6. Limitación de responsabilidad
  7. Disponibilidad del servicio
  8. Modificaciones
  9. Terminación
  10. Ley aplicable
  11. Contacto

## 🧪 Testing

### Probar Rutas Existentes

```bash
# Home
curl -I http://localhost:3000/
curl -I http://localhost:3000/home

# Features
curl -I http://localhost:3000/features

# Privacy
curl -I http://localhost:3000/privacy

# Terms
curl -I http://localhost:3000/terms
```

### Probar Rutas Inexistentes (404)

```bash
# Debe retornar 404 y mostrar 40x.php
curl -I http://localhost:3000/no-existe
curl -I http://localhost:3000/pagina-falsa
```

### Verificar Query Strings

```bash
# Query strings deben preservarse
curl http://localhost:3000/features?utm_source=email
```

## 🔒 Seguridad

### Protecciones Implementadas

1. **Validación de Rutas**

   - Solo rutas definidas en `$routes` son válidas
   - Verificación de existencia de archivos

2. **Prevención de Directory Traversal**

   - Rutas absolutas con `__DIR__`
   - Sin concatenación directa de input del usuario

3. **Nginx Hardened**

   ```nginx
   autoindex off;                    # Sin listado de directorios
   location ~ /\. { deny all; }      # Sin archivos ocultos
   location ~ /\.env { deny all; }   # Sin .env
   ```

4. **Sesiones Seguras**
   - `session_start()` al inicio
   - Validación en AdminLayout y UserLayout

## 📊 Flujo de Solicitudes

```
Usuario solicita: /features
    ↓
Nginx: try_files
    ↓
¿Existe archivo /features? → NO
    ↓
Nginx: pasar a /index.php
    ↓
index.php (Router):
    - Parsear URI: /features
    - Buscar en $routes array
    - ¿Existe ruta? → SÍ
    ↓
Cargar: /views/features.view.php
    ↓
features.view.php:
    - Cargar AppLayout
    - Definir $pageConfig
    - Capturar contenido HTML
    - Llamar AppLayout::render()
    ↓
AppLayout genera HTML completo
    ↓
Enviar respuesta al navegador
```

## 🚀 Extensión del Sistema

### Agregar Nueva Ruta

1. **Crear vista** en `/views/nueva-pagina.view.php`:

```php
<?php
require_once __DIR__ . '/../layout/AppLayout.php';

$pageConfig = [
    'title' => 'Nueva Página - HomeLab AR',
    'description' => 'Descripción de la página',
    'keywords' => 'keywords',
    'css' => [],
    'js' => []
];

ob_start();
?>
<!-- HTML aquí -->
<?php
$content = ob_get_clean();
AppLayout::render('nueva-pagina', ['content' => $content], $pageConfig);
?>
```

2. **Registrar ruta** en `index.php`:

```php
$routes = [
    // ... rutas existentes
    '/nueva-pagina' => 'nueva-pagina.view.php'
];
```

3. **Agregar enlace** en `footer.ui.php` o navegación.

## 📝 Notas Importantes

1. **Trailing Slashes**: Se eliminan automáticamente (`/features/` → `/features`)
2. **Query Strings**: Se preservan pero no afectan el routing
3. **Case Sensitive**: Las rutas son sensibles a mayúsculas/minúsculas
4. **404 Handling**: Nginx muestra `40x.php` con estilo consistente
5. **AppLayout**: Todas las vistas deben usar AppLayout para consistencia

## 🔄 Actualización vs Sistema Anterior

### Antes

```
/views/home.view.php → Acceso directo
/views/features.view.php → No existía
index.php → Solo renderizaba home
```

### Ahora

```
/ → Router → views/home.view.php
/features → Router → views/features.view.php
/privacy → Router → views/privacy.view.php
/terms → Router → views/terms.view.php
/cualquier-otra → Router → 404
```

## 🎨 Estilos Consistentes

Todas las páginas nuevas usan:

- ✅ Bootstrap 5 como framework
- ✅ Boxicons para iconografía
- ✅ AOS para animaciones de scroll
- ✅ Variables CSS de `variables.css`
- ✅ Tema claro/oscuro automático
- ✅ Diseño responsive

## 📞 Contacto y Soporte

Para más información:

- **Email**: privacy@roepard.online, legal@roepard.online
- **Website**: https://website.roepard.online
- **Documentación**: https://docs.roepard.online

---

**Última actualización**: 2025-11-03  
**Mantenido por**: Roepard Labs  
**Licencia**: MIT
