#!/usr/bin/env bash
set -e

GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

VERSION="${VERSION:-0.3.5}"
OUTPUT_DIR="$(pwd)/dist"
DEBUG="${DEBUG:-0}"

echo -e "${CYAN}=== MultiWall Flatpak Builder ===${RESET}"
echo -e "${YELLOW}Version: ${VERSION}${RESET}"
echo ""

# --- Procesamiento de argumentos ---
FORCE_REBUILD=false
VALIDATE_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        rebuild)
            FORCE_REBUILD=true
            shift
            ;;
        validate)
            VALIDATE_ONLY=true
            shift
            ;;
        --debug)
            DEBUG=1
            shift
            ;;
        -h|--help)
            echo "Uso: $0 [rebuild|validate] [--debug]"
            echo ""
            echo "Comandos:"
            echo "  rebuild   - Forzar reconstrucción de imagen Docker"
            echo "  validate  - Solo validar archivos sin construir"
            echo "  --debug   - Modo debug con output verbose"
            echo ""
            echo "Variables de entorno:"
            echo "  VERSION=x.y.z  - Versión del paquete (default: 0.3.5)"
            echo "  DEBUG=1        - Activar modo debug"
            echo ""
            echo "Ejemplos:"
            echo "  $0                      # Build normal"
            echo "  $0 rebuild              # Rebuild forzado"
            echo "  $0 --debug              # Build con debug"
            echo "  $0 validate             # Solo validar"
            echo "  VERSION=0.4.0 $0        # Build con versión específica"
            exit 0
            ;;
        *)
            echo -e "${RED}Argumento desconocido: $1${RESET}"
            echo "Usa '$0 --help' para ver opciones"
            exit 1
            ;;
    esac
done

if [[ "$FORCE_REBUILD" == "true" ]]; then
    echo -e "${YELLOW}⚡ Reconstrucción forzada de imagen Docker HABILITADA${RESET}"
fi

if [[ "$DEBUG" == "1" ]]; then
    echo -e "${YELLOW}🔍 Modo DEBUG activado${RESET}"
fi

# Verificar Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker no está instalado${RESET}"
    echo "Instala Docker desde: https://docs.docker.com/get-docker/"
    exit 1
fi

# Función para imprimir pasos
step() {
    echo -e "${CYAN}→${RESET} $1"
}

# Crear directorio de salida
mkdir -p "$OUTPUT_DIR"

# Función para validar Flatpak
validate_flatpak() {
    step "Validando archivos de Flatpak..."
    
    local errors=0
    
    # Verificar archivos requeridos
    for file in \
        "me.latinosoft.MultiWall.yml" \
        "me.latinosoft.MultiWall.metainfo.xml" \
        "me.latinosoft.MultiWall.desktop"
    do
        if [ ! -f "$file" ]; then
            echo -e "${RED}✗ Falta: $file${RESET}"
            ((errors++))
        else
            echo -e "${GREEN}✓ Encontrado: $file${RESET}"
        fi
    done
    
    # Validar con herramientas del sistema si están disponibles
    if command -v desktop-file-validate >/dev/null 2>&1; then
        step "Validando desktop file..."
        if desktop-file-validate me.latinosoft.MultiWall.desktop 2>&1; then
            echo -e "${GREEN}✓ Desktop file válido${RESET}"
        else
            echo -e "${YELLOW}⚠ Desktop file tiene warnings${RESET}"
        fi
    fi
    
    if command -v appstream-util >/dev/null 2>&1; then
        step "Validando metainfo..."
        if appstream-util validate-relax me.latinosoft.MultiWall.metainfo.xml 2>&1; then
            echo -e "${GREEN}✓ Metainfo válido${RESET}"
        else
            echo -e "${YELLOW}⚠ Metainfo tiene warnings${RESET}"
        fi
    fi
    
    if [ $errors -gt 0 ]; then
        echo -e "${RED}❌ Validación falló con $errors errores${RESET}"
        return 1
    else
        echo -e "${GREEN}✅ Validación exitosa${RESET}"
        return 0
    fi
}

# Si solo validar, ejecutar y salir
if [[ "$VALIDATE_ONLY" == "true" ]]; then
    validate_flatpak
    exit $?
fi

# Función para construir Flatpak
build_flatpak() {
    echo -e "${GREEN}→ Construyendo Flatpak...${RESET}"
    
    # Validar antes de construir
    if ! validate_flatpak; then
        echo -e "${RED}❌ Validación falló, abortando build${RESET}"
        return 1
    fi
    
    # Construir imagen Docker si necesario
    if [[ "$FORCE_REBUILD" == "true" ]] || [[ "$(docker images -q multiwall-flatpak 2> /dev/null)" == "" ]]; then
        step "Construyendo imagen Docker para Flatpak..."
        docker build -f docker/Dockerfile -t multiwall-flatpak .
    else
        echo -e "${GREEN}✓ Usando imagen Docker existente${RESET}"
    fi
    
    # Ejecutar construcción con acceso a red
    echo ""
    step "Ejecutando flatpak-builder en Docker..."
    docker run --rm \
        --privileged \
        -v "$(pwd):/app:ro" \
        -v "$OUTPUT_DIR:/output" \
        -e VERSION="$VERSION" \
        -e DEBUG="$DEBUG" \
        --network=host \
        multiwall-flatpak
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Flatpak generado: ${OUTPUT_DIR}/MultiWall-${VERSION}-x86_64.flatpak${RESET}"
    else
        echo -e "${RED}❌ Flatpak build falló${RESET}"
        return 1
    fi
}

# Construir Flatpak
build_flatpak

# Resumen final
echo ""
echo -e "${CYAN}=== Construcción completada ===${RESET}"
echo -e "Paquete generado en: ${GREEN}${OUTPUT_DIR}${RESET}"
echo ""

if [ -d "$OUTPUT_DIR" ] && [ "$(ls -A "$OUTPUT_DIR" 2>/dev/null)" ]; then
    ls -lh "$OUTPUT_DIR"
    echo ""
    
    echo -e "${YELLOW}Para instalar:${RESET}"
    echo -e "  ${GREEN}flatpak install --user $OUTPUT_DIR/MultiWall-${VERSION}-x86_64.flatpak${RESET}"
    echo ""
    echo -e "${YELLOW}Para ejecutar:${RESET}"
    echo -e "  ${GREEN}flatpak run me.latinosoft.MultiWall${RESET}"
else
    echo -e "${YELLOW}⚠️ No se generó el paquete${RESET}"
fi

echo ""
echo -e "${CYAN}Tips:${RESET}"
echo "  • Usa './build_packages.sh validate' para solo validar archivos"
echo "  • Usa './build_packages.sh --debug' para output verbose"
echo "  • Usa './build_packages.sh rebuild' para forzar rebuild de Docker"
echo "  • Usa 'VERSION=0.4.0 ./build_packages.sh' para versión específica"