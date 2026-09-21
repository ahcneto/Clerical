(function () {
    "use strict";
    let grupos = [], carregamento = null, contexto = { perfil: "", grupoUsuario: null, escopos: {} };
    const booleano = valor => valor === true || valor === 1 || valor === "1" || valor === "true";

    function carregar() {
        if (!carregamento) carregamento = fetch("grupos_api.jsp?acao=ativos", { credentials: "same-origin" })
            .then(resposta => { if (!resposta.ok) throw new Error("Não foi possível carregar os grupos."); return resposta.json(); })
            .then(dados => {
                grupos = Array.isArray(dados) ? dados : (dados.grupos || []);
                if (!Array.isArray(dados)) contexto = { perfil: dados.perfil || "", grupoUsuario: dados.grupoUsuario, escopos: dados.escopos || {} };
                document.dispatchEvent(new CustomEvent("grupos:carregados", { detail: grupos }));
                return grupos;
            }).catch(erro => { carregamento = null; console.error(erro); return grupos; });
        return carregamento;
    }
    function escopoDaOpcao(opcoes) {
        if (contexto.perfil === "FIN" && opcoes.modulo === "contribuicoes") return "PROPRIO";
        if (contexto.perfil !== "REP") return "TODOS";
        const chave = opcoes.escopo || ({ membros:"membros", encontros:"encontros", contribuicoes:"contribuicoes", relatorios:"relatorios" })[opcoes.modulo];
        return chave ? (contexto.escopos[chave] || "NENHUM") : "TODOS";
    }
    function listar(opcoes = {}) {
        const escopo = escopoDaOpcao(opcoes);
        return grupos.filter(grupo => {
            if (escopo === "NENHUM") return false;
            if (escopo === "PROPRIO" && String(grupo.id) !== String(contexto.grupoUsuario)) return false;
            if (opcoes.operacionais && !booleano(grupo.operacional)) return false;
            if (opcoes.usuarios && !booleano(grupo.usuarios)) return false;
            if (opcoes.modulo && grupo.modulos && !booleano(grupo.modulos[opcoes.modulo])) return false;
            if (opcoes.modulo === "contribuicoes" && !booleano(grupo.contribuicaoAtiva)) return false;
            return true;
        });
    }
    const porId = id => grupos.find(grupo => String(grupo.id) === String(id));
    function nome(id, forma) { const grupo = porId(id); return grupo ? (forma === "singular" ? grupo.singular : grupo.plural) : "Grupo " + id; }
    function cor(id) { const grupo = porId(id); return grupo && /^#[0-9a-f]{6}$/i.test(grupo.cor || "") ? grupo.cor : "#64748b"; }
    function estilo(id) { const valor = cor(id); return `background-color:${valor}20;color:${valor};border-color:${valor}40`; }
    function popularSelect(select, opcoes = {}) {
        if (!select) return;
        const selecionado = opcoes.selecionado != null ? String(opcoes.selecionado) : select.value;
        const itens = [];
        const escopo = escopoDaOpcao(opcoes);
        if (opcoes.todos && escopo !== "PROPRIO" && escopo !== "NENHUM") itens.push(new Option(opcoes.textoTodos || "Todos os grupos", opcoes.valorTodos == null ? "" : opcoes.valorTodos));
        listar(opcoes).forEach(grupo => itens.push(new Option(opcoes.forma === "singular" ? grupo.singular : grupo.plural, opcoes.valor === "singular" ? grupo.singular : grupo.id)));
        select.replaceChildren(...itens);
        if ([...select.options].some(option => option.value === selecionado)) select.value = selecionado;
        select.dispatchEvent(new CustomEvent("grupos:select-populado"));
    }
    function popularAutomaticos() {
        const legados = {
            checklistClasse: { modulo: "documentacao", operacionais: true },
            filtroGrupoCiclo: { modulo: "avaliacoes", operacionais: true, todos: true },
            grupoCiclo: { modulo: "avaliacoes", operacionais: true, todos: true, textoTodos: "Selecione" },
            filterGrupoContrib: { modulo: "contribuicoes", operacionais: true, todos: true },
            filtroGrupo: { modulo: "encontros", operacionais: true, todos: true },
            eventClasse: { modulo: "encontros", operacionais: true },
            grupoUsuarioFiltro: { usuarios: true, todos: true }
        };
        Object.keys(legados).forEach(id => {
            const select = document.getElementById(id);
            if (select && !select.hasAttribute("data-catalogo-grupos")) popularSelect(select, legados[id]);
        });
        const relatorios = {
            "relatorioAniversarios.jsp": { modulo: "relatorios", escopo: "relatorios", operacionais: true, todos: true, valorTodos: "0", textoTodos: "Todos" },
            "relatorioFormacao.jsp": { modulo: "formacao", escopo: "relatorios", operacionais: true, todos: true, valorTodos: "0", textoTodos: "Todos" },
            "relatorioListagemPorRegiao.jsp": { modulo: "relatorios", escopo: "relatorios", operacionais: true, todos: true, valorTodos: "0", textoTodos: "Todos" },
            "relatorioMapaPresenca.jsp": { modulo: "presencas", escopo: "relatorios", operacionais: true },
            "relatorioResumoPorRegiao.jsp": { modulo: "relatorios", escopo: "relatorios", operacionais: true, todos: true, valorTodos: "0", textoTodos: "Todos" },
            "relatorioUltimoLogin.jsp": { usuarios: true, todos: true, valorTodos: "-1", textoTodos: "Todos" }
        };
        const pagina = location.pathname.split("/").pop();
        const filtroRelatorio = relatorios[pagina];
        if (filtroRelatorio) popularSelect(document.querySelector('select[name="classe"], select[name="grupo"]'), filtroRelatorio);
        document.querySelectorAll("select[data-catalogo-grupos]").forEach(select => popularSelect(select, {
            modulo: select.dataset.gruposModulo || null,
            operacionais: booleano(select.dataset.gruposOperacionais), usuarios: booleano(select.dataset.gruposUsuarios),
            todos: booleano(select.dataset.gruposTodos), valorTodos: select.dataset.gruposTodosValor,
            textoTodos: select.dataset.gruposTodosTexto, selecionado: select.dataset.gruposSelecionado,
            valor: select.dataset.gruposValor, forma: select.dataset.gruposForma
        }));
        atualizarNomesFixos(document.body);
    }
    function atualizarNomesFixos(raiz) {
        if (!raiz) return;
        const equivalencias = {
            "Clero": nome(0), "Diácono": nome(1, "singular"), "Diáconos": nome(1),
            "Candidato": nome(2, "singular"), "Candidatos": nome(2),
            "Vocacionado": nome(3, "singular"), "Vocacionados": nome(3)
        };
        const processar = no => {
            if (no.nodeType === Node.TEXT_NODE) {
                const atual = no.nodeValue.trim();
                if (equivalencias[atual]) no.nodeValue = no.nodeValue.replace(atual, equivalencias[atual]);
            } else if (no.nodeType === Node.ELEMENT_NODE && !/^(SCRIPT|STYLE)$/.test(no.tagName)) {
                no.childNodes.forEach(processar);
            }
        };
        processar(raiz);
    }
    function aplicarModulosMenu() {
        if (["ADM", "EXT"].includes(window.usuarioCatalogoPerfil)) return;
        const grupo = porId(window.usuarioCatalogoGrupo);
        if (!grupo || !grupo.modulos) return;
        const paginas = {
            "membros.jsp": "membros", "encontros.jsp": "encontros",
            "contribuicoes.jsp": "contribuicoes", "formacoes.jsp": "formacao",
            "documentacoes.jsp": "documentacao", "avaliacoes.jsp": "avaliacoes",
            "relatorios.jsp": "relatorios"
        };
        document.querySelectorAll("#mainMenu a[href]").forEach(link => {
            const pagina = (link.getAttribute("href") || "").split("?")[0];
            const modulo = paginas[pagina];
            const escopo = contexto.perfil === "REP" ? contexto.escopos[modulo] : null;
            if (modulo && (!booleano(grupo.modulos[modulo]) || escopo === "NENHUM")) link.closest("li")?.classList.add("d-none");
        });
    }
    window.GruposCatalogo = { carregar, listar, porId, nome, cor, estilo, popularSelect, atualizarNomesFixos };
    const iniciar = () => carregar().then(() => { popularAutomaticos(); aplicarModulosMenu(); });
    document.readyState === "loading" ? document.addEventListener("DOMContentLoaded", iniciar) : iniciar();
    new MutationObserver(mudancas => {
        if (!grupos.length) return;
        mudancas.forEach(mudanca => mudanca.addedNodes.forEach(no => atualizarNomesFixos(no)));
    }).observe(document.documentElement, { childList: true, subtree: true });
}());
