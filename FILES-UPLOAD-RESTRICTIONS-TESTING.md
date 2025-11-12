# 🧪 Guía de Pruebas: Restricciones de Subida de Archivos

## 📋 Resumen del Sistema

**Arquitectura Implementada**:

- ✅ 4 carpetas fijas por usuario (Documentos, Música, Videos, Imágenes)
- ✅ Prohibido subir archivos en raíz
- ✅ Usuarios solo pueden subir en sus carpetas
- ✅ Admins pueden subir en carpetas de cualquier usuario
- ✅ Validación frontend + backend (defensa en profundidad)

**Fecha de Implementación**: Noviembre 2025  
**Versión**: 1.0

---

## 🎯 Casos de Prueba

### **Caso 1: Usuario Normal - Subida en Carpeta Propia** ✅

**Objetivo**: Verificar que usuario puede subir en sus carpetas

**Pasos**:

1. Login como usuario normal (user_id: 4, Juan Esteban)
2. Navegar a "Gestor de Archivos"
3. Click en botón "Subir Archivo" del header
4. Verificar selector de carpetas:
   - ✅ Muestra solo 4 carpetas (Documentos, Música, Videos, Imágenes)
   - ✅ No aparece opción "Raíz" o "root"
   - ✅ Select tiene `required` attribute
   - ✅ Placeholder: "Selecciona una carpeta..."
5. Seleccionar "Documentos"
6. Seleccionar archivo de prueba
7. Click en "Subir Archivo"

**Resultado Esperado**:

- ✅ Archivo sube exitosamente
- ✅ Aparece en carpeta "Documentos"
- ✅ Notificación de éxito
- ✅ Vista se actualiza mostrando el archivo

**Logs Backend**:

```bash
✅ Usuario 4 subió archivo a carpeta 10 (Documentos)
```

---

### **Caso 2: Usuario Normal - Intento de Subir Sin Seleccionar Carpeta** 🚫

**Objetivo**: Verificar validación frontend impide subida sin carpeta

**Pasos**:

1. Login como usuario normal
2. Click en "Subir Archivo"
3. Dejar selector en "Selecciona una carpeta..." (sin seleccionar)
4. Seleccionar archivo
5. Click en "Subir Archivo"

**Resultado Esperado**:

- ✅ Validación frontend previene subida
- ✅ Notificación Notyf: "Debes seleccionar una carpeta de destino. No se pueden subir archivos en la raíz."
- ✅ No se hace request al backend
- ✅ Modal permanece abierto

**Verificación en DevTools**:

```javascript
// En consola del navegador
// NO debe aparecer request a /routes/files/upload_file.php
```

---

### **Caso 3: Usuario Normal - Intento de Subir a Carpeta Ajena** 🚫

**Objetivo**: Verificar que backend rechaza subir en carpetas de otros usuarios

**Pre-condición**: Necesitas manipular el DOM o hacer request directo

**Pasos**:

1. Login como user_id 4 (Juan Esteban)
2. Abrir DevTools Console
3. Ejecutar bypass del frontend:

   ```javascript
   // Intentar subir a carpeta del admin (folder_id: 1)
   const formData = new FormData();
   formData.append("file", document.getElementById("fileInput").files[0]);
   formData.append("folder_id", 1); // Carpeta de admin

   fetch("http://localhost:3000/routes/files/upload_file.php", {
     method: "POST",
     credentials: "include",
     body: formData,
   })
     .then((r) => r.json())
     .then(console.log);
   ```

**Resultado Esperado**:

- ✅ Backend rechaza con HTTP 403
- ✅ Respuesta JSON:
  ```json
  {
    "status": "error",
    "message": "No tienes permiso para subir archivos a esta carpeta."
  }
  ```
- ✅ Log en backend:
  ```
  ❌ Usuario 4 intentó subir archivo a carpeta ajena: 1
  ```

---

### **Caso 4: Admin - Subida en Carpeta de Otro Usuario** ✅

**Objetivo**: Verificar que admin puede subir en carpetas de cualquier usuario

**Pasos**:

1. Login como admin (user_id: 1, uam admin)
2. Navegar a "Gestor de Archivos"
3. Click en "Subir Archivo"
4. Verificar selector:
   - ✅ Muestra todas las carpetas (16 total)
   - ✅ Carpetas de otros usuarios muestran owner: "📁 Documentos (Juan Esteban)"
   - ✅ Carpetas propias sin badge: "📁 Documentos"
5. Seleccionar "Documentos (Juan Esteban)"
6. Subir archivo

**Resultado Esperado**:

- ✅ Archivo sube exitosamente
- ✅ Aparece en carpeta de Juan Esteban
- ✅ Log backend:
  ```
  ✅ Admin 1 subió archivo a carpeta 10 (dueño: user_id 4)
  ```

---

### **Caso 5: Estado Vacío en Carpeta** 📂

**Objetivo**: Verificar mensaje dinámico en carpeta vacía

**Pasos**:

1. Login como usuario normal
2. Navegar a carpeta "Música" (vacía)
3. Verificar empty state

**Resultado Esperado**:

- ✅ Título: `Carpeta "Música" vacía`
- ✅ Texto: "Sube archivos aquí para comenzar a organizar tu contenido"
- ✅ Botón "Subir Archivo" visible
- ✅ Click en botón abre modal con "Música" pre-seleccionada (si implementado)

---

### **Caso 6: Estado Vacío en Raíz** 📁

**Objetivo**: Verificar mensaje en root vacío

**Pre-condición**: Eliminar todos los archivos de root (solo para testing)

**Pasos**:

1. Login como usuario
2. Navegar a root (Inicio)
3. Si no hay carpetas visibles, verificar empty state

**Resultado Esperado**:

- ✅ Título: "No hay carpetas"
- ✅ Texto: "Las carpetas se crean automáticamente: Documentos, Música, Videos, Imágenes"
- ✅ Botón "Subir Archivo" oculto (no se puede subir en root)

---

### **Caso 7: Intento de Subida Directa al Backend con folder_id=null** 🚫

**Objetivo**: Verificar que backend rechaza folder_id nulo/vacío

**Pasos**:

1. Usar cURL o Postman
2. Request directo al backend:
   ```bash
   curl -X POST http://localhost:3000/routes/files/upload_file.php \
     -H "Cookie: PHPSESSID=tu_session_id" \
     -F "file=@test.txt" \
     -F "folder_id="
   ```

**Resultado Esperado**:

- ✅ Backend rechaza con HTTP 400
- ✅ Respuesta JSON:
  ```json
  {
    "status": "error",
    "message": "No se pueden subir archivos en la raíz. Debes seleccionar una carpeta (Documentos, Música, Videos, Imágenes)."
  }
  ```
- ✅ Log backend:
  ```
  ❌ Intento de subir archivo en root - PROHIBIDO
  ```

---

### **Caso 8: Intento con folder_id='root' Explícito** 🚫

**Objetivo**: Verificar rechazo de valor 'root' string

**Request**:

```bash
curl -X POST http://localhost:3000/routes/files/upload_file.php \
  -H "Cookie: PHPSESSID=tu_session_id" \
  -F "file=@test.txt" \
  -F "folder_id=root"
```

**Resultado Esperado**:

- ✅ Mismo error que Caso 7
- ✅ Backend valida `$folderId === 'root'`

---

## 🔍 Validaciones Técnicas

### **Frontend Validation**

**Archivo**: `files.page.php` (línea ~1640)

**Código**:

```javascript
const folderId = document.getElementById("uploadFolder").value;

if (!folderId || folderId === "" || folderId === "root") {
  new Notyf().error(
    "Debes seleccionar una carpeta de destino. No se pueden subir archivos en la raíz."
  );
  return;
}
```

**Verificar**:

- ✅ Validación ejecuta antes de crear FormData
- ✅ Notificación Notyf aparece
- ✅ Early return previene request

---

### **Backend Validation 1: Root Check**

**Archivo**: `FileController.php` (línea ~65)

**Código**:

```php
if (empty($folderId) || $folderId === 'root') {
    error_log('❌ Intento de subir archivo en root - PROHIBIDO');
    $this->sendResponse([
        'status' => 'error',
        'message' => 'No se pueden subir archivos en la raíz. Debes seleccionar una carpeta (Documentos, Música, Videos, Imágenes).'
    ], 400);
    return;
}
```

**Verificar**:

- ✅ Validación ejecuta inmediatamente después de obtener `$folderId`
- ✅ HTTP 400 Bad Request
- ✅ Log en error_log

---

### **Backend Validation 2: Ownership Check**

**Archivo**: `FileController.php` (línea ~76)

**Código**:

```php
if (!$isAdmin) {
    require_once __DIR__ . '/../models/Folder.php';
    $folderModel = new Folder();
    $folderData = $folderModel->findById($folderId);

    if (!$folderData) {
        error_log('❌ Carpeta no encontrada: ' . $folderId);
        $this->sendResponse([
            'status' => 'error',
            'message' => 'La carpeta seleccionada no existe.'
        ], 404);
        return;
    }

    if ($folderData['user_id'] != $userId) {
        error_log('❌ Usuario ' . $userId . ' intentó subir archivo a carpeta ajena: ' . $folderId);
        $this->sendResponse([
            'status' => 'error',
            'message' => 'No tienes permiso para subir archivos a esta carpeta.'
        ], 403);
        return;
    }
}
```

**Verificar**:

- ✅ Solo ejecuta para usuarios no-admin
- ✅ Consulta BD para verificar dueño de carpeta
- ✅ HTTP 404 si carpeta no existe
- ✅ HTTP 403 si no es el dueño

---

## 📊 Matriz de Validaciones

| Escenario             | Frontend                     | Backend          | Resultado    |
| --------------------- | ---------------------------- | ---------------- | ------------ |
| Sin carpeta (vacío)   | ✅ Bloquea                   | ✅ Bloquea (400) | 🚫 Rechazado |
| folder_id='root'      | ✅ Bloquea                   | ✅ Bloquea (400) | 🚫 Rechazado |
| Carpeta propia        | ✅ Permite                   | ✅ Permite       | ✅ Exitoso   |
| Carpeta ajena (user)  | ⚠️ No disponible en selector | ✅ Bloquea (403) | 🚫 Rechazado |
| Carpeta ajena (admin) | ✅ Disponible con owner      | ✅ Permite       | ✅ Exitoso   |
| Carpeta inexistente   | ⚠️ No en selector            | ✅ Bloquea (404) | 🚫 Rechazado |

**Leyenda**:

- ✅ Exitoso = Upload permitido
- 🚫 Rechazado = Validación previene upload
- ⚠️ No disponible = UI no muestra opción

---

## 🐛 Debugging

### **Ver Logs Backend**

```bash
# En el backend
tail -f /path/to/backend/logs/error.log

# Buscar mensajes específicos
grep "❌" error.log
grep "✅" error.log
grep "Intento de subir" error.log
```

### **Ver Requests Frontend**

```javascript
// En DevTools Console
// Monitor all upload requests
const originalFetch = window.fetch;
window.fetch = function (...args) {
  if (args[0].includes("upload_file.php")) {
    console.log("🔼 Upload Request:", args);
  }
  return originalFetch.apply(this, args);
};
```

### **Verificar Selector de Carpetas**

```javascript
// En consola del navegador
const selector = document.getElementById("uploadFolder");
console.log("Carpetas disponibles:", selector.length, "opciones");
console.log(
  "Opciones:",
  Array.from(selector.options).map((o) => ({
    value: o.value,
    text: o.text,
  }))
);
```

### **Verificar Estado de Sesión**

```javascript
// Verificar rol actual
fetch("http://localhost:3000/routes/user/check_role.php", {
  credentials: "include",
})
  .then((r) => r.json())
  .then((data) => {
    console.log("Usuario:", data.user_name);
    console.log("Role ID:", data.role_id);
    console.log("Es Admin:", data.is_admin);
  });
```

---

## ✅ Checklist de Validación Completa

### **Frontend**:

- [ ] Modal muestra selector de carpetas sin opción root
- [ ] Usuario normal ve solo sus 4 carpetas
- [ ] Admin ve todas las carpetas con owner badges
- [ ] Select tiene attribute `required`
- [ ] Validación previene submit sin carpeta
- [ ] Notificación Notyf muestra error apropiado
- [ ] Empty state en carpeta muestra botón upload
- [ ] Empty state en root oculta botón upload

### **Backend**:

- [ ] Rechaza `folder_id` vacío con 400
- [ ] Rechaza `folder_id='root'` con 400
- [ ] Usuario normal: Rechaza carpeta ajena con 403
- [ ] Usuario normal: Rechaza carpeta inexistente con 404
- [ ] Admin: Permite subir en cualquier carpeta
- [ ] Logs muestran intentos de bypass

### **Base de Datos**:

- [ ] Todos los usuarios tienen 4 carpetas fijas
- [ ] Nombres: Documentos, Música, Videos, Imágenes
- [ ] Query: `SELECT user_id, COUNT(*) as carpetas FROM folders GROUP BY user_id`
- [ ] Resultado esperado: 4 carpetas por usuario

---

## 🎯 Criterios de Aceptación

**✅ Sistema completo si**:

1. Usuario normal **NO puede** subir archivos en root
2. Usuario normal **NO puede** subir en carpetas de otros
3. Usuario normal **SÍ puede** subir en sus 4 carpetas fijas
4. Admin **SÍ puede** subir en cualquier carpeta
5. Admin **VE** el nombre del dueño en carpetas ajenas
6. Frontend valida antes de request
7. Backend valida como defensa en profundidad
8. Empty states muestran mensajes contextuales
9. Logs registran intentos de bypass
10. Base de datos tiene 16 carpetas (4 × 4 usuarios)

---

## 🚀 Testing en Producción

### **Pre-Deployment Checklist**:

- [ ] Ejecutar todos los casos de prueba en localhost
- [ ] Verificar logs no muestran errores
- [ ] Backup de base de datos
- [ ] Subir cambios al servidor
- [ ] Re-ejecutar pruebas en producción
- [ ] Monitorear logs en primeras 24 horas

### **Rollback Plan**:

Si algo falla en producción:

1. Revertir `FileController.php` a versión anterior
2. Revertir `files.page.php` (frontend)
3. Verificar que uploads funcionen
4. Investigar causa raíz

---

## 📞 Soporte

**Documentación Relacionada**:

- `/docs/FILES-MANAGER-IMPLEMENTATION.md` - Implementación general
- `/docs/FILES-TESTING-GUIDE.md` - Guía de testing completa
- `/docs/ARQUITECTURA-FUNCIONAL.md` - Arquitectura del proyecto

**Logs Backend**:

- `/path/to/backend/logs/error.log`
- `/path/to/backend/logs/access.log`

---

**Última actualización**: Noviembre 2025  
**Versión**: 1.0  
**Mantenido por**: Roepard Labs Development Team
