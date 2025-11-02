# 📦 Migración de Dependencias a NPM

## ✅ Cambios Realizados

Se han migrado todas las dependencias desde `/dist` a npm en el archivo `package.json`, modernizando la gestión de librerías del proyecto.

## 📋 Dependencias Instaladas

### 🎨 **Frameworks CSS y UI**
- `bootstrap@5.3.3` - Framework CSS principal
- `boxicons@2.1.4` - Iconografía
- `animate.css@4.1.1` - Animaciones CSS
- `aos@2.3.4` - Animate on Scroll

### 🧰 **Librerías JavaScript Core**
- `jquery@3.7.1` - Manipulación DOM
- `@popperjs/core@2.11.8` - Tooltips y popovers
- `dayjs@1.11.13` - Manejo de fechas

### 📊 **Visualización de Datos**
- `chart.js@4.4.6` - Gráficos interactivos
- `datatables.net@2.1.8` + `datatables.net-bs5` - Tablas avanzadas
- `datatables.net-responsive` + `datatables.net-responsive-bs5` - Responsive tables

### 🎬 **Componentes Interactivos**
- `animejs@3.2.2` - Animaciones JavaScript
- `sweetalert2@11.14.5` - Alertas elegantes
- `notyf@3.10.0` - Notificaciones toast
- `tippy.js@6.3.7` - Tooltips avanzados

### 🖼️ **Multimedia**
- `glightbox@3.3.0` - Lightbox para imágenes/videos
- `photoswipe@5.4.4` - Galería de imágenes
- `video.js@8.21.1` - Reproductor de video

### 📝 **Formularios**
- `tom-select@2.3.1` - Select avanzados
- `flatpickr@4.6.13` - Date picker
- `filepond@4.31.4` + `filepond-plugin-file-encode` - File uploads

### 🥽 **VR/AR**
- `aframe@1.7.1` - Framework WebXR
- `three@0.179.1` - Gráficos 3D
- `ar.js@2.2.2` - Realidad aumentada
- `mind-ar@1.2.5` - AR con detección de imágenes
- `webvr-polyfill@0.10.12` - Compatibilidad WebVR

### 🛠️ **Dev Dependencies**
- `vite@5.4.11` - Build tool moderno
- `sass@1.81.0` - Preprocesador CSS

## 🚀 Instalación

### 1️⃣ Instalar Node.js y npm

Si no tienes Node.js instalado:

```bash
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verificar instalación
node --version
npm --version
```

### 2️⃣ Instalar Dependencias

En el directorio del proyecto:

```bash
cd /home/jemg/Documents/GitHub/roepard-labs/thepearlo_vr-website

# Instalar todas las dependencias
npm install

# O usar el script personalizado
npm run install:all
```

### 3️⃣ Verificar Instalación

```bash
# Verificar que node_modules se creó correctamente
ls -la node_modules/

# Debería mostrar todas las carpetas de las librerías instaladas
```

## 📄 Nuevos Templates

Se han creado **2 nuevos templates modernos** que utilizan las dependencias desde `node_modules`:

### 1. **modern.template.view.php** 
Template general con todos los componentes UI

**Características:**
- ✅ Showcase completo de componentes
- ✅ Ejemplos de SweetAlert2, Notyf, Chart.js
- ✅ DataTables con modal
- ✅ Formularios con validación
- ✅ TomSelect, Flatpickr, FilePond
- ✅ Estadísticas animadas
- ✅ Diseño responsivo con Bootstrap 5

**Ubicación:** `/views/modern.template.view.php`

**Uso:**
```bash
# Acceder desde el navegador
http://localhost/views/modern.template.view.php
```

### 2. **vr.modern.template.view.php**
Template especializado para VR/AR con A-Frame

**Características:**
- ✅ Escena A-Frame completamente funcional
- ✅ Controles interactivos (añadir cubos, esferas)
- ✅ UI overlay con stats en tiempo real
- ✅ FPS counter
- ✅ Integración con SweetAlert2 y Notyf
- ✅ Teclado shortcuts (1, 2, 3, H, Ctrl+C)
- ✅ Click interactions en objetos 3D
- ✅ WebXR ready

**Ubicación:** `/views/vr.modern.template.view.php`

**Uso:**
```bash
# Acceder desde el navegador
http://localhost/views/vr.modern.template.view.php
```

**Controles VR:**
- **WASD**: Mover cámara
- **Mouse**: Mirar alrededor
- **Click**: Interactuar con objetos
- **1**: Añadir cubo
- **2**: Añadir esfera
- **3**: Cambiar color del cielo
- **H**: Ocultar/Mostrar UI
- **Ctrl+C**: Limpiar escena

## 🔄 Migración desde /dist a node_modules

### Antes (usando /dist):
```html
<!-- CSS -->
<link href="../dist/bootstrap/css/bootstrap.min.css" rel="stylesheet">
<link href="../dist/sweetalert2/sweetalert2.min.css" rel="stylesheet">

<!-- JavaScript -->
<script src="../dist/jquery/jquery.min.js"></script>
<script src="../dist/bootstrap/js/bootstrap.min.js"></script>
```

### Después (usando node_modules):
```html
<!-- CSS -->
<link href="../node_modules/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="../node_modules/sweetalert2/dist/sweetalert2.min.css" rel="stylesheet">

<!-- JavaScript -->
<script src="../node_modules/jquery/dist/jquery.min.js"></script>
<script src="../node_modules/bootstrap/dist/js/bootstrap.bundle.min.js"></script>
```

## 📂 Estructura Actualizada

```
thepearlo_vr-website/
├── package.json              # ✅ Actualizado con todas las dependencias
├── package-lock.json         # 🆕 Generado por npm install
├── node_modules/             # 🆕 Carpeta con todas las librerías
│   ├── aframe/
│   ├── bootstrap/
│   ├── chart.js/
│   ├── jquery/
│   └── ... (todas las demás)
├── views/
│   ├── template.view.php           # Original (usa /dist)
│   ├── modern.template.view.php    # 🆕 Nuevo (usa node_modules)
│   └── vr.modern.template.view.php # 🆕 Nuevo VR (usa node_modules)
├── dist/                     # ⚠️ Mantener por compatibilidad
└── ...
```

## 🎯 Ventajas de Usar NPM

### ✅ **Gestión Centralizada**
- Todas las dependencias en `package.json`
- Versiones controladas y documentadas
- Fácil actualización: `npm update`

### ✅ **Reproducibilidad**
- Instalación consistente en cualquier máquina
- `package-lock.json` garantiza versiones exactas
- Ideal para trabajo en equipo

### ✅ **Actualizaciones Simples**
```bash
# Ver paquetes desactualizados
npm outdated

# Actualizar un paquete específico
npm update bootstrap

# Actualizar todos
npm update
```

### ✅ **Compatibilidad**
- Integración con build tools (Vite, Webpack)
- Soporte para módulos ES6
- Tree-shaking para optimización

## 🔧 Comandos Útiles

```bash
# Instalar todas las dependencias
npm install

# Instalar una dependencia específica
npm install nombre-paquete

# Actualizar dependencias
npm update

# Verificar dependencias instaladas
npm list --depth=0

# Limpiar caché de npm
npm cache clean --force

# Reinstalar todo desde cero
rm -rf node_modules package-lock.json
npm install
```

## ⚠️ Consideraciones

### **Compatibilidad con /dist**
- El directorio `/dist` NO ha sido eliminado
- Los templates antiguos seguirán funcionando
- Migración gradual recomendada

### **Tamaño de node_modules**
- `node_modules` puede ser grande (~500MB)
- Añadir a `.gitignore` (ya debería estar)
- No commitear a Git, solo `package.json` y `package-lock.json`

### **.gitignore**
Asegúrate de tener:
```gitignore
node_modules/
package-lock.json  # Opcional, algunos prefieren commitearlo
```

### **Servidor Web**
Si usas Nginx/Apache, asegúrate de que tengan acceso a `node_modules`:
```nginx
location /node_modules/ {
    alias /ruta/al/proyecto/node_modules/;
    access_log off;
    expires 30d;
}
```

## 🎨 Personalización

### Crear un Nuevo Template

1. Copiar uno de los templates modernos:
```bash
cp views/modern.template.view.php views/mi-template.view.php
```

2. Editar y ajustar según necesidades

3. Usar las mismas rutas de `node_modules`:
```html
<script src="../node_modules/nombre-libreria/dist/archivo.js"></script>
```

### Añadir Nueva Dependencia

```bash
# Instalar
npm install nombre-paquete

# Usar en tu template
<script src="../node_modules/nombre-paquete/dist/archivo.js"></script>
```

## 📚 Documentación de Librerías

- [Bootstrap](https://getbootstrap.com/docs/5.3/)
- [A-Frame](https://aframe.io/docs/)
- [Chart.js](https://www.chartjs.org/docs/)
- [DataTables](https://datatables.net/)
- [SweetAlert2](https://sweetalert2.github.io/)
- [jQuery](https://api.jquery.com/)

## 🐛 Troubleshooting

### Error: `npm: command not found`
```bash
# Instalar Node.js y npm
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### Error: `Cannot find module`
```bash
# Reinstalar dependencias
rm -rf node_modules package-lock.json
npm install
```

### Error: Permisos en node_modules
```bash
# Cambiar permisos
sudo chown -R $USER:$USER node_modules/
```

### Librerías no se cargan en el navegador
- Verificar rutas relativas: `../node_modules/`
- Verificar permisos del servidor web
- Revisar la consola del navegador (F12)

## 📞 Soporte

Para problemas o dudas:
- Revisar documentación oficial de cada librería
- Consultar `/docs/` del proyecto
- GitHub Issues del proyecto

---

**Desarrollado por Roepard Labs** 🚀  
**HomeLab VR - Realidad Aumentada Inmersiva**
