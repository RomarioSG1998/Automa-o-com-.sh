#!/bin/bash

# ==============================================================================
# SCRIPT DE AUTOMAÇÃO: ATIVIDADE 3 - PERMISSÕES E ESTRUTURA
# Objetivo: Criar usuários de lab, estrutura de pastas e gerir permissões.
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
    echo -e "${BLUE}=== GUIA DE EXECUÇÃO MANUAL (ATIVIDADE 3) ===${NC}"
    echo -e "${YELLOW}--- PASSO 1: GRUPOS E USUÁRIOS ---${NC}"
    echo -e "${YELLOW}sudo groupadd grouplab81 && sudo groupadd grouplab82${NC}"
    echo -e "${GREEN}# Cria os grupos de laboratório. Verifique com: getent group grouplab81 grouplab82${NC}"
    echo ""
    echo -e "${YELLOW}sudo useradd -m -g grouplab81 -G cdrom -s /bin/bash userlab81${NC}"
    echo -e "${GREEN}# Cria userlab81: grupo primário=grouplab81, grupo secundário=cdrom.${NC}"
    echo -e "${YELLOW}echo 'userlab81:lab123' | sudo chpasswd${NC}"
    echo ""
    echo -e "${YELLOW}sudo useradd -m -g grouplab82 -G sudo -s /bin/bash userlab82${NC}"
    echo -e "${GREEN}# Cria userlab82: grupo primário=grouplab82, grupo secundário=sudo (acesso total).${NC}"
    echo -e "${YELLOW}echo 'userlab82:lab123' | sudo chpasswd${NC}"
    echo -e "${GREEN}# Verifique com: groups userlab81 e groups userlab82${NC}"
    echo ""
    echo -e "${YELLOW}--- PASSO 2: ESTRUTURA DE DIRETÓRIOS EM /tmp ---${NC}"
    echo -e "${YELLOW}mkdir -p /tmp/Matematicas-RomarioJala/{Capitulo1,Capitulo2,Capitulo3}${NC}"
    echo -e "${GREEN}# Cria a árvore de diretórios dentro de /tmp (temporário, ok para lab).${NC}"
    echo -e "${YELLOW}touch /tmp/Matematicas-RomarioJala/Capitulo2/{leccionX.txt,leccionY.txt,leccionZ.txt}${NC}"
    echo -e "${YELLOW}touch /tmp/Matematicas-RomarioJala/Capitulo3/{leccionA.txt,leccionB.txt,leccionC.txt}${NC}"
    echo -e "${GREEN}# Cria os arquivos de lição em cada capítulo.${NC}"
    echo ""
    echo -e "${YELLOW}--- PASSO 3: DONOS E PERMISSÕES ---${NC}"
    echo -e "${YELLOW}sudo chown userlab81:grouplab81 /tmp/Matematicas-RomarioJala/Capitulo2${NC}"
    echo -e "${YELLOW}sudo chown userlab81:grouplab81 /tmp/Matematicas-RomarioJala/Capitulo2/*${NC}"
    echo -e "${GREEN}# Atribui dono e grupo ao Capítulo 2 e seus arquivos.${NC}"
    echo ""
    echo -e "${YELLOW}sudo chgrp grouplab82 /tmp/Matematicas-RomarioJala/Capitulo1${NC}"
    echo -e "${GREEN}# Define o grupo do Capítulo 1 como grouplab82.${NC}"
    echo ""
    echo -e "${YELLOW}chmod 600 /tmp/Matematicas-RomarioJala/Capitulo3/leccionA.txt${NC}"
    echo -e "${GREEN}# rw-------  só o dono pode ler e escrever.${NC}"
    echo -e "${YELLOW}chmod 777 /tmp/Matematicas-RomarioJala/Capitulo3/leccionB.txt${NC}"
    echo -e "${GREEN}# rwxrwxrwx  todos têm acesso total.${NC}"
    echo -e "${YELLOW}chmod 460 /tmp/Matematicas-RomarioJala/Capitulo3/leccionC.txt${NC}"
    echo -e "${GREEN}# r--rw----  dono lê; grupo lê+escreve; outros sem acesso.${NC}"
    echo -e "${GREEN}# Verifique com: ls -lR /tmp/Matematicas-RomarioJala${NC}"
    exit 0
fi

clear
echo -e "${BLUE}======================================================================"
echo -e "       AUTOMAÇÃO CAPSTONE - ATIVIDADE 3: PERMISSÕES"
echo -e "======================================================================${NC}"
log_context
echo ""

# --- PASSO 1: USUÁRIOS E GRUPOS ---
unlock_essential_services
echo -e "${GREEN}[PASSO 1] Criando grupos e usuários de laboratório...${NC}"
sudo groupadd grouplab81 2>/dev/null
sudo groupadd grouplab82 2>/dev/null

if ! id "userlab81" &>/dev/null; then
    sudo useradd -m -g grouplab81 -G cdrom -s /bin/bash userlab81
    echo "userlab81:lab123" | sudo chpasswd
fi

if ! id "userlab82" &>/dev/null; then
    sudo useradd -m -g grouplab82 -G sudo -s /bin/bash userlab82
    echo "userlab82:lab123" | sudo chpasswd
fi
echo "✔ Usuários userlab81 e userlab82 criados."

# --- PASSO 2: ESTRUTURA DE DIRETÓRIOS ---
echo -e "\n${GREEN}[PASSO 2] Criando estrutura de pastas em /tmp...${NC}"
BASE_DIR="/tmp/Matematicas-RomarioJala"
mkdir -p "$BASE_DIR"/{Capitulo1,Capitulo2,Capitulo3}

# Arquivos no Capitulo 2
touch "$BASE_DIR/Capitulo2"/{leccionX.txt,leccionY.txt,leccionZ.txt}

# Arquivos no Capitulo 3
touch "$BASE_DIR/Capitulo3"/{leccionA.txt,leccionB.txt,leccionC.txt}
echo "✔ Estrutura de pastas e arquivos criada."

# --- PASSO 3: DONOS E PERMISSÕES ---
echo -e "\n${GREEN}[PASSO 3] Configurando propriedades e permissões...${NC}"

# Dono do Capitulo 2
sudo chown userlab81:grouplab81 "$BASE_DIR/Capitulo2"
sudo chown userlab81:grouplab81 "$BASE_DIR/Capitulo2"/*

# Simulação de alteração pelo usuário (Exercício)
sudo -u userlab81 bash -c "echo 'Iniciando lição' >> $BASE_DIR/Capitulo2/leccionX.txt"
sudo -u userlab81 touch "$BASE_DIR/Capitulo2/leccion24.txt"

# Permissões Capitulo 3
chmod 600 "$BASE_DIR/Capitulo3/leccionA.txt"
chmod 777 "$BASE_DIR/Capitulo3/leccionB.txt"
chmod 460 "$BASE_DIR/Capitulo3/leccionC.txt"

# Grupo do Capitulo 1
sudo chgrp grouplab82 "$BASE_DIR/Capitulo1"

echo "✔ Permissões e propriedades aplicadas."

# --- VALIDAÇÃO ---
echo -e "\n${BLUE}======================================================================"
echo -e "                       VALIDAÇÃO DA ESTRUTURA"
echo -e "======================================================================${NC}"
if command -v tree > /dev/null; then
    tree -ugp "$BASE_DIR"
else
    ls -lR "$BASE_DIR"
fi

echo -e "\n${GREEN}✔ ATIVIDADE 3 CONCLUÍDA!${NC}"
echo "DICA: Caso o comando 'tree' não esteja instalado, use: sudo apt install tree -y"
