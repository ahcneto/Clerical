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
    const formacao100 = grupo.formacao100Disponivel ? Number(grupo.membrosFormacao100 || 0) : "—";
    const detalheFormacao100 = grupo.formacao100Disponivel
        ? `de ${total} membros ativos · todas as disciplinas obrigatórias concluídas`
        : "Sem disciplinas obrigatórias ativas";
    const membrosAbaixo50 = grupo.presencaAbaixo50Disponivel ? Number(grupo.membrosAbaixo50 || 0) : "—";
    const detalheAbaixo50 = grupo.presencaAbaixo50Disponivel
        ? `de ${grupo.membrosAvaliadosPresenca} avaliados · ano atual`
        : (grupo.presencaAbaixo50Configurada ? "Sem registros de presença no ano atual" : "Presença não configurada");

    return `<div class="col-12 col-xl-6"><section class="painel-grupo-card" style="--grupo-cor:${cor}">
        <div class="d-flex align-items-center justify-content-between gap-2 mb-3"><h2 class="h5 painel-grupo-titulo mb-0">${textoSeguro(grupo.nome)}</h2><span class="badge rounded-pill" style="background:${cor}">Grupo</span></div>
        <div class="row g-2">
            ${indicadorPainel("bi-people-fill", "Membros ativos", total, "No grupo")}
            ${indicadorPainel("bi-calendar2-check", "Presença no último encontro", presenca, detalhePresenca)}
            ${indicadorPainel("bi-cash-coin", "% contribuições · mês do encontro", contribuicao, detalheContribuicao)}
            ${indicadorPainel("bi-exclamation-circle", "Sem pagamento na competência", inadimplentes, detalheInadimplentes)}
            ${indicadorPainel("bi-clock-history", "Inadimplentes históricos", historico, detalheHistorico)}
            ${indicadorPainel("bi-journal-check", "Formação 100% concluída", formacao100, detalheFormacao100)}
            ${indicadorPainel("bi-graph-down-arrow", "Presença abaixo de 50%", membrosAbaixo50, detalheAbaixo50)}
        </div>
    </section></div>`;
}

function renderizarAniversariantes(aniversariantes, mes) {
    const lista = document.getElementById("aniversariantesLista");
    const total = document.getElementById("aniversariantesTotal");
    const titulo = document.getElementById("aniversariantesTitulo");
    const numeroMes = Number(mes);
    const nomeMes = numeroMes >= 1 && numeroMes <= 12
        ? new Intl.DateTimeFormat("pt-BR", { month: "long" }).format(new Date(2020, numeroMes - 1, 1))
        : "mês";
    titulo.innerHTML = `<i class="bi bi-gift me-1"></i> Aniversariantes de ${textoSeguro(nomeMes)}`;
    total.textContent = `${aniversariantes.length} membro(s)`;
    lista.innerHTML = aniversariantes.length
        ? aniversariantes.map(pessoa => {
            const cor = /^#[0-9a-f]{6}$/i.test(pessoa.cor || "") ? pessoa.cor : "#64748b";
            const dia = String(pessoa.dia || "").padStart(2, "0");
            return `<div class="birthday-row">
                <div class="birthday-date">${textoSeguro(dia)}<small>${textoSeguro(nomeMes.slice(0, 3))}</small></div>
                <div class="birthday-name"><strong>${textoSeguro(pessoa.nome)}</strong></div>
                <span class="badge rounded-pill birthday-group" style="--grupo-cor:${cor}">${textoSeguro(pessoa.grupo)}</span>
            </div>`;
        }).join("")
        : '<div class="text-center text-muted py-4"><i class="bi bi-balloon me-1"></i>Não há aniversariantes neste mês.</div>';
}
async function carregarPainelAdministrativo() {
    const container = document.getElementById("painelGrupos");
    try {
        const resposta = await fetch("painel_administrativo_api.jsp", { cache: "no-store" });
        const dados = await resposta.json();
        if (!resposta.ok || !dados.ok) throw new Error(dados.mensagem || "Não foi possível carregar o painel.");
        renderizarAniversariantes(dados.aniversariantes || [], dados.mes);
        container.innerHTML = dados.grupos.length
            ? dados.grupos.map(cartaoGrupoPainel).join("")
            : '<div class="col-12 text-muted">Nenhum grupo operacional ativo.</div>';
    } catch (erro) {
        console.error("Erro ao carregar painel administrativo:", erro);
        container.innerHTML = '<div class="col-12"><div class="alert alert-danger mb-0">Não foi possível carregar os indicadores dos grupos.</div></div>';
    }
}

carregarPainelAdministrativo();