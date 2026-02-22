#!/bin/bash

# ==============================================================================
# SCRIPT DE AUTOMAÇÃO: ATIVIDADE 2 - ADMINISTRAÇÃO DE USUÁRIOS
# Objetivo: Criar grupos, usuários e configurar sudoers conforme requisitos.
# ==============================================================================
# Cores para melhor legibilidade
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
    echo -e "${BLUE}=== GUIA DE EXECUÇÃO MANUAL (ATIVIDADE 2) ===${NC}"
    echo -e "${YELLOW}--- PASSO 1: CRIAR GRUPOS ---${NC}"
    echo -e "${YELLOW}sudo groupadd it${NC}"
    echo -e "${GREEN}# Cria o grupo 'it' (Tecnologia da Informação).${NC}"
    echo -e "${YELLOW}sudo groupadd qa${NC}"
    echo -e "${GREEN}# Cria o grupo 'qa' (Qualidade/Testes). Verifique com: getent group it qa${NC}"
    echo ""
    echo -e "${YELLOW}--- PASSO 2: CRIAR USUÁRIOS ---${NC}"
    echo -e "${YELLOW}sudo useradd -m -g it -s /bin/bash user1${NC}"
    echo -e "${GREEN}# Cria user1 com grupo primário 'it' e shell bash.${NC}"
    echo -e "${YELLOW}echo 'user1:password123' | sudo chpasswd${NC}"
    echo -e "${GREEN}# Define a senha 'password123' para user1.${NC}"
    echo ""
    echo -e "${YELLOW}sudo useradd -m -g it -s /bin/bash user2${NC}"
    echo -e "${YELLOW}sudo usermod -aG qa user2${NC}"
    echo -e "${GREEN}# Cria user2 (grupo primário: it) e adiciona ao grupo secundário 'qa'.${NC}"
    echo -e "${YELLOW}echo 'user2:password123' | sudo chpasswd${NC}"
    echo -e "${GREEN}# Verifique com: groups user1 e groups user2${NC}"
    echo ""
    echo -e "${YELLOW}--- PASSO 3: CONFIGURAR SUDOERS ---${NC}"
    echo -e "${YELLOW}echo '%it ALL=(ALL) /usr/bin/apt install, /usr/bin/apt remove, /usr/bin/apt purge' | sudo tee /etc/sudoers.d/it${NC}"
    echo -e "${GREEN}# Grupo 'it' pode usar apt install/remove/purge com sudo.${NC}"
    echo -e "${YELLOW}sudo chmod 440 /etc/sudoers.d/it${NC}"
    echo -e "${GREEN}# Permissão correta para arquivos sudoers (leitura só para root).${NC}"
    echo ""
    echo -e "${YELLOW}echo '%qa ALL=(ALL) /usr/sbin/useradd, /usr/sbin/usermod' | sudo tee /etc/sudoers.d/qa${NC}"
    echo -e "${GREEN}# Grupo 'qa' pode criar e modificar usuários com sudo.${NC}"
    echo -e "${YELLOW}sudo chmod 440 /etc/sudoers.d/qa${NC}"
    echo -e "${GREEN}# Verifique com: sudo -U user1 -l | grep apt${NC}"
    exit 0
fi

clear
echo -e "${BLUE}======================================================================"
echo -e "       AUTOMAÇÃO CAPSTONE - ATIVIDADE 2: USUÁRIOS E GRUPOS"
echo -e "======================================================================${NC}"
log_context
echo ""

# --- TEORIA ---
echo -e "${YELLOW}[CONCEITO TEÓRICO]${NC}"
echo "1. Grupos: Permitem aplicar permissões a múltiplos usuários de uma vez."
echo "2. Usuário Primário: Define o dono padrão de novos arquivos criados."
echo "3. Sudoers: O diretório /etc/sudoers.d/ é a forma recomendada de estender"
echo "   privilégios sem alterar o arquivo principal /etc/sudoers."
echo ""

# --- PASSO 1: CRIAÇÃO DE GRUPOS ---
unlock_essential_services
echo -e "${GREEN}[PASSO 1] Criando grupos 'it' e 'qa'...${NC}"
for group in it qa; do
    if getent group "$group" > /dev/null; then
        echo "Grupo '$group' já existe."
    else
        sudo groupadd "$group"
        echo "✔ Grupo '$group' criado."
    fi
done

# --- PASSO 2: CRIAÇÃO DE USUÁRIOS ---
echo -e "\n${GREEN}[PASSO 2] Criando usuários 'user1' e 'user2'...${NC}"
# user1 e user2 com grupo primário 'it'
for user in user1 user2; do
    if id "$user" &>/dev/null; then
        echo "Usuário '$user' já existe."
    else
        sudo useradd -m -g it -s /bin/bash "$user"
        echo "user$user:password123" | sudo chpasswd
        echo "✔ Usuário '$user' criado (Grupo: it, Senha: password123)."
    fi
done

# Adicionar user2 ao grupo secundário 'qa'
sudo usermod -aG qa user2
echo "✔ Usuário 'user2' adicionado ao grupo secundário 'qa'."

# Verificação de pastas home
ls -ld /home/user1 /home/user2

# --- PASSO 3: CONFIGURAÇÃO DE SUDOERS ---
echo -e "\n${GREEN}[PASSO 3] Configurando privilégios SUDO...${NC}"

# Configuração para o grupo 'it'
# Permite: apt install, apt remove, apt purge
cat <<EOF | sudo tee /etc/sudoers.d/it > /dev/null
%it ALL=(ALL) /usr/bin/apt install, /usr/bin/apt remove, /usr/bin/apt purge
EOF
sudo chmod 440 /etc/sudoers.d/it

# Configuração para o grupo 'qa'
# Permite: useradd, usermod
cat <<EOF | sudo tee /etc/sudoers.d/qa > /dev/null
%qa ALL=(ALL) /usr/sbin/useradd, /usr/sbin/usermod
EOF
sudo chmod 440 /etc/sudoers.d/qa

echo "✔ Arquivos em /etc/sudoers.d/ configurados."

# --- VALIDAÇÃO FINAL ---
echo -e "\n${BLUE}======================================================================"
echo -e "                       VALIDAÇÃO DA ATIVIDADE"
echo -e "======================================================================${NC}"
echo "Grupos do user1: $(groups user1)"
echo "Grupos do user2: $(groups user2)"
echo ""
echo "Teste de Sudo para o grupo 'it' (user1):"
sudo -U user1 -l | grep -E 'apt'
echo ""
echo "Teste de Sudo para o grupo 'qa' (user2):"
sudo -U user2 -l | grep -E 'useradd|usermod'

echo -e "\n${GREEN}✔ ATIVIDADE 2 CONCLUÍDA!${NC}"
echo "DICA: Tire um print da Validação acima para o seu relatório."
