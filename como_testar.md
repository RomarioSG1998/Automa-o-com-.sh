# 🧪 Guia de Testes: Capstone VM

Este guia contém as instruções para acessar e testar as automações em seu laboratório.

---

## 🔑 1. Acesso às Máquinas Virtuais

### 🏠 VM Servidor NFS (Original)
* **Hostname**: `rgaldino-linux`
* **Usuário**: `rgaldino`
* **IP**: `10.0.0.102`
* **Porta**: `2244`
* **Senha (Sudo)**: *(não compartilhe senhas em repositórios públicos)*
```bash
ssh -p 2244 rgaldino@10.0.0.102
```

---

### 🖥️ VM Cliente NFS (Nova VM cliente)
* **Hostname**: `rgaldinocapstonecliente`
* **Usuário**: `rgaldino_capstone_cliente`
* **IP**: `10.0.0.127`
* **Senha**: *(não compartilhe senhas em repositórios públicos)*
```bash
ssh rgaldino_capstone_cliente@10.0.0.127
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

---

## 📂 3. Localização dos Arquivos

---

## � 3. Execução da Atividade 4 (NFS)

### Passo A: Configurar o Servidor (Na Original `.102`)
1. Entre na máquina original.
2. Execute o script:
```bash
bash /tmp/atividade_4_servidor.sh
```

### Passo B: Configurar o Cliente (Na Nova `.127`)
1. Entre na máquina nova.
2. Execute o script:
```bash
bash /tmp/atividade_4_cliente.sh
```
3. **Quando o script pedir o IP do servidor, digite**: `10.0.0.102`

---

## 📖 4. Modo Manual (Teoria + Código)
Se você quiser ver o **o código exato** e a **explicação teórica** de cada comando antes de executar, todos os scripts possuem um modo manual. 

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
