import flet as ft
import flet.canvas as cv
import math

def desenhar_roda_dinamica(quantidade_eixos, raio=100, centro_x=150, centro_y=150):
    elementos_desenho = []
    
    # Prevenção de erro (mínimo de 3 eixos)
    n_eixos = max(3, quantidade_eixos)
    angulo_base = (2 * math.pi) / n_eixos
    
    # 1. Desenhar a Teia (Polígono de Fundo)
    caminho_poligono = cv.Path(
        elements=[],
        paint=ft.Paint(
            style=ft.PaintStyle.STROKE,
            color=ft.colors.BLUE_GREY_700,
            stroke_width=1
        )
    )
    
    for i in range(n_eixos):
        angulo_atual = (i * angulo_base) - (math.pi / 2)
        
        # Aplicando a fórmula matemática
        x = centro_x + raio * math.cos(angulo_atual)
        y = centro_y + raio * math.sin(angulo_atual)
        
        # Se for o primeiro ponto, movemos o "pincel" para lá
        if i == 0:
            caminho_poligono.elements.append(cv.Path.MoveTo(x, y))
        else:
            caminho_poligono.elements.append(cv.Path.LineTo(x, y))
            
        # 2. Desenhar as linhas saindo do centro até a borda (os Eixos)
        linha_eixo = cv.Path(
            elements=[cv.Path.MoveTo(centro_x, centro_y), cv.Path.LineTo(x, y)],
            paint=ft.Paint(style=ft.PaintStyle.STROKE, color=ft.colors.BLUE_GREY_700)
        )
        elementos_desenho.append(linha_eixo)
        
    # Fechar o polígono ligando o último ponto ao primeiro
    caminho_poligono.elements.append(cv.Path.Close())
    elementos_desenho.append(caminho_poligono)
    
    return elementos_desenho

# Exemplo de uso na página principal do Flet:
# tela_canvas = cv.Canvas(shapes=desenhar_roda_dinamica(6)) # Hexágono