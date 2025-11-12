# 🧪 Guía de Pruebas - Explorador de Archivos

**HomeLab AR - Roepard Labs**  
**Fecha**: 4 de Noviembre 2025

---

## 🚀 Cómo Probar el Explorador de Archivos

### 1. Acceder al Explorador

```bash
# Navegar en el navegador a:
http://localhost:9000/dashboard/files
```

### 2. Verificar Carga Inicial

Al cargar la página, deberías ver:

✅ **En la carpeta raíz (root)**:

- 📄 Presentación HomeLab.pdf
- 🖼️ Logo HomeLab.png
- 🎬 Video Demo VR.mp4
- 📄 Base de datos backup.sql
- 🎵 Música Ambiente.mp3
- 📁 Documentos (carpeta)
- 📁 Modelos 3D (carpeta)
- 📁 Multimedia (carpeta)

**Total esperado**: 8 items (5 archivos + 3 carpetas)

### 3. Probar Navegación de Carpetas

#### Test 1: Navegar a "Documentos"

```
1. Hacer DOBLE CLICK en la carpeta "Documentos"
   O
   Hacer click en el botón "Abrir" (icono de carpeta)

✅ Resultado esperado:
   - Breadcrumb muestra: "Mis Archivos > Documentos"
   - Se muestran 5 items:
     * Manual Usuario.pdf
     * Especificaciones.docx
     * Presupuesto.xlsx
     * Contratos (carpeta)
     * Facturas (carpeta)
```

#### Test 2: Navegar a "Contratos" (carpeta dentro de carpeta)

```
1. Desde "Documentos", hacer DOBLE CLICK en "Contratos"

✅ Resultado esperado:
   - Breadcrumb: "Mis Archivos > Documentos > Contratos"
   - Se muestran 2 archivos:
     * Contrato Proyecto A.pdf
     * Contrato Proveedor.pdf
```

#### Test 3: Volver atrás con Breadcrumb

```
1. Hacer click en "Documentos" en el breadcrumb

✅ Resultado esperado:
   - Vuelve a mostrar contenido de "Documentos"
   - Breadcrumb: "Mis Archivos > Documentos"
```

#### Test 4: Volver a Raíz

```
1. Hacer click en "Mis Archivos" (icono home) en el breadcrumb

✅ Resultado esperado:
   - Vuelve a mostrar los 8 items iniciales
   - Breadcrumb: "Mis Archivos"
```

### 4. Probar Modelos 3D

#### Test 5: Navegar a "Modelos 3D"

```
1. Desde raíz, doble click en "Modelos 3D"

✅ Resultado esperado:
   - Breadcrumb: "Mis Archivos > Modelos 3D"
   - Se muestran 4 items:
     * Servidor HomeLab.gltf (modelo 3D)
     * Router Virtualizado.glb (modelo 3D)
     * Edificio Campus.obj (modelo 3D)
     * Assets VR (carpeta)
```

#### Test 6: Vista Previa de Modelo 3D

```
1. Hacer DOBLE CLICK en "Servidor HomeLab.gltf"

✅ Resultado esperado:
   - Modal se abre con:
     * Icono de cubo 3D grande
     * Nombre: "Servidor HomeLab.gltf"
     * Tamaño: "5.4 MB"
     * Tipo: "Modelo 3D GLTF"
     * Botón "Descargar Modelo"
     * Botón "Abrir en Three.js Editor"
```

### 5. Probar Multimedia

#### Test 7: Navegar a "Multimedia"

```
1. Desde raíz, doble click en "Multimedia"

✅ Resultado esperado:
   - Breadcrumb: "Mis Archivos > Multimedia"
   - Se muestran 5 items:
     * Tutorial AR.mp4 (video)
     * Música de Fondo.mp3 (audio)
     * Sonidos (carpeta - 20 archivos)
     * Videos Tutoriales (carpeta - 6 archivos)
     * Capturas Pantalla (carpeta - 30 archivos)
```

#### Test 8: Reproducir Video

```
1. Hacer DOBLE CLICK en "Tutorial AR.mp4"

✅ Resultado esperado:
   - Modal se abre con:
     * Reproductor de video HTML5
     * Video comienza a cargar
     * Controles: play/pause, volumen, fullscreen
     * Se puede reproducir el video
```

#### Test 9: Reproducir Audio

```
1. Hacer DOBLE CLICK en "Música de Fondo.mp3"

✅ Resultado esperado:
   - Modal se abre con:
     * Icono musical grande
     * Nombre del archivo
     * Metadata: tamaño y fecha
     * Reproductor de audio con controles
     * Se puede reproducir el audio
```

### 6. Probar Jerarquía Profunda

#### Test 10: Navegar 3 Niveles

```
1. Raíz → Multimedia (nivel 1)
2. Multimedia → Sonidos (nivel 2)
3. Verificar breadcrumb: "Mis Archivos > Multimedia > Sonidos"

✅ Resultado esperado:
   - Navegación fluida
   - Breadcrumb refleja ruta completa
   - Todos los niveles son clickeables
```

### 7. Probar Vista de Lista

#### Test 11: Cambiar a Vista de Lista

```
1. En cualquier carpeta, hacer click en el botón de lista (icono de lista)

✅ Resultado esperado:
   - Vista cambia de grid a tabla
   - Se muestran los mismos archivos
   - Columnas: checkbox, nombre, tamaño, tipo, fecha, acciones
   - Doble click en carpeta navega dentro
   - Doble click en archivo abre preview
```

### 8. Probar Búsqueda y Filtros

#### Test 12: Buscar Archivos

```
1. En campo de búsqueda, escribir "contrato"

✅ Resultado esperado:
   - Solo muestra archivos con "contrato" en el nombre
   - Filtro es en tiempo real
   - Solo busca en carpeta actual
```

#### Test 13: Filtrar por Tipo

```
1. En dropdown "Todos los tipos", seleccionar "🧊 Modelos 3D"
2. Navegar a "Modelos 3D"

✅ Resultado esperado:
   - Solo muestra archivos tipo "model"
   - Carpetas se ocultan (no son archivos)
```

#### Test 14: Filtrar por Fecha

```
1. En dropdown "Todas las fechas", seleccionar "Este mes"

✅ Resultado esperado:
   - Solo muestra archivos del mes actual
   - Archivos antiguos se ocultan
```

### 9. Verificar Estadísticas

#### Test 15: Estadísticas Globales

```
✅ Verificar cards superiores:
   - Total Storage: 10 GB (con barra de progreso)
   - Total de Archivos: Número correcto (excluyendo carpetas)
   - Carpetas: Número correcto
   - Archivos Compartidos: Solo visible para admin
```

### 10. Consola del Navegador

#### Test 16: Mensajes de Debug

```
1. Abrir DevTools (F12)
2. Ir a Console
3. Navegar entre carpetas

✅ Mensajes esperados:
   🚀 Files Manager: DOM cargado
   👔 Files Manager: Es admin? true/false | User ID: 1
   🔍 Filtrando archivos para carpeta: root
   📊 Total de archivos en sistema: 30+
   📂 Archivos encontrados: 8
   📋 Lista de archivos: [...]
   📂 Navegando a carpeta: 4
```

---

## 🐛 Solución de Problemas

### Problema 1: No se ven archivos

```
Solución:
1. Abrir consola (F12)
2. Verificar mensaje: "📊 Total de archivos en sistema: X"
3. Si es 0, recargar página (Ctrl+F5)
4. Verificar que loadDemoFiles() se ejecutó
```

### Problema 2: Carpetas no abren

```
Solución:
1. Verificar que onclick="navigateToFolder(ID)" esté presente
2. Verificar que ondblclick funcione
3. En consola, ejecutar manualmente: navigateToFolder(4)
```

### Problema 3: Breadcrumb no actualiza

```
Solución:
1. Verificar función updateBreadcrumb() se llama
2. Verificar buildFolderPath() construye ruta
3. En consola: console.log(folderPath)
```

### Problema 4: Vista previa no funciona

```
Solución:
1. Verificar que archivo tenga campo "preview"
2. Verificar tipo de archivo sea compatible
3. Verificar modal se abre (Bootstrap JS cargado)
```

---

## ✅ Checklist Completo

### Navegación Básica

- [ ] Página carga correctamente
- [ ] Se muestran 8 items en raíz
- [ ] Doble click en carpeta navega
- [ ] Botón "Abrir" navega
- [ ] Breadcrumb actualiza

### Navegación Profunda

- [ ] Carpeta dentro de carpeta funciona
- [ ] Breadcrumb muestra ruta completa
- [ ] Click en breadcrumb vuelve atrás
- [ ] Home en breadcrumb vuelve a raíz

### Tipos de Archivo

- [ ] Carpetas muestran icono amarillo
- [ ] Archivos PDF muestran icono azul
- [ ] Imágenes muestran icono azul claro
- [ ] Videos muestran icono rojo
- [ ] Audio muestra icono verde
- [ ] Modelos 3D muestran icono morado

### Vista Previa

- [ ] Doble click en imagen abre preview
- [ ] Doble click en video abre reproductor
- [ ] Doble click en audio abre reproductor
- [ ] Doble click en modelo 3D muestra info
- [ ] Modal tiene botón descargar

### Filtros y Búsqueda

- [ ] Búsqueda filtra en tiempo real
- [ ] Filtro por tipo funciona
- [ ] Filtro por fecha funciona
- [ ] Filtros solo aplican a carpeta actual

### Vistas

- [ ] Vista grid muestra cards
- [ ] Vista lista muestra tabla
- [ ] Toggle entre vistas funciona
- [ ] Doble click funciona en ambas vistas

### Estadísticas

- [ ] Total de archivos correcto
- [ ] Total de carpetas correcto
- [ ] Barra de progreso de storage
- [ ] Admin ve archivos compartidos

---

## 📊 Estructura Esperada

```
📁 Mis Archivos (root) - 8 items
├── 📄 Presentación HomeLab.pdf
├── 🖼️ Logo HomeLab.png
├── 🎬 Video Demo VR.mp4
├── 📄 Base de datos backup.sql
├── 🎵 Música Ambiente.mp3
│
├── 📁 Documentos - 5 items
│   ├── 📄 Manual Usuario.pdf
│   ├── 📄 Especificaciones.docx
│   ├── 📄 Presupuesto.xlsx
│   ├── 📁 Contratos - 2 items
│   │   ├── 📄 Contrato Proyecto A.pdf
│   │   └── 📄 Contrato Proveedor.pdf
│   └── 📁 Facturas - 15 items
│
├── 📁 Modelos 3D - 4 items
│   ├── 🧊 Servidor HomeLab.gltf
│   ├── 🧊 Router Virtualizado.glb
│   ├── 🧊 Edificio Campus.obj
│   └── 📁 Assets VR - 8 items
│
└── 📁 Multimedia - 5 items
    ├── 🎬 Tutorial AR.mp4
    ├── 🎵 Música de Fondo.mp3
    ├── 📁 Sonidos - 20 items
    ├── 📁 Videos Tutoriales - 6 items
    └── 📁 Capturas Pantalla - 30 items
```

---

## 🎯 Comandos de Debug Útiles

```javascript
// En la consola del navegador (F12):

// Ver carpeta actual
console.log("Carpeta actual:", currentFolder);

// Ver todos los archivos
console.log("Total archivos:", allFilesData.length);
console.table(allFilesData);

// Ver archivos de carpeta actual
console.log("Archivos actuales:", filesData.length);
console.table(filesData);

// Navegar programáticamente
navigateToFolder("root"); // Ir a raíz
navigateToFolder(4); // Ir a Documentos
navigateToFolder(44); // Ir a Contratos
navigateToFolder(9); // Ir a Modelos 3D
navigateToFolder(10); // Ir a Multimedia

// Ver ruta de breadcrumb
console.log("Ruta:", folderPath);

// Filtrar manualmente
filterFilesByFolder(4); // Ver archivos de Documentos

// Ver estadísticas
updateStats();

// Buscar archivo específico
const file = allFilesData.find((f) => f.name.includes("Servidor"));
console.log("Archivo encontrado:", file);

// Ver archivos de una carpeta específica
const archivosMultimedia = allFilesData.filter((f) => f.folderId === 10);
console.log("Archivos en Multimedia:", archivosMultimedia);
```

---

**¡Sistema listo para probar!** 🚀

Si encuentras algún problema, revisa la consola del navegador para mensajes de debug.
