#!/bin/bash

# ==============================================================================
# SCRIPT DE AUTOMAÇÃO: ATIVIDADE 6 - MYSQL COM DOCKER COMPOSE
# Objetivo: Subir MySQL com script de inicialização e mapeamento de porta.
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
    echo -e "${BLUE}=== GUIA DE EXECUÇÃO MANUAL (ATIVIDADE 6) ===${NC}"
    echo -e "${YELLOW}--- PASSO 1: INSTALAR PLUGIN DO COMPOSE ---${NC}"
    echo -e "${YELLOW}sudo apt install docker-compose-v2 -y${NC}"
    echo -e "${GREEN}# Instala o plugin 'docker compose' (v2) integrado ao Docker CLI.${NC}"
    echo ""
    echo -e "${YELLOW}--- PASSO 2: CRIAR DIRETÓRIO DO PROJETO ---${NC}"
    echo -e "${YELLOW}mkdir -p ~/mysql-project && cd ~/mysql-project${NC}"
    echo -e "${GREEN}# Cria e entra no diretório isolado do projeto.${NC}"
    echo ""
    echo -e "${YELLOW}--- PASSO 3: CRIAR SCRIPT SQL DE INICIALIZAÇÃO ---${NC}"
    echo -e "${YELLOW}cat > init.sql << 'EOF'${NC}"
    echo -e "${YELLOW}CREATE DATABASE IF NOT EXISTS capstone_db;${NC}"
    echo -e "${YELLOW}USE capstone_db;${NC}"
    echo -e "${YELLOW}CREATE TABLE alunos (id INT AUTO_INCREMENT PRIMARY KEY, nome VARCHAR(50), sobrenome VARCHAR(50), idade INT);${NC}"
    echo -e "${YELLOW}INSERT INTO alunos VALUES (1,'Romario','Galdino',25);${NC}"
    echo -e "${YELLOW}EOF${NC}"
    echo -e "${GREEN}# O script é executado automaticamente pelo MySQL na primeira vez que o container sobe.${NC}"
    echo -e "${GREEN}# É montado via volume em: /docker-entrypoint-initdb.d/init.sql${NC}"
    echo ""
    echo -e "${YELLOW}--- PASSO 4: CRIAR docker-compose.yml ---${NC}"
    echo -e "${YELLOW}# Conteúdo mínimo do docker-compose.yml:${NC}"
    echo -e "${YELLOW}services:${NC}"
    echo -e "${YELLOW}  db:${NC}"
    echo -e "${YELLOW}    image: mysql:8.0${NC}"
    echo -e "${YELLOW}    container_name: mysql-capstone${NC}"
    echo -e "${YELLOW}    environment:${NC}"
    echo -e "${YELLOW}      MYSQL_ROOT_PASSWORD: 'root-password-123'${NC}"
    echo -e "${YELLOW}      MYSQL_DATABASE: 'capstone_db'${NC}"
    echo -e "${YELLOW}    ports:${NC}"
    echo -e "${YELLOW}      - '3366:3306'   # porta externa:interna${NC}"
    echo -e "${YELLOW}    volumes:${NC}"
    echo -e "${YELLOW}      - ./init.sql:/docker-entrypoint-initdb.d/init.sql${NC}"
    echo -e "${GREEN}# A porta 3366 é a externa (acesso da VM). A 3306 é a interna do MySQL.${NC}"
    echo ""
    echo -e "${YELLOW}--- PASSO 5: SUBIR O CONTAINER ---${NC}"
    echo -e "${YELLOW}sudo docker compose up -d${NC}"
    echo -e "${GREEN}# Sobe o banco em segundo plano. Verifique com: sudo docker ps${NC}"
    echo -e "${GREEN}# Acesse o banco com: sudo docker exec mysql-capstone mysql -uroot -proot-password-123 capstone_db${NC}"
    exit 0
fi

clear
echo -e "${BLUE}======================================================================"
echo -e "       AUTOMAÇÃO CAPSTONE - ATIVIDADE 6: MYSQL COMPOSE"
echo -e "======================================================================${NC}"
log_context
echo ""

# --- PASSO 1: INSTALAÇÃO DO DOCKER COMPOSE ---
unlock_essential_services
echo -e "${GREEN}[PASSO 1] Garantindo que o Docker Compose está instalado...${NC}"
sudo apt update > /dev/null
sudo apt install docker-compose-v2 -y > /dev/null
echo "✔ Docker Compose (Plugin) verificado."

# --- PASSO 2: PREPARAÇÃO DA ESTRUTURA ---
echo -e "\n${GREEN}[PASSO 2] Criando estrutura de arquivos...${NC}"
PROJECT_DIR="$HOME/mysql-project"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Script SQL de inicialização
cat <<EOF | sudo tee init.sql > /dev/null
CREATE DATABASE IF NOT EXISTS capstone_db;
USE capstone_db;

CREATE TABLE IF NOT EXISTS alunos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    sobrenome VARCHAR(50) NOT NULL,
    idade INT NOT NULL
);

INSERT INTO alunos (nome, sobrenome, idade) VALUES 
('Romário', 'Galdino', 25),
('Jala', 'University', 5),
('Admin', 'Capstone', 99);
EOF

# Arquivo Docker Compose
cat <<EOF | sudo tee docker-compose.yml > /dev/null
version: '3.8'

services:
  db:
    image: mysql:latest
    container_name: mysql-capstone
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: 'root-password-123'
      MYSQL_DATABASE: 'capstone_db'
    ports:
      - '3366:3306'
    volumes:
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
EOF

echo "✔ Arquivos criados em $PROJECT_DIR"

# --- PASSO 3: SUBIR O CONTÊINER ---
echo -e "\n${GREEN}[PASSO 3] Iniciando o MySQL via Docker Compose...${NC}"
sudo docker compose up -d

echo -e "${YELLOW}Aguardando o MySQL inicializar e processar o script SQL...${NC}"
echo -e "Nota: O primeiro boot pode levar cerca de 30-45 segundos."

# Loop de espera inteligente
M_READY=0
for i in {1..30}; do
    if sudo docker exec mysql-capstone mysql -uroot -proot-password-123 -e "SELECT 1" > /dev/null 2>&1; then
        M_READY=1
        break
    fi
    echo -n "."
    sleep 2
done

if [[ $M_READY -eq 0 ]]; then
    echo -e "\n${RED}✘ O MySQL demorou muito para iniciar. Verifique os logs com: docker logs mysql-capstone${NC}"
    exit 1
fi

echo -e "\n✔ MySQL está pronto!"

# --- VALIDAÇÃO ---
echo -e "\n${BLUE}======================================================================"
echo -e "                       VALIDAÇÃO DO MYSQL"
echo -e "======================================================================${NC}"

if sudo docker ps | grep -q mysql-capstone; then
    echo -e "${GREEN}✔ Contêiner em execução na porta 3366.${NC}"
    echo "Consultando dados inseridos pelo init.sql..."
    sudo docker exec mysql-capstone mysql -uroot -proot-password-123 -e "USE capstone_db; SELECT * FROM alunos;"
else
    echo -e "${RED}✘ Falha ao iniciar o contêiner.${NC}"
fi

# Libera no firewall
sudo ufw allow 3366/tcp comment 'MySQL Capstone'

echo -e "\n${GREEN}✔ ATIVIDADE 6 CONCLUÍDA!${NC}"
