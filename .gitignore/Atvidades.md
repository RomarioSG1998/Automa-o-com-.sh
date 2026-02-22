# [cite_start]Instruções do Capstone [cite: 25]

## Atividade 1: Máquina Virtual e Rede
* [cite_start]Crie uma VM Ubuntu Server LTS chamada `<APELIDO>-Capstone`[cite: 26, 34].
* [cite_start]Adicione dois adaptadores de rede: NAT e Bridge[cite: 34].
* [cite_start]Configure o SSH para a porta 2244[cite: 34].
* [cite_start]Crie o usuário "admin" e adicione-o ao grupo "sudo"[cite: 35].
* [cite_start]Configure o firewall para permitir apenas tráfego de saída na porta 8888[cite: 36].

## Atividade 2: Administração de Usuários
* [cite_start]Crie os grupos "it" e "qa"[cite: 39, 40].
* [cite_start]Crie os usuários "user1" e "user2" com o grupo primário "it"[cite: 41].
* [cite_start]Verifique se as pastas home foram criadas[cite: 42].
* [cite_start]Adicione o grupo secundário "qa" ao "user2"[cite: 43].
* [cite_start]Configure `/etc/sudoers.d` para o grupo "it" usar o `apt` (install, remove, purge)[cite: 44, 45].
* [cite_start]Configure `/etc/sudoers.d` para o grupo "qa" usar `useradd` e `usermod`[cite: 44, 46].
* [cite_start]Valide fazendo login com "user1" e "user2" executando comandos de instalação e criação de usuário[cite: 47, 48, 49, 50, 51].

## Atividade 3: Permissões
* [cite_start]Crie os grupos "grouplab81" e "grouplab82"[cite: 53, 54, 55].
* [cite_start]Crie "userlab81" (primário: grouplab81, secundário: cdrom) e "userlab82" (primário: grouplab82, secundário: sudo)[cite: 56, 57, 58, 59, 60, 61].
* [cite_start]Crie a estrutura `/tmp/Matematicas-[NombreApellido]/` com subdiretórios `Capitulo1`, `Capitulo2` e `Capitulo3`[cite: 63, 64, 65, 66, 67, 71].
* [cite_start]No `Capitulo2`, crie `leccionX.txt`, `leccionY.txt` e `leccionZ.txt`[cite: 68, 69, 70].
* [cite_start]No `Capitulo3`, crie `leccionA.txt`, `leccionB.txt` e `leccionC.txt`[cite: 72, 73, 74].
* [cite_start]Altere o dono e grupo de `Capitulo2` para `userlab81:grouplab81`[cite: 78].
* [cite_start]Com "userlab81", acesse `Capitulo2`, adicione uma linha em `leccionX.txt` e crie `leccion24.txt`[cite: 81, 82, 83].
* [cite_start]Modifique as permissões em `Capitulo3`: `leccionA.txt` para 600, `leccionB.txt` para 777 e `leccionC.txt` para 460[cite: 84, 85, 86, 87].
* [cite_start]Mude o grupo de `Capitulo1` para "grouplab82"[cite: 88, 89].
* [cite_start]Liste a estrutura com o comando `tree -ugp`[cite: 90].

## Atividade 4: Servidor NFS
* [cite_start]Crie uma nova VM para o servidor NFS com os diretórios `/nfs/<SOBRENOME>-drive` e `/nfs/installers`[cite: 92].
* [cite_start]Monte esses diretórios na VM cliente `<SOBRENOME>-Capstone`[cite: 93].
* [cite_start]Teste a cópia de arquivos a partir do cliente[cite: 94].

## Atividade 5: Docker e Nginx
* [cite_start]Com o usuário "admin", instale o Docker[cite: 95].
* [cite_start]Execute o contêiner `nginx:latest` na porta 9090:80[cite: 95].
* [cite_start]Substitua a página web padrão por uma contendo seu nome, sobrenome, cidade e data atual[cite: 96, 97].

## Atividade 6: Docker Compose e MySQL
* [cite_start]Crie um arquivo para a imagem do MySQL usando Docker Compose[cite: 98].
* [cite_start]Configure para executar um script SQL na inicialização (criar DB e tabelas com nome, sobrenome, idade)[cite: 99].
* [cite_start]Defina a senha de root e as portas (externa 3366, interna 3306) usando variáveis de ambiente[cite: 99].
* [cite_start]Conecte-se usando uma ferramenta cliente[cite: 100].

## Atividade 7: Múltiplos Contêineres
* [cite_start]Com o usuário "admin", instale o Docker Compose[cite: 101].
* [cite_start]Defina múltiplos contêineres (MySQL, Nginx, PHP) com rede isolada, variáveis de ambiente e volumes externos em um único arquivo YAML[cite: 101].