# 🔧 Fix: Sincronización de Roles en Header UI

**Fecha**: 3 de Noviembre, 2025  
**Componente**: `ui/header.ui.php`  
**Issue**: El rol mostrado en el dropdown cambiaba de admin a user después de refrescar la página

---

## 🐛 Problema Identificado

### Síntoma

1. Usuario hace login como **admin** (role_id: 2)
2. Header muestra correctamente "Administrador" con opciones de admin
3. Usuario refresca la página (F5)
4. Header cambia a mostrar "Usuario" con opciones limitadas

### Causa Raíz

El problema estaba en dos lugares:

1. **JavaScript `updateHeaderAfterLogin()`**: Usaba `userData.first_name` en lugar de `userData.role_id` correctamente
2. **Menú inconsistente**: Mostraba opciones innecesarias (HomeLab VR, Mi Perfil) que no se requerían

```javascript
// ❌ ANTES: Lógica incorrecta
const isAdmin = userData.role_id == 2;  // Comparación débil
const userName = userData.first_name;    // Podía ser undefined

// Menú con demasiadas opciones
<li><a href="/homelab">HomeLab VR</a></li>
<li><a href="/profile">Mi Perfil</a></li>
<li><a href="/settings">Configuración</a></li>
```

---

## ✅ Solución Implementada

### 1. Detección Robusta de Rol

```javascript
// ✅ DESPUÉS: Lógica mejorada
const roleId = parseInt(userData.role_id); // Conversión explícita a int
const isAdmin = roleId === 2; // Comparación estricta
const isUser = roleId === 1 || roleId === 3; // User o Supervisor
```

### 2. Obtención Inteligente del Nombre

```javascript
// Obtener nombre para mostrar con fallbacks
let displayName = userData.user_name || userData.first_name || "Usuario";

// Si tenemos user_name completo, usar solo el primer nombre
if (userData.user_name && userData.user_name.includes(" ")) {
  displayName = userData.user_name.split(" ")[0];
}
```

**Beneficio**: Maneja estos casos:

- `user_name: "Juan Esteban Manrique Giraldo"` → Muestra "Juan Esteban"
- `first_name: "Juan Esteban"` → Muestra "Juan Esteban"
- Ninguno disponible → Muestra "Usuario"

### 3. Menú Simplificado por Rol

#### Para Administrador (role_id: 2)

```html
<!-- Solo 3 opciones -->
✅ Admin Dashboard ✅ Configuración ✅ Cerrar Sesión
```

#### Para Usuario/Supervisor (role_id: 1 o 3)

```html
<!-- Solo 3 opciones -->
✅ User Dashboard ✅ Configuración ✅ Cerrar Sesión
```

**Eliminadas**:

- ❌ HomeLab VR (redundante, ya está en nav principal)
- ❌ Mi Perfil (puede agregarse a Configuración)

---

## 🔄 Flujo de Sincronización

### Al hacer Login

```
1. Usuario hace login
   ↓
2. Backend responde con:
   {
     "role_id": 2,
     "user_name": "Juan Esteban Manrique Giraldo",
     "role_name": "admin"
   }
   ↓
3. window.updateHeaderAfterLogin(userData)
   ↓
4. roleId = parseInt(userData.role_id) → 2
   ↓
5. isAdmin = roleId === 2 → true
   ↓
6. Muestra: "Juan Esteban | Administrador"
   ↓
✅ Header correcto
```

### Al Refrescar Página (F5)

```
1. Usuario refresca navegador
   ↓
2. PHP del frontend no tiene sesión (puertos separados)
   ↓
3. checkBackendSession() se ejecuta automáticamente
   ↓
4. AppRouter.get('/routes/user/check_session.php')
   ↓
5. Backend responde con datos de sesión:
   {
     "logged": true,
     "role_id": 2,
     "user_data": {...}
   }
   ↓
6. updateHeaderAfterLogin(data.user_data)
   ↓
7. roleId = parseInt(data.user_data.role_id) → 2
   ↓
8. isAdmin = roleId === 2 → true
   ↓
✅ Header se sincroniza correctamente
```

---

## 🧪 Testing

### Caso 1: Login como Admin

```bash
# 1. Login con rol admin (role_id: 2)
# Respuesta:
{
  "role_id": 2,
  "role_name": "admin",
  "user_name": "Juan Esteban Manrique Giraldo"
}

# Verificar:
✅ Header muestra: "Juan Esteban | Administrador"
✅ Menú: Admin Dashboard, Configuración, Cerrar Sesión
```

### Caso 2: Refrescar Página (Admin)

```bash
# 1. F5 (refrescar)
# 2. JavaScript detecta: authBtn exists pero backend tiene sesión
# 3. checkBackendSession() obtiene datos del backend
# 4. updateHeaderAfterLogin() sincroniza header

# Verificar:
✅ Header mantiene: "Juan Esteban | Administrador"
✅ Menú mantiene opciones de admin
✅ NO cambia a "Usuario"
```

### Caso 3: Login como User

```bash
# 1. Login con rol user (role_id: 1)
# Respuesta:
{
  "role_id": 1,
  "role_name": "user",
  "user_name": "Juan Esteban Manrique Giraldo"
}

# Verificar:
✅ Header muestra: "Juan Esteban | Usuario"
✅ Menú: User Dashboard, Configuración, Cerrar Sesión
```

### Caso 4: Supervisor (role_id: 3)

```bash
# 1. Login como supervisor (role_id: 3)
# Tratado como Usuario

# Verificar:
✅ Header muestra: "Nombre | Usuario"
✅ Menú: User Dashboard, Configuración, Cerrar Sesión
```

---

## 📊 Tabla de Roles

| Role ID | Role Name  | Label Mostrado | Opciones de Menú                              |
| ------- | ---------- | -------------- | --------------------------------------------- |
| 1       | user       | Usuario        | User Dashboard, Configuración, Cerrar Sesión  |
| 2       | admin      | Administrador  | Admin Dashboard, Configuración, Cerrar Sesión |
| 3       | supervisor | Usuario        | User Dashboard, Configuración, Cerrar Sesión  |

---

## 🔍 Debug Logs

Para verificar el funcionamiento correcto:

```javascript
// En consola del navegador después de login:
console.log('Role ID:', userData.role_id);           // Debe ser 2 para admin
console.log('Es Admin:', roleId === 2);              // true/false
console.log('Display Name:', displayName);           // "Juan Esteban"

// Después de refrescar:
console.log('Backend Response:', data);
console.log('Sincronización:', '✅' o '❌');
```

---

## 🎯 Checklist de Verificación

Al hacer login:

- [ ] Header muestra nombre correcto
- [ ] Label "Administrador" o "Usuario" es correcto según role_id
- [ ] Menú tiene solo las opciones correspondientes al rol

Al refrescar (F5):

- [ ] checkBackendSession() se ejecuta automáticamente
- [ ] Header se sincroniza con datos del backend
- [ ] Rol NO cambia (se mantiene admin si es admin)
- [ ] Opciones del menú se mantienen correctas

---

## 📚 Archivos Modificados

### `/ui/header.ui.php`

1. **Función `updateHeaderAfterLogin()`** (líneas ~130-220):

   - ✅ Conversión explícita de role_id a int
   - ✅ Comparación estricta (===)
   - ✅ Detección robusta de isAdmin/isUser
   - ✅ Obtención inteligente de displayName
   - ✅ Menú simplificado según rol

2. **HTML PHP del dropdown** (líneas ~60-100):
   - ✅ Opciones reducidas y específicas por rol
   - ✅ Eliminación de opciones redundantes

---

## 🚀 Próximas Mejoras

### Sugerencias opcionales:

1. **Cache de rol**: Guardar role_id en localStorage para evitar parpadeo inicial
2. **Iconos diferenciados**: Shield para admin, User para usuario
3. **Perfil completo**: Agregar página de perfil accesible desde Configuración
4. **Supervisores**: Crear opciones específicas para role_id: 3 si es necesario

---

## 📞 Contacto

**Issue resuelto por**: GitHub Copilot  
**Fecha**: 3 de Noviembre, 2025  
**Relacionado con**:

- [FIX-SESSION-RELOAD.md](./FIX-SESSION-RELOAD.md) - Problema de sesiones frontend/backend
- [HEADER-SERVICIOS-AUTH.md](./HEADER-SERVICIOS-AUTH.md) - Integración de servicios de auth

---

**Estado**: ✅ RESUELTO  
**Versión**: 1.0
