# 📜 Sistema de Gestión de Contenido Legal - HomeLab AR

> **Sistema completo de administración de Política de Privacidad y Términos y Condiciones con editor web y APIs RESTful**

[![Versión](https://img.shields.io/badge/versión-1.0-blue.svg)](https://github.com/roepard-labs)
[![PHP](https://img.shields.io/badge/PHP-8.4-777BB4.svg)](https://php.net)
[![MySQL](https://img.shields.io/badge/MySQL-10.11-4479A1.svg)](https://mysql.com)
[![Bootstrap](https://img.shields.io/badge/Bootstrap-5.3-7952B3.svg)](https://getbootstrap.com)
[![Estado](https://img.shields.io/badge/estado-producción-green.svg)](https://github.com/roepard-labs)

---

## 📋 Tabla de Contenidos

- [Descripción](#-descripción)
- [Características](#-características)
- [Requisitos](#-requisitos)
- [Instalación Rápida](#-instalación-rápida)
- [Uso](#-uso)
- [Arquitectura](#-arquitectura)
- [APIs](#-apis)
- [Seguridad](#-seguridad)
- [Documentación](#-documentación)
- [Contribuir](#-contribuir)
- [Licencia](#-licencia)

---

## 📖 Descripción

El **Sistema de Gestión de Contenido Legal** es una solución full-stack que permite a los administradores de HomeLab AR gestionar dinámicamente el contenido de las páginas legales del sitio web (Política de Privacidad y Términos y Condiciones) sin necesidad de editar código.

### ¿Qué Problema Resuelve?

- ❌ **Antes:** Editar archivos PHP/HTML directamente para cambiar contenido legal
- ❌ **Antes:** Dependencia de desarrolladores para actualizaciones simples
- ❌ **Antes:** Sin historial de cambios ni control de versiones
- ❌ **Antes:** Riesgo de errores de sintaxis al editar código

- ✅ **Ahora:** Editor web intuitivo para admins
- ✅ **Ahora:** Cambios en tiempo real sin tocar código
- ✅ **Ahora:** Versionado y registro de cambios
- ✅ **Ahora:** Soft delete para recuperar contenido eliminado

---

## ✨ Características

### 🎨 Editor Web Intuitivo

- Editor visual integrado en `/dashboard/settings`
- Modal de edición con SweetAlert2
- Notificaciones toast con Notyf
- Responsive design con Bootstrap 5

### 📊 Gestión Granular

- Organización por **secciones** y **párrafos**
- Control de **orden de visualización**
- Estado **activo/inactivo** (soft delete)
- Metadata: **versión**, **fecha de vigencia**, **changelog**

### 🔐 Seguridad Robusta

- Autenticación PHP session-based
- Autorización por roles (solo role_id = 2)
- Validación de datos backend
- Prevención de SQL injection (PDO)
- Escape de HTML para prevenir XSS

### ⚡ Performance

- APIs optimizadas (< 500ms)
- Índices de base de datos
- Carga dinámica con JavaScript
- Estados de loading/error

### 📱 Responsive

- Mobile-first design
- Funciona en todos los dispositivos
- Optimizado para touch

---

## 🛠️ Requisitos

### Backend

- PHP >= 8.4
- MySQL >= 10.11 (MariaDB)
- PDO extension
- Servidor web (Nginx/Apache)

### Frontend

- JavaScript ES6+ compatible browser
- Bootstrap 5.3+
- jQuery 3.7+ (para DataTables/Bootstrap)
- Axios (AppRouter)
- SweetAlert2
- Notyf

### Sistema

- Linux (Ubuntu 22.04 LTS recomendado)
- Git
- Composer (opcional, para dependencias PHP)
- NPM (para dependencias frontend)

---

## 🚀 Instalación Rápida

### Opción 1: Script Automático (Recomendado)

```bash
# 1. Clonar repositorio
git clone https://github.com/roepard-labs/thepearlo_vr-website.git
cd thepearlo_vr-website

# 2. Ejecutar script de instalación
cd scripts
chmod +x install-legal-system.sh
./install-legal-system.sh

# 3. Seguir prompts interactivos
# - Ingresa usuario de MySQL
# - Ingresa contraseña
# - Confirma instalación

# 4. Verificar instalación
mysql -u tu_usuario -p
USE homelab;
SELECT COUNT(*) FROM legal_privacy;  -- Debe retornar 35
SELECT COUNT(*) FROM legal_terms;    -- Debe retornar 38
```

### Opción 2: Instalación Manual

```bash
# 1. Importar migraciones SQL
mysql -u tu_usuario -p homelab < thepearlo_vr-backend/migrations/create_legal_tables.sql

# 2. Verificar tablas creadas
mysql -u tu_usuario -p
USE homelab;
SHOW TABLES LIKE 'legal%';

# 3. Verificar datos iniciales
SELECT section_number, section_title, COUNT(*) as paragraphs
FROM legal_privacy
GROUP BY section_number, section_title
ORDER BY section_number;
```

---

## 📚 Uso

### Para Administradores

#### 1. Acceder al Editor

```
1. Login como administrador (role_id = 2)
2. Navegar a /dashboard/settings
3. Click en tab "Política de Privacidad" o "Términos y Condiciones"
```

#### 2. Gestionar Metadata

```
- Versión: Ej. "1.0", "1.1", "2.0"
- Fecha de Vigencia: Fecha desde la cual aplica el documento
- Registro de Cambios: Descripción de cambios realizados
- Click "Guardar Metadata"
```

#### 3. Editar Párrafo

```
1. Buscar párrafo en la lista
2. Click botón "Editar" (✏️)
3. Modificar campos en el modal:
   - Número de sección
   - Título de sección
   - Número de párrafo
   - Contenido del párrafo
   - Orden de visualización
   - Estado (Activo/Inactivo)
4. Click "Guardar Cambios"
5. Verificar notificación de éxito
```

#### 4. Eliminar Párrafo (Soft Delete)

```
1. Click botón "Eliminar" (🗑️)
2. Confirmar eliminación
3. Párrafo se marca como inactivo (is_active = 0)
4. Párrafo NO aparece en vista pública
5. Párrafo SÍ aparece en editor (con badge "Inactivo")
```

### Para Desarrolladores

#### Integrar API Pública

```javascript
// Cargar política de privacidad
async function loadPrivacy() {
  const response = await window.AppRouter.get("/routes/web/privacy.php");

  if (response.status === "success") {
    const { metadata, sections, total_sections } = response.data;

    console.log("Versión:", metadata.version);
    console.log("Secciones:", total_sections);
    console.log("Contenido:", sections);
  }
}
```

#### Integrar API Admin

```javascript
// Crear nuevo párrafo (requiere autenticación)
async function createParagraph() {
  const data = {
    operation: "create",
    section_number: 9,
    section_title: "Nueva Sección",
    paragraph_number: 1,
    paragraph_content: "Contenido del párrafo...",
    is_active: 1,
    display_order: 999,
  };

  const response = await window.AppRouter.post(
    "/routes/privacy/up_privacy.php",
    data
  );

  if (response.status === "success") {
    console.log("Párrafo creado, ID:", response.privacy_id);
  }
}
```

---

## 🏗️ Arquitectura

### Diagrama de Componentes

```
┌─────────────────────────────────────────────────┐
│               FRONTEND (Port 9000)              │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌─────────────────┐      ┌─────────────────┐  │
│  │ Privacy View    │      │  Terms View     │  │
│  │ (Pública)       │      │  (Pública)      │  │
│  └────────┬────────┘      └────────┬────────┘  │
│           │                        │           │
│           └────────┬───────────────┘           │
│                    │                           │
│           ┌────────▼────────┐                  │
│           │  Legal Editor   │                  │
│           │    (Admin)      │                  │
│           └────────┬────────┘                  │
│                    │                           │
└────────────────────┼───────────────────────────┘
                     │
            ┌────────▼────────┐
            │   AppRouter     │
            │    (Axios)      │
            └────────┬────────┘
                     │ HTTP Requests
┌────────────────────▼───────────────────────────┐
│              BACKEND API (Port 3000)           │
├────────────────────────────────────────────────┤
│                                                │
│  ┌──────────────┐        ┌──────────────┐     │
│  │ Public APIs  │        │  Admin APIs  │     │
│  ├──────────────┤        ├──────────────┤     │
│  │ /web/        │        │ /privacy/    │     │
│  │  privacy.php │        │  list.php    │     │
│  │  terms.php   │        │  up.php      │     │
│  └──────┬───────┘        │ /legal/      │     │
│         │                │  list.php    │     │
│         │                │  up.php      │     │
│         │                └──────┬───────┘     │
│         │                       │             │
│         └───────┬───────────────┘             │
│                 │                             │
│        ┌────────▼─────────┐                   │
│        │     Models       │                   │
│        ├──────────────────┤                   │
│        │ LegalPrivacy.php │                   │
│        │ LegalTerms.php   │                   │
│        └────────┬─────────┘                   │
│                 │                             │
└─────────────────┼─────────────────────────────┘
                  │
        ┌─────────▼──────────┐
        │   MySQL Database   │
        ├────────────────────┤
        │ legal_privacy      │
        │ legal_terms        │
        │ legal_metadata     │
        └────────────────────┘
```

### Flujo de Datos

**Lectura (Usuario Público):**

```
Usuario → /privacy → privacy.view.php →
loadPrivacyContent() → AppRouter.get('/routes/web/privacy.php') →
Backend verifica is_active = 1 → Query SQL →
Retorna JSON → renderPrivacyContent() → Renderiza HTML
```

**Escritura (Admin):**

```
Admin → /dashboard/settings → Tab Privacy →
loadPrivacyAdmin() → AppRouter.get('/routes/privacy/list_privacy.php') →
Backend verifica Auth + role_id = 2 → Query SQL (ALL paragraphs) →
Retorna JSON → renderPrivacyEditor() → Usuario edita →
AppRouter.post('/routes/privacy/up_privacy.php', {operation: 'update'}) →
Backend valida + UPDATE SQL → Retorna success → Notificación → Recarga
```

---

## 📡 APIs

### APIs Públicas (Sin Autenticación)

#### `GET /routes/web/privacy.php`

Obtiene contenido activo de política de privacidad.

**Response:**

```json
{
  "status": "success",
  "data": {
    "metadata": {
      "version": "1.0",
      "effective_date": "2025-11-06",
      "last_updated": "2025-11-06 12:00:00"
    },
    "sections": [
      {
        "section_number": 1,
        "section_title": "Introducción",
        "paragraphs": [
          {
            "paragraph_number": 1,
            "content": "En HomeLab AR..."
          }
        ]
      }
    ],
    "total_sections": 8
  }
}
```

#### `GET /routes/web/terms.php`

Obtiene contenido activo de términos y condiciones. Estructura idéntica a `privacy.php`.

---

### APIs Admin (Requieren Autenticación + role_id = 2)

#### `GET /routes/privacy/list_privacy.php`

Lista TODO el contenido de privacidad (incluye inactivos).

**Headers:**

```
Cookie: PHPSESSID=...
```

**Response:**

```json
{
  "status": "success",
  "data": {
    "metadata": {...},
    "sections": [...]
  }
}
```

#### `POST /routes/privacy/up_privacy.php`

CRUD completo: create, update, delete, update_metadata.

**Operaciones:**

**CREATE:**

```json
{
  "operation": "create",
  "section_number": 9,
  "section_title": "Nueva Sección",
  "paragraph_number": 1,
  "paragraph_content": "Contenido...",
  "is_active": 1,
  "display_order": 99
}
```

**UPDATE:**

```json
{
  "operation": "update",
  "privacy_id": 15,
  "paragraph_content": "Contenido actualizado...",
  "is_active": 1
}
```

**DELETE:**

```json
{
  "operation": "delete",
  "privacy_id": 15
}
```

**UPDATE_METADATA:**

```json
{
  "operation": "update_metadata",
  "version": "1.1",
  "effective_date": "2025-12-01",
  "change_log": "Se actualizó la sección 3..."
}
```

#### `GET /routes/legal/list_legal.php`

Lista TODO el contenido de términos.

#### `POST /routes/legal/up_legal.php`

CRUD para términos (operaciones idénticas a privacy).

---

## 🔐 Seguridad

### Autenticación

- ✅ Sesiones PHP con `session_start()`
- ✅ Middleware `Auth::checkAuth()` en todas las rutas admin
- ✅ Cookies httpOnly

### Autorización

- ✅ Verificación de `role_id = 2` (solo admins)
- ✅ Status check: `Status::checkStatus(1)` (solo usuarios activos)

### Validación

- ✅ Validación de campos requeridos en backend
- ✅ Sanitización de inputs
- ✅ PDO prepared statements (prevención SQL injection)

### Prevención XSS

- ✅ Escape de HTML en frontend (`escapeHtml()`)
- ✅ Content-Type: application/json en APIs
- ✅ No evaluación de JavaScript user-provided

### Auditoría

- ✅ Tracking de quién creó/modificó (created_by, updated_by)
- ✅ Timestamps automáticos (created_at, updated_at)
- ✅ Soft delete (no eliminación física)

---

## 📖 Documentación

### Documentos Principales

- **[LEGAL-CONTENT-SYSTEM.md](./LEGAL-CONTENT-SYSTEM.md)** - Documentación técnica completa (arquitectura, implementación, troubleshooting)
- **[LEGAL-QUICK-START.md](./LEGAL-QUICK-START.md)** - Guía rápida de uso (instalación en 5 pasos, cómo usar el editor)
- **[LEGAL-TESTING-CHECKLIST.md](./LEGAL-TESTING-CHECKLIST.md)** - Checklist exhaustivo de testing (10 fases, 100+ tests)
- **[LEGAL-SYSTEM-SUMMARY.md](./LEGAL-SYSTEM-SUMMARY.md)** - Resumen ejecutivo del proyecto

### Archivos de Código

**Backend:**

- `/thepearlo_vr-backend/migrations/create_legal_tables.sql` - Schema de BD
- `/thepearlo_vr-backend/models/LegalPrivacy.php` - Modelo de privacidad
- `/thepearlo_vr-backend/models/LegalTerms.php` - Modelo de términos
- `/thepearlo_vr-backend/routes/web/privacy.php` - API pública privacy
- `/thepearlo_vr-backend/routes/web/terms.php` - API pública terms
- `/thepearlo_vr-backend/routes/privacy/list_privacy.php` - API admin list
- `/thepearlo_vr-backend/routes/privacy/up_privacy.php` - API admin CRUD
- `/thepearlo_vr-backend/routes/legal/list_legal.php` - API admin list terms
- `/thepearlo_vr-backend/routes/legal/up_legal.php` - API admin CRUD terms

**Frontend:**

- `/thepearlo_vr-website/views/privacy-dynamic.view.php` - Vista pública privacy
- `/thepearlo_vr-website/views/terms-dynamic.view.php` - Vista pública terms
- `/thepearlo_vr-website/js/legal-editor.js` - Editor admin (650+ líneas)
- `/thepearlo_vr-website/pages/settings.page.php` - Página de configuración

**Scripts:**

- `/scripts/install-legal-system.sh` - Script de instalación automática

---

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Por favor, sigue estos pasos:

1. **Fork** el repositorio
2. **Crea** una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. **Push** a la rama (`git push origin feature/AmazingFeature`)
5. **Abre** un Pull Request

### Guía de Contribución

- Sigue el estilo de código existente (PSR-12 para PHP)
- Agrega tests para nuevas funcionalidades
- Actualiza la documentación
- Usa commits descriptivos (Conventional Commits)

---

## 📄 Licencia

Este proyecto es parte de **HomeLab AR** desarrollado por **Roepard Labs**.

```
Copyright (c) 2025 Roepard Labs
Todos los derechos reservados.
```

---

## 📞 Soporte

- **Documentación:** [docs/](./docs/)
- **Issues:** [GitHub Issues](https://github.com/roepard-labs/issues)
- **Email:** [email protected]
- **Website:** https://roepard.online

---

## 🌟 Agradecimientos

- **Bootstrap** - Framework CSS
- **SweetAlert2** - Modales elegantes
- **Notyf** - Notificaciones toast
- **Axios** - HTTP client
- **AOS** - Animaciones on scroll

---

## 📊 Estadísticas del Proyecto

- **Líneas de Código (Backend):** ~1,500
- **Líneas de Código (Frontend):** ~1,200
- **Líneas de SQL:** ~600
- **Líneas de Documentación:** ~3,500
- **Total:** ~6,800 líneas

---

## 🗺️ Roadmap

### v1.1 (Próximo Release)

- [ ] Botón "Agregar Nuevo Párrafo" funcional
- [ ] Búsqueda/filtrado en el editor
- [ ] Preview en tiempo real de cambios

### v1.2

- [ ] Historial de versiones con restore
- [ ] Export/Import JSON de contenido
- [ ] Comparación de versiones (diff)

### v2.0

- [ ] Editor WYSIWYG (rich text)
- [ ] Drag-and-drop para reordenar párrafos
- [ ] Multi-idioma (i18n)
- [ ] API GraphQL

---

**Desarrollado con ❤️ por Roepard Labs**

[![GitHub](https://img.shields.io/badge/GitHub-roepard--labs-181717.svg?logo=github)](https://github.com/roepard-labs)
[![Website](https://img.shields.io/badge/Website-roepard.online-00ff88.svg)](https://roepard.online)
