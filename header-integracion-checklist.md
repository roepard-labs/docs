# ✅ Checklist: Integrar Header Dinámico en Otras Vistas

## 📋 Pasos de Integración

### ✅ **Paso 1: Verificar que la vista incluye el header**
```php
<?php include __DIR__ . '/../ui/header.ui.php'; ?>
```

**Ubicación común:**
- Al inicio del archivo, después del `<!DOCTYPE html>`
- O dentro del `<body>` si es un template

**Ejemplo:**
```php
<!DOCTYPE html>
<html lang="es">
<head>
    <!-- Meta tags y CSS -->
</head>
<body>
    <?php include __DIR__ . '/../ui/header.ui.php'; ?>
    
    <!-- Contenido de la vista -->
</body>
</html>
```

---

### ✅ **Paso 2: Verificar que Bootstrap 5 está cargado**
```html
<script src="../dist/bootstrap/js/bootstrap.min.js"></script>
```

**Importante:**
- Debe cargarse **antes** de `header-auth.js`
- Usualmente va al final del `</body>`

**Ejemplo:**
```html
<!-- Antes de cerrar </body> -->
<script src="../dist/jquery/jquery.min.js"></script>
<script src="../dist/popper/popper.min.js"></script>
<script src="../dist/bootstrap/js/bootstrap.min.js"></script>
```

---

### ✅ **Paso 3: Incluir header-auth.js**
```html
<script src="../js/header-auth.js"></script>
```

**Ubicación:**
- Después de Bootstrap
- Antes de cerrar `</body>`
- Opcional: después de SweetAlert2 para mejores notificaciones

**Ejemplo:**
```html
<!-- Librerías base -->
<script src="../dist/bootstrap/js/bootstrap.min.js"></script>
<script src="../dist/sweetalert2/sweetalert2.all.min.js"></script>

<!-- Header Auth (debe ir después de Bootstrap) -->
<script src="../js/header-auth.js"></script>

<!-- Scripts específicos de la vista -->
<script src="../js/mi-vista.js"></script>
</body>
</html>
```

---

### ✅ **Paso 4: (Opcional) Agregar SweetAlert2 para mejores notificaciones**
```html
<link href="../dist/sweetalert2/sweetalert2.min.css" rel="stylesheet">
<script src="../dist/sweetalert2/sweetalert2.all.min.js"></script>
```

**Beneficios:**
- Alertas más elegantes
- Confirmación de logout con estilo
- Notificaciones modernas

**Sin SweetAlert2:**
- El sistema funciona igual
- Usa `alert()` y `confirm()` nativos

---

## 🎯 Vistas Prioritarias para Integrar

### 1. **admin.dashboard.view.php** 🔴 ALTA PRIORIDAD
```php
<?php include __DIR__ . '/../ui/header.ui.php'; ?>

<!-- Contenido del dashboard -->

<!-- Antes de </body> -->
<script src="../dist/bootstrap/js/bootstrap.min.js"></script>
<script src="../js/header-auth.js"></script>
</body>
```

### 2. **user.dashboard.view.php** 🔴 ALTA PRIORIDAD
```php
<?php include __DIR__ . '/../ui/header.ui.php'; ?>

<!-- Contenido del dashboard -->

<!-- Antes de </body> -->
<script src="../dist/bootstrap/js/bootstrap.min.js"></script>
<script src="../js/header-auth.js"></script>
</body>
```

### 3. **homelab.php** 🟡 MEDIA PRIORIDAD
```php
<?php include __DIR__ . '/../ui/header.ui.php'; ?>

<!-- Contenido VR/AR -->

<!-- Antes de </body> -->
<script src="../dist/bootstrap/js/bootstrap.min.js"></script>
<script src="../js/header-auth.js"></script>
</body>
```

### 4. **Otras vistas** 🟢 BAJA PRIORIDAD
- Cualquier vista que tenga el header
- Páginas de perfil
- Páginas de configuración

---

## 🧪 Testing por Vista

### **Checklist de pruebas:**

#### ✅ **Vista sin sesión:**
```
1. □ Abrir vista en modo incógnito
2. □ Verificar que muestra botón "Ingresar"
3. □ Click en "Ingresar" abre modal
4. □ Hacer login
5. □ Verificar que botón cambia a dropdown
```

#### ✅ **Vista con sesión activa:**
```
1. □ Login en home.view.php
2. □ Navegar a la vista
3. □ Verificar que dropdown aparece automáticamente
4. □ Click en dropdown funciona
5. □ Opciones correctas según rol
```

#### ✅ **Logout desde la vista:**
```
1. □ Con sesión activa
2. □ Click en dropdown
3. □ Click en "Cerrar Sesión"
4. □ Confirmación aparece
5. □ Logout exitoso
6. □ Botón vuelve a "Ingresar"
```

---

## 📊 Estado de Integración

### ✅ **Ya Integrado:**
- [x] home.view.php
- [x] header.ui.php (actualizado)
- [x] auth.modal.php (actualizado)

### ⏳ **Pendiente de Integrar:**
- [ ] admin.dashboard.view.php
- [ ] user.dashboard.view.php
- [ ] homelab.php
- [ ] Otras vistas personalizadas

---

## 🔧 Template de Integración

### **Plantilla para copiar/pegar:**

```php
<!DOCTYPE html>
<html lang="es" data-bs-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mi Vista - HomeLab AR</title>
    
    <!-- CSS -->
    <link href="../css/variables.css" rel="stylesheet">
    <link href="../css/main.css" rel="stylesheet">
    <link href="../dist/bootstrap/css/bootstrap.min.css" rel="stylesheet">
    <link href="../dist/boxicons/fonts/basic/boxicons.min.css" rel="stylesheet">
    <link href="../dist/sweetalert2/sweetalert2.min.css" rel="stylesheet">
</head>
<body>
    <!-- Header Global -->
    <?php include __DIR__ . '/../ui/header.ui.php'; ?>
    
    <!-- Contenido Principal -->
    <main class="container mt-4">
        <h1>Mi Contenido</h1>
        <!-- Tu contenido aquí -->
    </main>
    
    <!-- Footer Global -->
    <?php include __DIR__ . '/../ui/footer.ui.php'; ?>
    
    <!-- Modal de Autenticación -->
    <?php include __DIR__ . '/../modals/auth.modal.php'; ?>
    
    <!-- Scripts Base -->
    <script src="../dist/jquery/jquery.min.js"></script>
    <script src="../dist/popper/popper.min.js"></script>
    <script src="../dist/bootstrap/js/bootstrap.min.js"></script>
    <script src="../dist/sweetalert2/sweetalert2.all.min.js"></script>
    
    <!-- Header Auth (Sistema Dinámico) -->
    <script src="../js/header-auth.js"></script>
    
    <!-- Scripts específicos de esta vista -->
    <script src="../js/mi-vista.js"></script>
</body>
</html>
```

---

## ⚠️ Errores Comunes

### **Error 1: Dropdown no funciona**
**Causa:** Bootstrap no cargado o cargado después de header-auth.js

**Solución:**
```html
<!-- INCORRECTO -->
<script src="../js/header-auth.js"></script>
<script src="../dist/bootstrap/js/bootstrap.min.js"></script>

<!-- CORRECTO -->
<script src="../dist/bootstrap/js/bootstrap.min.js"></script>
<script src="../js/header-auth.js"></script>
```

---

### **Error 2: Botón no cambia después del login**
**Causa:** header-auth.js no cargado

**Solución:**
```html
<!-- Verificar que existe el script -->
<script src="../js/header-auth.js"></script>

<!-- Verificar en consola -->
<script>
console.log(typeof checkUserSession); // Debe ser "function"
</script>
```

---

### **Error 3: Error 404 en check_session.php**
**Causa:** Ruta incorrecta al archivo

**Solución:**
```javascript
// En header-auth.js, verificar la ruta:
fetch('../api/routes/check_session.php', {...})

// Si la vista está en un subdirectorio diferente, ajustar:
fetch('../../api/routes/check_session.php', {...})
```

---

### **Error 4: Modal de autenticación no se incluye**
**Causa:** Falta incluir auth.modal.php

**Solución:**
```php
<!-- Agregar antes de cerrar </body> -->
<?php include __DIR__ . '/../modals/auth.modal.php'; ?>
```

---

## 🎯 Vistas que NO necesitan integración

### **Páginas públicas sin header:**
- Login standalone (si existe)
- Páginas de error (404, 500)
- Landing pages especiales
- Vistas de impresión

### **Vistas con header personalizado:**
- Editor VR (puede tener su propio header minimalista)
- Páginas en iframe
- Vistas embebidas

---

## 📚 Verificación Final

### **Checklist de integración completa:**

```
Vista: ___________________________

□ 1. Header incluido (header.ui.php)
□ 2. Bootstrap JS cargado
□ 3. header-auth.js incluido
□ 4. Modal de auth incluido (auth.modal.php)
□ 5. SweetAlert2 incluido (opcional)
□ 6. jQuery incluido (si es necesario)

Testing:
□ 7. Sin sesión: muestra "Ingresar"
□ 8. Con sesión: muestra dropdown
□ 9. Dropdown se despliega
□ 10. Opciones correctas por rol
□ 11. Logout funciona
□ 12. Animaciones suaves
□ 13. Responsive en móvil

✅ Integración completada
```

---

## 🚀 Script de Integración Rápida

### **Para desarrolladores:**

```bash
#!/bin/bash
# Script para verificar integración en una vista

VISTA=$1

echo "🔍 Verificando integración en: $VISTA"

# 1. Verificar header
if grep -q "header.ui.php" "$VISTA"; then
    echo "✅ Header incluido"
else
    echo "❌ Header NO incluido"
fi

# 2. Verificar Bootstrap
if grep -q "bootstrap.min.js" "$VISTA"; then
    echo "✅ Bootstrap JS incluido"
else
    echo "❌ Bootstrap JS NO incluido"
fi

# 3. Verificar header-auth.js
if grep -q "header-auth.js" "$VISTA"; then
    echo "✅ header-auth.js incluido"
else
    echo "❌ header-auth.js NO incluido"
fi

# 4. Verificar modal
if grep -q "auth.modal.php" "$VISTA"; then
    echo "✅ Modal de auth incluido"
else
    echo "⚠️  Modal de auth NO incluido (opcional)"
fi

echo ""
echo "🎯 Integración verificada"
```

**Uso:**
```bash
chmod +x verificar-integracion.sh
./verificar-integracion.sh /var/www/roepard-homelab/views/mi-vista.php
```

---

## 📞 Soporte

Si tienes problemas con la integración:

1. **Revisa este checklist** ☑️
2. **Verifica la consola del navegador** 🔍
3. **Consulta la documentación completa** 📚
   - `/docs/header-auth-dinamico.md`
   - `/docs/header-dinamico-resumen.md`

---

**¡Listo para integrar en todas las vistas!** 🚀
