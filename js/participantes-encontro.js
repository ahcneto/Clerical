const escParticipante = valor => {
    const elemento = document.createElement("div");
    elemento.textContent = valor || "";
    return elemento.innerHTML;
};

const classePresencaParticipante = presenca =>
    presenca === "Presente"
        ? "presenca-ok"
        : presenca === "Justificado"
            ? "presenca-justificado"
            : "presenca-falta";

const normalizarTextoParticipante = valor =>
    String(valor || "")
        .normalize("NFD")
        .replace(/[\u0300-\u036f]/g, "")
        .toLocaleLowerCase("pt-BR")
        .trim();

let participantesEncontro = [];

const textoJustificativaParticipante = participante => {
    if (participante.presenca !== "Presente") return participante.justificativa || "-";
    if (participante.distancia === null || participante.distancia === undefined || participante.distancia === "") return "-";
    return `${Number(participante.distancia).toLocaleString("pt-BR", { maximumFractionDigits: 1 })} m`;
};

function renderizarParticipantes() {
    const nomePesquisado = normalizarTextoParticipante(
        document.getElementById("filtroNomeParticipante")?.value
    );
    const statusSelecionado =
        document.getElementById("filtroStatusPresenca")?.value || "";

    const participantesFiltrados = participantesEncontro.filter(participante => {
        const correspondeNome =
            !nomePesquisado ||
            normalizarTextoParticipante(participante.nome).includes(nomePesquisado);
        const correspondeStatus =
            !statusSelecionado || participante.presenca === statusSelecionado;
        return correspondeNome && correspondeStatus;
    });

    const corpo = document.getElementById("participantesBody");
    const totalColunas = window.podeEditarPresenca ? 4 : 3;

    corpo.innerHTML = participantesFiltrados.map(participante => `
        <tr>
            <td>${escParticipante(participante.nome)}</td>
            <td class="${classePresencaParticipante(participante.presenca)}">
                ${escParticipante(participante.presenca)}
            </td>
            <td>${escParticipante(textoJustificativaParticipante(participante))}</td>
            ${window.podeEditarPresenca ? `
                <td>
                    ${participante.presenca !== "Presente" && participante.presenca !== "Justificado"
                        ? `<button class="btn btn-sm btn-success me-1" onclick="alterarPresenca(${participante.id},1)">Presente</button>
                           <button class="btn btn-sm btn-outline-secondary" onclick="justificar(${participante.id})">Justificar</button>`
                        : "-"}
                </td>
            ` : ""}
        </tr>
    `).join("") || `
        <tr>
            <td colspan="${totalColunas}" class="text-center text-muted py-4">
                Nenhum participante encontrado para os filtros selecionados.
            </td>
        </tr>
    `;

    const informacao = document.getElementById("participantesFiltradosInfo");
    if (informacao) {
        informacao.textContent = participantesFiltrados.length === participantesEncontro.length
            ? `${participantesEncontro.length} participante(s)`
            : `${participantesFiltrados.length} de ${participantesEncontro.length} participante(s)`;
    }
}

async function carregarParticipantes() {
    const resposta = await fetch(
        `listarParticipantesEncontro.jsp?id=${encodeURIComponent(window.idEncontro)}`,
        { cache: "no-store" }
    );
    const dados = await resposta.json();

    if (!resposta.ok || !dados.ok) {
        throw new Error(dados.mensagem || "Erro ao carregar participantes.");
    }

    document.getElementById("tituloEncontro").textContent = dados.encontro.descricao;
    document.getElementById("subtituloEncontro").textContent =
        `${dados.encontro.data} · ${dados.encontro.grupo}`;

    participantesEncontro = dados.participantes;

    const total = participantesEncontro.length;
    const presentes = participantesEncontro.filter(p => p.presenca === "Presente").length;
    const justificados = participantesEncontro.filter(p => p.presenca === "Justificado").length;
    const ausentes = total - presentes - justificados;
    const percentual = quantidade => total ? Math.round(quantidade * 100 / total) : 0;

    document.getElementById("resumoPresencas").innerHTML = `
        <div class="col-md-4">
            <div class="dashboard-card">
                <h5>Presentes</h5>
                <div class="card-number presenca-ok">${presentes}</div>
                <span>${percentual(presentes)}%</span>
            </div>
        </div>
        <div class="col-md-4">
            <div class="dashboard-card">
                <h5>Ausentes</h5>
                <div class="card-number presenca-falta">${ausentes}</div>
                <span>${percentual(ausentes)}%</span>
            </div>
        </div>
        <div class="col-md-4">
            <div class="dashboard-card">
                <h5>Justificados</h5>
                <div class="card-number presenca-justificado">${justificados}</div>
                <span>${percentual(justificados)}%</span>
            </div>
        </div>
    `;

    renderizarParticipantes();
}

async function alterarPresenca(idPessoa, flgPresenca, justificativa = " ") {
    const resposta = await fetch("registrarPresencaParticipante.jsp", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8" },
        body: new URLSearchParams({
            idEncontro: window.idEncontro,
            idPessoa,
            flgPresenca,
            justificativa
        })
    });
    const dados = await resposta.json();

    if (!resposta.ok || !dados.ok) {
        throw new Error(dados.mensagem || "Erro ao atualizar presença.");
    }

    await carregarParticipantes();
}

async function justificar(idPessoa) {
    const texto = prompt("Informe a justificativa:", "");
    if (texto === null) return;
    if (!texto.trim()) {
        alert("Informe a justificativa.");
        return;
    }

    try {
        await alterarPresenca(idPessoa, 2, texto.trim());
    } catch (erro) {
        alert(erro.message);
    }
}

document.getElementById("filtroNomeParticipante")
    ?.addEventListener("input", renderizarParticipantes);
document.getElementById("filtroStatusPresenca")
    ?.addEventListener("change", renderizarParticipantes);

carregarParticipantes().catch(erro => {
    console.error(erro);
    const totalColunas = window.podeEditarPresenca ? 4 : 3;
    document.getElementById("participantesBody").innerHTML = `
        <tr>
            <td colspan="${totalColunas}">Não foi possível carregar os participantes.</td>
        </tr>
    `;
});
