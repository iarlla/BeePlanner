
Abra seu terminal e siga os passos:

### 1. Instalação dos Pacotes

Vamos instalar o PostgreSQL e o pacote `contrib` (que tem extensões úteis), além do `libpq-dev` que é **obrigatório** para instalar bibliotecas Python depois.

```bash
sudo apt update
sudo apt install postgresql postgresql-contrib libpq-dev

```

### 2. Iniciar e Habilitar o Serviço

Garanta que o banco inicie sempre que você ligar o computador.

```bash
sudo systemctl start postgresql
sudo systemctl enable postgresql

```

Para verificar se está rodando (deve aparecer "Active: active (exited)"):

```bash
sudo systemctl status postgresql

```

### 3. Configurar a Senha do Usuário `postgres`

Por padrão, o Linux cria um usuário chamado `postgres` sem senha definida para acesso externo. Como seu arquivo `.env` espera uma senha, vamos definir uma agora.

1. Entre no prompt do PostgreSQL:
```bash
sudo -u postgres psql

```


2. Agora você está dentro do terminal SQL (`postgres=#`). Digite este comando (não esqueça o ponto e vírgula):
```sql
ALTER USER postgres PASSWORD 'sua_senha_secreta';

```


*(Dica: Use a mesma senha que você colocou no seu arquivo `.env` ou atualize o arquivo depois).*
3. Saia do terminal SQL:
```sql
\q

```



### 4. Criar o Banco de Dados `beeplanner`

Ainda no terminal do Linux, vamos usar o utilitário `createdb` para já deixar o banco pronto para receber suas tabelas.

```bash
sudo -u postgres createdb beeplanner

```

---

### 5. Verificação de Engenharia (Teste de Conexão)

Vamos garantir que o Python vai conseguir conectar. Tente logar no banco recém-criado usando a senha que você definiu:

```bash
psql -h localhost -U postgres -d beeplanner

```

* Ele vai pedir a senha. Digite-a.
* Se o prompt mudar para `beeplanner=#`, **Parabéns! O ambiente está pronto.**
* Digite `\q` para sair.

---

### 6. Ferramenta Visual (Recomendado)

Como você está no Linux Mint, recomendo muito instalar o **DBeaver Community**. É muito melhor que o pgAdmin para quem trabalha com engenharia de dados.

No terminal:

```bash
flatpak install flathub io.dbeaver.DBeaverCommunity

```

*(Ou baixe o `.deb` no site oficial se preferir não usar Flatpak).*

---

### Próximo Passo

Agora que o **PostgreSQL** está instalado e o banco `beeplanner` criado, você pode voltar para o arquivo `docs/setup_banco.md` que criamos e rodar os scripts SQL para criar as tabelas (`dim_metas`, `fact_execucoes`, etc.).

Deu tudo certo com a instalação?