#!/bin/bash

# ==============================================================================
# SCRIPT DE AUTOMAÇÃO: ATIVIDADE 1 - VM e REDE
# Objetivo: Configurar SSH, Usuário Admin e Firewall com explicações teóricas.
# ==============================================================================

# Cores para melhor legibilidade
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Suporte a sincronização
source /tmp/common_utils.sh 2>/dev/null

# --- MODO MANUAL (Para o Aluno) ---
if [[ "$1" == "-m" || "$1" == "--manual" ]]; then
    clear
    echo -e "${BLUE}=== GUIA DE EXECUÇÃO MANUAL (ATIVIDADE 1) ===${NC}"
    echo -e "${YELLOW}--- PASSO 1: ALTERAR PORTA SSH ---${NC}"
    echo -e "${YELLOW}sudo sed -i '/^Port /d' /etc/ssh/sshd_config${NC}"
    echo -e "${GREEN}# Remove qualquer linha 'Port' existente para evitar duplicação.${NC}"
    echo ""
    echo -e "${YELLOW}echo 'Port 2244' | sudo tee -a /etc/ssh/sshd_config${NC}"
    echo -e "${GREEN}# Adiciona a nova porta 2244 ao final do arquivo.${NC}"
    echo ""
    echo -e "${YELLOW}# No Ubuntu 24.04+: desabilitar o ssh.socket antes de reiniciar${NC}"
    echo -e "${YELLOW}sudo systemctl stop ssh.socket && sudo systemctl disable ssh.socket${NC}"
    echo -e "${GREEN}# Garante que o serviço SSH use o arquivo de config, não o socket.${NC}"
    echo ""
    echo -e "${YELLOW}sudo systemctl restart ssh${NC}"
    echo -e "${GREEN}# Reinicia o SSH para aplicar a porta 2244.${NC}"
    echo -e "${GREEN}# Verifique com: ss -tuln | grep 2244${NC}"
    echo ""
    echo -e "${YELLOW}--- PASSO 2: CRIAR USUÁRIO ADMIN ---${NC}"
    echo -e "${YELLOW}sudo useradd -m -s /bin/bash admin${NC}"
    echo -e "${GREEN}# Cria o usuário 'admin' com diretório home e shell bash.${NC}"
    echo ""
    echo -e "${YELLOW}echo 'admin:admin123' | sudo chpasswd${NC}"
    echo -e "${GREEN}# Define a senha 'admin123' para o usuário admin.${NC}"
    echo ""
    echo -e "${YELLOW}sudo usermod -aG sudo admin${NC}"
    echo -e "${GREEN}# Adiciona o admin ao grupo sudo (privilégios elevados).${NC}"
    echo -e "${GREEN}# Verifique com: groups admin${NC}"
    echo ""
    echo -e "${YELLOW}--- PASSO 3: CONFIGURAR FIREWALL (UFW) ---${NC}"
    echo -e "${YELLOW}sudo ufw default deny incoming && sudo ufw default deny outgoing${NC}"
    echo -e "${GREEN}# Política restritiva: bloqueia tudo por padrão.${NC}"
    echo ""
    echo -e "${YELLOW}sudo ufw allow 2244/tcp${NC}"
    echo -e "${GREEN}# Abre a porta SSH 2244 para acesso remoto.${NC}"
    echo ""
    echo -e "${YELLOW}sudo ufw allow out 8888/tcp${NC}"
    echo -e "${GREEN}# Permite saída na porta 8888 conforme requisito.${NC}"
    echo ""
    echo -e "${YELLOW}sudo ufw enable${NC}"
    echo -e "${GREEN}# Ativa o firewall. Verifique com: sudo ufw status verbose${NC}"
    exit 0
fi

clear

echo -e "${BLUE}======================================================================"
echo -e "       AUTOMAÇÃO CAPSTONE - ATIVIDADE 1: INFRAESTRUTURA BÁSICA"
echo -e "======================================================================${NC}"
log_context
echo ""

# --- TEORIA INICIAL ---
echo -e "${YELLOW}[CONCEITO TEÓRICO]${NC}"
echo "Nesta atividade, estamos estabelecendo as bases de segurança de um servidor Linux."
echo "1. Redes: O uso de NAT permite acesso à internet, enquanto a Bridge permite"
echo "   que a VM seja vista como um dispositivo real na rede local."
echo "2. Acesso Remoto: O SSH (Secure Shell) é o padrão para gerência remota segura."
echo "3. Firewall: Atuamos na camada de rede para filtrar o que entra e sai."
echo ""
read -p "Pressione ENTER para começar as configurações..."

# --- PASSO 1: CONFIGURAÇÃO DO SSH ---
unlock_essential_services
echo -e "\n${GREEN}[PASSO 1] Alterando porta do SSH para 2244...${NC}"

# Teoria do SSH
echo -e "${YELLOW}[POR QUE ALTERAR A PORTA?]${NC}"
echo "Mudar a porta padrão (22) é uma técnica de 'Security by Obscurity'."
echo "Isso evita 90% dos ataques de força bruta automatizados que buscam apenas a porta 22."

# Backup do arquivo original
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Alterando a porta de forma robusta
# Remove qualquer linha de 'Port' existente para evitar duplicações e insere a correta
sudo sed -i '/^Port /d' /etc/ssh/sshd_config
sudo sed -i '/^#Port /d' /etc/ssh/sshd_config
echo "Port 2244" | sudo tee -a /etc/ssh/sshd_config > /dev/null

# Reiniciando o serviço
# NOVO: No Ubuntu 24.04+, o ssh.socket GERALMENTE mata a porta 22. 
# Para garantir que a porta 2244 funcione, vamos desabilitar o socket e usar o serviço tradicional.
if systemctl is-active --quiet ssh.socket || [ -f /lib/systemd/system/ssh.socket ]; then
    echo "Configurando compatibilidade com Ubuntu 24.04... (Desabilitando ssh.socket)"
    sudo systemctl stop ssh.socket > /dev/null 2>&1
    sudo systemctl disable ssh.socket > /dev/null 2>&1
    sudo systemctl mask ssh.socket > /dev/null 2>&1
fi

sudo systemctl daemon-reload
sudo systemctl restart ssh
sudo systemctl enable ssh

echo -e "${GREEN}✔ SSH configurado para a porta 2244.${NC}"
echo "DICA: Para tirar o print, verifique com: 'ss -tuln | grep 2244'"
read -p "Tire seu PRINT da tela e pressione ENTER para continuar..."

# --- PASSO 2: CRIAÇÃO DO USUÁRIO ADMIN ---
echo -e "\n${GREEN}[PASSO 2] Criando usuário 'admin' e adicionando ao grupo 'sudo'...${NC}"

# Teoria de Usuários
echo -e "${YELLOW}[PRINCÍPIO DO MENOR PRIVILÉGIO]${NC}"
echo "Não devemos realizar tarefas rotineiras como root. Criamos um usuário admin"
echo "separado que usa o 'sudo' para elevar privilégios apenas quando necessário."

# Verifica se o usuário já existe
if id "admin" &>/dev/null; then
    echo "Usuário 'admin' já existe."
else
    # Cria o usuário com senha padrão (pode ser alterada depois)
    sudo useradd -m -s /bin/bash admin
    echo "admin:admin123" | sudo chpasswd
    echo "Usuário 'admin' criado (Senha padrão: admin123)."
fi

# Adiciona ao grupo sudo
sudo usermod -aG sudo admin

echo -e "${GREEN}✔ Usuário 'admin' configurado com sucesso.${NC}"
echo "DICA: Verifique com: 'groups admin' ou 'id admin'"
read -p "Tire seu PRINT da tela e pressione ENTER para continuar..."

# --- PASSO 3: CONFIGURAÇÃO DO FIREWALL (UFW) ---
echo -e "\n${GREEN}[PASSO 3] Configurando o Firewall (UFW)...${NC}"

# Teoria de Firewall
echo -e "${YELLOW}[SEGURANÇA PERIMETRAL]${NC}"
echo "O UFW (Uncomplicated Firewall) simplifica a gestão do iptables."
echo "Configuramos uma política restritiva: Bloqueia tudo por padrão e abre apenas o essencial."

# Reseta o firewall para estado limpo
sudo ufw --force reset

# Define políticas básicas
sudo ufw default deny incoming
sudo ufw default deny outgoing

# Permite SSH na nova porta
sudo ufw allow 2244/tcp comment 'Acesso SSH'

# Permite saída na porta 8888 conforme instrução
sudo ufw allow out 8888/tcp comment 'Saída específica solicitada'

# Ativa o firewall
echo "y" | sudo ufw enable

echo -e "${GREEN}✔ Firewall configurado e ativo.${NC}"
echo -e "Políticas Atuais:"
echo -e "- Entrada: Bloqueada (exceto porta 2244 para SSH)"
echo -e "- Saída: Bloqueada (exceto porta 8888)"
echo ""
echo "DICA: Verifique com: 'sudo ufw status verbose'"
read -p "Tire seu ÚLTIMO PRINT desta atividade e pressione ENTER para finalizar..."

echo -e "\n${BLUE}======================================================================"
echo -e "         ATIVIDADE 1 CONCLUÍDA COM SUCESSO!"
echo -e "======================================================================${NC}"
