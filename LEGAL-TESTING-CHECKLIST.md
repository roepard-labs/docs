# ✅ Checklist de Testing: Sistema de Contenido Legal

## 📋 Testing Completo del Sistema

### Fase 1: Instalación y Configuración

- [ ] **Migración de Base de Datos**
  - [ ] Ejecutar `install-legal-system.sh`
  - [ ] Verificar creación de 3 tablas: `legal_privacy`, `legal_terms`, `legal_metadata`
  - [ ] Verificar 35 registros en `legal_privacy`
  - [ ] Verificar 38 registros en `legal_terms`
  - [ ] Verificar 2 registros de metadata (privacy + terms)
  - [ ] Verificar índices creados correctamente

```bash
# Verificar tablas
mysql -u usuario -p
USE homelab;
SHOW TABLES LIKE 'legal%';
SELECT COUNT(*) FROM legal_privacy;
SELECT COUNT(*) FROM legal_terms;
SELECT COUNT(*) FROM legal_metadata;
```

---

### Fase 2: Testing de APIs Públicas (Sin Autenticación)

#### API Privacy (GET /routes/web/privacy.php)

- [ ] **Request Básico**
  ```bash
  curl http://localhost:3000/routes/web/privacy.php
  ```
- [ ] **Verificar Respuesta**

  - [ ] Status: "success"
  - [ ] Campo `data.metadata` existe
  - [ ] Campo `data.sections` es array
  - [ ] Campo `data.total_sections` = 8
  - [ ] Metadata incluye: version, effective_date, last_updated
  - [ ] Cada sección incluye: section_number, section_title, paragraphs[]
  - [ ] Solo párrafos activos (is_active = 1)

- [ ] **Verificar Orden**
  - [ ] Secciones ordenadas por section_number
  - [ ] Párrafos ordenados por display_order dentro de cada sección

#### API Terms (GET /routes/web/terms.php)

- [ ] **Request Básico**

  ```bash
  curl http://localhost:3000/routes/web/terms.php
  ```

- [ ] **Verificar Respuesta**
  - [ ] Status: "success"
  - [ ] Campo `data.metadata` existe
  - [ ] Campo `data.sections` es array
  - [ ] Campo `data.total_sections` = 11
  - [ ] Solo párrafos activos

---

### Fase 3: Testing de APIs Admin (Con Autenticación)

**Requisitos Previos:**

- Usuario con role_id = 2 (admin)
- Sesión activa (cookie PHPSESSID)

#### API List Privacy (GET /routes/privacy/list_privacy.php)

- [ ] **Request Sin Autenticación**

  ```bash
  curl http://localhost:3000/routes/privacy/list_privacy.php
  ```

  - [ ] Debe retornar error de autenticación

- [ ] **Request Con Autenticación (Admin)**

  ```bash
  curl -b "PHPSESSID=tu_session_id" \
       http://localhost:3000/routes/privacy/list_privacy.php
  ```

  - [ ] Status: "success"
  - [ ] Retorna ALL paragraphs (incluye is_active = 0)
  - [ ] Incluye metadata

- [ ] **Request Con Usuario No-Admin (role_id != 2)**
  - [ ] Debe retornar error de permisos

#### API Update Privacy (POST /routes/privacy/up_privacy.php)

**Operación: CREATE**

- [ ] **Crear Nuevo Párrafo**
  ```bash
  curl -X POST http://localhost:3000/routes/privacy/up_privacy.php \
       -b "PHPSESSID=tu_session_id" \
       -H "Content-Type: application/json" \
       -d '{
         "operation": "create",
         "section_number": 9,
         "section_title": "Sección de Test",
         "paragraph_number": 1,
         "paragraph_content": "Este es un párrafo de prueba.",
         "is_active": 1,
         "display_order": 999
       }'
  ```
  - [ ] Status: "success"
  - [ ] Retorna privacy_id del nuevo registro
  - [ ] Verificar en BD que el registro existe

**Operación: UPDATE**

- [ ] **Actualizar Párrafo Existente**
  ```bash
  curl -X POST http://localhost:3000/routes/privacy/up_privacy.php \
       -b "PHPSESSID=tu_session_id" \
       -H "Content-Type: application/json" \
       -d '{
         "operation": "update",
         "privacy_id": [ID_CREADO],
         "paragraph_content": "Contenido actualizado.",
         "is_active": 1
       }'
  ```
  - [ ] Status: "success"
  - [ ] Verificar cambio en BD

**Operación: DELETE (Soft Delete)**

- [ ] **Eliminar Párrafo**
  ```bash
  curl -X POST http://localhost:3000/routes/privacy/up_privacy.php \
       -b "PHPSESSID=tu_session_id" \
       -H "Content-Type: application/json" \
       -d '{
         "operation": "delete",
         "privacy_id": [ID_CREADO]
       }'
  ```
  - [ ] Status: "success"
  - [ ] Verificar is_active = 0 en BD
  - [ ] Párrafo NO aparece en API pública
  - [ ] Párrafo SÍ aparece en API admin

**Operación: UPDATE_METADATA**

- [ ] **Actualizar Metadata**
  ```bash
  curl -X POST http://localhost:3000/routes/privacy/up_privacy.php \
       -b "PHPSESSID=tu_session_id" \
       -H "Content-Type: application/json" \
       -d '{
         "operation": "update_metadata",
         "version": "1.1",
         "effective_date": "2025-12-01",
         "change_log": "Se actualizó la sección de test"
       }'
  ```
  - [ ] Status: "success"
  - [ ] Verificar cambios en tabla legal_metadata

#### API List/Update Terms (Similares a Privacy)

- [ ] **GET /routes/legal/list_legal.php**

  - [ ] Requiere autenticación
  - [ ] Retorna todos los términos

- [ ] **POST /routes/legal/up_legal.php**
  - [ ] Operación CREATE funciona
  - [ ] Operación UPDATE funciona
  - [ ] Operación DELETE funciona
  - [ ] Operación UPDATE_METADATA funciona

---

### Fase 4: Testing de Vistas Dinámicas

#### Vista Privacy (/privacy)

- [ ] **Navegación**

  - [ ] Acceder a http://localhost:9000/privacy
  - [ ] Debe cargar sin errores

- [ ] **Estado de Loading**

  - [ ] Spinner visible al inicio
  - [ ] Mensaje "Cargando política de privacidad..."

- [ ] **Contenido Renderizado**

  - [ ] Título: "Política de Privacidad"
  - [ ] Metadata visible (versión, vigencia, última actualización)
  - [ ] 8 secciones renderizadas
  - [ ] Secciones con títulos y párrafos
  - [ ] Animaciones AOS funcionan

- [ ] **Manejo de Errores**
  - [ ] Detener backend temporalmente
  - [ ] Recargar /privacy
  - [ ] Debe mostrar mensaje de error
  - [ ] Botón "Reintentar" funciona

#### Vista Terms (/terms)

- [ ] **Navegación**

  - [ ] Acceder a http://localhost:9000/terms
  - [ ] Debe cargar sin errores

- [ ] **Estado de Loading**

  - [ ] Spinner visible al inicio

- [ ] **Contenido Renderizado**
  - [ ] Título: "Términos y Condiciones"
  - [ ] Metadata visible
  - [ ] 11 secciones renderizadas
  - [ ] Contenido correcto

---

### Fase 5: Testing del Editor Admin

**Requisitos Previos:**

- Login como admin (role_id = 2)
- Navegar a `/dashboard/settings`

#### Tab "Política de Privacidad"

- [ ] **Carga Inicial**

  - [ ] Click en tab "Política de Privacidad"
  - [ ] Debe cargar contenido automáticamente
  - [ ] Loading spinner visible durante carga
  - [ ] Verificar en consola: "📄 Cargando privacidad..."
  - [ ] Verificar en consola: "✅ Privacidad cargada"

- [ ] **Card de Metadata**

  - [ ] Versión visible
  - [ ] Fecha de vigencia visible
  - [ ] Última actualización visible
  - [ ] Registro de cambios visible
  - [ ] Botón "Guardar Metadata" funciona

- [ ] **Lista de Secciones**

  - [ ] 8 secciones renderizadas
  - [ ] Cada sección con título
  - [ ] Cada sección con lista de párrafos
  - [ ] Párrafos muestran número y contenido
  - [ ] Badge verde/rojo para estado activo/inactivo

- [ ] **Editar Párrafo**

  - [ ] Click en botón "Editar" de cualquier párrafo
  - [ ] Modal SweetAlert2 aparece
  - [ ] Formulario con todos los campos:
    - [ ] Número de sección
    - [ ] Título de sección
    - [ ] Número de párrafo
    - [ ] Contenido (textarea)
    - [ ] Orden de visualización
    - [ ] Checkbox "Activo"
  - [ ] Modificar contenido
  - [ ] Click "Guardar Cambios"
  - [ ] Notificación Notyf: "Párrafo actualizado exitosamente"
  - [ ] Lista se recarga automáticamente
  - [ ] Cambios reflejados en la lista

- [ ] **Eliminar Párrafo**

  - [ ] Click en botón "Eliminar" de cualquier párrafo
  - [ ] Modal de confirmación aparece
  - [ ] Click "Sí, eliminar"
  - [ ] Notificación: "Párrafo eliminado exitosamente"
  - [ ] Párrafo ahora muestra badge "Inactivo"
  - [ ] Verificar que NO aparece en vista pública

- [ ] **Actualizar Metadata**
  - [ ] Cambiar versión (ej. "1.0" → "1.1")
  - [ ] Cambiar fecha de vigencia
  - [ ] Agregar texto en "Registro de cambios"
  - [ ] Click "Guardar Metadata"
  - [ ] Notificación: "Metadata actualizada exitosamente"
  - [ ] Verificar cambios en BD
  - [ ] Verificar cambios en vista pública

#### Tab "Términos y Condiciones"

- [ ] **Carga Inicial**

  - [ ] Click en tab "Términos y Condiciones"
  - [ ] Debe cargar contenido automáticamente
  - [ ] Verificar en consola: "📄 Cargando términos..."

- [ ] **Card de Metadata**

  - [ ] Versión visible
  - [ ] Datos correctos

- [ ] **Lista de Secciones**

  - [ ] 11 secciones renderizadas

- [ ] **Editar Párrafo**

  - [ ] Click en botón "Editar"
  - [ ] Modal aparece con formulario
  - [ ] Modificar y guardar
  - [ ] Notificación de éxito
  - [ ] Lista recarga

- [ ] **Eliminar Párrafo**

  - [ ] Click en botón "Eliminar"
  - [ ] Confirmación
  - [ ] Eliminación exitosa

- [ ] **Actualizar Metadata**
  - [ ] Guardar cambios
  - [ ] Verificar actualización

---

### Fase 6: Testing de Integración

#### Flujo Completo: Editar Privacy

1. [ ] **Admin edita contenido**

   - Login como admin
   - Ir a /dashboard/settings
   - Tab "Política de Privacidad"
   - Editar párrafo #1 de sección #1
   - Cambiar contenido a "EDITADO PARA TEST"
   - Guardar

2. [ ] **Verificar en BD**

   ```sql
   SELECT paragraph_content FROM legal_privacy WHERE privacy_id = 1;
   ```

   - [ ] Debe mostrar "EDITADO PARA TEST"

3. [ ] **Verificar en API Admin**

   ```bash
   curl -b "PHPSESSID=..." http://localhost:3000/routes/privacy/list_privacy.php
   ```

   - [ ] Debe incluir el texto editado

4. [ ] **Verificar en API Pública**

   ```bash
   curl http://localhost:3000/routes/web/privacy.php
   ```

   - [ ] Debe incluir el texto editado

5. [ ] **Verificar en Vista Pública**
   - Navegar a /privacy
   - [ ] Debe mostrar "EDITADO PARA TEST" en sección 1

#### Flujo Completo: Soft Delete

1. [ ] **Admin elimina párrafo**

   - Eliminar párrafo de test creado anteriormente

2. [ ] **Verificar en BD**

   ```sql
   SELECT is_active FROM legal_privacy WHERE privacy_id = [ID];
   ```

   - [ ] Debe ser `0`

3. [ ] **Verificar en API Pública**

   - [ ] Párrafo NO debe aparecer

4. [ ] **Verificar en API Admin**

   - [ ] Párrafo SÍ debe aparecer (con is_active = 0)

5. [ ] **Verificar en Vista Pública**
   - [ ] Párrafo NO debe aparecer

---

### Fase 7: Testing de Seguridad

#### Autenticación y Autorización

- [ ] **Usuario No Autenticado**

  - [ ] Intentar acceder a /routes/privacy/list_privacy.php sin sesión
  - [ ] Debe retornar error 401 o mensaje de no autenticado

- [ ] **Usuario No Admin (role_id = 1)**

  - [ ] Login como usuario normal
  - [ ] Intentar acceder a editor en /dashboard/settings
  - [ ] Tab de Privacy/Terms debe mostrar "Acceso denegado" o redirigir

- [ ] **Usuario Admin (role_id = 2)**
  - [ ] Login como admin
  - [ ] Debe tener acceso completo al editor

#### Validación de Datos

- [ ] **Crear Párrafo con Datos Inválidos**

  ```json
  {
    "operation": "create",
    "section_number": "",
    "paragraph_content": ""
  }
  ```

  - [ ] Debe retornar error de validación

- [ ] **Update sin privacy_id**
  ```json
  {
    "operation": "update",
    "paragraph_content": "Test"
  }
  ```
  - [ ] Debe retornar error

#### Inyección SQL

- [ ] **Content con comillas**
  ```json
  {
    "operation": "create",
    "paragraph_content": "Test con 'comillas' y \"dobles\""
  }
  ```
  - [ ] Debe guardar correctamente sin error SQL

#### XSS Prevention

- [ ] **Content con HTML/JavaScript**
  ```json
  {
    "paragraph_content": "<script>alert('XSS')</script>"
  }
  ```
  - [ ] Al renderizar en vista pública, debe escaparse el HTML
  - [ ] No debe ejecutarse JavaScript

---

### Fase 8: Testing de Performance

- [ ] **Tiempo de Carga de APIs**

  - [ ] /routes/web/privacy.php < 500ms
  - [ ] /routes/web/terms.php < 500ms
  - [ ] /routes/privacy/list_privacy.php < 1s
  - [ ] /routes/legal/list_legal.php < 1s

- [ ] **Renderizado de Vistas**

  - [ ] /privacy carga en < 2s
  - [ ] /terms carga en < 2s
  - [ ] Editor carga en < 2s

- [ ] **Operaciones CRUD**
  - [ ] Create < 300ms
  - [ ] Update < 300ms
  - [ ] Delete < 300ms

---

### Fase 9: Testing Cross-Browser

- [ ] **Chrome**

  - [ ] Vista pública funciona
  - [ ] Editor funciona
  - [ ] Animaciones AOS funcionan

- [ ] **Firefox**

  - [ ] Vista pública funciona
  - [ ] Editor funciona

- [ ] **Safari**

  - [ ] Vista pública funciona
  - [ ] Editor funciona

- [ ] **Edge**
  - [ ] Vista pública funciona
  - [ ] Editor funciona

---

### Fase 10: Testing Responsive

- [ ] **Mobile (320px)**

  - [ ] Vista pública legible
  - [ ] Editor usable
  - [ ] Modales se ajustan

- [ ] **Tablet (768px)**

  - [ ] Layout correcto
  - [ ] Editor funcional

- [ ] **Desktop (1920px)**
  - [ ] Diseño óptimo
  - [ ] Todas las funcionalidades

---

## 🐛 Registro de Bugs Encontrados

| #   | Descripción | Prioridad | Estado | Solución |
| --- | ----------- | --------- | ------ | -------- |
| 1   |             |           |        |          |
| 2   |             |           |        |          |
| 3   |             |           |        |          |

---

## ✅ Resumen de Testing

**Fecha de Última Actualización:** ******\_\_\_******

**Tests Pasados:** **\_** / **\_**  
**Tests Fallidos:** **\_**  
**Tests Pendientes:** **\_**

**Estado General:** [ ] APROBADO [ ] RECHAZADO [ ] EN PROGRESO

**Comentarios:**

```
[Espacio para notas adicionales del testing]
```

---

**Responsable de Testing:** ******\_\_\_******  
**Firma:** ******\_\_\_******  
**Fecha:** ******\_\_\_******
