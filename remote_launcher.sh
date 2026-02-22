#!/bin/bash

# ==============================================================================
# LANÇADOR REMOTO: AUTOMAÇÃO CAPSTONE
# Objetivo: Coletar credenciais e executar scripts na VM via SSH.
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${BLUE}======================================================================"
echo -e "           LANÇADOR DE AUTOMAÇÃO REMOTA - CAPSTONE"
echo -e "======================================================================${NC}"

# 1. Seleção da Máquina Alvo
echo -e "\n${YELLOW}Em qual máquina deseja trabalhar?${NC}"
echo "1) Servidor NFS (Original - 10.0.0.102)"
echo "2) Cliente NFS (Novo - 10.0.0.127)"
read -p "Escolha a VM [1]: " VM_CHOICE
VM_CHOICE=${VM_CHOICE:-1}

if [[ "$VM_CHOICE" == "2" ]]; then
    VM_IP="10.0.0.127"
    VM_USER="rgaldino_capstone_cliente"
    VM_PORT="22"
    echo -e "${BLUE}>>> Alvo definido: CLIENTE NFS (10.0.0.127)${NC}"
else
    VM_IP="10.0.0.102"
    VM_USER="rgaldino"
    VM_PORT="2244"
    echo -e "${BLUE}>>> Alvo definido: SERVIDOR NFS (Original - 10.0.0.102)${NC}"
fi

echo -e "\n${YELLOW}=== O QUE DESEJA FAZER? ===${NC}"
echo "1) Entrar no Terminal (Apenas SSH)"
echo "2) Enviar e Rodar Script (Automação rápida)"
echo "3) Enviar, Rodar e CONTINUAR na VM (Recomendado)"
read -p "Escolha uma opção [3]: " OPCAO
OPCAO=${OPCAO:-3}

case $OPCAO in
    1)
        echo -e "${BLUE}Conectando ao terminal da VM...${NC}"
        ssh -p "$VM_PORT" "$VM_USER@$VM_IP"
        ;;
    2|3)
        # Seleção do Script
        echo -e "\n${YELLOW}Scripts locais encontrados:${NC}"
        ls *.sh
        read -p "Qual atividade deseja enviar? [atividade_1.sh]: " TARGET_SCRIPT
        TARGET_SCRIPT=${TARGET_SCRIPT:-atividade_1.sh}
        # Limpa espaços ou pontos acidentais
        TARGET_SCRIPT=$(echo "$TARGET_SCRIPT" | sed 's/[[:space:].]*$//')

        if [[ ! -f "$TARGET_SCRIPT" ]]; then
            echo -e "${RED}Erro: '$TARGET_SCRIPT' não existe nesta pasta.${NC}"
            exit 1
        fi

        echo -e "${BLUE}Propagando utilitários e '$TARGET_SCRIPT' para a VM...${NC}"
        scp -P "$VM_PORT" "common_utils.sh" "$VM_USER@$VM_IP:/tmp/common_utils.sh" > /dev/null
        scp -P "$VM_PORT" "$TARGET_SCRIPT" "$VM_USER@$VM_IP:/tmp/$TARGET_SCRIPT"
        
        if [[ "$OPCAO" == "3" ]]; then
            echo -e "${GREEN}Script enviado! Entrando na VM para execução...${NC}"
            ssh -t -p "$VM_PORT" "$VM_USER@$VM_IP" "bash /tmp/$TARGET_SCRIPT; bash"
        else
            echo -e "${GREEN}Executando script e retornando...${NC}"
            ssh -t -p "$VM_PORT" "$VM_USER@$VM_IP" "bash /tmp/$TARGET_SCRIPT"
        fi
        ;;
    *)
        echo -e "${RED}Opção inválida.${NC}"
        ;;
esac

echo -e "\n${GREEN}Portal finalizado.${NC}"
