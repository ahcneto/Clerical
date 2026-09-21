const regioes = {
    R1: "N. Sra. da Conceição", R2: "São Francisco das Chagas",
    R3: "Sagrada Família", R4: "São Pedro e São Paulo",
    R5: "Bom Jesus dos Aflitos", R6: "N. Sra. da Assunção",
    R7: "São José", R8: "N. Sra. da Palma", R9: "N. Sra. dos Prazeres"
};

let pessoas = [];
let regiaoSelecionada = null;
let paroquiaSelecionada = null;
let tipoSelecionado = "TODOS";

const escaparHtml = valor => {
    const elemento = document.createElement("div");
    elemento.textContent = valor == null ? "" : String(valor);
    return elemento.innerHTML;
};

async function carregarDadosDashboard() {
    const resposta = await fetch("xsql/dashboard.xsql", { cache: "no-store" });
    if (!resposta.ok) throw new Error("Não foi possível carregar os dados do painel.");

    const xml = new DOMParser().parseFromString(await resposta.text(), "application/xml");
    if (xml.querySelector("parsererror")) throw new Error("Resposta inválida do painel.");

    pessoas = [...xml.querySelectorAll("ROWSET > ROW")].map(linha => ({
        nome: linha.querySelector("Nome")?.textContent || "",
        tipo: linha.querySelector("tipo")?.textContent || "",
        idade: Number(linha.querySelector("idade")?.textContent) || 0,
        data_ref: linha.querySelector("data_ref")?.textContent || "-",
        paroquia: linha.querySelector("paroquia")?.textContent || "Não informada",
        regiao: `R${linha.querySelector("regiao")?.textContent || ""}`
    }));

    atualizarDashboard();
}

function selecionarRegiao(regiao) {
    if (regiaoSelecionada === regiao) {
        regiaoSelecionada = null;
        paroquiaSelecionada = null;
    } else {
        regiaoSelecionada = regiao;
        paroquiaSelecionada = null;
    }
    atualizarDashboard();
}

function selecionarParoquia(paroquia) {
    paroquiaSelecionada = paroquiaSelecionada === paroquia ? null : paroquia;
    atualizarDashboard();
}

function selecionarTipo(tipo) {
    tipoSelecionado = tipoSelecionado === tipo ? "TODOS" : tipo;
    atualizarDashboard();
}

function getPessoasFiltradas() {
    const busca = document.getElementById("buscaNome").value.trim().toLowerCase();
    return pessoas.filter(pessoa =>
        (!regiaoSelecionada || pessoa.regiao === regiaoSelecionada) &&
        (!paroquiaSelecionada || pessoa.paroquia === paroquiaSelecionada) &&
        (tipoSelecionado === "TODOS" || pessoa.tipo === tipoSelecionado) &&
        (!busca || pessoa.nome.toLowerCase().includes(busca))
    );
}

function atualizarDashboard() {
    const dados = getPessoasFiltradas();
    document.getElementById("kpiRegioes").innerText = new Set(dados.map(p => p.regiao)).size;
    document.getElementById("kpiParoquias").innerText = new Set(dados.map(p => p.paroquia)).size;
    document.getElementById("kpiDiaconos").innerText = dados.filter(p => p.tipo === "DIACONO").length;
    document.getElementById("kpiCandidatos").innerText = dados.filter(p => p.tipo === "CANDIDATO").length;
    document.getElementById("kpiVocacionados").innerText = dados.filter(p => p.tipo === "VOCACIONADO").length;
    document.getElementById("kpiIdade").innerText = dados.length ? Math.round(dados.reduce((soma, p) => soma + p.idade, 0) / dados.length) : 0;

    [["cardDiaconos", "DIACONO"], ["cardCandidatos", "CANDIDATO"], ["cardVocacionados", "VOCACIONADO"]]
        .forEach(([id, tipo]) => document.getElementById(id).classList.toggle("kpi-selected", tipoSelecionado === tipo));

    atualizarLabelRegiao();
    renderParoquias(dados);
    renderPessoas(dados);
    atualizarTabelaRegioes();
}

function atualizarLabelRegiao() {
    let texto = "Região selecionada: <strong>TODAS</strong>";
    if (regiaoSelecionada) {
        texto = `Região selecionada: <strong>${escaparHtml(regioes[regiaoSelecionada] || regiaoSelecionada)}</strong>`;
        if (paroquiaSelecionada) texto += ` | Paróquia: <strong>${escaparHtml(paroquiaSelecionada)}</strong>`;
    }
    document.getElementById("regiaoSelecionadaLabel").innerHTML = texto;
}

function renderParoquias(dados) {
    const agrupado = {};
    dados.forEach(p => {
        if (!agrupado[p.paroquia]) agrupado[p.paroquia] = { d: 0, c: 0, v: 0 };
        if (p.tipo === "DIACONO") agrupado[p.paroquia].d++;
        if (p.tipo === "CANDIDATO") agrupado[p.paroquia].c++;
        if (p.tipo === "VOCACIONADO") agrupado[p.paroquia].v++;
    });
    document.getElementById("paroquiasBody").innerHTML = Object.keys(agrupado).sort().map(paroquia => {
        const p = agrupado[paroquia], total = p.d + p.c + p.v;
        const selecionada = paroquiaSelecionada === paroquia ? ' style="background:#dbeafe;font-weight:bold;"' : "";
        return `<tr${selecionada} data-paroquia="${escaparHtml(paroquia)}"><td>${escaparHtml(paroquia)}</td><td>${p.d}</td><td>${p.c}</td><td>${p.v}</td><td><b>${total}</b></td></tr>`;
    }).join("");
    document.querySelectorAll("#paroquiasBody tr").forEach(linha => linha.addEventListener("click", () => selecionarParoquia(linha.dataset.paroquia)));
}

function renderPessoas(dados) {
    document.getElementById("pessoasBody").innerHTML = dados.map(p =>
        `<tr><td>${escaparHtml(p.nome)}</td><td>${escaparHtml(p.tipo)}</td><td>${p.idade || "-"}</td><td>${escaparHtml(p.data_ref)}</td><td>${escaparHtml(p.paroquia)}</td><td>${escaparHtml(regioes[p.regiao] || p.regiao)}</td></tr>`
    ).join("");
}

function atualizarTabelaRegioes() {
    const resumo = {};
    pessoas.forEach(p => {
        if (!resumo[p.regiao]) resumo[p.regiao] = { voc: 0, cand: 0, diac: 0 };
        if (p.tipo === "VOCACIONADO") resumo[p.regiao].voc++;
        if (p.tipo === "CANDIDATO") resumo[p.regiao].cand++;
        if (p.tipo === "DIACONO") resumo[p.regiao].diac++;
    });
    document.getElementById("regioesBody").innerHTML = Object.keys(resumo).sort().map(regiao => {
        const r = resumo[regiao], total = r.voc + r.cand + r.diac;
        return `<tr data-regiao="${regiao}"><td>${escaparHtml(regioes[regiao] || regiao)}</td><td>${r.voc}</td><td>${r.cand}</td><td>${r.diac}</td><td><b>${total}</b></td></tr>`;
    }).join("");
    document.querySelectorAll("#regioesBody tr").forEach(linha => linha.addEventListener("click", () => selecionarRegiao(linha.dataset.regiao)));
}

document.getElementById("buscaNome").addEventListener("input", atualizarDashboard);
if (typeof imageMapResize === "function") imageMapResize();
carregarDadosDashboard().catch(erro => {
    console.error(erro);
    document.getElementById("pessoasBody").innerHTML = '<tr><td colspan="6">Não foi possível carregar os dados do painel.</td></tr>';
});
