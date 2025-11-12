# 📁 Sistema de Creación Automática de Carpetas Físicas

## 🎯 Resumen

Sistema que **automáticamente crea las carpetas físicas** en `/storage/app/private/user_{id}/` cuando:

1. ✅ Usuario se **registra** → Crea estructura completa
2. ✅ Usuario **inicia sesión** → Verifica/sincroniza carpetas
3. ✅ Admin **actualiza usuario** → Verifica estructura (si se implementa)

---

## 📂 Estructura de Carpetas Creadas

```
/storage/app/private/
└── user_{id}/                    # ID del usuario (ej: user_4)
    ├── Documentos/               # Carpeta fija 1
    ├── Música/                   # Carpeta fija 2
    ├── Videos/                   # Carpeta fija 3
    └── Imágenes/                 # Carpeta fija 4
```

**Permisos automáticos:**

- Directorio usuario: `0755` (rwxr-xr-x)
- Subcarpetas: `0755` (rwxr-xr-x)
- Archivos subidos: `0644` (rw-r--r--)

---

## 🔧 Archivos Modificados

### 1. **StorageService.php** (Mejorado)

**Ubicación**: `/services/StorageService.php`

**Nuevas funciones:**

#### `createUserDirectory($userId, $folderNames = null)`

Crea el directorio del usuario y sus subcarpetas.

```php
$storageService = new StorageService();
$result = $storageService->createUserDirectory(4, ['Documentos', 'Música', 'Videos', 'Imágenes']);

// Resultado:
[
    'status' => 'success',
    'message' => 'Estructura de carpetas verificada/creada correctamente',
    'user_dir' => '/path/to/storage/app/private/user_4/',
    'created_folders' => ['Documentos', 'Música', 'Videos', 'Imágenes'],
    'skipped_folders' => [], // Carpetas que ya existían
    'total_folders' => 4
]
```

#### `syncUserFolders($userId, $dbFolders)`

Sincroniza carpetas de la BD con el filesystem.

```php
$storageService = new StorageService();
$dbFolders = $folderModel->listByUser(4, null);
$result = $storageService->syncUserFolders(4, $dbFolders);

// Resultado:
[
    'status' => 'success',
    'message' => 'Carpetas sincronizadas correctamente',
    'created' => ['Videos'], // Solo Video faltaba
    'existing' => ['Documentos', 'Música', 'Imágenes'],
    'total' => 4
]
```

---

### 2. **RegisterService.php** (Modificado)

**Ubicación**: `/services/RegisterService.php`

**Cambios realizados:**

```php
// ANTES: Solo creaba carpetas en BD
foreach ($defaultFolders as $folder) {
    $folderStmt->execute([...]);
}
$db->commit();

// DESPUÉS: Crea carpetas en BD Y filesystem
foreach ($defaultFolders as $folder) {
    $folderStmt->execute([...]);
}

// ✅ NUEVO: Crear carpetas físicas
require_once __DIR__ . '/StorageService.php';
$storageService = new StorageService();

$folderNames = array_column($defaultFolders, 'name');
$storageResult = $storageService->createUserDirectory($user_id, $folderNames);

if ($storageResult['status'] === 'error') {
    $db->rollBack(); // Rollback si falla
    return ['status' => 'error', 'message' => 'Error creating user storage structure.'];
}

$db->commit();
```

**Beneficios:**

- ✅ Carpetas BD y físicas creadas en una sola transacción
- ✅ Rollback automático si falla creación física
- ✅ Logs detallados de carpetas creadas

---

### 3. **AuthService.php** (Modificado)

**Ubicación**: `/services/AuthService.php`

**Nueva función privada:**

```php
private function ensureUserStorageStructure($userId): void
{
    // Obtener carpetas del usuario desde BD
    $folderModel = new Folder();
    $dbFolders = $folderModel->listByUser($userId, null);

    if (!empty($dbFolders)) {
        // Sincronizar con filesystem
        $storageService = new StorageService();
        $syncResult = $storageService->syncUserFolders($userId, $dbFolders);
    } else {
        // Crear estructura por defecto si no tiene carpetas en BD
        $storageService = new StorageService();
        $createResult = $storageService->createUserDirectory($userId);
    }
}
```

**Se ejecuta automáticamente al iniciar sesión:**

```php
public function validateCredentials($input, $password): array
{
    // ... validaciones ...

    // ✅ NUEVO: Verificar/crear carpetas al login
    $this->ensureUserStorageStructure($user['user_id']);

    return ['status' => 'success', 'user_data' => $user];
}
```

**Beneficios:**

- ✅ Verifica carpetas en cada login
- ✅ Crea carpetas faltantes automáticamente
- ✅ No bloquea el login si falla (solo log)

---

## 🧪 Testing

### Test 1: Registro de Usuario Nuevo

```bash
# Backend: Ver logs en tiempo real
tail -f /var/log/php-fpm/error.log

# Frontend: Registrar usuario
curl -X POST http://localhost:3000/routes/user/reg_user.php \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "Test123!",
    "password_confirm": "Test123!",
    "first_name": "Test",
    "last_name": "User",
    "phone": "1234567890"
  }'

# Verificar que se crearon las carpetas físicas
ls -la /path/to/storage/app/private/user_{NEW_ID}/
# Debe mostrar: Documentos/ Música/ Videos/ Imágenes/
```

**Logs esperados:**

```
✅ Directorio creado: /path/to/storage/app/private/user_5/
✅ Subcarpeta creada: /path/to/storage/app/private/user_5/Documentos/
✅ Subcarpeta creada: /path/to/storage/app/private/user_5/Música/
✅ Subcarpeta creada: /path/to/storage/app/private/user_5/Videos/
✅ Subcarpeta creada: /path/to/storage/app/private/user_5/Imágenes/
✅ Usuario registrado con ID: 5 - Carpetas BD: 4 | Carpetas físicas: ['Documentos', 'Música', 'Videos', 'Imágenes']
```

---

### Test 2: Login de Usuario Existente (Sin Carpetas Físicas)

```bash
# Simular que faltan carpetas físicas
rm -rf /path/to/storage/app/private/user_4/

# Login
curl -X POST http://localhost:3000/routes/user/auth_user.php \
  -H "Content-Type: application/json" \
  -d '{
    "username": "juane.manriqueg@autonoma.edu.co",
    "password": "correctpassword"
  }'

# Verificar que se crearon automáticamente
ls -la /path/to/storage/app/private/user_4/
```

**Logs esperados:**

```
🔄 Usuario 4: Carpetas físicas creadas: Documentos, Música, Videos, Imágenes
```

---

### Test 3: Login de Usuario con Carpetas Parciales

```bash
# Crear solo algunas carpetas manualmente
mkdir -p /path/to/storage/app/private/user_4/Documentos
mkdir -p /path/to/storage/app/private/user_4/Música

# Login
curl -X POST http://localhost:3000/routes/user/auth_user.php ...

# Verificar que se crearon las faltantes
ls -la /path/to/storage/app/private/user_4/
# Debe mostrar: Documentos/ Música/ Videos/ Imágenes/ (todos)
```

**Logs esperados:**

```
🔄 Usuario 4: Carpetas físicas creadas: Videos, Imágenes
```

---

## 🔍 Verificación Manual

### Verificar Estructura Actual

```bash
# Ver usuarios registrados
mysql -u root -p homelab_db -e "SELECT user_id, first_name, email FROM users;"

# Ver carpetas en BD por usuario
mysql -u root -p homelab_db -e "SELECT folder_id, user_id, folder_name FROM folders WHERE user_id = 4;"

# Ver carpetas físicas
ls -la /path/to/storage/app/private/
ls -la /path/to/storage/app/private/user_1/
ls -la /path/to/storage/app/private/user_4/
```

### Verificar Permisos

```bash
# Permisos correctos:
# Directorios: drwxr-xr-x (755)
# Archivos: -rw-r--r-- (644)

stat /path/to/storage/app/private/user_4/
stat /path/to/storage/app/private/user_4/Documentos/
```

---

## 📊 Diagrama de Flujo

### Registro de Usuario

```
Usuario → Formulario Registro
    ↓
RegisterController
    ↓
RegisterService.register()
    ↓
DB Transaction Start
    ↓
1. Insertar usuario en BD
    ↓
2. Crear carpetas en BD (folders table)
    ↓
3. ✅ StorageService.createUserDirectory()
    ├── Crear /user_{id}/
    ├── Crear /user_{id}/Documentos/
    ├── Crear /user_{id}/Música/
    ├── Crear /user_{id}/Videos/
    └── Crear /user_{id}/Imágenes/
    ↓
¿Éxito?
├─ SÍ → Commit Transaction
└─ NO → Rollback Transaction
```

### Login de Usuario

```
Usuario → Login
    ↓
AuthController
    ↓
AuthService.validateCredentials()
    ↓
1. Verificar credenciales
    ↓
2. ✅ ensureUserStorageStructure()
    ↓
Obtener carpetas desde BD
    ↓
¿Tiene carpetas en BD?
├─ SÍ → StorageService.syncUserFolders()
│        ├── Verificar existencia física
│        └── Crear faltantes
│
└─ NO → StorageService.createUserDirectory()
         └── Crear estructura por defecto
    ↓
Continuar con login normal
```

---

## 🚨 Troubleshooting

### Problema: Carpetas no se crean

**Síntomas:**

- Registro exitoso pero no hay carpetas físicas
- Logs no muestran mensajes de creación

**Solución:**

1. Verificar permisos del directorio storage:

```bash
chmod 755 /path/to/storage/app/private/
chown www-data:www-data /path/to/storage/app/private/
```

2. Verificar logs de PHP:

```bash
tail -f /var/log/php-fpm/error.log
```

---

### Problema: Rollback en registro

**Síntomas:**

- Usuario no se registra
- Error: "Error creating user storage structure"

**Solución:**

1. Verificar que StorageService.php existe
2. Verificar permisos de escritura
3. Revisar logs para ver error específico

---

### Problema: Login lento

**Síntomas:**

- Login tarda varios segundos
- Muchos logs de sincronización

**Solución:**

- Normal en primera ejecución (crea carpetas)
- Posteriores logins serán rápidos (solo verificación)
- Si persiste, verificar permisos de lectura del filesystem

---

## 📈 Próximas Mejoras

### Implementaciones Futuras

1. **Script de Migración**

   - Crear carpetas para usuarios existentes
   - Ejecutar una sola vez en producción

2. **Limpieza Automática**

   - Eliminar carpetas de usuarios borrados
   - Implementar en delete_user.php

3. **Monitoreo de Espacio**

   - Alertas cuando usuario supera 80% de cuota
   - Dashboard de uso de storage

4. **Carpetas Personalizadas**
   - Permitir crear carpetas adicionales
   - Sincronizar automáticamente con filesystem

---

## 🔐 Seguridad

### Buenas Prácticas Implementadas

1. ✅ **Validación de Permisos**

   - Solo el usuario puede acceder a sus carpetas
   - Admin puede ver todas pero con validación

2. ✅ **Path Traversal Prevention**

   - Rutas sanitizadas en StorageService
   - No se permiten ../ en nombres de carpeta

3. ✅ **Transacciones Atómicas**

   - Rollback si falla creación física
   - Consistencia entre BD y filesystem

4. ✅ **Logs de Auditoría**
   - Registra todas las creaciones
   - Facilita debugging y monitoreo

---

## 📞 Soporte

Si encuentras problemas con el sistema de carpetas automáticas:

1. Verificar logs: `tail -f /var/log/php-fpm/error.log`
2. Verificar permisos: `ls -la /storage/app/private/`
3. Verificar BD: Consulta tabla `folders`
4. Ejecutar tests manuales de este documento

---

**Última actualización**: Noviembre 2025  
**Versión**: 1.0  
**Autor**: Roepard Labs Development Team
