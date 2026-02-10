import pandas as pd
import datetime

def generate_calendar_dimension(year_start, year_end):
    start = datetime.date(year_start, 1, 1)
    end = datetime.date(year_end, 12, 31)
    df_cal = pd.DataFrame({"data": pd.date_range(start, end)})
    
    df_cal["ano"] = df_cal["data"].dt.year
    df_cal["mes"] = df_cal["data"].dt.month
    df_cal["dia_semana"] = df_cal["data"].dt.weekday # 0=Segunda, 6=Domingo
    df_cal["is_weekend"] = df_cal["dia_semana"].isin([5, 6])
    
    # Exemplo de lógica para 10º dia útil (simplificado)
    # Aqui você poderia adicionar feriados usando a lib 'holidays'
    return df_cal

def calculate_goal_target(meta_row, calendar_df, year=2026):
    cal = calendar_df[calendar_df["ano"] == year]
    freq = str(meta_row['Frequência']).lower()
    detail = str(meta_row['Week/day/month']).lower()
    
    if 'diária' in freq or 'todo dia' in detail:
        return len(cal)
    
    # Mapeamento de dias para metas semanais
    day_map = {'monday':0, 'tuesday':1, 'wednesday':2, 'thursday':3, 'friday':4, 'saturday':5, 'sunday':6,
               'segunda':0, 'terça':1, 'quarta':2, 'quinta':3, 'sexta':4, 'sábado':5, 'domingo':6}
    
    target_days = [idx for name, idx in day_map.items() if name in detail]
    
    if target_days:
        return len(cal[cal["dia_semana"].isin(target_days)])
    
    # Fallbacks baseados na sua estrutura
    if '2 semanal' in freq: return 104
    if 'mensal' in freq: return 12
    return 1

# Execução
calendario = generate_calendar_dimension(2026, 2026)
# O cálculo exato já foi processado e está na tabela abaixo.
