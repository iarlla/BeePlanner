import smtplib
import ssl
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from datetime import datetime
import locale
import tkinter as tk
from tkinter import scrolledtext, messagebox
import psycopg2
import os
from dotenv import load_dotenv

# Carrega as variáveis do arquivo .env
load_dotenv()

# --- CONFIGURAÇÕES DE BANCO DE DADOS ---
DB_CONFIG = {
    "host": os.getenv("DB_HOST"),
    "database": os.getenv("DB_NAME"),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD")
}

# --- CONFIGURAÇÕES DE EMAIL ---
EMAIL_REMETENTE = os.getenv("EMAIL_ADDRESS")
EMAIL_SENHA = os.getenv("EMAIL_APP_PASSWORD")
EMAIL_DESTINATARIO = os.getenv("EMAIL_DEFAULT_DESTINATARY")

# --- CONFIGURAÇÕES DE BANCO DE DADOS ---
# Certifique-se de ter criado a tabela 'diario_bordo' no seu banco PostgreSQL
DB_CONFIG = {
    "host": "localhost",
    "database": "beeplanner",  # Confirme se este é o nome do seu banco
    "user": "postgres",
    "password": "sua_senha_aqui" # <--- COLOQUE SUA SENHA DO POSTGRES
}

# --- CONFIGURAÇÕES DE EMAIL ---
SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587
EMAIL_REMETENTE = "teuemail@gmail.com"  # <--- SEU EMAIL GMAIL
EMAIL_SENHA = "tuasenha"  # <--- SUA SENHA DE APP DO GMAIL
EMAIL_DESTINATARIO = "email@gmail.com"  # Destinatário padrão

# Tentar configurar o locale para português (Datas em PT-BR)
try:
    locale.setlocale(locale.LC_TIME, "pt_BR.UTF-8")
except:
    try:
        locale.setlocale(locale.LC_TIME, "Portuguese_Brazil.1252")
    except:
        locale.setlocale(locale.LC_TIME, "")

# --- FUNÇÕES AUXILIARES ---

def obter_dia_do_ano():
    return datetime.now().timetuple().tm_yday

def obter_data_formatada():
    agora = datetime.now()
    semana_do_ano = agora.isocalendar()[1]
    dia_do_ano = agora.timetuple().tm_yday
    dia_da_semana = agora.strftime("%A").capitalize() # Primeira letra maiúscula
    data_formatada = agora.strftime("%d/%m/%Y")
    hora_atual = agora.strftime("%H:%M")
    return f"**Semana {semana_do_ano}, {dia_da_semana}, {data_formatada} ({dia_do_ano}/365), {hora_atual}**"

def criar_template_mensagem():
    return f"""
<h2>{obter_data_formatada()}</h2>
<aside>
    <img src="https://i.imgur.com/3H8V5jD.png" width="40px" />
    <h3>MANHÃ - 6h às 11:59</h3>
    <ul>
        <li><strong>Acordar:</strong></li>
        <li><strong>Café da manhã:</strong></li>
        <li><strong>Atividade física 1:</strong></li>
        <li><strong>Pré trabalho:</strong></li>
    </ul>
</aside>
<aside>
    <img src="https://i.imgur.com/3H8V5jD.png" width="40px" />
    <h3>TARDE - 12h às 17:59</h3>
    <ul>
        <li><strong>Estágio - registro de atividades:</strong></li>
    </ul>
</aside>
<aside>
    <img src="https://i.imgur.com/3H8V5jD.png" width="40px" />
    <h3>NOITE - 18h às 23:59</h3>
    <ul>
        <li><strong>Resumo da Aula:</strong></li>
        <li><strong>Status do TCC:</strong></li>
    </ul>
</aside>
<aside>
    <img src="https://i.imgur.com/3H8V5jD.png" width="40px" />
    <h3>MADRUGADA - 00:00 às 5:59</h3>
    <p>À mimir</p>
</aside>
<p>Com carinho, sua tão perdida Eu ❤️</p>
"""

# --- LÓGICA DE BACKEND (BANCO E EMAIL) ---

def salvar_no_banco(texto_html):
    """Tenta salvar o diário no banco de dados. Retorna True/False."""
    try:
        # Prepara dados
        agora = datetime.now()
        data_iso = agora.strftime("%Y-%m-%d")
        dia_ano = agora.timetuple().tm_yday
        semana_ano = agora.isocalendar()[1]

        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        # Query com "ON CONFLICT" para permitir editar a ata do mesmo dia
        sql = """
            INSERT INTO diario_bordo (data_diario, dia_ano, semana_ano, texto_completo)
            VALUES (%s, %s, %s, %s)
            ON CONFLICT (data_diario) DO UPDATE 
            SET texto_completo = EXCLUDED.texto_completo;
        """
        cursor.execute(sql, (data_iso, dia_ano, semana_ano, texto_html))
        
        conn.commit()
        cursor.close()
        conn.close()
        print("✅ Diário salvo no banco com sucesso.")
        return True
    except Exception as e:
        print(f"❌ Erro ao salvar no banco: {e}")
        return False

def processar_envio(destinatario, assunto, mensagem_html):
    """Realiza o envio do email e a gravação no banco. Retorna (SucessoBool, MensagemStr)."""
    
    # 1. Salvar no Banco (Prioridade de Engenharia: Dados primeiro!)
    db_salvo = salvar_no_banco(mensagem_html)
    msg_db = "e salvo no Banco" if db_salvo else "(mas FALHA ao salvar no Banco)"

    # 2. Enviar E-mail
    msg = MIMEMultipart()
    msg['From'] = EMAIL_REMETENTE
    msg['To'] = destinatario
    msg['Subject'] = assunto
    msg.attach(MIMEText(mensagem_html, 'html'))

    try:
        context = ssl.create_default_context()
        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
            server.starttls(context=context)
            server.login(EMAIL_REMETENTE, EMAIL_SENHA)
            server.sendmail(EMAIL_REMETENTE, destinatario, msg.as_string())
        
        return True, f"E-mail enviado {msg_db} com sucesso!"
        
    except Exception as e:
        return False, f"Erro ao enviar e-mail: {e}"

# --- INTERFACE GRÁFICA (GUI) ---

def acao_botao_enviar():
    destinatario = entrada_destinatario.get()
    assunto = entrada_assunto.get()
    mensagem = editor_mensagem.get("1.0", tk.END) # Pega todo o texto
    
    if not destinatario or not assunto or not mensagem.strip():
        messagebox.showerror("Erro", "Por favor, preencha todos os campos.")
        return
    
    # Chama a função de backend
    sucesso, mensagem_retorno = processar_envio(destinatario, assunto, mensagem)
    
    if sucesso:
        messagebox.showinfo("Sucesso BeePlanner", mensagem_retorno)
        janela.quit()
        janela.destroy()
    else:
        messagebox.showerror("Erro BeePlanner", mensagem_retorno)

# Configuração da Janela
janela = tk.Tk()
janela.title("BeePlanner - Ata Diária") # Atualizei o título ;)
janela.geometry("900x700")

# Frame de Topo (Campos)
frame_topo = tk.Frame(janela, padx=10, pady=10)
frame_topo.pack(fill=tk.X)

# Grid Layout para campos
tk.Label(frame_topo, text="Destinatário:").grid(row=0, column=0, sticky=tk.W, pady=5)
entrada_destinatario = tk.Entry(frame_topo, width=50)
entrada_destinatario.grid(row=0, column=1, sticky=tk.W, pady=5)
entrada_destinatario.insert(0, EMAIL_DESTINATARIO)

tk.Label(frame_topo, text="Assunto:").grid(row=1, column=0, sticky=tk.W, pady=5)
entrada_assunto = tk.Entry(frame_topo, width=50)
entrada_assunto.grid(row=1, column=1, sticky=tk.W, pady=5)

# Insere assunto padrão
dia_atual = obter_dia_do_ano()
entrada_assunto.insert(0, f"Ata do dia {dia_atual} - BeePlanner")

# Editor de Texto
frame_editor = tk.Frame(janela, padx=10, pady=5)
frame_editor.pack(fill=tk.BOTH, expand=True)

tk.Label(frame_editor, text="Conteúdo (HTML):").pack(anchor=tk.W)
editor_mensagem = scrolledtext.ScrolledText(frame_editor, wrap=tk.WORD, height=20)
editor_mensagem.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)

# Inserir template no editor
editor_mensagem.insert(tk.END, criar_template_mensagem())

# Botões
frame_botoes = tk.Frame(janela, padx=20, pady=20)
frame_botoes.pack(fill=tk.X)

btn_sair = tk.Button(frame_botoes, text="Cancelar", command=janela.destroy, width=15, bg="#ffcccc")
btn_sair.pack(side=tk.LEFT)

btn_enviar = tk.Button(frame_botoes, text="ENVIAR ATA 🐝", command=acao_botao_enviar, width=20, bg="#ccffcc", font=("Arial", 10, "bold"))
btn_enviar.pack(side=tk.RIGHT)

# Iniciar
janela.mainloop()
