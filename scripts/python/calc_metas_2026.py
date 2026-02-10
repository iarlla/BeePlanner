import pandas as pd

def calculate_targets(notion_csv, calendar_csv):
    df_metas = pd.read_csv(notion_csv)
    df_cal = pd.read_csv(calendar_csv)
    df_cal_2026 = df_cal[df_cal['ano'] == 2026]
    
    def get_days(row):
        freq = str(row['Frequência']).lower()
        detail = str(row['Week/day/month']).lower()
        
        if 'diária' in freq or 'todo dia' in detail:
            return len(df_cal_2026)
        
        # Mapeamento para filtro no calendário
        day_map = {'sunday':0, 'monday':1, 'tuesday':2, 'wednesday':3, 'thursday':4, 'friday':5, 'saturday':6,
                   'domingo':0, 'segunda':1, 'terça':2, 'quarta':3, 'quinta':4, 'sexta':5, 'sábado':6}
        
        targets = [idx for name, idx in day_map.items() if name in detail]
        if targets:
            return len(df_cal_2026[df_cal_2026['dia_semana'].isin(targets)])
        
        # Fallbacks estatísticos
        if '2 semanal' in freq: return 104
        if 'mensal' in freq: return 12
        return 0

    df_metas['total_dias_100'] = df_metas.apply(get_days, axis=1)
    df_metas['alvo_75_percent'] = (df_metas['total_dias_100'] * 0.75).round().astype(int)
    
    df_metas.to_csv("metas_processadas_2026.csv", index=False)

if __name__ == "__main__":
    calculate_targets("notion_metas.csv", "dim_calendario.csv")