#!/bin/bash

# ==============================================================================
# SCRIPT DE AUTOMAÇÃO: ATIVIDADE 4 - SERVIDOR NFS
# Objetivo: Instalar e configurar servidor de arquivos NFS.
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Suporte a sincronização
source /tmp/common_utils.sh 2>/dev/null

# --- MODO MANUAL (Para o Aluno) ---
if [[ "$1" == "-m" || "$1" == "--manual" ]]; then
    clear
    echo -e "${BLUE}=== GUIA DE EXECUÇÃO MANUAL (ATIVIDADE 4 - SERVIDOR NFS) ===${NC}"
    echo -e "${YELLOW}--- PASSO 1: INSTALAR ---${NC}"
    echo -e "${YELLOW}sudo apt install nfs-kernel-server -y${NC}"
    echo -e "${GREEN}# Instala o software para o servidor NFS.${NC}"
    echo ""
    echo -e "${YELLOW}--- PASSO 2: DIRETÓRIOS COMPARTILHADOS ---${NC}"
    echo -e "${YELLOW}sudo mkdir -p /nfs/Jala-drive /nfs/installers${NC}"
    echo -e "${GREEN}# Cria os dois diretórios que serão exportados: Jala-drive e installers.${NC}"
    echo -e "${YELLOW}sudo chown nobody:nogroup /nfs/Jala-drive /nfs/installers${NC}"
    echo -e "${YELLOW}sudo chmod 777 /nfs/Jala-drive /nfs/installers${NC}"
    echo -e "${GREEN}# Ajusta dono y permissões para que qualquer cliente possa ler e escrever.${NC}"
    echo ""
    echo -e "${YELLOW}--- PASSO 3: CONFIGURAR /etc/exports ---${NC}"
    echo -e "${YELLOW}echo '/nfs/Jala-drive *(rw,sync,no_subtree_check)' | sudo tee -a /etc/exports${NC}"
    echo -e "${YELLOW}echo '/nfs/installers *(rw,sync,no_subtree_check)' | sudo tee -a /etc/exports${NC}"
    echo -e "${GREEN}# Exporta ambos os diretórios para qualquer IP (*). Em produção, restrinja o IP.${NC}"
    echo ""
    echo -e "${YELLOW}sudo exportfs -ra${NC}"
    echo -e "${YELLOW}sudo systemctl restart nfs-kernel-server${NC}"
    echo -e "${GREEN}# Aplica as exportações e reinicia o serviço. Verifique com: sudo exportfs -v${NC}"
    echo ""
    echo -e "${YELLOW}--- PASSO 4: FIREWALL ---${NC}"
    echo -e "${YELLOW}sudo ufw allow nfs${NC}"
    echo -e "${GREEN}# Abre a porta 2049 (NFS) no firewall. Verifique com: sudo ufw status${NC}"
    exit 0
fi

clear
echo -e "${BLUE}======================================================================"
echo -e "       AUTOMAÇÃO CAPSTONE - ATIVIDADE 4: SERVIDOR NFS"
echo -e "======================================================================${NC}"
log_context
echo ""

# --- TEORIA ---
echo -e "${YELLOW}[CONCEITO TEÓRICO]${NC}"
echo "NFS (Network File System) permite que um servidor compartilhe diretórios"
echo "com outros computadores pela rede como se fossem discos locais."
echo ""
read -p "Pressione ENTER para começar..."

# --- PASSO 1: INSTALAÇÃO ---
unlock_essential_services
echo -e "${GREEN}[PASSO 1] Instalando nfs-kernel-server...${NC}"
sudo apt update > /dev/null
sudo apt install nfs-kernel-server -y > /dev/null
echo "✔ Pacote NFS instalado."

# --- PASSO 2: DIRETÓRIOS ---
echo -e "\n${GREEN}[PASSO 2] Criando diretórios do drive...${NC}"
# Sobrenome: Jala
sudo mkdir -p /nfs/Jala-drive
sudo mkdir -p /nfs/installers

# Permissões genéricas para teste de laboratório
sudo chown nobody:nogroup /nfs/Jala-drive
sudo chown nobody:nogroup /nfs/installers
sudo chmod 777 /nfs/Jala-drive
sudo chmod 777 /nfs/installers
echo "✔ Diretórios criados em /nfs"

# --- PASSO 3: EXPORTS ---
echo -e "\n${GREEN}[PASSO 3] Configurando /etc/exports...${NC}"

# Limpa configurações antigas para evitar duplicidade
sudo sed -i '/\/nfs/d' /etc/exports

# Adiciona o compartilhamento (Permissivo para lab: qualquer IP '*' ou rede local)
echo "/nfs/Jala-drive *(rw,sync,no_subtree_check)" | sudo tee -a /etc/exports > /dev/null
echo "/nfs/installers *(rw,sync,no_subtree_check)" | sudo tee -a /etc/exports > /dev/null

# Aplica exportação
sudo exportfs -ra
sudo systemctl restart nfs-kernel-server
echo "✔ Compartilhamentos exportados com sucesso."

# --- PASSO 4: FIREWALL ---
echo -e "\n${GREEN}[PASSO 4] Abrindo Firewall para NFS...${NC}"
# NFS usa tradicionalmente a porta 2049
sudo ufw allow nfs comment 'Servidor NFS'
echo "✔ Regras de firewall aplicadas."

# --- VALIDAÇÃO ---
echo -e "\n${BLUE}======================================================================"
echo -e "                       VALIDAÇÃO DO SERVIDOR"
echo -e "======================================================================${NC}"
sudo exportfs -v
echo ""
echo -e "${YELLOW}[DICA PARA O CLIENTE]${NC}"
echo "Para montar no cliente, use o comando:"
echo "sudo mount ${VM_IP}:/nfs/Jala-drive /ponto/de/montagem"

echo -e "\n${GREEN}✔ ATIVIDADE 4 CONCLUÍDA NO SERVIDOR!${NC}"
