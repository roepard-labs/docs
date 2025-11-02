#!/bin/bash

# ============================================
# NPM Dependencies Installation Script
# HomeLab VR - Roepard Labs
# ============================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored messages
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_header() {
    echo -e "\n${BLUE}================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================================${NC}\n"
}

# Check if Node.js is installed
check_node() {
    print_header "Verificando Node.js y npm"
    
    if ! command -v node &> /dev/null; then
        print_error "Node.js no está instalado"
        print_info "Instalando Node.js..."
        
        # Install Node.js
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        sudo apt-get install -y nodejs
        
        print_success "Node.js instalado correctamente"
    else
        NODE_VERSION=$(node --version)
        print_success "Node.js encontrado: $NODE_VERSION"
    fi
    
    if ! command -v npm &> /dev/null; then
        print_error "npm no está instalado"
        exit 1
    else
        NPM_VERSION=$(npm --version)
        print_success "npm encontrado: $NPM_VERSION"
    fi
}

# Clean previous installations
clean_installation() {
    print_header "Limpiando instalaciones previas"
    
    if [ -d "node_modules" ]; then
        print_warning "Eliminando node_modules existente..."
        rm -rf node_modules
        print_success "node_modules eliminado"
    fi
    
    if [ -f "package-lock.json" ]; then
        print_warning "Eliminando package-lock.json existente..."
        rm -f package-lock.json
        print_success "package-lock.json eliminado"
    fi
    
    # Clear npm cache
    print_info "Limpiando caché de npm..."
    npm cache clean --force
    print_success "Caché limpiado"
}

# Install dependencies
install_dependencies() {
    print_header "Instalando dependencias desde package.json"
    
    if [ ! -f "package.json" ]; then
        print_error "package.json no encontrado"
        exit 1
    fi
    
    print_info "Iniciando instalación..."
    npm install
    
    print_success "Todas las dependencias instaladas correctamente"
}

# Verify installation
verify_installation() {
    print_header "Verificando instalación"
    
    # Check if node_modules exists
    if [ ! -d "node_modules" ]; then
        print_error "node_modules no fue creado"
        exit 1
    fi
    
    # Check key dependencies
    DEPENDENCIES=(
        "bootstrap"
        "jquery"
        "aframe"
        "chart.js"
        "datatables.net"
        "sweetalert2"
        "notyf"
        "three"
    )
    
    MISSING_COUNT=0
    
    for dep in "${DEPENDENCIES[@]}"; do
        if [ -d "node_modules/$dep" ]; then
            print_success "$dep instalado"
        else
            print_error "$dep NO instalado"
            ((MISSING_COUNT++))
        fi
    done
    
    if [ $MISSING_COUNT -eq 0 ]; then
        print_success "Todas las dependencias clave verificadas"
    else
        print_error "$MISSING_COUNT dependencias faltantes"
        exit 1
    fi
}

# Show installation summary
show_summary() {
    print_header "Resumen de Instalación"
    
    # Count installed packages
    PACKAGE_COUNT=$(ls -1 node_modules | wc -l)
    
    # Get size of node_modules
    NODE_MODULES_SIZE=$(du -sh node_modules 2>/dev/null | cut -f1)
    
    print_success "Total de paquetes instalados: $PACKAGE_COUNT"
    print_success "Tamaño de node_modules: $NODE_MODULES_SIZE"
    
    echo -e "\n${GREEN}📦 Principales dependencias instaladas:${NC}"
    echo "  • Bootstrap 5.3.3 (Framework CSS)"
    echo "  • A-Frame 1.7.1 (WebXR VR)"
    echo "  • Three.js 0.179.1 (3D Graphics)"
    echo "  • jQuery 3.7.1 (DOM Manipulation)"
    echo "  • Chart.js 4.4.6 (Charts)"
    echo "  • DataTables 2.1.8 (Tables)"
    echo "  • SweetAlert2 11.14.5 (Alerts)"
    echo "  • Notyf 3.10.0 (Notifications)"
    
    echo -e "\n${GREEN}✅ Instalación completada exitosamente${NC}"
    echo -e "\n${BLUE}Próximos pasos:${NC}"
    echo "  1. Accede a los nuevos templates:"
    echo "     • http://localhost/views/modern.template.view.php"
    echo "     • http://localhost/views/vr.modern.template.view.php"
    echo ""
    echo "  2. Lee la documentación completa:"
    echo "     • cat NPM-MIGRATION.md"
    echo ""
    echo "  3. Comienza a desarrollar con las nuevas dependencias"
}

# Create .gitignore if not exists
setup_gitignore() {
    print_header "Configurando .gitignore"
    
    if [ ! -f ".gitignore" ]; then
        print_info "Creando .gitignore..."
        cat > .gitignore << 'EOF'
# Dependencies
node_modules/

# Environment
.env
.env.local

# Logs
*.log
npm-debug.log*

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo
EOF
        print_success ".gitignore creado"
    else
        # Check if node_modules is in .gitignore
        if ! grep -q "node_modules" .gitignore; then
            print_warning "Añadiendo node_modules a .gitignore..."
            echo "" >> .gitignore
            echo "# Dependencies" >> .gitignore
            echo "node_modules/" >> .gitignore
            print_success "node_modules añadido a .gitignore"
        else
            print_success ".gitignore ya configurado correctamente"
        fi
    fi
}

# Main execution
main() {
    clear
    
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║     🚀 HomeLab VR - NPM Dependencies Installer 🚀         ║"
    echo "║                                                            ║"
    echo "║              Roepard Labs - Installation Script           ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
    
    # Get script directory
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    cd "$SCRIPT_DIR"
    
    print_info "Directorio de trabajo: $SCRIPT_DIR"
    
    # Run installation steps
    check_node
    setup_gitignore
    
    # Ask for clean install
    echo -e "\n${YELLOW}¿Deseas hacer una instalación limpia? (Eliminar node_modules existente)${NC}"
    read -p "Responder (s/n): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[SsYy]$ ]]; then
        clean_installation
    fi
    
    install_dependencies
    verify_installation
    show_summary
    
    echo -e "\n${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║          ✅ Instalación completada exitosamente ✅          ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}\n"
}

# Run main function
main
