# 📚 Sistema de Gestión de Contenido Legal - HomeLab AR

## ✅ Implementación Completada

### 🎯 Objetivo

Crear un sistema completo de gestión de Política de Privacidad y Términos y Condiciones **editable desde el dashboard de administración**, con contenido almacenado en base de datos MySQL/MariaDB y accesible mediante API pública.

---

## 📦 Archivos Creados/Modificados

### 🗄️ Backend (thepearlo_vr-backend)

#### Migraciones SQL

```
📁 /migrations/
└── create_legal_tables.sql ⭐ NUEVO
```

**Tablas creadas:**

- `legal_privacy` - Contenido de Política de Privacidad
- `legal_terms` - Contenido de Términos y Condiciones
- `legal_metadata` - Metadatos de documentos (versión, fecha, changelog)

#### Modelos

```
📁 /models/
├── LegalPrivacy.php ⭐ NUEVO
└── LegalTerms.php ⭐ NUEVO
```

**Métodos disponibles:**

- `getAllActive()` - Contenido público activo
- `getAll()` - Todo el contenido (admin)
- `getById($id)` - Un párrafo específico
- `create($data)` - Crear párrafo
- `update($id, $data)` - Actualizar párrafo
- `delete($id, $userId)` - Soft delete (marcar inactivo)
- `getMetadata()` - Metadata del documento
- `updateMetadata($data)` - Actualizar metadata

#### Rutas API Públicas

```
📁 /routes/web/
├── privacy.php ✅ MODIFICADO (API pública)
└── terms.php ✅ MODIFICADO (API pública)
```

**Endpoint:** `GET /routes/web/privacy.php`  
**Endpoint:** `GET /routes/web/terms.php`  
**Autenticación:** ❌ No requiere (público)  
**Retorna:** JSON con secciones y párrafos activos

#### Rutas API Admin (Privadas)

```
📁 /routes/privacy/
├── list_privacy.php ✅ MODIFICADO (GET - listar todo)
└── up_privacy.php ✅ MODIFICADO (POST/PUT - CRUD)

📁 /routes/legal/
├── list_legal.php ✅ MODIFICADO (GET - listar todo)
└── up_legal.php ✅ MODIFICADO (POST/PUT - CRUD)
```

**Autenticación:** ✅ Requerida (role_id = 2 - Admin)  
**Operaciones soportadas:**

- `create` - Crear nuevo párrafo
- `update` - Actualizar párrafo existente
- `delete` - Eliminar párrafo (soft delete)
- `update_metadata` - Actualizar versión/fecha/changelog

---

### 🎨 Frontend (thepearlo_vr-website)

#### Vistas Dinámicas

```
📁 /views/
├── privacy-dynamic.view.php ⭐ NUEVO (carga desde API)
└── terms-dynamic.view.php ⭐ PENDIENTE
```

**Características:**

- ✅ Carga contenido dinámicamente desde API
- ✅ Loading states
- ✅ Error handling con retry
- ✅ Renderizado automático de secciones
- ✅ Animaciones AOS
- ✅ Responsive design

#### Editor de Contenido Legal

```
📁 /pages/
└── settings.page.php ✅ MODIFICADO (agregado tabs)

📁 /js/
└── legal-editor.js ⭐ NUEVO
```

**Funcionalidades del Editor:**

- ✅ Tab "Política de Privacidad"
- ✅ Tab "Términos y Condiciones"
- ✅ Edición de metadata (versión, fecha, changelog)
- ✅ Listado de secciones y párrafos
- ✅ CRUD completo con modales SweetAlert2
- ✅ Estados: Activo/Inactivo
- ✅ Orden de visualización configurable
- ✅ Solo accesible para admins

---

## 🗃️ Estructura de Base de Datos

### Tabla: `legal_privacy`

```sql
privacy_id          INT PK AUTO_INCREMENT
section_number      INT (1, 2, 3...)
section_title       VARCHAR(255) (título de sección)
paragraph_number    INT (1, 2, 3... dentro de sección)
paragraph_content   TEXT (contenido del párrafo)
is_active           TINYINT(1) (1=activo, 0=inactivo)
display_order       INT (orden de visualización)
created_by          INT (user_id del admin)
updated_by          INT (user_id del admin)
created_at          TIMESTAMP
updated_at          TIMESTAMP
```

### Tabla: `legal_terms`

```sql
term_id             INT PK AUTO_INCREMENT
section_number      INT
section_title       VARCHAR(255)
paragraph_number    INT
paragraph_content   TEXT
is_active           TINYINT(1)
display_order       INT
created_by          INT
updated_by          INT
created_at          TIMESTAMP
updated_at          TIMESTAMP
```

### Tabla: `legal_metadata`

```sql
meta_id             INT PK AUTO_INCREMENT
document_type       ENUM('privacy', 'terms')
last_updated        TIMESTAMP
version             VARCHAR(50) (ej: "1.0", "1.1")
effective_date      DATE (fecha de vigencia)
updated_by          INT
change_log          TEXT (registro de cambios)
```

---

## 📝 Datos Iniciales

El archivo `create_legal_tables.sql` incluye **datos de ejemplo completos** basados en el contenido que proporcionaste:

### Política de Privacidad:

- ✅ 8 secciones
- ✅ 35 párrafos
- ✅ Metadata v1.0

### Términos y Condiciones:

- ✅ 11 secciones
- ✅ 38 párrafos
- ✅ Metadata v1.0

---

## 🚀 Cómo Implementar

### 1. Ejecutar Migración SQL

```bash
# Conectar a MySQL/MariaDB
mysql -u tu_usuario -p homelab < /path/to/migrations/create_legal_tables.sql

# O desde phpMyAdmin:
# - Ir a "SQL"
# - Copiar y pegar contenido de create_legal_tables.sql
# - Ejecutar
```

### 2. Verificar Tablas Creadas

```sql
SHOW TABLES LIKE 'legal%';
-- Debe mostrar:
-- legal_metadata
-- legal_privacy
-- legal_terms

SELECT COUNT(*) FROM legal_privacy; -- 35 párrafos
SELECT COUNT(*) FROM legal_terms;   -- 38 párrafos
```

### 3. Probar APIs Públicas

```bash
# Obtener política de privacidad
curl http://localhost:3000/routes/web/privacy.php

# Obtener términos y condiciones
curl http://localhost:3000/routes/web/terms.php
```

**Respuesta esperada:**

```json
{
  "status": "success",
  "message": "Política de privacidad obtenida",
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
        "paragraphs": [...]
      }
    ],
    "total_sections": 8
  }
}
```

### 4. Acceder al Editor (Admin)

1. Iniciar sesión como administrador (role_id = 2)
2. Ir a `/dashboard/settings`
3. Click en tab "Política de Privacidad" o "Términos y Condiciones"
4. Editar contenido con los botones:
   - ✏️ Editar párrafo
   - 🗑️ Eliminar párrafo
   - ➕ Nuevo párrafo
   - 💾 Guardar metadata

### 5. Actualizar Vistas Públicas

Reemplazar archivos actuales (opcional):

```bash
# Hacer backup
mv /views/privacy.view.php /views/privacy-old.view.php
mv /views/terms.view.php /views/terms-old.view.php

# Usar versiones dinámicas
mv /views/privacy-dynamic.view.php /views/privacy.view.php
# (crear terms-dynamic.view.php similar a privacy-dynamic.view.php)
```

---

## 🔐 Seguridad

### Control de Acceso:

- ✅ APIs admin requieren autenticación (`Auth::checkAuth()`)
- ✅ Verificación de rol administrador (`role_id = 2`)
- ✅ Usuario debe estar activo (`Status::checkStatus(1)`)
- ✅ Logging de cambios (created_by, updated_by)

### Validación de Datos:

- ✅ Campos requeridos validados
- ✅ IDs verificados antes de actualizar/eliminar
- ✅ Soft delete (no elimina registros, marca como inactivo)

---

## 📊 Ejemplo de Uso (Admin)

### Crear Nuevo Párrafo:

```javascript
await window.AppRouter.post("/routes/privacy/up_privacy.php", {
  operation: "create",
  section_number: 9,
  section_title: "Nueva Sección",
  paragraph_number: 1,
  paragraph_content: "Contenido del nuevo párrafo...",
  is_active: 1,
  display_order: 99,
});
```

### Actualizar Párrafo Existente:

```javascript
await window.AppRouter.post("/routes/privacy/up_privacy.php", {
  operation: "update",
  privacy_id: 15,
  paragraph_content: "Contenido actualizado...",
  is_active: 1,
});
```

### Actualizar Metadata:

```javascript
await window.AppRouter.post("/routes/privacy/up_privacy.php", {
  operation: "update_metadata",
  version: "1.1",
  effective_date: "2025-12-01",
  change_log: "Se actualizó la sección 3 con nuevas medidas de seguridad",
});
```

---

## ✅ Checklist de Implementación

- [x] Crear tablas SQL
- [x] Crear modelos backend
- [x] Crear rutas API públicas
- [x] Crear rutas API admin
- [x] Crear editor JavaScript
- [x] Modificar settings.page.php
- [x] Crear vista dinámica privacy
- [ ] Crear vista dinámica terms (pendiente)
- [ ] Actualizar sidebar con acceso a settings
- [ ] Testing completo
- [ ] Documentación de API

---

## 🎯 Próximos Pasos

1. **Completar vista de términos dinámica** (copiar de privacy-dynamic.view.php)
2. **Implementar funciones de edición para términos** en legal-editor.js
3. **Agregar búsqueda/filtrado** en el editor
4. **Preview en tiempo real** antes de publicar
5. **Historial de versiones** (changelog automático)
6. **Export/Import** en formato JSON

---

**Desarrollado por:** Roepard Labs Development Team  
**Fecha:** Noviembre 6, 2025  
**Versión:** 1.0  
**Estado:** ✅ Backend Completo | 🔄 Frontend 80% Completo
