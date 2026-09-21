async function carregarTotaisPorGrupo() {
    const container = document.getElementById("cardsGruposPainel");
    if (!container) return;
    try {
        const response = await fetch("resumoMembros.jsp", { cache: "no-store" });
        const dados = await response.json();

        if (!response.ok || !dados.ok) {
            throw new Error(dados.mensagem || "Nenhum total de membros foi retornado.");
        }
        container.innerHTML = dados.grupos.map(grupo => {
            const cor = /^#[0-9a-f]{6}$/i.test(grupo.cor || "") ? grupo.cor : "#64748b";
            return `<div class="col-md-4"><div class="dashboard-card dashboard-card-compact clickable-card" data-grupo="${escaparHtml(grupo.singular)}" role="link" tabindex="0" style="border-top:4px solid ${cor}"><h5>${escaparHtml(grupo.plural)}</h5><div class="card-number" style="color:${cor}">${grupo.total}</div><i class="bi bi-people-fill" style="color:${cor}"></i></div></div>`;
        }).join("") || '<div class="col-12 text-muted">Nenhum grupo disponível.</div>';
        ativarCardsGrupos();
    } catch (error) {
        console.error("Erro ao carregar os totais por grupo:", error);
        container.innerHTML = '<div class="col-12 text-danger">Não foi possível carregar os grupos.</div>';
    }
}

carregarTotaisPorGrupo();

async function carregarResumoPessoal() {
    const resumo = document.getElementById("resumoPessoal");
    if (!resumo) return;
    try {
        const response = await fetch("resumoPessoal.jsp", { cache: "no-store" });
        const dados = await response.json();
        if (!response.ok || !dados.ok) throw new Error(dados.mensagem || "Não foi possível carregar o resumo.");
        document.getElementById("resumoPresencaAtual").textContent = `${dados.percentualPresenca}%`;
        document.getElementById("resumoContribuicaoAtual").textContent = `${dados.percentualContribuicao}%`;
    } catch (error) {
        console.error("Erro ao carregar resumo pessoal:", error);
        document.getElementById("resumoPresencaAtual").textContent = "—";
        document.getElementById("resumoContribuicaoAtual").textContent = "—";
    }
}

carregarResumoPessoal();

async function carregarResumoFormacoesAtivas() {
    const percentualElemento = document.getElementById("resumoFormacaoAtual");
    const detalheElemento = document.getElementById("resumoFormacaoDetalhe");
    const cardElemento = document.getElementById("cardResumoFormacao");
    if (!percentualElemento || !detalheElemento || !cardElemento) return;

    try {
        const response = await fetch("formacao_api.jsp?acao=programas", { cache: "no-store" });
        const dados = await response.json();
        if (!response.ok || !dados.ok) {
            throw new Error(dados.mensagem || "Não foi possível carregar as formações.");
        }

        const programasAtivos = dados.programas.filter(programa => programa.status === "ATIVO");
        if (!programasAtivos.length) {
            cardElemento.classList.add("d-none");
            cardElemento.parentElement.classList.add("without-formation");
            return;
        }
        const totalObrigatorias = programasAtivos.reduce(
            (total, programa) => total + Number(programa.obrigatorias || 0), 0
        );
        const totalConcluidas = programasAtivos.reduce(
            (total, programa) => total + Number(programa.concluidas || 0), 0
        );
        const percentual = totalObrigatorias > 0
            ? Math.round(totalConcluidas * 100 / totalObrigatorias)
            : 0;

        percentualElemento.textContent = `${percentual}%`;
        cardElemento.classList.remove("d-none");
        cardElemento.parentElement.classList.remove("without-formation");
        detalheElemento.textContent = programasAtivos.length
            ? `${totalConcluidas} de ${totalObrigatorias} obrigatórias · ${programasAtivos.length} programa(s)`
            : "Nenhuma formação ativa";
    } catch (error) {
        console.error("Erro ao carregar formações ativas:", error);
        percentualElemento.textContent = "—";
        detalheElemento.textContent = "Formações indisponíveis";
    }
}

carregarResumoFormacoesAtivas();

async function carregarDocumentacoesIniciais() {
    const secao = document.getElementById("documentosPendentesInicial");
    if (!secao) return;
    try {
        const response = await fetch("documentacao_api.jsp?acao=meus", { cache: "no-store" });
        const dados = await response.json();
        if (!response.ok || !dados.ok) throw new Error(dados.mensagem || "Não foi possível carregar as documentações.");
        if (!dados.total) {
            secao.classList.add("d-none");
            return;
        }
        secao.classList.remove("d-none");
        document.getElementById("documentosResumoInicial").textContent =
            `${dados.concluidos} entregue(s) · ${dados.pendentes} pendente(s)`;
        document.getElementById("documentosListaInicial").innerHTML = dados.documentos.map(item => `
            <div class="list-group-item px-0 d-flex justify-content-between align-items-center gap-3">
                <div>
                    <strong>${escaparHtml(item.descricao)}</strong>
                    <small class="d-block text-muted">${escaparHtml(item.checklist)}</small>
                </div>
                <span class="badge rounded-pill ${item.status === "CONCLUIDO" ? "text-bg-success" : "text-bg-warning"}">
                    ${item.status === "CONCLUIDO" ? "Entregue" : "Pendente"}
                </span>
            </div>`).join("");
    } catch (error) {
        console.error("Erro ao carregar documentações:", error);
        secao.classList.add("d-none");
    }
}

carregarDocumentacoesIniciais();

const trocarFotoInicialBtn = document.getElementById("trocarFotoInicialBtn");
const trocarFotoInicialInput = document.getElementById("trocarFotoInicialInput");
if (trocarFotoInicialBtn && trocarFotoInicialInput) {
    trocarFotoInicialBtn.addEventListener("click", () => trocarFotoInicialInput.click());
    trocarFotoInicialInput.addEventListener("change", async () => {
        const arquivo = trocarFotoInicialInput.files[0];
        if (!arquivo) return;
        if (!arquivo.type.startsWith("image/")) { alert("Selecione um arquivo de imagem válido."); return; }
        if (arquivo.size > 5 * 1024 * 1024) { alert("A imagem deve ter no máximo 5 MB."); return; }
        const dados = new FormData();
        dados.append("idPessoa", String(window.usuarioIdAtual));
        dados.append("nome", "");
        dados.append("ajax", "1");
        dados.append("foto", arquivo);
        trocarFotoInicialBtn.disabled = true;
        try {
            const resposta = await fetch("UploadFotoServlet", { method: "POST", body: dados });
            const resultado = await resposta.json();
            if (!resposta.ok || !resultado.ok) throw new Error(resultado.mensagem || "Não foi possível alterar a foto.");
            const foto = document.querySelector(".personal-summary-photo");
            foto.src = `${resultado.foto}?v=${Date.now()}`;
            foto.classList.remove("d-none");
            document.querySelector(".personal-summary-avatar").classList.add("d-none");
        } catch (erro) {
            alert(erro.message);
        } finally {
            trocarFotoInicialBtn.disabled = false;
            trocarFotoInicialInput.value = "";
        }
    });
}

const modalResumoElemento = document.getElementById("modalResumoAnual");
const modalResumoAnual = modalResumoElemento ? new bootstrap.Modal(modalResumoElemento) : null;

async function carregarDetalhesResumo(ano) {
    const response = await fetch(`detalhesResumoPessoal.jsp?ano=${encodeURIComponent(ano)}`, { cache: "no-store" });
    const dados = await response.json();
    if (!response.ok || !dados.ok) throw new Error(dados.mensagem || "Não foi possível carregar os detalhes.");
    const seletor = document.getElementById("anoResumoPessoal");
    seletor.innerHTML = dados.anos.map(item => `<option value="${item}">${item}</option>`).join("");
    seletor.value = String(dados.ano);
    document.getElementById("detalhePercentualPresenca").textContent = `${dados.percentualPresenca}%`;
    document.getElementById("detalhePercentualContribuicao").textContent = `${dados.percentualContribuicao}%`;
    document.getElementById("detalhePresencas").innerHTML = dados.presencas.length ? dados.presencas.map(item => {
        const classe = item.situacao === "Presente" ? "personal-detail-status-ok" : item.situacao === "Justificado" ? "personal-detail-status-warning" : "personal-detail-status-error";
        return `<tr><td>${escaparHtml(item.data)}</td><td>${escaparHtml(item.descricao)}</td><td class="${classe}">${escaparHtml(item.situacao)}</td><td>${escaparHtml(item.justificativa || "—")}</td></tr>`;
    }).join("") : '<tr><td colspan="4" class="text-muted text-center">Nenhum encontro encontrado neste ano.</td></tr>';
    document.getElementById("detalheContribuicoes").innerHTML = dados.contribuicoes.length ? dados.contribuicoes.map(item =>
        `<tr><td>${escaparHtml(item.mes)}</td><td>${escaparHtml(item.pagamento || "—")}</td><td>${escaparHtml(item.valor)}</td><td class="${item.paga ? "personal-detail-status-ok" : "personal-detail-status-error"}">${item.paga ? "Paga" : "Pendente"}</td></tr>`
    ).join("") : '<tr><td colspan="4" class="text-muted text-center">Nenhuma contribuição prevista neste ano.</td></tr>';
}

document.querySelectorAll("[data-abrir-resumo]").forEach(card => card.addEventListener("click", async () => {
    try {
        modalResumoAnual.show();
        await carregarDetalhesResumo(new Date().getFullYear());
        document.getElementById(card.dataset.abrirResumo === "presencas" ? "secaoResumoPresencas" : "secaoResumoContribuicoes")
            .scrollIntoView({ behavior: "smooth", block: "nearest" });
    } catch (error) {
        console.error("Erro ao carregar detalhes:", error);
        alert(error.message);
    }
}));

if (document.getElementById("anoResumoPessoal")) {
    document.getElementById("anoResumoPessoal").addEventListener("change", event => carregarDetalhesResumo(event.target.value));
}

function escaparHtml(valor) {
    const elemento = document.createElement("div");
    elemento.textContent = valor || "";
    return elemento.innerHTML;
}

function classePresenca(presenca) {
    if (presenca === "Presente") return "presenca-ok";
    if (presenca === "Justificado") return "presenca-justificado";
    return "presenca-falta";
}

async function carregarEncontros() {
    const container = document.getElementById("eventos-container");

    try {
        const response = await fetch("ultimosEncontros.jsp", { cache: "no-store" });
        const resultado = await response.json();

        if (!response.ok || !resultado.ok) {
            throw new Error(resultado.mensagem || "Não foi possível carregar os encontros.");
        }

        if (resultado.encontros.length === 0) {
            container.innerHTML = '<div class="list-group-item text-muted">Nenhum encontro encontrado.</div>';
            return;
        }

        container.innerHTML = resultado.encontros.map(encontro => {
            const podeAgir = encontro.podeRegistrar && encontro.presenca !== "Presente" && encontro.presenca !== "Justificado";
            const acoes = podeAgir ? `
                <div class="mt-2">
                    <button type="button" class="btn btn-sm btn-success me-1" data-acao-encontro="presente" data-encontro-id="${encontro.id}">Registrar presença</button>
                    <button type="button" class="btn btn-sm btn-outline-secondary" data-acao-encontro="justificar" data-encontro-id="${encontro.id}">Justificar ausência</button>
                </div>` : "";
            const contribuicao = !encontro.contribuicaoAplicavel ? "" : encontro.contribuicaoRealizada
                ? '<div class="mt-2"><span class="badge rounded-pill text-bg-success"><i class="bi bi-check-circle"></i> Contribuição paga</span></div>'
                : '<div class="mt-2"><span class="badge rounded-pill text-bg-warning"><i class="bi bi-exclamation-circle"></i> Contribuição pendente</span></div>';

            const local = encontro.local
                ? `<small class="d-block text-muted mt-1"><i class="bi bi-geo-alt"></i> ${escaparHtml(encontro.local)}</small>`
                : "";

            return `
                <div class="list-group-item">
                    <div class="d-flex justify-content-between align-items-start gap-3">
                        <div>
                            <div class="fw-semibold">${escaparHtml(encontro.descricao)}</div>
                            <small class="text-muted">${escaparHtml(encontro.data)} · ${escaparHtml(encontro.grupo)}</small>
                            ${local}
                            ${contribuicao}
                        </div>
                        <span class="${classePresenca(encontro.presenca)}">${escaparHtml(encontro.presenca)}</span>
                    </div>
                    ${encontro.justificativa ? `<small class="d-block mt-2">Justificativa: ${escaparHtml(encontro.justificativa)}</small>` : ""}
                    ${acoes}
                </div>`;
        }).join("");
    } catch (error) {
        console.error("Erro ao carregar encontros:", error);
        container.innerHTML = '<div class="list-group-item text-danger">Não foi possível carregar os encontros.</div>';
    }
}

function obterLocalizacaoAtual() {
    return new Promise(resolve => {
        if (!navigator.geolocation) {
            resolve({ latitude: 0, longitude: 0 });
            return;
        }
        navigator.geolocation.getCurrentPosition(
            posicao => resolve({
                latitude: posicao.coords.latitude,
                longitude: posicao.coords.longitude
            }),
            () => resolve({ latitude: 0, longitude: 0 }),
            { enableHighAccuracy: true, timeout: 15000, maximumAge: 0 }
        );
    });
}

async function registrarMinhaPresenca(idEncontro, flgPresenca, justificativa = "", localizacao = null) {
    const dados = new URLSearchParams({ idEncontro, flgPresenca, justificativa });
    if (localizacao) {
        dados.set("latitude", String(localizacao.latitude));
        dados.set("longitude", String(localizacao.longitude));
    }
    const response = await fetch("registrarMinhaPresenca.jsp", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8" },
        body: dados.toString()
    });
    const resultado = await response.json();

    if (!response.ok || !resultado.ok) {
        throw new Error(resultado.mensagem || "Não foi possível registrar a presença.");
    }
}

document.getElementById("eventos-container").addEventListener("click", async event => {
    const botao = event.target.closest("[data-acao-encontro]");
    if (!botao) return;

    const { acaoEncontro, encontroId } = botao.dataset;
    let flgPresenca = "1";
    let justificativa = "";

    if (acaoEncontro === "justificar") {
        justificativa = window.prompt("Informe a justificativa da ausência:", "");
        if (justificativa === null) return;
        justificativa = justificativa.trim();
        if (!justificativa) {
            alert("Informe a justificativa para continuar.");
            return;
        }
        flgPresenca = "2";
    }

    try {
        botao.disabled = true;
        const localizacao = flgPresenca === "1" ? await obterLocalizacaoAtual() : null;
        await registrarMinhaPresenca(encontroId, flgPresenca, justificativa, localizacao);
        await carregarEncontros();
    } catch (error) {
        console.error("Erro ao registrar presença:", error);
        alert(error.message);
        botao.disabled = false;
    }
});

carregarEncontros();

function abrirMembrosPorGrupo(grupo) {
    window.location.href = `membros.jsp?grupo=${encodeURIComponent(grupo)}`;
}

function ativarCardsGrupos() {
    document.querySelectorAll("[data-grupo]").forEach(card => {
        card.addEventListener("click", () => abrirMembrosPorGrupo(card.dataset.grupo));
        card.addEventListener("keydown", event => {
            if (event.key === "Enter" || event.key === " ") {
                event.preventDefault();
                abrirMembrosPorGrupo(card.dataset.grupo);
            }
        });
    });
}
