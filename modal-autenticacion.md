# 🎨 Modal de Autenticación - HomeLab AR

## ✨ Características Implementadas

### 🔹 **Modal Moderno con Tabs Horizontales**

El modal de autenticación ahora incluye:

- ✅ **Tabs Horizontales** (Login y Register) con estilo Halfmoon CSS
- ✅ **Diseño Responsivo** - Funciona perfectamente en móvil y desktop
- ✅ **Animaciones Suaves** - Transiciones elegantes entre tabs
- ✅ **Validación en Tiempo Real** - Feedback inmediato al usuario
- ✅ **Toggle de Contraseña** - Botón para mostrar/ocultar contraseña
- ✅ **Integración con API** - Conectado con auth_user.php y reg_user.php
- ✅ **Notificaciones SweetAlert2** - Alertas modernas y elegantes
- ✅ **Loading States** - Indicadores de carga durante el envío

---

## 📦 Archivos Creados/Modificados

### 1. `/modals/auth.modal.php` ✨ **NUEVO**
Modal completo con:
- Tabs de Login y Register
- Formularios validados
- Integración con backend
- Estilos inline con variables CSS
- JavaScript para manejo de formularios

### 2. `/ui/header.ui.php` 🔄 **ACTUALIZADO**
Botón de "Ingresar" mejorado:
- Gradiente de colores aqua
- Efecto de onda al hacer hover
- Abre el modal al hacer clic
- Animación de shadow

### 3. `/views/home.view.php` 🔄 **ACTUALIZADO**
- Incluye el nuevo modal
- Agregadas variables CSS
- Botón "Sign in" en CTA section actualizado

---

## 🎨 Diseño del Modal

### **Tab: Iniciar Sesión**
```
┌─────────────────────────────────────┐
│  🔐 Acceso al Sistema              │
│  Inicia sesión o crea cuenta       │
├─────────────────────────────────────┤
│  [Iniciar Sesión] [Crear Cuenta]   │ <- Tabs
├─────────────────────────────────────┤
│  📧 Email o Usuario                 │
│  [___________________________]      │
│                                     │
│  🔒 Contraseña                      │
│  [___________________________] 👁   │
│                                     │
│  ☑️ Recordarme                      │
│                                     │
│  [🔐 Iniciar Sesión]               │
│                                     │
│  ¿Olvidaste tu contraseña?         │
└─────────────────────────────────────┘
```

### **Tab: Crear Cuenta**
```
┌─────────────────────────────────────┐
│  🔐 Acceso al Sistema              │
│  Inicia sesión o crea cuenta       │
├─────────────────────────────────────┤
│  [Iniciar Sesión] [Crear Cuenta]   │ <- Tabs
├─────────────────────────────────────┤
│  👤 Nombre        👤 Apellido       │
│  [____________]  [____________]     │
│                                     │
│  📧 Correo Electrónico              │
│  [___________________________]      │
│                                     │
│  📱 Teléfono (Opcional)             │
│  [___________________________]      │
│                                     │
│  🔒 Contraseña                      │
│  [___________________________] 👁   │
│                                     │
│  🔒 Confirmar Contraseña            │
│  [___________________________]      │
│                                     │
│  ☑️ Acepto términos y condiciones   │
│                                     │
│  [✨ Crear Cuenta]                  │
└─────────────────────────────────────┘
```

---

## 🎯 Paleta de Colores Utilizada

```css
/* Primario - Aqua Brillante */
--hl-primary: #00b4d8

/* Primario Oscuro - Aqua Profundo */
--hl-primary-dark: #0096c7

/* Éxito - Verde Aqua */
--hl-success: #06d6a0

/* Peligro - Rojo Coral */
--hl-danger: #ef476f

/* Background Dark */
--hl-bg-dark-secondary: #1e293b

/* Borders */
--hl-border-dark: #334155
```

---

## 🔧 Cómo Usar el Modal

### **Desde cualquier botón:**
```html
<button type="button" class="btn btn-primary" 
        data-bs-toggle="modal" 
        data-bs-target="#auth-modal">
    Ingresar
</button>
```

### **Desde JavaScript:**
```javascript
// Abrir modal
const modal = new bootstrap.Modal(document.getElementById('auth-modal'));
modal.show();

// Cambiar a tab de registro
document.getElementById('register-tab').click();
```

---

## 📋 Campos del Formulario

### **Login:**
- `username` - Email, usuario o teléfono
- `password` - Contraseña
- `remember` - Recordar sesión (opcional)

### **Register:**
- `first_name` - Nombre *
- `last_name` - Apellido *
- `email` - Email *
- `phone` - Teléfono (opcional)
- `password` - Contraseña (mín. 8 caracteres) *
- `password_confirm` - Confirmar contraseña *
- `accept_terms` - Aceptar términos *

---

## 🚀 Funcionalidades JavaScript

### **1. Toggle de Contraseña**
```javascript
// Click en el ícono del ojo
toggleLoginPassword.addEventListener('click', function() {
    // Cambia entre tipo 'password' y 'text'
    // Cambia ícono entre 'bx-show' y 'bx-hide'
});
```

### **2. Validación de Registro**
```javascript
// Verifica que las contraseñas coincidan
if (password !== passwordConfirm) {
    Swal.fire({ icon: 'error', text: 'Las contraseñas no coinciden' });
}

// Verifica longitud mínima
if (password.length < 8) {
    Swal.fire({ icon: 'error', text: 'Mínimo 8 caracteres' });
}
```

### **3. Envío AJAX**
```javascript
// Login
fetch('../api/routes/auth_user.php', {
    method: 'POST',
    body: formData
})
.then(response => response.json())
.then(data => {
    if (data.status === 'success') {
        // Recargar página o redirigir
        window.location.reload();
    }
});

// Register
fetch('../api/routes/reg_user.php', {
    method: 'POST',
    body: formData
})
.then(response => response.json())
.then(data => {
    if (data.status === 'success') {
        // Cambiar a tab de login
        document.getElementById('login-tab').click();
    }
});
```

---

## 🎨 Estilos Personalizados

### **Tabs Activos**
```css
#auth-tabs .nav-link.active {
    color: var(--hl-primary);
    background: rgba(0, 180, 216, 0.1);
    border-bottom-color: var(--hl-primary);
    font-weight: 600;
}
```

### **Form Controls**
```css
.auth-form .form-control:focus {
    background: var(--hl-bg-dark-secondary);
    border-color: var(--hl-primary);
    box-shadow: 0 0 0 3px rgba(0, 180, 216, 0.1);
}
```

### **Botones**
```css
.auth-form button[type="submit"]:hover {
    transform: translateY(-2px);
    box-shadow: var(--hl-shadow-lg);
}
```

---

## 🔄 Flujo de Autenticación

```
┌──────────────┐
│  User Click  │
│  "Ingresar"  │
└──────┬───────┘
       │
       v
┌──────────────┐
│ Modal Opens  │
│ (Login Tab)  │
└──────┬───────┘
       │
       ├─────> [Login] ──> API ──> Success ──> Reload
       │
       └─────> [Register] ──> API ──> Success ──> Switch to Login
```

---

## ✅ Validaciones Implementadas

### **Frontend:**
- ✅ Campos requeridos (HTML5 required)
- ✅ Formato de email válido
- ✅ Contraseñas coincidentes
- ✅ Longitud mínima de contraseña (8 caracteres)
- ✅ Aceptar términos y condiciones

### **Backend:**
- ✅ Sanitización de inputs
- ✅ Validación de email único
- ✅ Hash seguro de contraseñas (bcrypt)
- ✅ Verificación de credenciales
- ✅ Gestión de sesiones

---

## 📱 Responsive Design

### **Desktop (> 768px):**
- Modal tamaño `modal-lg`
- Campos en dos columnas (nombre/apellido)
- Tabs horizontales completos

### **Mobile (< 768px):**
- Modal con margen reducido
- Campos en una columna
- Tabs compactos
- Padding ajustado

---

## 🎯 Próximas Mejoras Sugeridas

1. **Integración con redes sociales**
   - Login con Google
   - Login con Facebook
   - Login con GitHub

2. **Recuperación de contraseña**
   - Modal de "Olvidé mi contraseña"
   - Envío de email con token
   - Reset de contraseña

3. **Verificación de email**
   - Envío de email de confirmación
   - Link de activación de cuenta

4. **Seguridad adicional**
   - reCAPTCHA v3
   - Rate limiting
   - 2FA (Two-Factor Authentication)

5. **UX Mejorada**
   - Indicador de fortaleza de contraseña
   - Sugerencias de contraseña segura
   - Autocompletado inteligente

---

## 🐛 Testing

Para probar el modal:

1. **Abrir** `http://localhost:3000/views/home.view.php`
2. **Click** en el botón "Ingresar" del header
3. **Probar Login:**
   - Ingresar credenciales válidas
   - Verificar redirección
4. **Probar Register:**
   - Cambiar a tab "Crear Cuenta"
   - Llenar formulario
   - Verificar creación y cambio a tab login

---

## 📚 Dependencias

- ✅ Bootstrap 5.x (Modal y Tabs)
- ✅ Halfmoon CSS (Estilos base)
- ✅ Boxicons (Iconos)
- ✅ SweetAlert2 (Notificaciones)
- ✅ jQuery (AJAX)

---

**¡Modal de autenticación completamente funcional y listo para usar! 🚀**
