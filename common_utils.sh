#!/bin/bash

# ==============================================================================
# COMMON UTILS: CAPSTONE SYNCHRONIZER
# Objetivo: Garantir que o ambiente esteja pronto para as atividades.
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Função para desbloquear serviços essenciais no firewall
unlock_essential_services() {
    echo -e "${YELLOW}[SYNC] Verificando conectividade...${NC}"
    
    # Testa DNS (Google DNS como referência)
    if ! timeout 2 bash -c 'cat < /dev/null > /dev/tcp/8.8.8.8/53' 2>/dev/null; then
        echo -e "${BLUE}[SYNC] DNS bloqueado. Liberando porta 53...${NC}"
        sudo ufw allow out 53 > /dev/null
    fi

    # Testa HTTP/HTTPS (para o apt)
    if ! timeout 2 bash -c 'cat < /dev/null > /dev/tcp/archive.ubuntu.com/80' 2>/dev/null; then
        echo -e "${BLUE}[SYNC] APT bloqueado. Liberando portas 80 e 443...${NC}"
        sudo ufw allow out 80/tcp > /dev/null
        sudo ufw allow out 443/tcp > /dev/null
    fi

    echo -e "${GREEN}[SYNC] Ambiente sincronizado e pronto.${NC}"
}

# Função de log padrão para mostrar contexto da VM
log_context() {
    echo -e "${YELLOW}[AMBIENTE ATUAL]${NC} $(whoami)@$(hostname)"
}
