# ✅ Quick Start Checklist - NPM Migration

## 🚀 Instalación Rápida (5 minutos)

### Paso 1: Verificar Node.js
```bash
node --version  # Debe mostrar v18+ o v20+
npm --version   # Debe mostrar 9+ o 10+
```

**Si no está instalado:**
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

---

### Paso 2: Navegar al Proyecto
```bash
cd /home/jemg/Documents/GitHub/roepard-labs/thepearlo_vr-website
```

---

### Paso 3: Ejecutar Instalación Automatizada
```bash
./install-npm-deps.sh
```

**O instalación manual:**
```bash
npm install
```

---

### Paso 4: Verificar Instalación
```bash
ls -la node_modules/  # Debe mostrar ~700+ carpetas
```

Verificar carpetas clave:
```bash
ls node_modules/ | grep -E "(aframe|bootstrap|jquery|chart.js|three)"
```

Debe mostrar:
```
aframe/
bootstrap/
chart.js/
jquery/
three/
```

---

### Paso 5: Probar Templates

#### Template UI General:
```
http://localhost/views/modern.template.view.php
```

#### Template VR/AR:
```
http://localhost/views/vr.modern.template.view.php
```

---

## ✅ Checklist de Verificación

### Pre-instalación
- [ ] Node.js instalado (v18+ o v20+)
- [ ] npm instalado (v9+ o v10+)
- [ ] Ubicado en directorio del proyecto
- [ ] package.json presente

### Instalación
- [ ] `npm install` ejecutado sin errores
- [ ] node_modules/ creado
- [ ] package-lock.json generado
- [ ] ~700+ paquetes instalados
- [ ] Tamaño de node_modules ~400-500MB

### Dependencias Clave
- [ ] aframe instalado
- [ ] bootstrap instalado
- [ ] jquery instalado
- [ ] chart.js instalado
- [ ] three instalado
- [ ] sweetalert2 instalado
- [ ] datatables.net instalado

### Templates
- [ ] modern.template.view.php accesible
- [ ] vr.modern.template.view.php accesible
- [ ] Componentes UI funcionando
- [ ] Escena VR cargando correctamente

### Funcionalidad
- [ ] SweetAlert2 muestra alertas
- [ ] Notyf muestra notificaciones
- [ ] Chart.js renderiza gráficos
- [ ] DataTables funciona en modal
- [ ] A-Frame scene visible
- [ ] Controles VR responden

---

## 🐛 Troubleshooting Rápido

### ❌ Error: `npm: command not found`
**Solución:**
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### ❌ Error: `Cannot find module`
**Solución:**
```bash
rm -rf node_modules package-lock.json
npm cache clean --force
npm install
```

### ❌ Error: `Permission denied`
**Solución:**
```bash
chmod +x install-npm-deps.sh
./install-npm-deps.sh
```

### ❌ Error: Templates no cargan librerías
**Solución:**
```bash
# Verificar permisos
sudo chmod -R 755 node_modules/

# Verificar ruta relativa en template
# Debe ser: ../node_modules/libreria/dist/archivo.js
```

### ❌ Error: A-Frame no carga
**Solución:**
```bash
# Verificar instalación de aframe
ls node_modules/aframe/

# Reinstalar si falta
npm install aframe@1.7.1
```

---

## 📊 Resumen de Comandos

```bash
# Instalación completa en un comando
cd thepearlo_vr-website && npm install && ls node_modules/ | wc -l

# Verificar dependencias instaladas
npm list --depth=0

# Ver tamaño de node_modules
du -sh node_modules/

# Actualizar todas las dependencias
npm update

# Reinstalar desde cero
rm -rf node_modules package-lock.json && npm install
```

---

## 🎯 Siguiente Paso

Después de completar el checklist:

1. **Lee la documentación completa:**
   ```bash
   cat NPM-MIGRATION.md
   ```

2. **Revisa el resumen ejecutivo:**
   ```bash
   cat RESUMEN-MIGRACION-NPM.md
   ```

3. **Abre los templates en el navegador:**
   - modern.template.view.php
   - vr.modern.template.view.php

4. **Comienza a desarrollar con las nuevas dependencias**

---

## 📞 Soporte

Si tienes problemas:
- Consulta **NPM-MIGRATION.md** (documentación completa)
- Revisa **RESUMEN-MIGRACION-NPM.md** (resumen ejecutivo)
- Ejecuta `./install-npm-deps.sh` (instalación automatizada)

---

**✅ ¡Todo listo! Ahora puedes usar las dependencias desde node_modules**

*Desarrollado por Roepard Labs - HomeLab VR*
