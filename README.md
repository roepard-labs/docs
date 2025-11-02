# 📚 HomeLab VR - Documentación Completa

> Manual técnico, arquitectura y guías de deployment del proyecto **HomeLab VR**

**Versión:** 1.0.0  
**Última actualización:** 02/01/2025

---

## 🚀 Quick Start - Deployment

### **Para deployment rápido:**
1. **[Quick Deployment Checklist](QUICK-DEPLOYMENT-CHECKLIST.md)** - 5 pasos para producción ⚡

### **Para entender la arquitectura:**
2. **[Architecture Diagrams](ARCHITECTURE-DIAGRAMS.md)** - Diagramas visuales 📊
3. **[Deployment Final Summary](DEPLOYMENT-FINAL-SUMMARY.md)** - Resumen completo ✅

---

## 📖 Índice de Documentación

### **🐳 Docker & Deployment**
| Documento | Descripción | Audiencia |
|-----------|-------------|-----------|
| **[QUICK-DEPLOYMENT-CHECKLIST.md](QUICK-DEPLOYMENT-CHECKLIST.md)** | Checklist de 5 pasos para deployment rápido | DevOps, Developers |
| **[DOKPLOY-DEPLOYMENT.md](DOKPLOY-DEPLOYMENT.md)** | Guía completa de deployment en Dokploy | DevOps, SysAdmin |
| **[DOCKER-SECURITY.md](DOCKER-SECURITY.md)** | Arquitectura de seguridad en Docker | DevOps, Security |
| **[DEPLOYMENT-FINAL-SUMMARY.md](DEPLOYMENT-FINAL-SUMMARY.md)** | Resumen de todos los cambios implementados | Team Lead, Developers |

### **🏗️ Arquitectura & Diseño**
| Documento | Descripción | Audiencia |
|-----------|-------------|-----------|
| **[ARCHITECTURE-DIAGRAMS.md](ARCHITECTURE-DIAGRAMS.md)** | Diagramas Mermaid de la arquitectura | Developers, Architects |
| **[LAYOUTS-ARQUITECTURA.md](LAYOUTS-ARQUITECTURA.md)** | Sistema de layouts PHP (AppLayout, AdminLayout, UserLayout) | Frontend Developers |
| **[sistema-layouts.md](sistema-layouts.md)** | Documentación del sistema de layouts | Frontend Developers |
| **[mvc.md](mvc.md)** | Arquitectura MVC del backend | Backend Developers |

### **🔧 Configuración & Setup**
| Documento | Descripción | Audiencia |
|-----------|-------------|-----------|
| **[ENV-CONFIG.md](ENV-CONFIG.md)** | Sistema de variables de entorno | Developers, DevOps |
| **[desarrollo.md](desarrollo.md)** | Guía de desarrollo local | Developers |
| **[especificaciones-tecnicas.md](especificaciones-tecnicas.md)** | Stack tecnológico y dependencias | Architects, Developers |

### **🔒 Seguridad**
| Documento | Descripción | Audiencia |
|-----------|-------------|-----------|
| **[SECURITY-GUIDE.md](SECURITY-GUIDE.md)** | Guía de seguridad completa | Security, DevOps |
| **[SECURITY-SUMMARY.md](SECURITY-SUMMARY.md)** | Resumen de medidas de seguridad | Team Lead, Security |
| **[CORS-IMPLEMENTATION-SUMMARY.md](CORS-IMPLEMENTATION-SUMMARY.md)** | Implementación de CORS | Backend Developers |

### **🎨 Frontend & UI**
| Documento | Descripción | Audiencia |
|-----------|-------------|-----------|
| **[guia-estilos.md](guia-estilos.md)** | Guía de estilos CSS y componentes | Frontend Developers, Designers |
| **[componentes.md](componentes.md)** | Componentes VR/AR con A-Frame | VR Developers |
| **[header-auth-dinamico.md](header-auth-dinamico.md)** | Sistema de autenticación en header | Frontend Developers |
| **[modal-autenticacion.md](modal-autenticacion.md)** | Modal de login/registro | Frontend Developers |

### **🔌 API & Backend**
| Documento | Descripción | Audiencia |
|-----------|-------------|-----------|
| **[api.md](api.md)** | Documentación de endpoints API | Developers |
| **[CORS-README.md](CORS-README.md)** | Configuración de CORS | Backend Developers |

### **📋 General**
| Documento | Descripción | Audiencia |
|-----------|-------------|-----------|
| **[caracteristicas.md](caracteristicas.md)** | Características del proyecto | Product Owner, Team |
| **[mockup.md](mockup.md)** | Mockups y diseños visuales | Designers, Product Owner |
| **[acerca-de.md](acerca-de.md)** | Información del proyecto | Everyone |
| **[ACTUALIZACIONES.md](ACTUALIZACIONES.md)** | Historial de cambios | Team Lead, Developers |

---

## 🎯 Guías por Rol

### **👨‍💻 Para Developers (Nuevos en el Proyecto)**
1. Leer: [acerca-de.md](acerca-de.md) - Entender el proyecto
2. Leer: [especificaciones-tecnicas.md](especificaciones-tecnicas.md) - Stack tecnológico
3. Leer: [desarrollo.md](desarrollo.md) - Setup local
4. Leer: [ENV-CONFIG.md](ENV-CONFIG.md) - Configurar variables de entorno
5. Leer: [mvc.md](mvc.md) - Arquitectura backend
6. Leer: [LAYOUTS-ARQUITECTURA.md](LAYOUTS-ARQUITECTURA.md) - Sistema de layouts

### **🚀 Para DevOps (Deployment)**
1. Leer: [QUICK-DEPLOYMENT-CHECKLIST.md](QUICK-DEPLOYMENT-CHECKLIST.md) - Quick start
2. Leer: [DOKPLOY-DEPLOYMENT.md](DOKPLOY-DEPLOYMENT.md) - Guía paso a paso
3. Leer: [DOCKER-SECURITY.md](DOCKER-SECURITY.md) - Seguridad en Docker
4. Leer: [ENV-CONFIG.md](ENV-CONFIG.md) - Variables de entorno
5. Ejecutar: `scripts/security-check.sh` - Validar deployment

### **🔒 Para Security Team**
1. Leer: [SECURITY-GUIDE.md](SECURITY-GUIDE.md) - Guía completa
2. Leer: [DOCKER-SECURITY.md](DOCKER-SECURITY.md) - Seguridad en Docker
3. Leer: [SECURITY-SUMMARY.md](SECURITY-SUMMARY.md) - Resumen
4. Revisar: [ARCHITECTURE-DIAGRAMS.md](ARCHITECTURE-DIAGRAMS.md) - Capas de seguridad
5. Ejecutar: `scripts/security-check.sh` - Tests automáticos

### **🎨 Para Frontend Developers**
1. Leer: [guia-estilos.md](guia-estilos.md) - Estilos y componentes
2. Leer: [LAYOUTS-ARQUITECTURA.md](LAYOUTS-ARQUITECTURA.md) - Sistema de layouts
3. Leer: [componentes.md](componentes.md) - Componentes VR/AR
4. Leer: [header-auth-dinamico.md](header-auth-dinamico.md) - Autenticación
5. Leer: [modal-autenticacion.md](modal-autenticacion.md) - Modal login

### **🏗️ Para Architects**
1. Leer: [ARCHITECTURE-DIAGRAMS.md](ARCHITECTURE-DIAGRAMS.md) - Diagramas completos
2. Leer: [especificaciones-tecnicas.md](especificaciones-tecnicas.md) - Stack
3. Leer: [mvc.md](mvc.md) - Arquitectura MVC
4. Leer: [DOCKER-SECURITY.md](DOCKER-SECURITY.md) - Arquitectura de seguridad
5. Leer: [LAYOUTS-ARQUITECTURA.md](LAYOUTS-ARQUITECTURA.md) - Sistema de layouts

---

## 🆕 Últimas Actualizaciones (02/01/2025)

### **Nuevos Documentos:**
- ✅ **QUICK-DEPLOYMENT-CHECKLIST.md** - Checklist de 5 pasos
- ✅ **DOKPLOY-DEPLOYMENT.md** - Guía de deployment
- ✅ **DOCKER-SECURITY.md** - Seguridad en Docker
- ✅ **DEPLOYMENT-FINAL-SUMMARY.md** - Resumen completo
- ✅ **ARCHITECTURE-DIAGRAMS.md** - Diagramas visuales

### **Actualizaciones de Sistema:**
- ✅ Dockerfile con build de npm integrado
- ✅ Generación automática de `js/config.js` desde `.env`
- ✅ Protección condicional de directorios (chmod)
- ✅ nginx.conf con reglas de seguridad frontend
- ✅ Script `security-check.sh` para validación automática

---

## 🎨 Guía de Estilo Original

| Sección | Descripción |
|---------|-------------|
| 🎨 **[Guía de Estilo](guia-estilos.md)** | Paleta de colores, tipografías y componentes. |
| 👀 **[Mockup](mockup.md)** | Vistazo visual al diseño de la plataforma. |
| 👀 **[Referencia](referencia-rapida.md)** | Vistazo visual al diseño de la plataforma. |
| 🛠️ **[Desarrollo](desarrollo.md)** | Pasos de instalación, comandos, Nginx, roles y más. |
| ✨ **[Acerca de](acerca-de.md)** | Información del proyecto, equipo y roadmap. |

