# Relatório de Execução de Atividades - Capstone Midterm

**Usuário:** Romario Jala  
**Data:** 23 de Fevereiro de 2026  

---

## 1. Introdução

Este documento detalha a execução técnica das atividades do Capstone Midterm, abrangendo desde a configuração da infraestrutura de rede e segurança da máquina virtual até a gestão avançada de permissões, sistemas de arquivos, serviços de rede (NFS), virtualização com Docker e a orquestração complexa de microserviços com Docker Compose.

---

## 2. Registro de Atividades

### Atividade 01: Configuração de Infraestrutura e Segurança Inicial

**Descrição:** Criação da VM Ubuntu Server LTS, configuração de adaptadores de rede híbridos, alteração da porta SSH, criação de conta administrativa e endurecimento de tráfego de saída.

#### Execução:
- **VM e Rede:** Criação da VM Romario-Capstone com dois adaptadores (NAT e Bridge).
- **Acesso Remoto:** Alteração da porta SSH para 2244 no arquivo `/etc/ssh/sshd_config`.
- **Conta Admin:** Criação do usuário admin com privilégios `sudo`.
- **Firewall (UFW):** Bloqueio de saída exceto para a porta 8888.

#### Evidências Visuais:
> [Print 01: Configuração dos adaptadores NAT e Bridge na VM]  
> [Print 02: Edição do arquivo sshd_config (Port 2244)]  
> [Print 03: Criação do usuário admin e teste de privilégios sudo]  
> [Print 04: Configuração e status do UFW bloqueando saída exceto porta 8888]

---

### Atividade 02: Administração de Usuários e Controle de Privilégios (Sudoers)

**Descrição:** Implementação de hierarquia de grupos (`it`/`qa`), gestão de usuários específicos e configuração de permissões granulares via `sudoers.d`.

#### Execução:
- **Grupos e Usuários:** Criação dos grupos `it`/`qa` e usuários `user1`/`user2`.
- **Sudoers Granular:** Definição de comandos específicos para cada grupo em `/etc/sudoers.d/`.

#### Evidências Visuais:
> [Print 05: Comandos de criação de grupos e usuários]  
> [Print 06: Listagem do /home e comando id user2]  
> [Print 07: Conteúdo dos arquivos criados em /etc/sudoers.d/]  
> [Print 08: Teste de validação de comandos sudo por usuário]

---

### Atividade 03: Permissões de Grupos e Manipulação de Arquivos

**Descrição:** Configuração de grupos laboratoriais, criação de estrutura complexa de arquivos em diretório temporário e gestão de propriedade/permissões de sistema.

#### Execução:
- **Usuários e Grupos Lab:** Criação de usuários e grupos `grouplab81`/`grouplab82`.
- **Estrutura de Arquivos:** Criação da árvore em `/tmp/Matematicas-RomarioJala`.
- **Gestão de Propriedade:** Alteração para `userlab81:grouplab81` no Capítulo 2.
- **Permissões (Chmod):** Configuração de permissões octais `600`, `777` e `460`.

#### Evidências Visuais:
> [Print 09: Criação dos usuários e grupos lab (81 e 82)]  
> [Print 10: Estrutura de arquivos criada no /tmp]  
> [Print 11: Dono e grupo atualizados do Capitulo2]  
> [Print 12: Execução do comando tree -ugp exibindo permissões finais]

---

### Atividade 04: Implementação de Servidor e Cliente NFS

**Descrição:** Criação de uma nova VM para atuar como Servidor NFS e configuração da VM Jala-Capstone como cliente para montagem remota de diretórios.

#### Execução:
- **Configuração do Servidor NFS:** Instalação do `nfs-kernel-server` e exportação dos diretórios `/nfs/Jala-drive` e `/nfs/installers`.
- **Configuração do Cliente:** Montagem dos diretórios remotos na VM Capstone.
- **Teste de Persistência:** Validação de cópia de arquivos entre cliente e servidor.

#### Evidências Visuais:
> [Print 13: Configuração do /etc/exports no Servidor NFS]  
> [Print 14: Comando de montagem e saída do df -h no Cliente]  
> [Print 15: Teste de cópia de arquivo validando a sincronização]

---

### Atividade 05: Virtualização com Docker e Servidor Web Nginx

**Descrição:** Instalação do motor Docker e execução de um contêiner Nginx personalizado servindo uma página web identificada.

#### Execução:
- **Instalação do Docker:** Realizada com o usuário admin.
- **Execução do Contêiner:** Inicialização do Nginx com mapeamento `9090:80`.
- **Personalização:** Substituição do `index.html` via `docker cp` com dados pessoais.

#### Evidências Visuais:
> [Print 16: Instalação do Docker e comando docker run]  
> [Print 17: Página personalizada exibida no navegador na porta 9090]

---

### Atividade 06: Orquestração de Banco de Dados com Docker Compose

**Descrição:** Configuração de um ambiente MySQL automatizado utilizando Docker Compose, incluindo a inicialização automática de banco de dados e dados de teste.

#### Execução:
- **Criação do Script SQL (`init.sql`):** Script para criação de tabela e inserção de registros iniciais.
- **Configuração do `docker-compose.yml`:** Definição de imagem MySQL, senha root, porta `3366` e volume de inicialização.
- **Deploy:** Execução via `docker-compose up -d`.

#### Evidências Visuais:
> [Print 18: Conteúdo do arquivo docker-compose.yml]  
> [Print 19: Teste de conexão bem-sucedido via ferramenta cliente]

---

### Atividade 07: Orquestração Multi-Serviço com Docker Compose (Stack LEMP)

**Descrição:** Implementação de uma arquitetura de múltiplos serviços (MySQL, Nginx e PHP) utilizando Docker Compose, garantindo isolamento de rede, persistência de volumes e gestão de variáveis de ambiente.

#### Execução:
- **Instalação do Docker Compose:** Caso não presente, instalação da versão estável via usuário admin.
- **Definição do `docker-compose.yml`:**
  - **Serviço DB (MySQL):** Banco de dados persistente com volumes externos para dados.
  - **Serviço Backend (PHP-FPM):** Processamento de scripts PHP isolado.
  - **Serviço Frontend (Nginx):** Servidor web configurado para atuar como proxy reverso para o PHP.
- **Rede Isolada:** Criação de uma rede interna customizada (ex: `backend-network`) para comunicação segura entre contêineres, sem exposição desnecessária de portas internas.
- **Volumes e Persistência:** Configuração de volumes fora dos contêineres para garantir que os dados do banco e o código-fonte permaneçam íntegros após reinicializações.
- **Variáveis de Ambiente:** Uso de arquivo `.env` ou diretivas `environment` para gerenciar credenciais de acesso ao DB.
- **Deploy e Validação:** Subida do ambiente completo com `docker-compose up -d` e verificação da conectividade entre o frontend (Nginx) e o banco de dados via PHP.

#### Evidências Visuais:
> [Print 20: Estrutura do arquivo docker-compose.yml multi-serviço]  
> [Print 21: Criação e configuração da rede isolada e volumes no YAML]  
> [Print 22: Comandos de execução e status dos contêineres (docker-compose ps)]  
> [Print 23: Teste final de integração entre Frontend, Backend e DB]

---

## 3. Conclusão Geral

As atividades apresentadas consolidam o conhecimento em administração de sistemas Linux, segurança de rede e infraestrutura moderna. Desde o endurecimento inicial do servidor até a orquestração avançada de microserviços com Docker Compose na Atividade 7, foi demonstrada a capacidade de projetar e manter ambientes escaláveis, seguros e resilientes, seguindo as melhores práticas de DevOps e administração de sistemas.