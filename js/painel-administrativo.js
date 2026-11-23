function textoSeguro(valor) {
    const elemento = document.createElement("div");
    elemento.textContent = valor == null ? "" : String(valor);
    return elemento.innerHTML;
}

function indicadorPainel(icone, titulo, valor, detalhe) {
    return `<div class="col-6 col-lg-4"><div class="painel-indicador"><small><i class="bi ${icone} me-1"></i>${textoSeguro(titulo)}</small><strong>${textoSeguro(valor)}</strong><small>${textoSeguro(detalhe || "")}</small></div></div>`;
}

function cartaoGrupoPainel(grupo) {
    const cor = /^#[0-9a-f]{6}$/i.test(grupo.cor || "") ? grupo.cor : "#64748b";
    const total = Number(grupo.membrosAtivos || 0);
    const presenca = grupo.presencaDisponivel ? `${Number(grupo.percentualPresenca || 0)}%` : "—";
    const detalhePresenca = grupo.presencaDisponivel
        ? `${grupo.presentes} de ${total} presentes · ${grupo.dataEncontro}`
        : (grupo.encontroId ? "Presença não configurada" : "Sem encontro realizado");
    const contribuicao = grupo.contribuicaoDisponivel ? `${Number(grupo.percentualContribuicao || 0)}%` : "—";
    const detalheContribuicao = grupo.contribuicaoDisponivel
        ? `${grupo.pagaram} de ${total} pagos · competência ${grupo.mesReferencia}`
        : "Sem competência de contribuição";
    const inadimplentes = grupo.contribuicaoDisponivel
        ? `${grupo.inadimplentesCompetencia} (${Number(grupo.percentualInadimplenciaCompetencia || 0)}%)`
        : "—";
    const detalheInadimplentes = grupo.contribuicaoDisponivel
        ? `Sem pagamento em ${grupo.mesReferencia}`
        : "Não calculado";
    const historico = grupo.inadimplenciaHistoricaDisponivel
        ? `${grupo.inadimplentesHistoricos} (${Number(grupo.percentualInadimplenciaHistorica || 0)}%)`
        : "—";
    const detalheHistorico = grupo.inadimplenciaHistoricaDisponivel
        ? "Com lançamento vencido registrado"
        : "Contribuição não configurada";

    return `<div class="col-12 col-xl-6"><section class="painel-grupo-card" style="--grupo-cor:${cor}">
        <div class="d-flex align-items-center justify-content-between gap-2 mb-3"><h2 class="h5 painel-grupo-titulo mb-0">${textoSeguro(grupo.nome)}</h2><span class="badge rounded-pill" style="background:${cor}">Grupo</span></div>
        <div class="row g-2">
            ${indicadorPainel("bi-people-fill", "Membros ativos", total, "No grupo")}
            ${indicadorPainel("bi-calendar2-check", "Presença no último encontro", presenca, detalhePresenca)}
            ${indicadorPainel("bi-cash-coin", "% contribuições · mês do encontro", contribuicao, detalheContribuicao)}
            ${indicadorPainel("bi-exclamation-circle", "Sem pagamento na competência", inadimplentes, detalheInadimplentes)}
            ${indicadorPainel("bi-clock-history", "Inadimplentes históricos", historico, detalheHistorico)}
        </div>
    </section></div>`;
}

async function carregarPainelAdministrativo() {
    const container = document.getElementById("painelGrupos");
    try {
        const resposta = await fetch("painel_administrativo_api.jsp", { cache: "no-store" });
        const dados = await resposta.json();
        if (!resposta.ok || !dados.ok) throw new Error(dados.mensagem || "Não foi possível carregar o painel.");
        container.innerHTML = dados.grupos.length
            ? dados.grupos.map(cartaoGrupoPainel).join("")
            : '<div class="col-12 text-muted">Nenhum grupo operacional ativo.</div>';
    } catch (erro) {
        console.error("Erro ao carregar painel administrativo:", erro);
        container.innerHTML = '<div class="col-12"><div class="alert alert-danger mb-0">Não foi possível carregar os indicadores dos grupos.</div></div>';
    }
}

carregarPainelAdministrativo();