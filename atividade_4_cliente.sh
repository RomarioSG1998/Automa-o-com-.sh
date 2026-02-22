#!/bin/bash

# ==============================================================================
# SCRIPT DE AUTOMAÇÃO: ATIVIDADE 4 - CLIENTE NFS
# Objetivo: Montar diretórios remotos do servidor NFS.
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
    echo -e "${BLUE}=== GUIA DE EXECUÇÃO MANUAL (ATIVIDADE 4 - CLIENTE NFS) ===${NC}"
    echo -e "${YELLOW}--- PASSO 1: INSTALAR ---${NC}"
    echo -e "${YELLOW}sudo apt install nfs-common -y${NC}"
    echo -e "${GREEN}# Instala as ferramentas de cliente para montar NFS.${NC}"
    echo ""
    echo -e "${YELLOW}--- PASSO 2: PONTOS DE MONTAGEM ---${NC}"
    echo -e "${YELLOW}sudo mkdir -p /mnt/nfs-drive /mnt/nfs-installers${NC}"
    echo -e "${GREEN}# Cria as pastas locais onde os diretórios remotos serão montados.${NC}"
    echo ""
    echo -e "${YELLOW}--- PASSO 3: MONTAR OS DIRETÓRIOS REMOTOS ---${NC}"
    echo -e "${YELLOW}sudo mount -t nfs 10.0.0.102:/nfs/Jala-drive /mnt/nfs-drive${NC}"
    echo -e "${GREEN}# Monta o Jala-drive do servidor (IP: 10.0.0.102) localmente.${NC}"
    echo -e "${YELLOW}sudo mount -t nfs 10.0.0.102:/nfs/installers /mnt/nfs-installers${NC}"
    echo -e "${GREEN}# Monta o installers do servidor localmente.${NC}"
    echo -e "${GREEN}# Verifique com: df -h | grep nfs${NC}"
    echo ""
    echo -e "${YELLOW}--- PASSO 4: TESTE DE ESCRITA ---${NC}"
    echo -e "${YELLOW}echo 'Teste NFS OK' > /mnt/nfs-drive/teste.txt${NC}"
    echo -e "${GREEN}# Escreve um arquivo no compartilhamento. Se funcionar, a montagem está correta.${NC}"
    echo -e "${GREEN}# No servidor, o arquivo aparecerá em /nfs/Jala-drive/teste.txt${NC}"
    exit 0
fi

clear
echo -e "${BLUE}======================================================================"
echo -e "       AUTOMAÇÃO CAPSTONE - ATIVIDADE 4: CLIENTE NFS"
echo -e "======================================================================${NC}"
log_context
echo ""

# --- PASSO 1: INSTALAÇÃO ---
unlock_essential_services
echo -e "${GREEN}[PASSO 1] Instalando pacotes NFS Client...${NC}"
sudo apt update > /dev/null
sudo apt install nfs-common -y > /dev/null
echo "✔ Pacotes de cliente instalados."

# --- PASSO 2: PONTOS DE MONTAGEM ---
echo -e "\n${GREEN}[PASSO 2] Criando pastas locais para montagem...${NC}"
sudo mkdir -p /mnt/nfs-drive /mnt/nfs-installers
echo "✔ Pontos de montagem criados em /mnt"

# --- PASSO 3: MONTAGEM ---
echo -e "\n${GREEN}[PASSO 3] Conectando ao servidor NFS...${NC}"
read -p "Digite o IP do Servidor NFS (Ex: 10.0.0.X): " NFS_SERVER_IP

if [[ -z "$NFS_SERVER_IP" ]]; then
    echo -e "${RED}Erro: O IP do servidor é obrigatório.${NC}"
    exit 1
fi

sudo mount -t nfs "$NFS_SERVER_IP:/nfs/Jala-drive" /mnt/nfs-drive
sudo mount -t nfs "$NFS_SERVER_IP:/nfs/installers" /mnt/nfs-installers

if mountpoint -q /mnt/nfs-drive && mountpoint -q /mnt/nfs-installers; then
    echo -e "${GREEN}✔ Diretórios montados com sucesso!${NC}"
else
    echo -e "${RED}Erro: Não foi possível montar os diretórios. Verifique o IP e o Firewall do servidor.${NC}"
    exit 1
fi

# --- PASSO 4: TESTE DE ESCRITA ---
echo -e "\n${GREEN}[PASSO 4] Testando cópia de arquivos...${NC}"
echo "Teste de conexão NFS Jala" > /tmp/teste_nfs.txt
cp /tmp/teste_nfs.txt /mnt/nfs-drive/
cp /tmp/teste_nfs.txt /mnt/nfs-installers/

if [[ -f "/mnt/nfs-drive/teste_nfs.txt" ]]; then
    echo -e "${GREEN}✔ Teste de cópia realizado com sucesso no Jala-drive.${NC}"
fi

# --- VALIDAÇÃO ---
echo -e "\n${BLUE}======================================================================"
echo -e "                       VALIDAÇÃO DO CLIENTE"
echo -e "======================================================================${NC}"
df -h | grep nfs
echo ""
ls -l /mnt/nfs-drive/teste_nfs.txt

echo -e "\n${GREEN}✔ ATIVIDADE 4 (CLIENTE) CONCLUÍDA!${NC}"
