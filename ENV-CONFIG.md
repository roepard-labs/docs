# 🔧 Configuración de Variables de Entorno

Este proyecto usa **dotenv** para gestionar variables de entorno en desarrollo y producción.

## 📋 Requisitos

- Node.js instalado
- Archivo `.env` en la raíz del proyecto

## 🚀 Instalación

```bash
npm install
```

## ⚙️ Configuración

### 1️⃣ Crear archivo .env

Crea un archivo `.env` en la raíz del proyecto:

```env
# API configuration
API_URL=https://api.roepard.online
APP_NAME="Roepard Homelab"
```

### 2️⃣ Generar config.js

Ejecuta el script de build para generar `js/config.js` desde `.env`:

```bash
npm run build:config
```

Este comando:
- ✅ Lee las variables de `.env`
- ✅ Genera `js/config.js` con `window.ENV_CONFIG`
- ✅ Listo para usar en el navegador

### 3️⃣ Desarrollo

El comando `dev` ejecuta automáticamente `build:config`:

```bash
npm run dev
```

## 📝 Scripts Disponibles

```json
{
  "scripts": {
    "build:config": "node scripts/generate-config.js",
    "dev": "npm run install:all && npm run build:config"
  }
}
```

## 🌐 Uso en el Navegador

El archivo `js/config.js` expone las variables en `window.ENV_CONFIG`:

```javascript
// Acceder a la configuración
console.log(window.ENV_CONFIG.API_URL);   // https://api.roepard.online
console.log(window.ENV_CONFIG.APP_NAME);  // Roepard Homelab

// Usar con Router
AppRouter.get('/api/users');  // GET https://api.roepard.online/api/users
```

## 🔒 Seguridad

### .gitignore

El archivo `js/config.js` está en `.gitignore` para **NO** subirlo al repositorio:

```gitignore
# Generated config from .env
js/config.js
```

### Variables Públicas vs Secretas

⚠️ **IMPORTANTE:** Solo exponer variables **públicas** en `config.js`:

✅ **Seguro (Frontend):**
- `API_URL` - URL pública de la API
- `APP_NAME` - Nombre de la aplicación
- `PUBLIC_KEY` - Claves públicas

❌ **NO EXPONER (Backend only):**
- `DATABASE_PASSWORD` - Credenciales de BD
- `SECRET_KEY` - Keys secretas
- `API_SECRET` - Tokens privados

### Configurar Variables a Exponer

Edita `scripts/generate-config.js`:

```javascript
const ENV_VARS_TO_EXPOSE = [
    'API_URL',
    'APP_NAME'
    // Agregar más variables públicas aquí
];
```

## 🚀 Despliegue en Producción

### Opción 1: Build Script

```bash
# 1. Configurar .env de producción
echo "API_URL=https://api.production.com" > .env

# 2. Generar config.js
npm run build:config

# 3. Deploy
# Subir archivos al servidor
```

### Opción 2: CI/CD (GitHub Actions)

```yaml
# .github/workflows/deploy.yml
- name: Generate config
  run: npm run build:config
  env:
    API_URL: ${{ secrets.API_URL }}
    APP_NAME: ${{ secrets.APP_NAME }}
```

## 📊 Estructura de Archivos

```
/roepard-labs/thepearlo_vr-website/
├── .env                          # Variables de entorno (no subir)
├── .gitignore                    # Ignora config.js
├── package.json                  # Scripts npm
├── scripts/
│   └── generate-config.js        # Script de build
└── js/
    ├── config.js                 # ⚠️  Auto-generado (no editar)
    ├── router.js                 # Usa window.ENV_CONFIG
    └── npm-loader.js
```

## 🔄 Flujo de Trabajo

### Desarrollo

```bash
1. Editar .env
   ↓
2. npm run build:config
   ↓
3. Recargar página
   ↓
4. Variables actualizadas
```

### Producción

```bash
1. Configurar .env en servidor
   ↓
2. npm run build:config
   ↓
3. Deploy archivos
   ↓
4. Variables en producción
```

## 🐛 Troubleshooting

### Error: config.js no está cargado

```javascript
❌ ERROR: config.js no está cargado
Ejecuta: npm run build:config
```

**Solución:**
```bash
npm run build:config
```

### Variables no se actualizan

1. Verifica que `.env` tenga los cambios
2. Ejecuta `npm run build:config`
3. Recarga la página (Ctrl+Shift+R para limpiar cache)

### Fallback en desarrollo

Si `config.js` no existe, `router.js` usa valores por defecto:

```javascript
window.ENV_CONFIG = {
    API_URL: 'http://localhost:3000',
    APP_NAME: 'Roepard Homelab (Fallback)'
};
```

## 📚 Más Información

- [dotenv documentation](https://www.npmjs.com/package/dotenv)
- [Node.js --env-file](https://nodejs.org/api/cli.html#--env-fileconfig)
- [Environment variables best practices](https://12factor.net/config)

---

**HomeLab VR - Roepard Labs** 🚀
