import sqlite3
import pandas as pd

def rodar_seed():
    # 1. Ler o CSV gerado
    df = pd.read_csv('metas_12_areas.csv')
    
    # 2. Conectar ao banco local do MVP (SQLite)
    conn = sqlite3.connect('database/beeplanner.db')
    cursor = conn.cursor()
    
    try:
        cursor.execute("BEGIN TRANSACTION;")
        
        # 3. Criar a configuração Mestre (12 Eixos)
        cursor.execute("""
            INSERT INTO configuracao_roda (nome_config, qnt_eixos_min, qnt_eixos_max) 
            VALUES ('Teia de Aranha (12 Eixos)', 3, 12)
        """)
        id_config = cursor.lastrowid
        
        # 4. Extrair áreas únicas e inserir dinamicamente em dim_eixos
        areas_unicas = df['area'].unique()
        mapa_eixos = {}
        
        for ordem, nome_area in enumerate(areas_unicas, start=1):
            cursor.execute("""
                INSERT INTO dim_eixos (id_config, nome_eixo, ordem_apresentacao) 
                VALUES (?, ?, ?)
            """, (id_config, nome_area, ordem))
            mapa_eixos[nome_area] = cursor.lastrowid
            
        # 5. Inserir as Metas vinculando aos Eixos dinâmicos
        for _, row in df.iterrows():
            # Simplificação para o MVP: assumindo frequencia_id = 1 (Genérico) para todos inicialmente
            cursor.execute("""
                INSERT INTO dim_metas (eixo_id, frequencia_id, titulo, total_dias_100, alvo_75_percent) 
                VALUES (?, ?, ?, ?, ?)
            """, (
                mapa_eixos[row['area']], 
                1, 
                row['Meta'], 
                row['total_dias_100'], 
                row['alvo_75_percent']
            ))
            
        cursor.execute("COMMIT;")
        print("✅ Seed finalizado: 1 Configuração, 12 Eixos e 36 Metas inseridas com sucesso!")
        
    except Exception as e:
        cursor.execute("ROLLBACK;")
        print(f"❌ Erro na transação: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    rodar_seed()