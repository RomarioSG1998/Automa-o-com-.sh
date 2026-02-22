# 🧪 Guia de Testes: Capstone VM

Este guia contém as instruções para acessar e testar as automações em seu laboratório.

---

## 🔑 1. Acesso às Máquinas Virtuais

> **Atenção:** Substitua os valores entre `< >` pelas informações da **sua** configuração de VM.

### 🏠 VM Servidor NFS
* **Hostname**: `<seu-hostname-servidor>`
* **Usuário**: `<seu-usuario>`
* **IP**: `<IP-do-servidor>` *(ex: 10.0.0.X)*
* **Porta**: `2244`
* **Senha (Sudo)**: *(definida durante a Atividade 1)*
```bash
ssh -p 2244 <seu-usuario>@<IP-do-servidor>
```

---

### 🖥️ VM Cliente NFS
* **Hostname**: `<seu-hostname-cliente>`
* **Usuário**: `<seu-usuario-cliente>`
* **IP**: `<IP-do-cliente>` *(ex: 10.0.0.Y)*
* **Senha**: *(definida na criação da VM cliente)*
```bash
ssh <seu-usuario-cliente>@<IP-do-cliente>
```

---

## 🚀 2. Ferramenta de Automação: Remote Launcher
Para facilitar tudo, use o lançador inteligente:

```bash
./remote_launcher.sh
```

**Como funciona:**
1. O script vai te perguntar: "Em qual máquina deseja trabalhar?".
2. Escolha **1** para o Servidor (Original) ou **2** para o Cliente (Novo).
3. Depois, escolha se quer apenas entrar no SSH ou rodar um script. 
4. **Acabou!** Sem precisar digitar IPs ou usuários complicados.

> **Antes de rodar:** edite o `remote_launcher.sh` e preencha com o IP, usuário e porta das suas VMs.

---

## 📋 3. Execução da Atividade 4 (NFS)

### Passo A: Configurar o Servidor
1. Entre na VM Servidor.
2. Execute o script:
```bash
bash /tmp/atividade_4_servidor.sh
```

### Passo B: Configurar o Cliente
1. Entre na VM Cliente.
2. Execute o script:
```bash
bash /tmp/atividade_4_cliente.sh
```
3. **Quando o script pedir o IP do servidor, digite**: `<IP-do-servidor>`

---

## 📖 4. Modo Manual (Teoria + Código)
Se você quiser ver o **código exato** e a **explicação teórica** de cada comando antes de executar, todos os scripts possuem um modo manual. 

Basta adicionar `-m` ao final do comando:
```bash
# Exemplos:
bash /tmp/atividade_1.sh -m
bash /tmp/atividade_4_servidor.sh -m
```
*Ele exibirá o comando em amarelo e a explicação do que ele faz logo abaixo.*

---

## 🚪 Como Sair
Para sair de qualquer VM e voltar para o seu computador, digite:
```bash
exit
```
Ou use o atalho **Ctrl + D**.
