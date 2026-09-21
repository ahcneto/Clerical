let membros = [];

async function carregarMembros() {
    try {
		const status = document.getElementById("filterStatus").value;
		const response = await fetch(`membros_consulta.jsp?acao=listar&status=${encodeURIComponent(status)}`, { cache: "no-store" });
        const dados = await response.json();
        if (!response.ok || !dados.ok) throw new Error(dados.mensagem || "Não foi possível carregar os membros.");
        membros = dados.membros.map(membro => ({ ...membro, funcao: null }));

        atualizarFiltroRegioes();
        filtrar();

    } catch(error) {
        console.error("Erro ao carregar membros:", error);
    }
}

function getBadgeStyle(grupo) {
    const item = window.GruposCatalogo && GruposCatalogo.listar().find(g => g.singular === grupo);
    return item ? GruposCatalogo.estilo(item.id) : "";
}
function escapeHtml(valor) {
    return String(valor || "").replace(/[&<>"']/g, caractere => ({
        "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#039;"
    })[caractere]);
}
function renderMembers(lista) {
    const container = document.getElementById("membersContainer");
    const totalMembros = document.getElementById("total-membros");

    totalMembros.textContent = `${lista.length} ${lista.length === 1 ? "listado" : "listados"}`;
    container.innerHTML = "";

    lista.forEach(m => {
        container.innerHTML += `
            <div class="col-md-6">
                <article class="evaluation-member-card d-flex align-items-center gap-3" onclick="abrirPerfil(${Number(m.id)})" tabindex="0" role="button">
                    <img src="fotos/foto_${Number(m.id)}.jpg" class="evaluation-member-photo" alt=""
                         onerror="this.classList.add('d-none');this.nextElementSibling.classList.remove('d-none')">
                    <span class="evaluation-avatar d-none">${escapeHtml(m.nome.charAt(0))}</span>
                    <div class="flex-grow-1">
                        <div class="d-flex align-items-center gap-2 flex-wrap mb-1">
                            <h5 class="mb-0">${escapeHtml(m.nome)}</h5>
                            <span class="badge-tag" style="${getBadgeStyle(m.grupo)}">${escapeHtml(m.grupo)}</span>
                            ${m.funcao ? `<span class="badge-tag tag-gray">${escapeHtml(m.funcao)}</span>` : ""}
                        </div>
                        <div class="text-muted small">${escapeHtml(m.paroquia || "Paróquia não informada")}${m.bairro ? ` - ${escapeHtml(m.bairro)}` : ""}</div>
                        <div class="text-muted small mt-1"><i class="bi bi-geo-alt"></i> ${escapeHtml(m.regiao || "Região não informada")}</div>
                    </div>
                </article>
            </div>
        `;
    });
}

function atualizarFiltroRegioes() {
    const select = document.getElementById("filterRegiao");
    const selecionada = select.value;
    const regioes = [...new Set(membros.map(m => m.regiao).filter(Boolean))]
        .sort((a, b) => a.localeCompare(b, "pt-BR"));

    select.innerHTML = '<option value="">Todas as regiões</option>' +
        regioes.map(regiao => `<option value="${escapeHtml(regiao)}">${escapeHtml(regiao)}</option>`).join("");

    if (regioes.includes(selecionada)) select.value = selecionada;
}

function filtrar() {
    const termo = document.getElementById("searchInput").value.toLowerCase();
    const grupo = document.getElementById("filterGrupo").value;
    const regiao = document.getElementById("filterRegiao").value;

    const filtrado = membros.filter(m => {
        const busca =
            m.nome.toLowerCase().includes(termo) ||
            m.paroquia.toLowerCase().includes(termo) ||
            m.bairro.toLowerCase().includes(termo);

        const filtroGrupo =
            grupo === "" || m.grupo === grupo;

        const filtroRegiao =
            regiao === "" || m.regiao === regiao;

        return busca && filtroGrupo && filtroRegiao;
    });

    renderMembers(filtrado);
}

function abrirPerfil(id) {
    window.location.href = `perfil.jsp?id=${id}`;
}


const grupoInicial = new URLSearchParams(window.location.search).get("grupo");
document.getElementById("filterGrupo").addEventListener("grupos:select-populado", function () {
    if (grupoInicial && [...this.options].some(option => option.value === grupoInicial)) this.value = grupoInicial;
    filtrar();
});

document.getElementById("searchInput").addEventListener("keyup", filtrar);
document.getElementById("filterGrupo").addEventListener("change", filtrar);
document.getElementById("filterRegiao").addEventListener("change", filtrar);
document.getElementById("filterStatus").addEventListener("change", carregarMembros);

//renderMembers(membros);

carregarMembros();
