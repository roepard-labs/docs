# 🚀 Guía Rápida: Sistema de Contenido Legal

## 📥 Instalación en 5 Pasos

### 1️⃣ Ejecutar Migraciones SQL

```bash
# Opción A: Script automático (recomendado)
cd scripts
chmod +x install-legal-system.sh
./install-legal-system.sh

# Opción B: Manual con MySQL
mysql -u tu_usuario -p homelab < thepearlo_vr-backend/migrations/create_legal_tables.sql
```

### 2️⃣ Verificar Tablas Creadas

```sql
USE homelab;
SHOW TABLES LIKE 'legal%';
-- Debe mostrar: legal_metadata, legal_privacy, legal_terms

SELECT COUNT(*) FROM legal_privacy; -- 35 párrafos
SELECT COUNT(*) FROM legal_terms;   -- 38 párrafos
```

### 3️⃣ Probar APIs Públicas

```bash
# API de Privacidad
curl http://localhost:3000/routes/web/privacy.php

# API de Términos
curl http://localhost:3000/routes/web/terms.php
```

### 4️⃣ Acceder al Editor (Admin)

1. Login como **administrador** (role_id = 2)
2. Ir a `/dashboard/settings`
3. Click en tab **"Política de Privacidad"** o **"Términos y Condiciones"**

### 5️⃣ Usar Vistas Dinámicas (Opcional)

Si deseas que `/privacy` y `/terms` carguen desde la API:

```bash
# Renombrar vistas actuales
mv views/privacy.view.php views/privacy-static.view.php.bak
mv views/terms.view.php views/terms-static.view.php.bak

# Usar versiones dinámicas
mv views/privacy-dynamic.view.php views/privacy.view.php
# Crear terms-dynamic.view.php (copiar de privacy-dynamic.view.php)
```

---

## 🎨 Cómo Usar el Editor

### Editar Metadata del Documento

1. En el tab correspondiente, ve a la sección **"Información del Documento"**
2. Edita:
   - **Versión**: Ej. "1.0", "1.1", "2.0"
   - **Fecha de Vigencia**: Fecha desde la cual aplica
   - **Registro de Cambios**: Descripción de cambios realizados
3. Click **"Guardar Metadata"**

### Editar un Párrafo

1. Busca el párrafo en la lista
2. Click botón **✏️ Editar**
3. En el modal, modifica:
   - Número de sección
   - Título de sección
   - Número de párrafo
   - Contenido del párrafo
   - Orden de visualización
   - Estado (Activo/Inactivo)
4. Click **"Guardar Cambios"**

### Eliminar un Párrafo

1. Click botón **🗑️ Eliminar**
2. Confirmar eliminación
3. El párrafo se elimina de la base de datos

### ➕ Crear Nuevo Párrafo

1. Click botón **"Nuevo Párrafo"**
2. En el modal SweetAlert2, completar:
   - **Número de Sección**: Número entero (Ej: 8)
   - **Título de Sección**: Título descriptivo (Ej: "Nuevas Políticas")
   - **Número de Párrafo**: Número entero (Ej: 1)
   - **Contenido**: Texto del párrafo (requerido)
   - **Orden de Visualización**: Número para ordenar (Ej: 100)
   - **Activo**: Checkbox para habilitar inmediatamente
3. Click **"Crear Párrafo"**
4. ✅ Notificación de éxito
5. Editor se recarga automáticamente con el nuevo contenido

**Tip**: Usa un `display_order` alto (ej: 100) para nuevos párrafos para evitar colisiones.

---

## 🔑 APIs Disponibles

### 🌐 APIs Públicas (sin autenticación)

#### GET /routes/web/privacy.php

Obtiene contenido activo de política de privacidad.

**Respuesta:**

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

#### GET /routes/web/terms.php

Obtiene contenido activo de términos y condiciones.

---

### 🔒 APIs Admin (requieren autenticación)

#### GET /routes/privacy/list_privacy.php

Lista **todo** el contenido de privacidad (incluye inactivos).

**Headers:**

```
Cookie: PHPSESSID=...
```

**Requiere:**

- Autenticado
- role_id = 2 (admin)

---

#### POST /routes/privacy/up_privacy.php

Crea, actualiza o elimina párrafos de privacidad.

**Operaciones:**

##### Crear Párrafo

```json
{
  "operation": "create",
  "section_number": 9,
  "section_title": "Nueva Sección",
  "paragraph_number": 1,
  "paragraph_content": "Contenido del párrafo...",
  "is_active": 1,
  "display_order": 99
}
```

##### Actualizar Párrafo

```json
{
  "operation": "update",
  "privacy_id": 15,
  "paragraph_content": "Contenido actualizado...",
  "is_active": 1
}
```

##### Eliminar Párrafo (Soft Delete)

```json
{
  "operation": "delete",
  "privacy_id": 15
}
```

##### Actualizar Metadata

```json
{
  "operation": "update_metadata",
  "version": "1.1",
  "effective_date": "2025-12-01",
  "change_log": "Se actualizó la sección 3..."
}
```

---

#### GET /routes/legal/list_legal.php

Lista **todo** el contenido de términos (incluye inactivos).

---

#### POST /routes/legal/up_legal.php

Crea, actualiza o elimina párrafos de términos.

**Operaciones:** (Iguales a privacy pero con `term_id`)

---

## 📊 Estructura de Datos

### Tabla: legal_privacy / legal_terms

| Campo              | Tipo         | Descripción                      |
| ------------------ | ------------ | -------------------------------- |
| privacy_id/term_id | INT PK       | ID único del párrafo             |
| section_number     | INT          | Número de sección (1, 2, 3...)   |
| section_title      | VARCHAR(255) | Título de la sección             |
| paragraph_number   | INT          | Número del párrafo en la sección |
| paragraph_content  | TEXT         | Contenido del párrafo            |
| is_active          | TINYINT(1)   | 1 = Activo, 0 = Inactivo         |
| display_order      | INT          | Orden de visualización           |
| created_by         | INT          | ID del admin que creó            |
| updated_by         | INT          | ID del admin que actualizó       |
| created_at         | TIMESTAMP    | Fecha de creación                |
| updated_at         | TIMESTAMP    | Fecha de actualización           |

### Tabla: legal_metadata

| Campo          | Tipo                    | Descripción                |
| -------------- | ----------------------- | -------------------------- |
| meta_id        | INT PK                  | ID único                   |
| document_type  | ENUM('privacy','terms') | Tipo de documento          |
| last_updated   | TIMESTAMP               | Última actualización       |
| version        | VARCHAR(50)             | Versión del documento      |
| effective_date | DATE                    | Fecha de vigencia          |
| updated_by     | INT                     | ID del admin que actualizó |
| change_log     | TEXT                    | Registro de cambios        |

---

## 🔧 Solución de Problemas

### ❌ Error: "Notyf is not defined"

**Síntoma en consola:**

```javascript
ReferenceError: notyf is not defined
    at updatePrivacyMetadata (legal-editor.js:305:17)
```

**Causa:** Timing de carga - Notyf no está disponible cuando el script lo necesita.

**Solución:**
El sistema ahora inicializa Notyf automáticamente con reintentos. Si persiste:

1. Verificar que Notyf esté instalado:

   ```bash
   npm install notyf
   ```

2. Verificar consola del navegador:

   ```
   ✅ Notyf inicializado en legal-editor.js
   ```

3. Si ves errores después de 20 intentos:
   ```
   ❌ No se pudo inicializar Notyf después de 20 intentos
   ```
   - Verificar que AppLayout cargue Notyf en `$cssCore` y `$jsCore`
   - Verificar que `/node_modules/notyf/` exista

**Ver:** [FIX-NOTYF-LEGAL-EDITOR.md](./FIX-NOTYF-LEGAL-EDITOR.md) para detalles completos.

### ❌ Error: "addNewPrivacyParagraph is not defined"

```
Uncaught ReferenceError: addNewPrivacyParagraph is not defined
```

**Solución:**

- ✅ **FIXED**: Funciones implementadas en legal-editor.js
- Verificar que legal-editor.js se cargue correctamente
- Verificar en consola: `typeof window.addNewPrivacyParagraph` debe retornar `'function'`

**Ver:** [FIX-LEGAL-EDITOR-ADD-PARAGRAPH.md](./FIX-LEGAL-EDITOR-ADD-PARAGRAPH.md) para detalles.

### ❌ Problema: Loading spinner no desaparece

```
El spinner "Cargando contenido..." se queda visible permanentemente
```

**Solución:**

- ✅ **FIXED**: Gestión de visibilidad implementada en loadPrivacyAdmin() y loadTermsAdmin()
- Verificar que `#privacy-loading` / `#terms-loading` se oculten después de cargar
- Verificar que `#privacy-editor-container` / `#terms-editor-container` se muestren

**Ver:** [FIX-LEGAL-EDITOR-ADD-PARAGRAPH.md](./FIX-LEGAL-EDITOR-ADD-PARAGRAPH.md) para detalles.

---

### ❌ Error: "Tablas no encontradas"

```bash
# Verificar que las tablas existan
mysql -u usuario -p
USE homelab;
SHOW TABLES LIKE 'legal%';
```

### ❌ Error: "Acceso denegado al editor"

- Verifica que el usuario tenga `role_id = 2` (admin)
- Verifica que la sesión esté activa
- Revisa logs del navegador (F12)

### ❌ Error: "AppRouter is not defined"

- Asegúrate de que `router.js` se cargue antes
- Verifica que `config.js` esté cargado
- Revisa orden de scripts en AppLayout.php

### ❌ Error: "CORS policy"

- Verifica que `/config/cors.php` esté configurado correctamente
- Verifica que el backend tenga:
  ```php
  header("Access-Control-Allow-Origin: http://localhost:9000");
  header("Access-Control-Allow-Credentials: true");
  ```

---

## 📚 Documentación Completa

Para más detalles, consulta:

- **[LEGAL-CONTENT-SYSTEM.md](./LEGAL-CONTENT-SYSTEM.md)** - Documentación técnica completa
- **[FIX-NOTYF-LEGAL-EDITOR.md](./FIX-NOTYF-LEGAL-EDITOR.md)** - Fix de Notyf no disponible
- **[FIX-LEGAL-EDITOR-ADD-PARAGRAPH.md](./FIX-LEGAL-EDITOR-ADD-PARAGRAPH.md)** - Fix de funciones crear párrafo y loading state
- **Backend Models:** `/thepearlo_vr-backend/models/Legal*.php`
- **Backend Routes:** `/thepearlo_vr-backend/routes/privacy/` y `/routes/legal/`
- **Frontend Editor:** `/thepearlo_vr-website/js/legal-editor.js`

---

## 🎯 Próximas Mejoras

- [ ] Búsqueda/filtrado en el editor
- [ ] Preview en tiempo real
- [ ] Historial de versiones
- [ ] Export/Import JSON
- [ ] Comparación de versiones
- [ ] Restaurar párrafos eliminados

---

**Desarrollado por:** Roepard Labs  
**Versión:** 1.0  
**Fecha:** Noviembre 6, 2025
