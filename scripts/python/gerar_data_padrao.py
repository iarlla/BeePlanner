import datetime
import locale

def formatar_data_hora_atual():
  """
  Define a localidade para português do Brasil e formata a data e hora atuais.

  Retorna:
    Uma string com a data e hora formatada no padrão solicitado.
  """
  try:
    # Define a localidade para português do Brasil para obter nomes em português
    # Use 'pt_BR.UTF-8' em Linux/macOS ou 'Portuguese_Brazil' em Windows
    locale.setlocale(locale.LC_TIME, 'pt_BR.UTF-8')
  except locale.Error:
    try:
      locale.setlocale(locale.LC_TIME, 'Portuguese_Brazil')
    except locale.Error:
      print("Aviso: Localidade 'pt_BR' não encontrada. Usando a localidade padrão do sistema.")

  # Pega a data e hora atuais
  agora = datetime.datetime.now()

  # Formata a string de acordo com as diretivas fornecidas
  # %j -> Dia do ano como um número decimal [001,366]
  # %U -> Número da semana do ano (Domingo como primeiro dia) [00,53]
  # %A -> Nome completo do dia da semana (localizado)
  # %d -> Dia do mês como um número decimal [01,31]
  # %B -> Nome completo do mês (localizado)
  # %Y -> Ano com século como um número decimal
  # %H -> Hora (relógio 24h) como um número decimal [00,23]
  # %M -> Minuto como um número decimal [00,59]
  # %S -> Segundo como um número decimal [00,61]
  formato = "Dia %j, Semana %U, %A, %d de %B de %Y, %H:%M:%S"
  data_hora_formatada = agora.strftime(formato)

  return data_hora_formatada

# Gera e imprime a data e hora formatada
dados_formatados = formatar_data_hora_atual()
print(dados_formatados)
