#!/bin/bash
# ====================================================
#  U U I D - D L L (Solution for UUID Bypass)
# Feito por: Thiago Amorim (1B - IFAL)
# Contato: @0xffff00
# ====================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

function log_step {
    echo -e "\n${BLUE}═══════════════════════════════════════════════${NC}"
    echo -e "${GREEN}    $1    ${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}\n"
    sleep 1
}

function log_success {
    echo -e "${GREEN}[ ✓ ]: $1${NC}"
}

function log_warning {
    echo -e "${YELLOW}[ ! ]: $1${NC}"
}

function log_error {
    echo -e "${RED}[ ✗ ]: $1${NC}"
}

function ensure_uuid_tools {
    if ! command -v uuidgen >/dev/null 2>&1 && ! command -v dbus-uuidgen >/dev/null 2>&1 && ! command -v systemd-machine-id-setup >/dev/null 2>&1; then
        log_warning "Ferramentas UUID não encontradas. Tentando instalar..."
        sudo apt update -qq >/dev/null 2>&1 && sudo apt install -y uuid-runtime dbus >/dev/null 2>&1 || true
    fi
}

function reset_uuid {
    log_step "Resetando UUID do sistema para bypass e anonimato..."
    ensure_uuid_tools
    if command -v systemd-machine-id-setup >/dev/null 2>&1; then
        sudo systemd-machine-id-setup 2>/dev/null || true
        log_success "UUID resetado via systemd."
    elif command -v dbus-uuidgen >/dev/null 2>&1; then
        sudo rm -f /etc/machine-id /var/lib/dbus/machine-id 2>/dev/null || true
        sudo dbus-uuidgen --ensure=/etc/machine-id 2>/dev/null || true
        sudo ln -s /etc/machine-id /var/lib/dbus/machine-id 2>/dev/null || true
        log_success "UUID resetado via dbus-uuidgen."
    elif command -v uuidgen >/dev/null 2>&1; then
        sudo rm -f /etc/machine-id /var/lib/dbus/machine-id 2>/dev/null || true
        sudo uuidgen | sudo tee /etc/machine-id >/dev/null || true
        sudo ln -s /etc/machine-id /var/lib/dbus/machine-id 2>/dev/null || true
        log_success "UUID gerado via uuidgen."
    else
        log_error "Nenhuma ferramenta para gerar UUID disponível."
        return 1
    fi
    NEW_UUID=$(cat /etc/machine-id 2>/dev/null)
    if [ -n "$NEW_UUID" ]; then
        log_success "Novo UUID: $NEW_UUID"
    else
        log_error "Falha ao verificar novo UUID."
    fi
}

# ====================================================
# MAIN
# ====================================================
if [ "$EUID" -ne 0 ]; then
    log_error "Execute como root: sudo bash $0"
    exit 1
fi

clear
echo -e "${BLUE}══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}          U U I D - D L L (Bypass Solution)              ${NC}"
echo -e "${PURPLE}              Thiago Amorim (1B - IFAL)                  ${NC}"
echo -e "${CYAN}                    @0xffff00                            ${NC}"
echo -e "${BLUE}══════════════════════════════════════════════════════════${NC}"
echo ""
reset_uuid
echo -e "\n${BLUE}══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Feito por: Thiago Amorim (1B - IFAL)                     ${NC}"
echo -e "${CYAN}Contato: @0xffff00                                   ${NC}"
echo -e "${BLUE}══════════════════════════════════════════════════════════${NC}"
