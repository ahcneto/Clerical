(() => {
    const state = { ciclos: [], ciclo: null, pessoa: null, avaliacoes: [] };
    const $ = id => document.getElementById(id);
    const modal = new bootstrap.Modal($("modalCiclo"));
    const modalIndicadores = new bootstrap.Modal($("modalIndicadores"));
    const modalFoto = new bootstrap.Modal($("modalFotoAvaliado"));
    let botaoFotoOrigem = null;
    $("pessoaCabecalho").addEventListener("click", event => {
        const botao = event.target.closest(".evaluation-photo-button");
        if (!botao) return;
        const foto = botao.querySelector("img");
        if (!foto.complete || !foto.naturalWidth) return;
        botaoFotoOrigem = botao;
        $("fotoAvaliadoAmpliada").src = foto.currentSrc || foto.src;
        $("fotoAvaliadoAmpliada").alt = foto.alt;
        $("tituloFotoAvaliado").textContent = foto.alt;
        modalFoto.show();
    });
    $("modalFotoAvaliado").addEventListener("hidden.bs.modal", () => {
        $("fotoAvaliadoAmpliada").removeAttribute("src");
        if (botaoFotoOrigem && botaoFotoOrigem.isConnected) botaoFotoOrigem.focus();
        botaoFotoOrigem = null;
    });
    const esc = value => String(value ?? "").replace(/[&<>"']/g, char => ({ "&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#039;" })[char]);
    const grupoTag = () => "";

    async function api(acao, options = {}) {
        const query = new URLSearchParams({ acao, ...(options.params || {}) });
        const init = options.body ? {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8" },
            body: new URLSearchParams(options.body)
        } : {};
        const response = await fetch(`avaliacoes_api.jsp?${query}`, init);
        let data;
        try { data = await response.json(); } catch (_) { data = { ok: false, mensagem: "Resposta inválida do servidor." }; }
        if (!response.ok || !data.ok) throw new Error(data.mensagem || "Não foi possível concluir a operação.");
        return data;
    }

    async function carregarResumoFormacaoAvaliacao(pessoa) {
        $("percentualFormacao").textContent = "…";
        try {
            const response = await fetch(`formacao_api.jsp?acao=programas&pessoa=${encodeURIComponent(pessoa)}`, { cache: "no-store" });
            const dados = await response.json();
            if (!response.ok || !dados.ok) throw new Error(dados.mensagem || "Erro ao carregar formação.");
            const ativos = dados.programas.filter(programa => programa.status === "ATIVO");
            const total = ativos.reduce((soma, programa) => soma + Number(programa.obrigatorias || 0), 0);
            const concluidas = ativos.reduce((soma, programa) => soma + Number(programa.concluidas || 0), 0);
            $("percentualFormacao").textContent = ativos.length
                ? `${total ? Math.round(concluidas * 100 / total) : 0}%`
                : "—";
        } catch (error) {
            console.error("Erro ao carregar formação na avaliação:", error);
            $("percentualFormacao").textContent = "—";
        }
    }

    function alertar(message, type = "danger") {
        const box = $("alerta");
        box.className = `alert alert-${type}`;
        box.textContent = message;
        box.scrollIntoView({ behavior: "smooth", block: "start" });
        window.setTimeout(() => box.classList.add("d-none"), 5000);
    }

    function mostrar(tela) {
        ["telaCiclos", "telaMembros", "telaPessoa"].forEach(id => $(id).classList.toggle("d-none", id !== tela));
        window.scrollTo({ top: 0, behavior: "smooth" });
    }

    async function carregarCiclos() {
        $("listaCiclos").innerHTML = '<div class="col-12 text-muted">Carregando ciclos...</div>';
        try {
            const data = await api("ciclos");
            state.ciclos = data.ciclos;
            const anoSelecionado = $("filtroAnoCiclo").value;
            const anos = [...new Set(data.ciclos.map(c => c.data.slice(0, 4)))].sort((a, b) => b.localeCompare(a));
            $("filtroAnoCiclo").innerHTML = '<option value="">Todos os anos</option>' + anos.map(ano => `<option value="${ano}">${ano}</option>`).join("");
            if (anos.includes(anoSelecionado)) $("filtroAnoCiclo").value = anoSelecionado;
            renderCiclos();
        } catch (e) { $("listaCiclos").innerHTML = ""; alertar(e.message); }
    }

    function renderCiclos() {
        const ano = $("filtroAnoCiclo").value;
        const classe = $("filtroGrupoCiclo").value;
        const ciclos = state.ciclos.filter(c => (!ano || c.data.startsWith(ano)) && (!classe || c.classe === Number(classe)));
        $("listaCiclos").innerHTML = ciclos.length ? ciclos.map(c => `
                <div class="col-md-6 col-xl-4">
                    <article class="cycle-card" data-ciclo="${c.id}" tabindex="0" role="button">
                        <div class="d-flex justify-content-between gap-2 mb-3">
                            <span class="cycle-date"><i class="bi bi-calendar3"></i> ${esc(c.dataFormatada)}</span>
                            <span class="badge-tag ${grupoTag(c.classe)}">${esc(c.grupo)}</span>
                        </div>
                        <h4>${esc(c.descricao)}</h4>
                        <div class="text-muted mt-3"><i class="bi bi-people"></i> ${c.avaliados} de ${c.total} avaliados</div>
                        <div class="progress mt-2" style="height:6px"><div class="progress-bar bg-success" style="width:${c.total ? Math.round(c.avaliados * 100 / c.total) : 0}%"></div></div>
                    </article>
                </div>`).join("") : '<div class="col-12"><div class="evaluation-panel text-center text-muted py-5"><i class="bi bi-clipboard2 fs-1 d-block mb-2"></i>Nenhum ciclo encontrado para os filtros selecionados.</div></div>';
    }

    async function carregarRegioes() {
        try {
            const data = await api("regioes");
            $("filtroRegiao").innerHTML = '<option value="">Todas as regiões</option>' + data.regioes.map(r => `<option value="${r.id}">${esc(r.nome)}</option>`).join("");
        } catch (e) { alertar(e.message); }
    }

    async function abrirCiclo(id) {
        state.ciclo = state.ciclos.find(c => c.id === Number(id)) || { id: Number(id) };
        mostrar("telaMembros");
        $("filtroNome").value = "";
        $("filtroRegiao").value = "";
        $("filtroSituacao").value = "";
        await carregarMembros();
    }

    async function carregarMembros() {
        $("listaMembros").innerHTML = '<div class="col-12 text-muted">Carregando membros...</div>';
        try {
            const data = await api("membros", { params: { ciclo: state.ciclo.id, nome: $("filtroNome").value, regiao: $("filtroRegiao").value, situacao: $("filtroSituacao").value } });
            state.ciclo = data.ciclo;
            $("cicloTitulo").textContent = data.ciclo.descricao;
            $("cicloResumo").textContent = `${data.ciclo.dataFormatada} · ${data.ciclo.grupo}`;
            $("totalMembros").textContent = `${data.membros.length} membro${data.membros.length === 1 ? "" : "s"} encontrado${data.membros.length === 1 ? "" : "s"}`;
            $("listaMembros").innerHTML = data.membros.length ? data.membros.map(m => `
                <div class="col-md-6">
                    <article class="evaluation-member-card d-flex align-items-center gap-3" data-pessoa="${m.id}" tabindex="0" role="button">
                        <img src="fotos/foto_${m.id}.jpg" class="evaluation-member-photo" alt="" onerror="this.classList.add('d-none');this.nextElementSibling.classList.remove('d-none')">
                        <span class="evaluation-avatar d-none">${esc(m.nome.charAt(0))}</span>
                        <div class="flex-grow-1"><h5 class="mb-1">${esc(m.nome)}</h5><div class="text-muted small">${esc(m.paroquia || "Paróquia não informada")} · ${esc(m.regiao || "Região não informada")}</div></div>
                        <span class="badge ${m.avaliado ? "text-bg-success" : "text-bg-secondary"}">${m.avaliado ? "Avaliado" : "Pendente"}</span>
                    </article>
                </div>`).join("") : '<div class="col-12"><div class="evaluation-panel text-center text-muted">Nenhum membro encontrado.</div></div>';
        } catch (e) { $("listaMembros").innerHTML = ""; alertar(e.message); }
    }

    async function abrirPessoa(id) {
        mostrar("telaPessoa");
        try {
            const data = await api("pessoa", { params: { ciclo: state.ciclo.id, pessoa: id } });
            state.pessoa = data.pessoa;
            state.avaliacoes = data.avaliacoes;
            const ministerial = data.pessoa.ministerial;
            const indicador = (rotulo, valor) => `<div class="ministerial-item"><i class="bi ${valor ? "bi-check-circle-fill text-success" : "bi-dash-circle text-secondary"}"></i><span>${esc(rotulo)}</span></div>`;
            $("pessoaCabecalho").innerHTML = `<div class="d-flex align-items-center gap-4 flex-wrap">
                <button type="button" class="evaluation-photo-button" title="Clique para ampliar" aria-label="Ampliar foto de ${esc(data.pessoa.nome)}">
                    <img src="fotos/foto_${data.pessoa.id}.jpg" class="evaluation-person-photo" alt="Foto de ${esc(data.pessoa.nome)}" onerror="this.parentElement.classList.add('d-none');this.parentElement.nextElementSibling.classList.remove('d-none')">
                </button>
                <span class="evaluation-avatar d-none" style="width:108px;height:108px;font-size:2rem">${esc(data.pessoa.nome.charAt(0))}</span>
                <div><h2 class="fw-bold mb-2">${esc(data.pessoa.nome)}</h2>
                <div class="person-detail-lines text-muted">
                    <div><i class="bi bi-cake2"></i><span>${esc(data.pessoa.nascimento || "Não informada")} (${esc(data.pessoa.idade || "—")} anos)</span></div>
                    <div><i class="bi bi-heart-fill"></i><span>${data.pessoa.casamento ? `Casamento: ${esc(data.pessoa.casamento)} · ${data.pessoa.anosMatrimonio} ${data.pessoa.anosMatrimonio === 1 ? "ano" : "anos"} de matrimônio` : "Casamento não informado"}</span></div>
                    <div><i class="bi bi-geo-alt"></i><span>${esc(data.pessoa.paroquia || "Paróquia não informada")} · ${esc(data.pessoa.regiao || "Região não informada")}</span></div>
                    <div><i class="bi bi-briefcase"></i><span>${esc(data.pessoa.profissao || "Profissão não informada")}</span></div>
                </div></div></div>
                <hr class="my-4">
                <h5 class="mb-3"><i class="bi bi-person-badge"></i> Informações ministeriais</h5>
                <div class="ministerial-grid">
                    ${indicador("Teologia", ministerial.teologia)}
                    ${indicador("Seminário de Leitor", ministerial.seminarioLeitor)}
                    ${indicador("Seminário de Acólito", ministerial.seminarioAcolito)}
                    ${indicador("Ordens Sacras", ministerial.ordemSacra)}
                    ${indicador("Ministério de Leitor", ministerial.leitor)}
                    ${indicador("Ministério de Acólito", ministerial.acolito)}
                    <div class="ministerial-item"><i class="bi bi-calendar-check text-secondary"></i><span><strong>Ordenação:</strong> ${esc(ministerial.dataOrdenacao || "Não informada")}</span></div>
                    <div class="ministerial-item"><i class="bi bi-calendar-check text-secondary"></i><span><strong>Provisão:</strong> ${esc(ministerial.dataProvisao || "Não informada")}</span></div>
                </div>
                <div class="pastoral-line"><i class="bi bi-heart"></i><div><strong>Pastoral</strong><div class="text-muted">${esc(ministerial.pastoral || "Não informada")}</div></div></div>`;
            renderHistorico();
            const anoAvaliacao = String(data.ciclo.data).slice(0, 4);
            $("anoIndicadores").textContent = anoAvaliacao;
            await carregarIndicadores(anoAvaliacao, false);
            await carregarResumoFormacaoAvaliacao(data.pessoa.id);
            const atual = data.avaliacoes.find(a => a.idCiclo === state.ciclo.id);
            atual ? editarAvaliacao(atual) : limparAvaliacao();
        } catch (e) { alertar(e.message); }
    }

    function renderHistorico() {
        $("historicoAvaliacoes").innerHTML = state.avaliacoes.length ? state.avaliacoes.map(a => `
            <article class="history-item result-${a.resultado}">
                <div class="d-flex justify-content-between gap-2"><strong>${esc(a.dataFormatada)}</strong><span class="badge text-bg-light">${resultadoLabel(a.resultado)}</span></div>
                <div class="small text-muted mb-2">${esc(a.ciclo)} · <i class="bi bi-people"></i> ${esc(a.grupo)}</div><div class="history-text">${esc(a.texto)}</div>
                ${a.acao ? `<div class="action-box mt-3 small"><strong>Ação:</strong> ${esc(a.acao)}<br><strong>Responsável:</strong> ${esc(a.responsavel || "Não informado")}<br><strong>Status:</strong> ${a.status === "CONCLUIDA" ? "Concluída" : "Pendente"}</div>` : ""}
                ${a.idCiclo === state.ciclo.id && !window.avaliacoesSomenteLeitura ? `<button class="btn btn-sm btn-outline-secondary mt-3" data-editar-avaliacao="${a.id}"><i class="bi bi-pencil"></i> Editar</button>` : ""}
            </article>`).join("") : '<p class="text-muted">Esta pessoa ainda não possui avaliações.</p>';
    }

    function resultadoLabel(value) { return value === "POSITIVA" ? "Positiva" : value === "NEGATIVA" ? "Negativa" : "Neutra"; }
    async function carregarIndicadores(ano, detalhar) {
        if (!detalhar) {
            $("percentualPresenca").textContent = "…";
            $("percentualContribuicao").textContent = "…";
        }
        try {
            const dados = await api("indicadores", { params: { pessoa: state.pessoa.id, ano } });
            if (!detalhar) {
                $("percentualPresenca").textContent = `${dados.percentualPresenca}%`;
                $("percentualContribuicao").textContent = `${dados.percentualContribuicao}%`;
                return;
            }
            $("modalPercentualPresenca").textContent = `${dados.percentualPresenca}%`;
            $("modalPercentualContribuicao").textContent = `${dados.percentualContribuicao}%`;
            const selecionado = String(dados.ano);
            $("anoDetalhes").innerHTML = dados.anos.map(item => `<option value="${item}">${item}</option>`).join("");
            $("anoDetalhes").value = selecionado;
            $("tabelaPresencas").innerHTML = dados.presencas.length ? dados.presencas.map(item => {
                const classe = item.situacao === "Presente" ? "status-present" : item.situacao === "Justificado" ? "status-justified" : "status-absent";
                return `<tr><td>${esc(item.data)}</td><td>${esc(item.descricao)}</td><td class="${classe}">${esc(item.situacao)}</td><td>${esc(item.justificativa || "—")}</td></tr>`;
            }).join("") : '<tr><td colspan="4" class="text-muted text-center">Nenhum encontro encontrado neste ano.</td></tr>';
            $("tabelaContribuicoes").innerHTML = dados.contribuicoes.length ? dados.contribuicoes.map(item =>
                `<tr><td>${esc(item.competencia)}</td><td>${esc(item.pagamento || "—")}</td><td>${esc(item.valor)}</td><td class="${item.paga ? "status-present" : "status-absent"}">${item.paga ? "Paga" : "Pendente"}</td></tr>`
            ).join("") : '<tr><td colspan="4" class="text-muted text-center">Nenhuma contribuição encontrada neste ano.</td></tr>';
        } catch (error) {
            if (!detalhar) {
                $("percentualPresenca").textContent = "—";
                $("percentualContribuicao").textContent = "—";
            }
            alertar(error.message);
        }
    }

    async function abrirModalIndicadores() {
        const ano = $("anoIndicadores").textContent;
        $("indicadoresPessoa").textContent = state.pessoa.nome;
        modalIndicadores.show();
        await carregarIndicadores(ano, true);
    }
    function limparAvaliacao() {
        $("formAvaliacao").reset(); $("idAvaliacao").value = ""; $("dataAvaliacao").value = state.ciclo.data; $("acaoStatus").value = "PENDENTE";
        $("formAvaliacaoTitulo").textContent = "Realizar avaliação"; $("cancelarEdicao").classList.add("d-none");
    }
    function editarAvaliacao(a) {
        $("idAvaliacao").value = a.id; $("dataAvaliacao").value = a.data; $("textoAvaliacao").value = a.texto;
        document.querySelector(`input[name="resultado"][value="${a.resultado}"]`).checked = true;
        $("acaoTexto").value = a.acao; $("acaoResponsavel").value = a.responsavel; $("acaoStatus").value = a.status || "PENDENTE";
        $("formAvaliacaoTitulo").textContent = "Editar avaliação"; $("cancelarEdicao").classList.remove("d-none");
    }

    function abrirModalCiclo(ciclo) {
        $("formCiclo").reset(); $("idCiclo").value = ciclo?.id || ""; $("dataCiclo").value = ciclo?.data || new Date().toISOString().slice(0, 10);
        $("grupoCiclo").value = ciclo?.classe || ""; $("descricaoCiclo").value = ciclo?.descricao || "";
        $("modalCicloTitulo").textContent = ciclo ? "Editar ciclo de avaliação" : "Novo ciclo de avaliação"; modal.show();
    }

    $("novoCiclo").addEventListener("click", () => abrirModalCiclo());
    $("editarCiclo").addEventListener("click", () => abrirModalCiclo(state.ciclo));
    $("formCiclo").addEventListener("submit", async e => {
        e.preventDefault();
        try {
            await api("salvarCiclo", { body: { id: $("idCiclo").value, data: $("dataCiclo").value, classe: $("grupoCiclo").value, descricao: $("descricaoCiclo").value } });
            modal.hide(); await carregarCiclos(); alertar("Ciclo salvo com sucesso.", "success");
            if ($("idCiclo").value) await abrirCiclo($("idCiclo").value);
        } catch (error) { alertar(error.message); }
    });
    $("formAvaliacao").addEventListener("submit", async e => {
        e.preventDefault();
        const resultado = document.querySelector('input[name="resultado"]:checked');
        try {
            await api("salvarAvaliacao", { body: { id: $("idAvaliacao").value, ciclo: state.ciclo.id, pessoa: state.pessoa.id, data: $("dataAvaliacao").value, texto: $("textoAvaliacao").value, resultado: resultado?.value || "", acaoTexto: $("acaoTexto").value, responsavel: $("acaoResponsavel").value, status: $("acaoStatus").value } });
            await abrirPessoa(state.pessoa.id); alertar("Avaliação salva com sucesso.", "success");
        } catch (error) { alertar(error.message); }
    });
    $("cancelarEdicao").addEventListener("click", limparAvaliacao);
    $("abrirIndicadores").addEventListener("click", abrirModalIndicadores);
    document.querySelectorAll("[data-abrir-indicadores]").forEach(botao => botao.addEventListener("click", abrirModalIndicadores));
    $("anoDetalhes").addEventListener("change", event => carregarIndicadores(event.target.value, true));
    $("filtroNome").addEventListener("input", (() => { let timer; return () => { clearTimeout(timer); timer = setTimeout(carregarMembros, 300); }; })());
    $("filtroRegiao").addEventListener("change", carregarMembros);
    $("filtroSituacao").addEventListener("change", carregarMembros);
    $("filtroAnoCiclo").addEventListener("change", renderCiclos);
    $("filtroGrupoCiclo").addEventListener("change", renderCiclos);
    document.addEventListener("click", e => {
        const cycle = e.target.closest("[data-ciclo]"); if (cycle) abrirCiclo(cycle.dataset.ciclo);
        const person = e.target.closest("[data-pessoa]"); if (person) abrirPessoa(person.dataset.pessoa);
        const edit = e.target.closest("[data-editar-avaliacao]"); if (edit) editarAvaliacao(state.avaliacoes.find(a => a.id === Number(edit.dataset.editarAvaliacao)));
        const back = e.target.closest("[data-voltar]"); if (back?.dataset.voltar === "ciclos") { mostrar("telaCiclos"); carregarCiclos(); } else if (back) { mostrar("telaMembros"); carregarMembros(); }
    });
    document.addEventListener("keydown", e => {
        if (e.key !== "Enter") return;
        const cycle = e.target.closest("[data-ciclo]"); if (cycle) abrirCiclo(cycle.dataset.ciclo);
        const person = e.target.closest("[data-pessoa]"); if (person) abrirPessoa(person.dataset.pessoa);
    });

    carregarRegioes();
    carregarCiclos();
})();
