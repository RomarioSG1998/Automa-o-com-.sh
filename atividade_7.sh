#!/bin/bash

# ==============================================================================
# SCRIPT DE AUTOMAÇÃO: ATIVIDADE 7 - STACK COMPLETA COM DOCKER COMPOSE
# Objetivo: Subir MySQL + Nginx + PHP com rede isolada, volumes externos
#           e variáveis de ambiente em um único arquivo docker-compose.yml.
# Usuário operante: admin
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
    echo -e "${BLUE}=== GUIA DE EXECUÇÃO MANUAL (ATIVIDADE 7 - STACK COMPLETA) ===${NC}"
    echo -e "${YELLOW}--- PASSO 1: DEPENDÊNCIAS ---${NC}"
    echo -e "${YELLOW}sudo apt install docker.io docker-compose-v2 -y${NC}"
    echo -e "${YELLOW}sudo usermod -aG docker admin${NC}"
    echo -e "${GREEN}# Instala Docker + Compose e permite que 'admin' use Docker sem sudo.${NC}"
    echo ""
    echo -e "${YELLOW}--- PASSO 2: ESTRUTURA DE DIRETÓRIOS (VOLUMES EXTERNOS) ---${NC}"
    echo -e "${YELLOW}mkdir -p ~/capstone-stack/{html,php,db-data} && cd ~/capstone-stack${NC}"
    echo -e "${GREEN}# 3 pastas fora dos containers = volumes externos (bind mounts):${NC}"
    echo -e "${GREEN}#   html/    -> servido pelo Nginx (frontend)${NC}"
    echo -e "${GREEN}#   php/     -> aplicação PHP (backend)${NC}"
    echo -e "${GREEN}#   db-data/ -> dados persistentes do MySQL${NC}"
    echo ""
    echo -e "${YELLOW}--- PASSO 3: ARQUIVO DE VARIÁVEIS (.env) ---${NC}"
    echo -e "${YELLOW}cat > .env << 'EOF'${NC}"
    echo -e "${YELLOW}MYSQL_ROOT_PASSWORD=root-capstone-123${NC}"
    echo -e "${YELLOW}MYSQL_DATABASE=capstone_app${NC}"
    echo -e "${YELLOW}MYSQL_USER=capstone_user${NC}"
    echo -e "${YELLOW}MYSQL_PASSWORD=capstone_pass_456${NC}"
    echo -e "${YELLOW}NGINX_PORT=8080${NC}"
    echo -e "${YELLOW}EOF${NC}"
    echo -e "${GREEN}# Todas as senhas e portas ficam no .env, fora do docker-compose.yml.${NC}"
    echo ""
    echo -e "${YELLOW}--- PASSO 4: ESTRUTURA DO docker-compose.yml ---${NC}"
    echo -e "${YELLOW}# Os 3 serviços principais:${NC}"
    echo -e "${YELLOW}#   db:    image: mysql:8.0  | env_file: .env | volume: db-data${NC}"
    echo -e "${YELLOW}#   php:   image: php:8.2-fpm | env_file: .env | volume: php${NC}"
    echo -e "${YELLOW}#   nginx: image: nginx:alpine | ports: 8080:80 | volumes: html + php${NC}"
    echo -e "${GREEN}# Rede isolada 'capstone-net' (bridge): os containers se comunicam${NC}"
    echo -e "${GREEN}# pelo nome do serviço (ex: PHP acessa MySQL via hostname 'db').${NC}"
    echo -e "${GREEN}# Volumes externos usam driver_opts type:none, o:bind.${NC}"
    echo ""
    echo -e "${YELLOW}--- PASSO 5: SUBIR A STACK ---${NC}"
    echo -e "${YELLOW}sudo docker compose --env-file .env up -d${NC}"
    echo -e "${GREEN}# Sobe os 3 containers em background lendo as variáveis do .env.${NC}"
    echo -e "${GREEN}# Verifique com: sudo docker ps --filter name=capstone${NC}"
    echo -e "${GREEN}# Frontend: http://IP-DA-VM:8080 | Backend PHP: http://IP-DA-VM:9000${NC}"
    exit 0
fi

clear
echo -e "${BLUE}======================================================================"
echo -e "       AUTOMAÇÃO CAPSTONE - ATIVIDADE 7: STACK MYSQL+NGINX+PHP"
echo -e "======================================================================${NC}"
log_context
echo ""

# --- PASSO 1: DEPENDÊNCIAS ---
unlock_essential_services
echo -e "${GREEN}[PASSO 1] Garantindo Docker e Docker Compose instalados...${NC}"
sudo apt update > /dev/null
sudo apt install -y docker.io docker-compose-v2 > /dev/null
sudo systemctl enable --now docker > /dev/null 2>&1
sudo usermod -aG docker admin 2>/dev/null
echo "✔ Docker e Docker Compose verificados."

# --- PASSO 2: ESTRUTURA DE DIRETÓRIOS ---
echo -e "\n${GREEN}[PASSO 2] Criando estrutura do projeto...${NC}"
PROJECT_DIR="$HOME/capstone-stack"
mkdir -p "$PROJECT_DIR"/{html,php,db-data}
cd "$PROJECT_DIR"
echo "✔ Estrutura criada em $PROJECT_DIR"
echo "   ├── html/     (volume Nginx - frontend)"
echo "   ├── php/      (volume PHP - backend)"
echo "   └── db-data/  (volume MySQL - dados persistentes)"

# --- PASSO 3: VARIÁVEIS DE AMBIENTE (.env) ---
echo -e "\n${GREEN}[PASSO 3] Criando arquivo de variáveis de ambiente (.env)...${NC}"
cat <<EOF | sudo tee "$PROJECT_DIR/.env" > /dev/null
# === VARIÁVEIS DE AMBIENTE - CAPSTONE STACK ===
MYSQL_ROOT_PASSWORD=root-capstone-123
MYSQL_DATABASE=capstone_app
MYSQL_USER=capstone_user
MYSQL_PASSWORD=capstone_pass_456
NGINX_PORT=8080
PHP_PORT=9000
EOF
echo "✔ Arquivo .env criado com credenciais e portas."

# --- PASSO 4: PÁGINA PHP ---
echo -e "\n${GREEN}[PASSO 4] Criando arquivos da aplicação...${NC}"

# index.php (backend PHP conectando ao MySQL)
cat <<'EOF' | sudo tee "$PROJECT_DIR/php/index.php" > /dev/null
<?php
$host     = 'db';
$dbname   = getenv('MYSQL_DATABASE');
$user     = getenv('MYSQL_USER');
$password = getenv('MYSQL_PASSWORD');

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $stmt = $pdo->query("SELECT id, nome, sobrenome, idade FROM alunos");
    $alunos = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $status = "✅ Conexão com MySQL bem-sucedida!";
} catch (PDOException $e) {
    $alunos = [];
    $status = "❌ Erro: " . $e->getMessage();
}
?>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Capstone Stack - Atividade 7</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Segoe UI', sans-serif; background: #0f0f1a; color: #e0e0e0; min-height: 100vh; display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 20px; }
        h1 { font-size: 2em; color: #00e5ff; margin-bottom: 8px; }
        .subtitle { color: #888; margin-bottom: 30px; font-size: 0.95em; }
        .badge { display: inline-block; padding: 6px 16px; border-radius: 20px; font-size: 0.85em; margin-bottom: 24px; }
        .ok   { background: #0d2b0d; color: #00e676; border: 1px solid #00e676; }
        .fail { background: #2b0d0d; color: #ff5252; border: 1px solid #ff5252; }
        table { width: 100%; max-width: 640px; border-collapse: collapse; margin-top: 10px; }
        th { background: #1a1a2e; color: #00e5ff; padding: 12px; text-align: left; }
        td { padding: 10px 12px; border-bottom: 1px solid #1e1e30; }
        tr:hover td { background: #16162a; }
        .footer { margin-top: 30px; font-size: 0.75em; color: #444; }
    </style>
</head>
<body>
    <h1>🐳 Capstone Stack</h1>
    <p class="subtitle">Nginx + PHP + MySQL · Atividade 7 · Docker Compose</p>
    <span class="badge <?= $alunos ? 'ok' : 'fail' ?>"><?= $status ?></span>
    <?php if ($alunos): ?>
    <table>
        <tr><th>ID</th><th>Nome</th><th>Sobrenome</th><th>Idade</th></tr>
        <?php foreach ($alunos as $a): ?>
        <tr><td><?= $a['id'] ?></td><td><?= htmlspecialchars($a['nome']) ?></td><td><?= htmlspecialchars($a['sobrenome']) ?></td><td><?= $a['idade'] ?></td></tr>
        <?php endforeach; ?>
    </table>
    <?php endif; ?>
    <p class="footer">Desenvolvido por Romário Galdino · <?= date('d/m/Y H:i') ?></p>
</body>
</html>
EOF

# Página estática Nginx (frontend)
cat <<EOF | sudo tee "$PROJECT_DIR/html/index.html" > /dev/null
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Capstone - Portal</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; background: #0f0f1a; color: #e0e0e0; display: flex; align-items: center; justify-content: center; height: 100vh; margin: 0; }
        .card { text-align: center; background: #1a1a2e; padding: 50px 60px; border-radius: 16px; border: 1px solid #00e5ff33; }
        h1 { color: #00e5ff; font-size: 2.2em; }
        p  { color: #aaa; margin-top: 12px; }
        a  { display: inline-block; margin-top: 24px; padding: 12px 28px; background: #00e5ff; color: #0f0f1a; border-radius: 8px; font-weight: bold; text-decoration: none; }
        a:hover { background: #00b8d4; }
    </style>
</head>
<body>
    <div class="card">
        <h1>🚀 Portal dos Estudantes</h1>
        <p>Stack Docker: <strong>Nginx + PHP + MySQL</strong></p>
        <p>Capstone SO Final · Atividade 7</p>
        <a href="http://$(hostname -I | awk '{print $1}'):9000">→ Acessar App PHP</a>
    </div>
</body>
</html>
EOF

echo "✔ index.php (PHP/backend) criado."
echo "✔ index.html (Nginx/frontend) criado."

# --- PASSO 5: SCRIPT SQL ---
cat <<EOF | sudo tee "$PROJECT_DIR/init.sql" > /dev/null
CREATE DATABASE IF NOT EXISTS capstone_app;
USE capstone_app;

CREATE TABLE IF NOT EXISTS alunos (
    id        INT AUTO_INCREMENT PRIMARY KEY,
    nome      VARCHAR(50) NOT NULL,
    sobrenome VARCHAR(50) NOT NULL,
    idade     INT NOT NULL
);

INSERT IGNORE INTO alunos (id, nome, sobrenome, idade) VALUES
(1, 'Romário',  'Galdino',    25),
(2, 'Jala',     'University',  5),
(3, 'Admin',    'Capstone',   99);
EOF
echo "✔ init.sql criado para seed do banco."

# --- PASSO 6: DOCKER COMPOSE ---
echo -e "\n${GREEN}[PASSO 5] Gerando docker-compose.yml...${NC}"
cat <<'EOF' | sudo tee "$PROJECT_DIR/docker-compose.yml" > /dev/null
# ================================================================
# ATIVIDADE 7 - CAPSTONE SO FINAL
# Stack: MySQL + PHP-FPM + Nginx
# Rede isolada: capstone-net
# Volumes externos: db-data, html, php
# Variáveis: lidas do .env
# ================================================================

services:

  # --- BANCO DE DADOS ---
  db:
    image: mysql:8.0
    container_name: capstone-db
    restart: always
    env_file: .env
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE:      ${MYSQL_DATABASE}
      MYSQL_USER:          ${MYSQL_USER}
      MYSQL_PASSWORD:      ${MYSQL_PASSWORD}
    volumes:
      - db-data:/var/lib/mysql
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - capstone-net
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-proot-capstone-123"]
      interval: 10s
      timeout: 5s
      retries: 10

  # --- BACKEND PHP-FPM ---
  php:
    image: php:8.2-fpm
    container_name: capstone-php
    restart: always
    env_file: .env
    environment:
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER:     ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    volumes:
      - php:/var/www/html
    networks:
      - capstone-net
    depends_on:
      db:
        condition: service_healthy
    command: >
      sh -c "docker-php-ext-install pdo pdo_mysql && php-fpm"

  # --- FRONTEND NGINX ---
  nginx:
    image: nginx:alpine
    container_name: capstone-nginx
    restart: always
    ports:
      - "${NGINX_PORT:-8080}:80"
      - "${PHP_PORT:-9000}:9001"
    volumes:
      - html:/usr/share/nginx/html
      - php:/var/www/html
    networks:
      - capstone-net
    depends_on:
      - php

# ================================================================
# REDE ISOLADA
# ================================================================
networks:
  capstone-net:
    driver: bridge

# ================================================================
# VOLUMES EXTERNOS (fora dos containers)
# ================================================================
volumes:
  db-data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ./db-data
  html:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ./html
  php:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ./php
EOF
echo "✔ docker-compose.yml gerado."

# --- PASSO 7: SUBIR A STACK ---
echo -e "\n${GREEN}[PASSO 6] Derrubando stack antiga (se existir) e subindo nova...${NC}"
sudo docker compose --env-file "$PROJECT_DIR/.env" down --remove-orphans 2>/dev/null
sudo docker compose --env-file "$PROJECT_DIR/.env" up -d

echo -e "${YELLOW}Aguardando serviços inicializarem...${NC}"
sleep 10

# --- VALIDAÇÃO ---
echo -e "\n${BLUE}======================================================================"
echo -e "                     VALIDAÇÃO DA STACK"
echo -e "======================================================================${NC}"

VM_IP=$(hostname -I | awk '{print $1}')

# MySQL
if sudo docker exec capstone-db mysqladmin ping -h localhost -proot-capstone-123 --silent 2>/dev/null; then
    echo -e "${GREEN}✔ [DB]    MySQL (capstone-db) rodando.${NC}"
else
    echo -e "${RED}✘ [DB]    MySQL não respondeu ainda. Use: docker logs capstone-db${NC}"
fi

# PHP
if sudo docker ps | grep -q capstone-php; then
    echo -e "${GREEN}✔ [PHP]   PHP-FPM (capstone-php) em execução.${NC}"
else
    echo -e "${RED}✘ [PHP]   PHP-FPM não iniciou.${NC}"
fi

# Nginx
if sudo docker ps | grep -q capstone-nginx; then
    echo -e "${GREEN}✔ [NGINX] Nginx (capstone-nginx) em execução.${NC}"
else
    echo -e "${RED}✘ [NGINX] Nginx não iniciou.${NC}"
fi

echo ""
echo -e "${BLUE}Containers ativos:${NC}"
sudo docker ps --filter "name=capstone" --format "  • {{.Names}} · {{.Status}} · {{.Ports}}"

# Libera portas no firewall
sudo ufw allow 8080/tcp comment 'Nginx Capstone Stack' > /dev/null 2>&1
sudo ufw allow 9000/tcp comment 'PHP Capstone Stack'   > /dev/null 2>&1

echo ""
echo -e "${YELLOW}[ACESSO]${NC}"
echo -e "  Frontend (Nginx): ${GREEN}http://$VM_IP:8080${NC}"
echo -e "  Backend  (PHP):   ${GREEN}http://$VM_IP:9000${NC}"

echo -e "\n${GREEN}✔ ATIVIDADE 7 CONCLUÍDA!${NC}"
