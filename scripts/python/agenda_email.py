import smtplib
import ssl
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from datetime import datetime
import locale
import tkinter as tk
from tkinter import scrolledtext, messagebox

# Tentar configurar o locale para português
try:
    locale.setlocale(locale.LC_TIME, "pt_PT.utf8")  # Linux/macOS
except:
    try:
        locale.setlocale(locale.LC_TIME, "pt_BR.UTF-8")  # Outra opção para Linux
    except:
        try:
            locale.setlocale(locale.LC_TIME, "Portuguese_Brazil.1252")  # Windows
        except:
            locale.setlocale(locale.LC_TIME, "")  # Fallback para o locale padrão

# Configurações do e-mail
SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587
EMAIL_REMETENTE = "teuemail@gmail.com"  # Substitua pelo seu email
EMAIL_SENHA = "tuasenha"  # Substitua pela sua senha de app
EMAIL_DESTINATARIO = "iarl.a@outlook.com"  # Destinatário padrão

# Função para obter o dia do ano
def obter_dia_do_ano():
    agora = datetime.now()
    return agora.timetuple().tm_yday

# Função para gerar a data formatada
def obter_data_formatada():
    agora = datetime.now()
    semana_do_ano = agora.isocalendar()[1]
    dia_do_ano = agora.timetuple().tm_yday
    dia_da_semana = agora.strftime("%A")
    data_formatada = agora.strftime("%d/%m/%Y")
    hora_atual = agora.strftime("%H:%M")
    return f"**Semana {semana_do_ano}, {dia_da_semana}, {data_formatada} ({dia_do_ano}/365), {hora_atual}**"

# Função para enviar e-mail
def enviar_email(destinatario, assunto, mensagem):
    try:
        # Criar a mensagem de e-mail
        msg = MIMEMultipart()
        msg["From"] = EMAIL_REMETENTE
        msg["To"] = destinatario
        msg["Subject"] = assunto
        
        # Adicionar corpo do e-mail
        msg.attach(MIMEText(mensagem, "html"))
        
        # Conectar ao servidor SMTP
        servidor = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
        servidor.starttls()
        servidor.login(EMAIL_REMETENTE, EMAIL_SENHA)
        
        # Enviar e-mail
        servidor.sendmail(EMAIL_REMETENTE, destinatario, msg.as_string())
        servidor.quit()
        return True, f"✅ E-mail enviado para {destinatario}"
    except Exception as e:
        return False, f"❌ Erro ao enviar e-mail: {e}"

# Criar o template da mensagem com a data dinâmica
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
<p>Com carinho, sua tão perdida Iarla ❤️</p>
"""

# Função para lidar com o botão de enviar
def enviar():
    destinatario = entrada_destinatario.get()
    assunto = entrada_assunto.get()
    mensagem = editor_mensagem.get("1.0", tk.END)
    
    if not destinatario or not assunto or not mensagem.strip():
        messagebox.showerror("Erro", "Por favor, preencha todos os campos.")
        return
    
    sucesso, mensagem_resultado = enviar_email(destinatario, assunto, mensagem)
    if sucesso:
        # Mostrar mensagem de sucesso e configurar para fechar após o clique
        messagebox.showinfo("Sucesso", mensagem_resultado)
        # Fechar a janela após mostrar a mensagem
        janela.quit()
        janela.destroy()
    else:
        messagebox.showerror("Erro", mensagem_resultado)

# Criar a janela principal
janela = tk.Tk()
janela.title("Agenda Diária - Enviar E-mail")
janela.geometry("800x600")

# Criar os widgets
frame_topo = tk.Frame(janela, padx=10, pady=10)
frame_topo.pack(fill=tk.X)

tk.Label(frame_topo, text="Destinatário:").grid(row=0, column=0, sticky=tk.W)
entrada_destinatario = tk.Entry(frame_topo, width=40)
entrada_destinatario.grid(row=0, column=1, sticky=tk.W)
entrada_destinatario.insert(0, EMAIL_DESTINATARIO)  # Inserir o destinatário padrão

tk.Label(frame_topo, text="Assunto:").grid(row=1, column=0, sticky=tk.W)
entrada_assunto = tk.Entry(frame_topo, width=40)
entrada_assunto.grid(row=1, column=1, sticky=tk.W)

# Configurar o assunto com o dia do ano
dia_atual = obter_dia_do_ano()
entrada_assunto.insert(0, f"Ata do dia {dia_atual}")

# Criar o editor de texto
frame_editor = tk.Frame(janela, padx=10, pady=10)
frame_editor.pack(fill=tk.BOTH, expand=True)

tk.Label(frame_editor, text="Mensagem HTML:").pack(anchor=tk.W)
editor_mensagem = scrolledtext.ScrolledText(frame_editor, wrap=tk.WORD, width=80, height=20)
editor_mensagem.pack(fill=tk.BOTH, expand=True)
editor_mensagem.insert(tk.END, criar_template_mensagem())

# Botão de enviar
frame_botoes = tk.Frame(janela, padx=10, pady=10)
frame_botoes.pack(fill=tk.X)

botao_enviar = tk.Button(frame_botoes, text="Enviar E-mail", command=enviar, padx=10, pady=5)
botao_enviar.pack(side=tk.RIGHT)

# Botão para sair sem enviar
botao_sair = tk.Button(frame_botoes, text="Sair", command=janela.destroy, padx=10, pady=5)
botao_sair.pack(side=tk.LEFT)

# Iniciar o loop de eventos
janela.mainloop()
