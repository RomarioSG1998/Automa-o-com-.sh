# 🖥️ SO FINAL — Capstone de Sistemas Operacionais

Conjunto de **scripts Bash de automação** para o projeto Capstone da disciplina de Sistemas Operacionais. Cada script configura e valida uma atividade específica em uma VM Ubuntu Server, com suporte a modo manual (explicativo) e sessão remota interativa via SSH.

---

## 📁 Estrutura do Projeto

```
SO FINAL/
├── remote_launcher.sh        # 🚀 Lançador principal — envia e executa scripts remotamente
├── common_utils.sh           # 🔧 Utilitários compartilhados (cores, logs, etc.)
├── atividade_1.sh            # VM, Rede, SSH e Firewall
├── atividade_2.sh            # Criação de Usuários e Grupos
├── atividade_3.sh            # Permissões de Arquivos e Diretórios
├── atividade_4_servidor.sh   # Servidor NFS
├── atividade_4_cliente.sh    # Cliente NFS
├── atividade_5.sh            # Docker + Nginx
├── atividade_6.sh            # Docker Compose + MySQL
├── atividade_7.sh            # Stack Completa (MySQL + Nginx + PHP)
└── como_testar.md            # Guia rápido de acesso e testes
```

---

## 🚀 Como Usar

### Pré-requisitos

- **Máquina host** com `bash`, `ssh` e `scp` instalados.
- **Conexão de rede** com as VMs configuradas.
- Na **VM**, você deve ter permissão `sudo`.

---

### 1. Executar com o Lançador Remoto (Recomendado)

O `remote_launcher.sh` automatiza o envio e a execução de qualquer script de atividade na VM correta, sem que você precise digitar IPs ou usuários manualmente.

```bash
./remote_launcher.sh
```

**Fluxo interativo:**

1. **Escolha a VM alvo:**
   - `1` → Servidor NFS (`rgaldino@10.0.0.102` — porta `2244`)
   - `2` → Cliente NFS (`rgaldino_capstone_cliente@10.0.0.127`)

2. **Escolha a ação:**
   - `1` — Entrar apenas no terminal (SSH interativo)
   - `2` — Enviar e executar o script (retorna ao host ao final)
   - `3` — Enviar, executar e **permanecer na VM** *(recomendado)*

3. **Escolha o script** (ex: `atividade_1.sh`, `atividade_4_servidor.sh`).

> O lançador copia o `common_utils.sh` e o script escolhido para `/tmp/` na VM e inicia a execução automaticamente.

---

### 2. Executar Manualmente na VM

Se você já estiver dentro da VM, pode executar qualquer script diretamente:

```bash
# Modo automático — executa e configura tudo com pausas para prints
bash /tmp/atividade_1.sh

# Modo manual — exibe cada comando + explicação teórica, sem executar
bash /tmp/atividade_1.sh -m
```

> **Dica:** Use o flag `-m` para estudar os comandos antes de aplicá-los ou para usar como roteiro de execução manual.

---

## 📋 Atividades

| # | Script | O que faz |
|---|--------|-----------|
| 1 | `atividade_1.sh` | Altera porta SSH para `2244`, cria usuário `admin` com sudo, configura o Firewall (UFW) |
| 2 | `atividade_2.sh` | Cria grupos `it` e `qa`, usuários `user1`/`user2`, configura `/etc/sudoers.d/` |
| 3 | `atividade_3.sh` | Cria estrutura de diretórios, define donos e permissões (`chmod`/`chown`) |
| 4 | `atividade_4_servidor.sh` | Instala e configura servidor NFS, exporta diretórios |
| 4 | `atividade_4_cliente.sh` | Monta diretórios NFS do servidor na VM cliente |
| 5 | `atividade_5.sh` | Instala Docker, sobe contêiner `nginx:latest` na porta `9090` com página personalizada |
| 6 | `atividade_6.sh` | Sobe MySQL via Docker Compose (porta `3366`), executa script SQL de inicialização |
| 7 | `atividade_7.sh` | Stack completa com MySQL + Nginx + PHP em rede Docker isolada |

---

## 🌐 Acesso às VMs

| VM | Usuário | IP | Porta SSH | Comando |
|----|---------|----|-----------|---------|
| Servidor NFS (original) | `rgaldino` | `10.0.0.102` | `2244` | `ssh -p 2244 rgaldino@10.0.0.102` |
| Cliente NFS (nova) | `rgaldino_capstone_cliente` | `10.0.0.127` | `22` | `ssh rgaldino_capstone_cliente@10.0.0.127` |

> **Senha sudo das VMs:** `145869`

---

## 🔄 Fluxo da Atividade 4 (NFS — Dois Scripts)

A Atividade 4 requer execução em **duas VMs diferentes**, nesta ordem:

```
Passo 1 — No Servidor (10.0.0.102):
  bash /tmp/atividade_4_servidor.sh

Passo 2 — No Cliente (10.0.0.127):
  bash /tmp/atividade_4_cliente.sh
  # Quando solicitado, informe o IP do servidor: 10.0.0.102
```

---

## 📖 Modo Manual (`-m`)

Todos os scripts possuem um modo educativo que exibe os comandos em destaque e explica o que cada um faz, **sem executar nada**:

```bash
bash /tmp/atividade_1.sh -m
bash /tmp/atividade_5.sh --manual
```

Ideal para revisar antes de executar ou para usar como roteiro em apresentações.

---

## 🚪 Saindo da VM

Para retornar ao seu computador a partir de qualquer VM:

```bash
exit
# ou Ctrl + D
```

---

## 📄 Documentação Adicional

- [`como_testar.md`](./como_testar.md) — Guia rápido de acesso e execução das atividades
- [`.gitignore/Atvidades.md`](./.gitignore/Atvidades.md) — Enunciado original do Capstone com todos os requisitos
