/* ==========================================================
 * BeePlanner — JS compartilhado
 * ==========================================================
 * Funções usadas por mais de uma página (index, dashboard,
 * metas, tarefas, roda-da-vida). Lógica específica de cada
 * página (ex: chips de dia da semana em metas.html) continua
 * embutida no <script> do próprio arquivo.
 * ========================================================== */

// --- DATA DO CABEÇALHO ---
// Espelha a lógica de scripts/daily_ops/gerar_data_padrao.py (Python).
// Importante: usa %U (semana iniciando no domingo, 00–53), igual ao
// script Python — NÃO é a semana ISO 8601 (%V). Se a regra do .py
// mudar um dia, esta função precisa ser atualizada também (e só
// precisa ser atualizada AQUI, já que é compartilhada pelas 5 páginas).
function calcularDataPadrao(agora = new Date()) {
    const MESES = [
        'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
        'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
    ];
    const MESES_ABREV = [
        'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
        'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    const DIAS_SEMANA = [
        'domingo', 'segunda-feira', 'terça-feira', 'quarta-feira',
        'quinta-feira', 'sexta-feira', 'sábado'
    ];

    const ano = agora.getFullYear();
    const mes = agora.getMonth(); // 0-indexado
    const dia = agora.getDate();
    const diaSemana = agora.getDay(); // 0=domingo ... 6=sábado

    // %j — dia do ano (1–366)
    const inicioAno = new Date(ano, 0, 1);
    const diaDoAno = Math.floor((agora - inicioAno) / 86400000) + 1;

    // %U — número da semana, domingo como primeiro dia (00–53)
    // Mesma fórmula usada pelo strftime('%U') do Python.
    const semanaU = Math.floor((diaDoAno + 6 - diaSemana) / 7);

    return {
        dataCurta: `${String(dia).padStart(2, '0')} ${MESES_ABREV[mes]} ${ano}`,
        diaDoAno: String(diaDoAno).padStart(3, '0'),
        semana: String(semanaU).padStart(2, '0'),
        diaSemanaExtenso: DIAS_SEMANA[diaSemana],
        mesExtenso: MESES[mes],
        dataExtensa: `Dia ${String(diaDoAno).padStart(3, '0')}, Semana ${String(semanaU).padStart(2, '0')}, ${DIAS_SEMANA[diaSemana]}, ${String(dia).padStart(2, '0')} de ${MESES[mes]} de ${ano}`
    };
}

// Usado por dashboard.html, metas.html, tarefas.html e roda-da-vida.html,
// que têm os elementos #data-extenso e #data-dia-semana no header.
// index.html usa um único elemento #splash-data (formato mais compacto).
function atualizarCabecalhoData() {
    const d = calcularDataPadrao();

    const elExtenso = document.getElementById('data-extenso');
    const elDiaSemana = document.getElementById('data-dia-semana');
    if (elExtenso && elDiaSemana) {
        elExtenso.textContent = d.dataCurta;
        elDiaSemana.textContent = `Dia ${d.diaDoAno}, Semana ${d.semana}`;
    }

    const elSplash = document.getElementById('splash-data');
    if (elSplash) {
        elSplash.textContent = `${d.dataCurta} · Dia ${d.diaDoAno}, Semana ${d.semana}`;
    }
}

// --- MODAIS ---
// Usado por metas.html, tarefas.html e roda-da-vida.html.
function openModal(id) {
    document.getElementById(id).classList.add('active');
}
function closeModal(id) {
    document.getElementById(id).classList.remove('active');
}

// --- TOAST DE CONFIRMAÇÃO ---
// Usado por metas.html, tarefas.html e roda-da-vida.html.
function showToast(msg) {
    const toast = document.getElementById('toast');
    if (!toast) return;
    toast.textContent = '✅ ' + msg;
    toast.classList.add('show');
    setTimeout(() => toast.classList.remove('show'), 2600);
}

// --- INICIALIZAÇÃO COMUM ---
// Roda em todas as páginas que carregam este arquivo.
document.addEventListener('DOMContentLoaded', () => {
    atualizarCabecalhoData();

    // Fechar modal ao clicar fora da caixa (apenas onde houver .modal-overlay)
    document.querySelectorAll('.modal-overlay').forEach(overlay => {
        overlay.addEventListener('click', (e) => {
            if (e.target === overlay) overlay.classList.remove('active');
        });
    });

    // Swatches de cor — seleção única por grupo (metas.html e roda-da-vida.html)
    document.querySelectorAll('.color-picker').forEach(group => {
        group.querySelectorAll('.color-swatch').forEach(swatch => {
            swatch.addEventListener('click', () => {
                group.querySelectorAll('.color-swatch').forEach(s => s.classList.remove('selected'));
                swatch.classList.add('selected');
            });
        });
    });

    // Filter chips da toolbar — seleção única (metas.html e tarefas.html)
    document.querySelectorAll('.table-toolbar').forEach(toolbar => {
        const chips = toolbar.querySelectorAll('.filter-chip');
        chips.forEach(chip => {
            chip.addEventListener('click', () => {
                chips.forEach(c => c.classList.remove('active'));
                chip.classList.add('active');
            });
        });
    });
});
