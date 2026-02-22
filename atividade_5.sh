#!/bin/bash

# ==============================================================================
# SCRIPT DE AUTOMAÇÃO: ATIVIDADE 5 - DOCKER & NGINX
# Objetivo: Instalar Docker e subir container Nginx personalizado.
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
    echo -e "${BLUE}=== GUIA DE EXECUÇÃO MANUAL (ATIVIDADE 5) ===${NC}"
    echo -e "${YELLOW}sudo apt install docker.io -y${NC}"
    echo -e "${GREEN}# Instala o motor do Docker no sistema.${NC}"
    echo ""
    echo -e "${YELLOW}sudo usermod -aG docker admin${NC}"
    echo -e "${GREEN}# Permite que o usuário 'admin' use o Docker sem sudo.${NC}"
    echo ""
    echo -e "${YELLOW}docker pull nginx:latest${NC}"
    echo -e "${GREEN}# Baixa a imagem oficial mais recente do Nginx.${NC}"
    echo ""
    echo -e "${YELLOW}echo \"...html...\" > index.html${NC}"
    echo -e "${GREEN}# Cria a página personalizada com seus dados.${NC}"
    echo ""
    echo -e "${YELLOW}docker run -d -p 9090:80 --name web-capstone -v \$(pwd)/index.html:/usr/share/nginx/html/index.html nginx:latest${NC}"
    echo -e "${GREEN}# Sobe o container mapeando porta 9090 e montando a página customizada.${NC}"
    exit 0
fi

clear
echo -e "${BLUE}======================================================================"
echo -e "       AUTOMAÇÃO CAPSTONE - ATIVIDADE 5: DOCKER & NGINX"
echo -e "======================================================================${NC}"
log_context
echo ""

# --- PASSO 1: INSTALAÇÃO DO DOCKER ---
unlock_essential_services
echo -e "${GREEN}[PASSO 1] Instalando Docker...${NC}"
sudo apt update > /dev/null
sudo apt install docker.io -y > /dev/null
sudo systemctl enable --now docker
echo "✔ Docker instalado e ativo."

# --- PASSO 2: PERMISSÕES ---
echo -e "\n${GREEN}[PASSO 2] Configurando permissões do usuário admin...${NC}"
sudo usermod -aG docker admin
echo "✔ Usuário 'admin' adicionado ao grupo docker."
echo -e "${YELLOW}[AVISO]${NC} Pode ser necessário deslogar e logar para as permissões do grupo docker surtirem efeito."

# --- PASSO 3: CRIAÇÃO DA PÁGINA PERSONALIZADA ---
echo -e "\n${GREEN}[PASSO 3] Criando página HTML personalizada...${NC}"
NOME="Romário Galdino"
CIDADE="Mogi das Cruzes" # Exemplo, ajuste se necessário
DATA=$(date +%d/%m/%Y)

cat <<EOF > /tmp/index.html
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Capstone - Docker Nginx</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #121212; color: white; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .card { background: #1e1e1e; padding: 40px; border-radius: 15px; border: 1px solid #333; box-shadow: 0 10px 30px rgba(0,0,0,0.5); text-align: center; }
        h1 { color: #00ff88; margin-bottom: 20px; }
        p { font-size: 1.2em; margin: 10px 0; color: #ccc; }
        .highlight { color: #fff; font-weight: bold; }
    </style>
</head>
<body>
    <div class="card">
        <h1>🚀 Servidor Nginx Docker</h1>
        <p>Desenvolvido por: <span class="highlight">$NOME</span></p>
        <p>Cidade: <span class="highlight">$CIDADE</span></p>
        <p>Data Atual: <span class="highlight">$DATA</span></p>
        <hr style="border: 0; border-top: 1px solid #333; margin: 20px 0;">
        <p style="font-size: 0.8em; color: #555;">Atividade 5 - Capstone SO Final</p>
    </div>
</body>
</html>
EOF
echo "✔ Página index.html criada em /tmp/index.html"

# --- PASSO 4: EXECUTAR CONTAINER ---
echo -e "\n${GREEN}[PASSO 4] Subindo o container Nginx (Porta 9090)...${NC}"
# Remove se já existir para evitar conflito de nome
sudo docker rm -f web-capstone 2>/dev/null

sudo docker run -d \
    --name web-capstone \
    -p 9090:80 \
    -v /tmp/index.html:/usr/share/nginx/html/index.html \
    nginx:latest

echo "✔ Container Nginx iniciado na porta 9090."

# --- VALIDAÇÃO ---
echo -e "\n${BLUE}======================================================================"
echo -e "                       VALIDAÇÃO DO DOCKER"
echo -e "======================================================================${NC}"
sudo docker ps | grep web-capstone
echo ""
echo -e "${YELLOW}[TESTE]${NC} Tente acessar: http://$(hostname -I | awk '{print $1}'):9090"
echo ""

# Libera a porta no firewall se necessário
sudo ufw allow 9090/tcp comment 'Nginx Docker'

echo -e "\n${GREEN}✔ ATIVIDADE 5 CONCLUÍDA!${NC}"
