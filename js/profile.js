let perfil = {};
let perfilOriginal = {};
const $ = (id) => document.getElementById(id);

async function carregarPerfil() {
    try {
        const response = await fetch(`membros_consulta.jsp?acao=perfil&pessoa=${encodeURIComponent(window.perfilId)}`, { cache: "no-store" });
        const dadosPerfil = await response.json();
        if (!response.ok || !dadosPerfil.ok) throw new Error(dadosPerfil.mensagem || "Perfil não encontrado.");
        const getValue = tag => String(dadosPerfil.perfil[tag] ?? "");
		
		perfil = {

    id: getValue("IdPessoa"),

    // Dados pessoais
    nome: getValue("Nome"),
    matricula: getValue("Matricula"),
    tpMatricula: getValue("tpMatricula"),
    grupo: getValue("DescClasse"),

    telefone: getValue("Fone1"),
    telefone2: getValue("Fone2"),
    email: getValue("Email"),
    nascimento: getValue("DtNascimento"),

    profissao: getValue("Profissao"),
    pastoral: getValue("Pastoral"),

    // Dados familiares
    esposa: getValue("NomeEsposa"),
    foneEsposa: getValue("FoneEsposa"),
    nascEsposa: getValue("DtNascEsposa"),
    casamento: getValue("DtCasamento"),
    profissaoEsposa: getValue("ProfissaoEsposa"),

    // Dados ministeriais
    paroquiaId: getValue("IdParoquia"),
    paroquia: getValue("Paroquia"),
    bairro: getValue("Bairro"),
    regiao: getValue("Regiao"),
    turma: getValue("Turma"),
    ordenacao: getValue("DtOrdenacao"),
    provisao: getValue("DtProvisao"),
    bispo: getValue("BispoOrdenante"),

    // Administrativo
    transferido: getValue("Transferido"),
    dioceseTransf: getValue("DioceseTransf"),
    status: getValue("status"),

    flgTeologia: getValue("flgTeologia"),
    flgSeminarioLeitor: getValue("flgSeminarioLeitor"),
    flgSeminarioAcolito: getValue("flgSeminarioAcolito"),
    flgLeitor: getValue("flgLeitor"),
    flgAcolito: getValue("flgAcolito"),
    flgOrdemSacra: getValue("flgOrdemSacra"),

    // Observações
    obs: getValue("Obs")

};

perfilOriginal = JSON.parse(JSON.stringify(perfil));	

        // Dados principais
        const nome = getValue("Nome");
        const grupo = getValue("DescClasse");
        const paroquia = getValue("Paroquia");
        const bairro = getValue("Bairro");
        const regiao = getValue("Regiao");

        document.getElementById("profileNome").textContent = nome;
        document.getElementById("profileResumo").textContent =
            `${grupo} • ${paroquia}${bairro ? ` - ${bairro}` : ""}${regiao ? ` • ${regiao}` : ""}`;

        // Dados pessoais
        document.getElementById("profileTelefone").textContent = getValue("Fone1");
        document.getElementById("profileEmail").textContent = getValue("Email");
        document.getElementById("profileNascimento").textContent = getValue("DtNascimento");
        document.getElementById("profileIdade").textContent = getValue("Idade") + " anos";
        document.getElementById("profileCasamento").textContent = getValue("DtCasamento");
        document.getElementById("profileOrdenacao").textContent = getValue("DtOrdenacao");
        document.getElementById("profileParoquia").textContent = `${paroquia}${bairro ? ` - ${bairro}` : ""}`;
        document.getElementById("profileRegiao").textContent = regiao;
        document.getElementById("profileProfissao").textContent = getValue("Profissao");
        document.getElementById("profilePastoral").textContent = getValue("Pastoral");
        const simNao = valor => valor === "1" ? "Sim" : "Não";
        document.getElementById("profileTeologia").textContent = ({ "0": "Não iniciado", "1": "Concluído", "2": "Em andamento" })[perfil.flgTeologia] || "Não informado";
        document.getElementById("profileSeminarioLeitor").textContent = simNao(perfil.flgSeminarioLeitor);
        document.getElementById("profileSeminarioAcolito").textContent = simNao(perfil.flgSeminarioAcolito);
        document.getElementById("profileOrdemSacra").textContent = simNao(perfil.flgOrdemSacra);
        document.getElementById("profileLeitor").textContent = simNao(perfil.flgLeitor);
        document.getElementById("profileAcolito").textContent = simNao(perfil.flgAcolito);

        // Dados familiares
        document.getElementById("profileEsposa").textContent = getValue("NomeEsposa");
        document.getElementById("profileFoneEsposa").textContent = getValue("FoneEsposa");
        document.getElementById("profileNascEsposa").textContent = getValue("DtNascEsposa");

        // Indicadores (temporário)
        await carregarParticipacao();
        carregarResumoFormacao();
		carregarIndicadores();
    } catch (error) {
        console.error("Erro ao carregar perfil:", error);
    }
}

function carregarIndicadores() {
    // Indicadores financeiros são carregados por carregarContribuicoes().
}

async function carregarResumoFormacao() {
    try {
        const response = await fetch(`formacao_api.jsp?acao=programas&pessoa=${encodeURIComponent(window.perfilId)}`, { cache: "no-store" });
        const dados = await response.json();
        if (!response.ok || !dados.ok) throw new Error(dados.mensagem || "Erro ao carregar formação.");
        const ativos = dados.programas.filter(programa => programa.status === "ATIVO");
        const totalObrigatorias = ativos.reduce(
            (total, programa) => total + Number(programa.obrigatorias || 0), 0
        );
        const totalConcluidas = ativos.reduce(
            (total, programa) => total + Number(programa.concluidas || 0), 0
        );
        const percentual = totalObrigatorias
            ? Math.round(totalConcluidas * 100 / totalObrigatorias) : 0;
        document.getElementById("profileFormacaoTitulo").textContent = "Formações ativas";
        document.getElementById("profileFormacaoPercentual").textContent = ativos.length ? `${percentual}%` : "—";
        document.getElementById("profileFormacaoResumo").textContent = ativos.length
            ? `${totalConcluidas} de ${totalObrigatorias} obrigatórias · ${ativos.length} programa(s)`
            : "Nenhuma formação ativa";
    } catch (error) {
        console.error("Erro ao carregar resumo da formação:", error);
        document.getElementById("profileFormacaoPercentual").textContent = "—";
        document.getElementById("profileFormacaoResumo").textContent = "Grade ainda não configurada";
    }
}

function escaparHtml(valor) {
    const elemento = document.createElement("div");
    elemento.textContent = valor || "";
    return elemento.innerHTML;
}

async function carregarContribuicoes(ano = "") {
    try {
        const response = await fetch(`perfilContribuicoes.jsp?id=${encodeURIComponent(window.perfilId)}&ano=${encodeURIComponent(ano)}`, { cache: "no-store" });
        const dados = await response.json();
        if (!response.ok || !dados.ok) throw new Error(dados.mensagem || "Erro ao carregar contribuições.");
        document.getElementById("profileContribuicoes").textContent = dados.percentual + "%";
        return dados;
    } catch (error) {
        console.error("Erro ao carregar contribuições:", error);
        document.getElementById("profileContribuicoes").textContent = "0%";
        return { lancamentos: [], anos: [], anoSelecionado: "", totalAno: "R$ 0,00" };
    }
}

async function openContribuicoesModal() {
    const tbody = document.getElementById("contribuicoesTableBody");
    tbody.innerHTML = '<tr><td colspan="3">Carregando...</td></tr>';
    document.getElementById("contribuicoesModal").classList.add("show");
    const dados = await carregarContribuicoes(new Date().getFullYear());
    const select = document.getElementById("filterAnoPerfilContrib");
    select.innerHTML = dados.anos.map(ano => `<option value="${ano}">${ano}</option>`).join("") || '<option value="">Sem contribuições</option>';
    select.value = dados.anoSelecionado;
    document.getElementById("totalAnoPerfilContrib").textContent = dados.totalAno;
    const lancamentos = dados.lancamentos;
    tbody.innerHTML = lancamentos.map(l => `<tr><td>${escaparHtml(l.competencia)}</td><td>${escaparHtml(l.dataPagamento) || "-"}</td><td>${escaparHtml(l.valor)}</td></tr>`).join("") || '<tr><td colspan="3">Nenhuma contribuição encontrada.</td></tr>';
}

document.getElementById("filterAnoPerfilContrib").addEventListener("change", async event => {
    const dados = await carregarContribuicoes(event.target.value);
    document.getElementById("totalAnoPerfilContrib").textContent = dados.totalAno;
    document.getElementById("contribuicoesTableBody").innerHTML = dados.lancamentos.map(l => `<tr><td>${escaparHtml(l.competencia)}</td><td>${escaparHtml(l.dataPagamento) || "-"}</td><td>${escaparHtml(l.valor)}</td></tr>`).join("") || '<tr><td colspan="3">Nenhuma contribuição encontrada.</td></tr>';
});

function closeContribuicoesModal() {
    document.getElementById("contribuicoesModal").classList.remove("show");
}

function classePresenca(presenca) {
    if (presenca === "Presente") return "presenca-ok";
    if (presenca === "Faltou") return "presenca-falta";
    return "presenca-justificado";
}

async function obterHistoricoPresencas() {
    const response = await fetch(`membros_consulta.jsp?acao=presencas&pessoa=${encodeURIComponent(window.perfilId)}`, {
        cache: "no-store"
    });
    const dados = await response.json();
    if (!response.ok || !dados.ok) throw new Error(dados.mensagem || "Não foi possível carregar as presenças.");
    return dados.presencas;
}

function obterAnoEncontro(data) {
    const partes = String(data || "").match(/(\d{2})\/(\d{2})\/(\d{4})/);
    return partes ? Number(partes[3]) : null;
}

function resumirPresencasPorAno(encontros) {
    const resumos = new Map();

    encontros.forEach(encontro => {
        const ano = obterAnoEncontro(encontro.data);
        if (!ano) return;

        if (!resumos.has(ano)) {
            resumos.set(ano, {
                ano,
                encontros: 0,
                presencas: 0,
                faltas: 0,
                justificativas: 0
            });
        }

        const resumo = resumos.get(ano);
        resumo.encontros++;
        if (encontro.presenca === "Presente") resumo.presencas++;
        else if (encontro.presenca === "Justificado") resumo.justificativas++;
        else resumo.faltas++;
    });

    return [...resumos.values()]
        .map(resumo => ({
            ...resumo,
            percentual: resumo.encontros > 0
                ? Math.round((resumo.presencas / resumo.encontros) * 100)
                : 0
        }))
        .sort((a, b) => b.ano - a.ano);
}

function atualizarCardParticipacao(encontros) {
    const anoAtual = new Date().getFullYear();
    const resumoAtual = resumirPresencasPorAno(encontros).find(item => item.ano === anoAtual);
    document.getElementById("profileParticipacao").textContent = `${resumoAtual?.percentual || 0}%`;
}

async function carregarUltimosEncontros() {
    const tbody = document.getElementById("profileEncontros");

    try {
        const encontros = await obterHistoricoPresencas();
        const resumos = resumirPresencasPorAno(encontros);
        atualizarCardParticipacao(encontros);

        if (resumos.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6">Nenhum encontro encontrado.</td></tr>';
            return;
        }

        tbody.innerHTML = resumos.map(resumo => `
                <tr>
                    <td>${resumo.ano}</td>
                    <td>${resumo.encontros}</td>
                    <td><strong>${resumo.percentual}%</strong></td>
                    <td class="presenca-ok">${resumo.presencas}</td>
                    <td class="presenca-falta">${resumo.faltas}</td>
                    <td class="presenca-justificado">${resumo.justificativas}</td>
                </tr>`).join("");
    } catch (error) {
        console.error("Erro ao carregar resumo dos encontros:", error);
        tbody.innerHTML = '<tr><td colspan="6">Não foi possível carregar os encontros.</td></tr>';
    }
}

async function atualizarPresenca(idEncontro, flgPresenca, justificativa = "") {
    const dados = new URLSearchParams({
        idPessoa: window.perfilId,
        idEncontro,
        flgPresenca,
        justificativa
    });

    const response = await fetch("atualizarPresenca.jsp", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8" },
        body: dados.toString()
    });

    const resultado = await response.json();
    if (!response.ok || !resultado.ok) {
        throw new Error(resultado.mensagem || "Não foi possível atualizar a presença.");
    }
}

document.getElementById("presencasTableBody").addEventListener("click", async event => {
    const botao = event.target.closest("[data-acao-presenca]");
    if (!botao || window.usuarioPerfil !== "ADM") return;

    const { acaoPresenca, encontroId } = botao.dataset;
    let justificativa = "";
    let flgPresenca = "1";

    if (acaoPresenca === "justificar") {
        justificativa = window.prompt("Informe a justificativa da ausência:", "");
        if (justificativa === null) return;
        justificativa = justificativa.trim();
        if (!justificativa) {
            alert("Informe a justificativa para registrar a ausência.");
            return;
        }
        flgPresenca = "2";
    }

    try {
        botao.disabled = true;
        await atualizarPresenca(encontroId, flgPresenca, justificativa);
        await carregarUltimosEncontros();
        await carregarDetalhesPresencas(document.getElementById("filterAnoPerfilPresenca").value);
    } catch (error) {
        console.error("Erro ao atualizar presença:", error);
        alert(error.message);
        botao.disabled = false;
    }
});



async function carregarDetalhesPresencas(anoSelecionado) {
    try {
        const encontros = await obterHistoricoPresencas();
        const resumos = resumirPresencasPorAno(encontros);
        const anoAtual = new Date().getFullYear();
        const anos = [...new Set([anoAtual, ...resumos.map(item => item.ano)])].sort((a, b) => b - a);
        const ano = Number(anoSelecionado) || anoAtual;
        const seletor = document.getElementById("filterAnoPerfilPresenca");
        const tbody = document.getElementById("presencasTableBody");
        const isAdmin = window.usuarioPerfil === "ADM";

        seletor.innerHTML = anos.map(item => `<option value="${item}" ${item === ano ? "selected" : ""}>${item}</option>`).join("");

        const encontrosAno = encontros.filter(encontro => obterAnoEncontro(encontro.data) === ano);
        const resumoAno = resumos.find(item => item.ano === ano);
        document.getElementById("percentualAnoPerfilPresenca").textContent = `${resumoAno?.percentual || 0}%`;
        atualizarCardParticipacao(encontros);

        if (encontrosAno.length === 0) {
            tbody.innerHTML = `<tr><td colspan="${isAdmin ? 5 : 4}">Nenhum encontro encontrado neste ano.</td></tr>`;
            return;
        }

        tbody.innerHTML = encontrosAno.map(encontro => {
            const acoes = isAdmin && encontro.presenca === "Faltou"
                ? `<td class="text-nowrap">
                    <button type="button" class="btn btn-sm btn-success me-1" data-acao-presenca="presente" data-encontro-id="${escaparHtml(encontro.idEncontro)}">Registrar presença</button>
                    <button type="button" class="btn btn-sm btn-outline-secondary" data-acao-presenca="justificar" data-encontro-id="${escaparHtml(encontro.idEncontro)}">Justificar</button>
                   </td>`
                : (isAdmin ? "<td>-</td>" : "");

            return `
                <tr>
                    <td>${escaparHtml(encontro.data)}</td>
                    <td>${escaparHtml(encontro.descricao)}</td>
                    <td class="${classePresenca(encontro.presenca)}">${escaparHtml(encontro.presenca)}</td>
                    <td>${escaparHtml(encontro.justificativa) || "-"}</td>
                    ${acoes}
                </tr>
            `;
        }).join("");
    } catch (error) {
        console.error("Erro ao carregar presenças:", error);
        const isAdmin = window.usuarioPerfil === "ADM";
        document.getElementById("presencasTableBody").innerHTML = `<tr><td colspan="${isAdmin ? 5 : 4}">Não foi possível carregar os encontros.</td></tr>`;
    }
}

async function openPresencasModal() {
    document.getElementById("presencasModal").classList.add("show");
    await carregarDetalhesPresencas(new Date().getFullYear());
}

function closePresencasModal() {
    document.getElementById("presencasModal").classList.remove("show");
}

document.addEventListener("click", function(e) {
    const modal = document.getElementById("presencasModal");

    if (e.target === modal) {
        closePresencasModal();
    }
});


document.getElementById("filterAnoPerfilPresenca").addEventListener("change", event => {
    carregarDetalhesPresencas(event.target.value);
});

async function carregarParticipacao() {
    const encontros = await obterHistoricoPresencas();
    atualizarCardParticipacao(encontros);
}

function dataLocalHoje() {
    const agora = new Date();
    const ano = agora.getFullYear();
    const mes = String(agora.getMonth() + 1).padStart(2, "0");
    const dia = String(agora.getDate()).padStart(2, "0");
    return `${ano}-${mes}-${dia}`;
}

let transicoesMovimentacao = [];

function atualizarRegrasMovimentacao() {
    const tipo = document.getElementById("movimentacaoTipo");
    if (!tipo) return;
    const transicao = transicoesMovimentacao.find(item => `TRANSICAO:${item.id}` === tipo.value);
    const mensagens = { INATIVACAO: "O membro será inativado e a descrição substituirá o campo de observações do cadastro.", OBSERVACAO: "A observação será registrada somente no histórico, sem alterar o cadastro do membro." };
    document.getElementById("movimentacaoRegra").textContent = transicao ? (transicao.efeito || `O membro passará para ${transicao.destinoNome}.`) : (mensagens[tipo.value] || "Selecione uma ação compatível com o grupo atual.");
    const motivo = document.getElementById("movimentacaoMotivo");
    motivo.required = tipo.value === "INATIVACAO" || tipo.value === "OBSERVACAO" || !!transicao?.exigeMotivo;
    document.getElementById("movimentacaoMotivoAjuda").textContent = motivo.required
        ? "Campo obrigatório para esta movimentação."
        : "Use este campo para complementar o histórico da movimentação.";
}

async function openMovimentacaoModal() {
    const modal = document.getElementById("movimentacaoModal");
    if (!modal || window.usuarioPerfil !== "ADM") return;

    document.getElementById("movimentacaoForm").reset();
    document.getElementById("movimentacaoNome").value = perfil.nome || "";
    document.getElementById("movimentacaoGrupo").value = perfil.grupo || "";
    document.getElementById("movimentacaoTurma").value = perfil.turma || "Não informada";
    document.getElementById("movimentacaoData").value = dataLocalHoje();
    const alerta = document.getElementById("movimentacaoAlerta");
    alerta.className = "alert d-none";
    alerta.textContent = "";
    try {
        const resposta = await fetch(`movimentacao_membro.jsp?idPessoa=${encodeURIComponent(window.perfilId)}`, { cache: "no-store" });
        const dados = await resposta.json();
        if (!resposta.ok || !dados.ok) throw new Error(dados.mensagem || "Não foi possível carregar as transições.");
        transicoesMovimentacao = dados.transicoes || [];
        document.getElementById("movimentacaoTipo").innerHTML = ['<option value="">Selecione...</option>']
            .concat(transicoesMovimentacao.map(item => `<option value="TRANSICAO:${item.id}">${escaparHtml(item.acao)} → ${escaparHtml(item.destinoNome)}</option>`))
            .concat(['<option value="INATIVACAO">Inativar Membro</option>', '<option value="OBSERVACAO">Observação</option>']).join("");
    } catch (erro) {
        alerta.className = "alert alert-danger";
        alerta.textContent = erro.message;
    }
    atualizarRegrasMovimentacao();
    modal.classList.add("show");
}

function closeMovimentacaoModal() {
    document.getElementById("movimentacaoModal")?.classList.remove("show");
}

const movimentacaoTipo = document.getElementById("movimentacaoTipo");
if (movimentacaoTipo) {
    movimentacaoTipo.addEventListener("change", atualizarRegrasMovimentacao);
    document.getElementById("movimentacaoForm").addEventListener("submit", async event => {
        event.preventDefault();
        const tipo = movimentacaoTipo.value;
        const motivo = document.getElementById("movimentacaoMotivo").value.trim();
        const dataMovimentacao = document.getElementById("movimentacaoData").value;
        const alerta = document.getElementById("movimentacaoAlerta");
        const botao = document.getElementById("salvarMovimentacaoBtn");
        const transicao = transicoesMovimentacao.find(item => `TRANSICAO:${item.id}` === tipo);

        if (!tipo || !dataMovimentacao || ((tipo === "INATIVACAO" || tipo === "OBSERVACAO" || transicao?.exigeMotivo) && !motivo)) {
            alerta.className = "alert alert-warning";
            alerta.textContent = "Preencha os campos obrigatórios da movimentação.";
            return;
        }

        try {
            botao.disabled = true;
            const resposta = await fetch("movimentacao_membro.jsp", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8" },
                body: new URLSearchParams({
                    idPessoa: window.perfilId,
                    tipo,
                    transicaoId: transicao?.id || "",
                    dataMovimentacao,
                    motivo
                }).toString()
            });
            const resultado = await resposta.json();
            if (!resposta.ok || !resultado.ok) throw new Error(resultado.mensagem || "Não foi possível registrar a movimentação.");

            alerta.className = "alert alert-success";
            alerta.textContent = resultado.mensagem;
            setTimeout(() => window.location.reload(), 700);
        } catch (erro) {
            alerta.className = "alert alert-danger";
            alerta.textContent = erro.message;
            botao.disabled = false;
        }
    });
}

function nomeTipoMovimentacao(tipo) {
    return ({
        TRANSICAO: "Transição de grupo",
        INATIVACAO: "Inativação",
        OBSERVACAO: "Observação"
    })[tipo] || tipo;
}

async function carregarHistoricoMovimentacoes() {
    const tbody = document.getElementById("historicoMovimentacoesBody");
    if (!tbody || window.usuarioPerfil !== "ADM") return;

    try {
        const resposta = await fetch(`historico_movimentacoes.jsp?idPessoa=${encodeURIComponent(window.perfilId)}`, { cache: "no-store" });
        const resultado = await resposta.json();
        if (!resposta.ok || !resultado.ok) throw new Error(resultado.mensagem || "Não foi possível carregar o histórico.");

        if (!resultado.movimentacoes.length) {
            tbody.innerHTML = '<tr><td colspan="6" class="text-muted">Nenhuma movimentação registrada para este membro.</td></tr>';
            return;
        }

        tbody.innerHTML = resultado.movimentacoes.map(item => `
            <tr>
                <td class="text-nowrap">${escaparHtml(item.data)}</td>
                <td><span class="badge text-bg-secondary">${escaparHtml(nomeTipoMovimentacao(item.tipo))}</span></td>
                <td>${escaparHtml(item.movimentacao)}</td>
                <td style="min-width: 220px; white-space: pre-line">${escaparHtml(item.motivo) || "-"}</td>
                <td>${escaparHtml(item.usuario)}</td>
                <td class="text-nowrap">${escaparHtml(item.dataRegistro)}</td>
            </tr>`).join("");
    } catch (erro) {
        console.error("Erro ao carregar histórico de movimentações:", erro);
        tbody.innerHTML = `<tr><td colspan="6" class="text-danger">${escaparHtml(erro.message)}</td></tr>`;
    }
}

function openEditProfileModal() {

    // Dados pessoais
    $("editNome").value = perfil.nome;
    $("editTelefone").value = perfil.telefone;
    $("editTelefone2").value = perfil.telefone2;
    $("editEmail").value = perfil.email;

    $("editNascimento").value =
        dataParaInput(perfil.nascimento);

    $("editProfissao").value =
        perfil.profissao;

    $("editPastoral").value =
        perfil.pastoral;

    $("editClasse").value =
        perfil.grupo;

    $("editMatricula").value =
        perfil.matricula;

    $("editTurma").value =
        perfil.turma;

    // Dados familiares

    $("editEsposa").value =
        perfil.esposa;

    $("editFoneEsposa").value =
        perfil.foneEsposa;

    $("editProfissaoEsposa").value =
        perfil.profissaoEsposa;

    $("editNascEsposa").value =
        dataParaInput(perfil.nascEsposa);

    $("editCasamento").value =
        dataParaInput(perfil.casamento);

    // Dados ministeriais

    $("editParoquiaId").value =
        perfil.paroquiaId;

    $("editParoquiaNome").value =
        perfil.paroquia;

    $("editBairro").value =
        perfil.bairro;

    $("editRegiao").value =
        perfil.regiao;

    $("editOrdenacao").value =
        dataParaInput(perfil.ordenacao);

    $("editProvisao").value =
        dataParaInput(perfil.provisao);

    $("editBispo").value =
        perfil.bispo;
    $("editTeologia").value = perfil.flgTeologia || "0";
    $("editSeminarioLeitor").value = perfil.flgSeminarioLeitor || "0";
    $("editSeminarioAcolito").value = perfil.flgSeminarioAcolito || "0";
    $("editOrdemSacra").value = perfil.flgOrdemSacra || "0";
    $("editLeitor").value = perfil.flgLeitor || "0";
    $("editAcolito").value = perfil.flgAcolito || "0";
    document.querySelectorAll("#ministerialFields input, #ministerialFields select, #ministerialFields button")
        .forEach(campo => campo.disabled = window.usuarioPerfil !== "ADM");

    // Observações

    if ($("editObs"))
        $("editObs").value = perfil.obs;

    document
        .getElementById("editProfileModal")
        .classList.add("show");
}

function closeEditProfileModal() {
    document.getElementById("editProfileModal").classList.remove("show");
}

let paroquias = [];
let paroquiasExibidas = [];

function openParoquiasModal() {
    document.getElementById("paroquiasModal").classList.add("show");
    carregarParoquias();
}

function closeParoquiasModal() {
    document.getElementById("paroquiasModal").classList.remove("show");
}

function renderParoquias(lista) {
    const container = document.getElementById("paroquiasContainer");
    container.innerHTML = "";
    paroquiasExibidas = lista;

    lista.forEach((p, indice) => {
        container.innerHTML += `
            <div class="paroquia-card" data-selecionar-paroquia="${indice}">
                <div class="paroquia-nome">${escaparHtml(p.nome)}${p.bairro ? ` - ${escaparHtml(p.bairro)}` : ""}</div>
                <div class="paroquia-regiao">${escaparHtml(p.regiao)}</div>
            </div>
        `;
    });
}

function filtrarParoquias() {
    const termo = document.getElementById("searchParoquia").value.toLowerCase();

    const filtradas = paroquias.filter(p =>
        p.nome.toLowerCase().includes(termo) ||
        p.bairro.toLowerCase().includes(termo) ||
        p.regiao.toLowerCase().includes(termo)
    );

    renderParoquias(filtradas);
}

function selecionarParoquia(paroquia) {
    document.getElementById("editParoquiaId").value = paroquia.id;
    document.getElementById("editParoquiaNome").value = paroquia.nome;
    document.getElementById("editBairro").value = paroquia.bairro;
    document.getElementById("editRegiao").value = paroquia.regiao;
    closeParoquiasModal();
}

async function carregarParoquias() {
    try {
        if (paroquias.length > 0) {
            renderParoquias(paroquias);
            return;
        }

        const response = await fetch('membros_consulta.jsp?acao=paroquias', { cache: "no-store" });
        const dados = await response.json();
        if (!response.ok || !dados.ok) throw new Error(dados.mensagem || "Não foi possível carregar as paróquias.");
        paroquias = dados.paroquias;

        renderParoquias(paroquias);

    } catch(error) {
        console.error("Erro ao carregar paróquias:", error);
    }
}


function dataParaInput(dataBR) {

    if (!dataBR || dataBR.trim() === "")
        return "";

    const partes = dataBR.split("/");

    if (partes.length !== 3)
        return "";

    return `${partes[2]}-${partes[1]}-${partes[0]}`;
}

function inputParaData(dataISO) {

    if (!dataISO) return "";

    const p = dataISO.split("-");

    if (p.length !== 3) return "";

    return `${p[2]}/${p[1]}/${p[0]}`;
}


function obterDadosFormulario() {

    return {

        id: window.perfilId,

        // Dados pessoais
        nome: $("editNome").value.trim(),
        telefone: $("editTelefone").value.trim(),
        telefone2: $("editTelefone2").value.trim(),
        email: $("editEmail").value.trim(),
        nascimento: $("editNascimento").value,
        profissao: $("editProfissao").value.trim(),
        pastoral: $("editPastoral").value.trim(),

        // Dados familiares
        esposa: $("editEsposa").value.trim(),
        foneEsposa: $("editFoneEsposa").value.trim(),
        profissaoEsposa: $("editProfissaoEsposa").value.trim(),
        nascEsposa: $("editNascEsposa").value,
        casamento: $("editCasamento").value,

        // Dados ministeriais
        paroquiaId: $("editParoquiaId").value,
        turma: $("editTurma").value.trim(),
        ordenacao: $("editOrdenacao").value,
        provisao: $("editProvisao").value,
        bispo: $("editBispo").value.trim(),
        flgTeologia: $("editTeologia").value,
        flgSeminarioLeitor: $("editSeminarioLeitor").value,
        flgSeminarioAcolito: $("editSeminarioAcolito").value,
        flgOrdemSacra: $("editOrdemSacra").value,
        flgLeitor: $("editLeitor").value,
        flgAcolito: $("editAcolito").value,

        // Observações
        obs: $("editObs") ? $("editObs").value.trim() : ""

    };

}

async function salvarPerfil() {

    const dados = obterDadosFormulario();

    const form = new URLSearchParams();

    Object.keys(dados).forEach(chave => {
        form.append(chave, dados[chave] ?? "");
    });

    try {

        const response = await fetch(
            `save_membro.jsp?id=${encodeURIComponent(window.perfilId)}`,
            {
                method: "POST",
                headers: {
                    "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"
                },
                body: form.toString()
            }
        );

        const resultado = await response.text();

        console.log(resultado);

        if(resultado.trim() === "OK"){

            alert("Dados atualizados com sucesso.");

            closeEditProfileModal();

            window.location.reload();

        }else{

            alert(resultado);

        }

    }catch(e){

        console.error(e);

        alert("Erro ao gravar os dados.");

    }

}

async function carregarArquivosMembro() {
    const card = document.getElementById("arquivosMembroCard");
    if (!card) return;
    try {
        const resposta = await fetch(`documentacao_api.jsp?acao=arquivosPerfil&pessoa=${encodeURIComponent(window.perfilId)}`, { cache: "no-store" });
        const dados = await resposta.json();
        if (!resposta.ok || !dados.ok) throw new Error(dados.mensagem || "Não foi possível carregar os arquivos.");
        if (!dados.arquivos.length) return;
        card.classList.remove("d-none");
        document.getElementById("arquivosMembroTotal").textContent = dados.arquivos.length;
        document.getElementById("arquivosMembroLista").innerHTML = dados.arquivos.map(arquivo => `<a class="list-group-item list-group-item-action d-flex justify-content-between align-items-center gap-3 flex-wrap" href="${escaparHtml(arquivo.url)}" target="_blank"><div><strong>${escaparHtml(arquivo.descricao)}</strong><small class="d-block text-muted">${escaparHtml(arquivo.checklist)} · Enviado em ${escaparHtml(arquivo.data)}</small></div><span class="text-nowrap"><i class="bi bi-file-earmark-arrow-down"></i> ${escaparHtml(arquivo.nome)} <small class="text-muted">(${(arquivo.tamanho/1024).toLocaleString("pt-BR",{maximumFractionDigits:1})} KB)</small></span></a>`).join("");
    } catch (erro) { console.error("Erro ao carregar arquivos do membro:", erro); }
}

carregarPerfil();
carregarContribuicoes();
carregarUltimosEncontros();
carregarHistoricoMovimentacoes();
carregarArquivosMembro();

const trocarFotoBtn = document.getElementById("trocarFotoBtn");
const trocarFotoInput = document.getElementById("trocarFotoInput");
if (trocarFotoBtn && trocarFotoInput) {
    trocarFotoBtn.addEventListener("click", () => trocarFotoInput.click());
    trocarFotoInput.addEventListener("change", async () => {
        const arquivo = trocarFotoInput.files[0];
        if (!arquivo) return;
        if (!arquivo.type.startsWith("image/")) { alert("Selecione um arquivo de imagem válido."); return; }
        if (arquivo.size > 5 * 1024 * 1024) { alert("A imagem deve ter no máximo 5 MB."); return; }
        const dados = new FormData();
        dados.append("idPessoa", String(window.perfilId));
        dados.append("nome", perfil.nome || "");
        dados.append("ajax", "1");
        dados.append("foto", arquivo);
        trocarFotoBtn.disabled = true;
        try {
            const resposta = await fetch("UploadFotoServlet", { method: "POST", body: dados });
            const resultado = await resposta.json();
            if (!resposta.ok || !resultado.ok) throw new Error(resultado.mensagem || "Não foi possível alterar a foto.");
            const foto = document.getElementById("profileFoto");
            foto.src = `${resultado.foto}?v=${Date.now()}`;
            foto.style.display = "block";
            document.getElementById("profileAvatar").style.display = "none";
        } catch (erro) {
            alert(erro.message);
        } finally {
            trocarFotoBtn.disabled = false;
            trocarFotoInput.value = "";
        }
    });
}

document.getElementById("paroquiasContainer").addEventListener("click", event => {
    const card = event.target.closest("[data-selecionar-paroquia]");
    if (!card) return;
    selecionarParoquia(paroquiasExibidas[Number(card.dataset.selecionarParoquia)]);
});

// Ampliação da foto atual, incluindo fotos recém-atualizadas.
(() => {
    const foto = document.getElementById("profileFoto");
    const elementoModal = document.getElementById("modalFotoPerfil");
    if (!foto || !elementoModal) return;
    const modalFoto = new bootstrap.Modal(elementoModal);
    function ampliarFoto() {
        if (!foto.complete || !foto.naturalWidth || foto.style.display === "none") return;
        const nome = document.getElementById("profileNome").textContent.trim();
        const titulo = nome ? `Foto de ${nome}` : "Foto do perfil";
        const ampliada = document.getElementById("fotoPerfilAmpliada");
        ampliada.src = foto.currentSrc || foto.src;
        ampliada.alt = titulo;
        document.getElementById("tituloFotoPerfil").textContent = titulo;
        modalFoto.show();
    }
    foto.addEventListener("click", ampliarFoto);
    foto.addEventListener("keydown", event => {
        if (event.key === "Enter" || event.key === " ") {
            event.preventDefault();
            ampliarFoto();
        }
    });
    elementoModal.addEventListener("hidden.bs.modal", () => {
        document.getElementById("fotoPerfilAmpliada").removeAttribute("src");
        foto.focus();
    });
})();