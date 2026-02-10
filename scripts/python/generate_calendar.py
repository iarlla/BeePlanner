import pandas as pd
import datetime

def generate_calendar_csv(start_year, end_year, filename="dim_calendario.csv"):
    start = datetime.date(start_year, 1, 1)
    end = datetime.date(end_year, 12, 31)
    dates = pd.date_range(start, end)
    
    df = pd.DataFrame({"data_id": dates})
    df["ano"] = df["data_id"].dt.year
    df["mes"] = df["data_id"].dt.month
    df["dia"] = df["data_id"].dt.day
    # Converte Segunda=0 (Pandas) para Domingo=0 (SQL Standard)
    df["dia_semana"] = (df["data_id"].dt.weekday + 1) % 7
    df["is_fim_semana"] = df["dia_semana"].isin([0, 6])
    df["is_bissexto"] = df["data_id"].dt.is_leap_year
    
    df.to_csv(filename, index=False)
    print(f"Arquivo {filename} gerado com sucesso.")

if __name__ == "__main__":
    generate_calendar_csv(2026, 2030)