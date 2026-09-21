const eventos = [
    {
        titulo: "Encontro de Formação Litúrgica",
        data: "19/07/2025",
        hora: "08:00",
        publico: "Todos"
    },
    {
        titulo: "Retiro Espiritual - Candidatos",
        data: "02/08/2025",
        hora: "07:30",
        publico: "Candidato"
    }
];

function carregarEventos() {
    const container = document.getElementById("eventos-container");

    eventos.forEach(ev => {
        container.innerHTML += `
            <div class="event-card">
                <span class="badge-status">Agendado</span>
                <div class="event-title">${ev.titulo}</div>
                <div class="text-muted mt-2">
                    ${ev.data} às ${ev.hora} - ${ev.publico}
                </div>
            </div>
        `;
    });
}

function toggleUserMenu() {
    document.getElementById("userMenu").classList.toggle("show");
}

async function carregarResumoContribuicoes() {
    const elemento = document.getElementById("resumoContribuicoesPct");
    if (!elemento) return;

    try {
        const resposta = await fetch("perfilContribuicoes.jsp", { cache: "no-store" });
        const dados = await resposta.json();
        if (resposta.ok && dados.ok) elemento.textContent = dados.percentual + "%";
    } catch (erro) {
        console.error("Erro ao carregar resumo de contribuições:", erro);
    }
}

async function carregarResumoFormacaoMenu() {
    const linha = document.getElementById("resumoFormacaoMenuLinha");
    const percentual = document.getElementById("resumoFormacaoMenuPct");
    if (!linha || !percentual) return;

    try {
        const resposta = await fetch("formacao_api.jsp?acao=programas", { cache: "no-store" });
        const dados = await resposta.json();
        if (!resposta.ok || !dados.ok) return;
        const ativos = dados.programas.filter(programa => programa.status === "ATIVO");
        if (!ativos.length) {
            linha.classList.add("d-none");
            return;
        }
        const total = ativos.reduce((soma, programa) => soma + Number(programa.obrigatorias || 0), 0);
        const concluidas = ativos.reduce((soma, programa) => soma + Number(programa.concluidas || 0), 0);
        percentual.textContent = `${total ? Math.round(concluidas * 100 / total) : 0}%`;
        linha.classList.remove("d-none");
    } catch (erro) {
        console.error("Erro ao carregar resumo da formação:", erro);
    }
}

document.addEventListener("click", function(event) {
    const menu = document.querySelector(".user-menu-container");

    if (!menu.contains(event.target)) {
        document.getElementById("userMenu").classList.remove("show");
    }
});

const participacao = 82;
const contribuicao = 100;

const participacaoElemento = document.getElementById("participacaoPct");
const contribuicaoElemento = document.getElementById("contribuicaoPct");
if (participacaoElemento) participacaoElemento.innerText = participacao + "%";
if (contribuicaoElemento) contribuicaoElemento.innerText = contribuicao + "%";

if (document.getElementById("eventos-container")) carregarEventos();
carregarResumoContribuicoes();
carregarResumoFormacaoMenu();
