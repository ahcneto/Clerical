<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="includes/auth.jsp" %>
<%!
String html(String valor) {
    if (valor == null) return "";
    return valor.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
}
%>
<%
String usuarioPerfil = (String) session.getAttribute("usuarioPerfil");
String usuarioRegiao = (String) session.getAttribute("usuarioRegiao");
String usuarioNome = (String) session.getAttribute("usuarioNome");
String usuarioParoquia = (String) session.getAttribute("usuarioParoquia");
String usuarioGrupo = (String) session.getAttribute("usuarioGrupo");
Integer usuarioId = (Integer) session.getAttribute("usuarioId");
Integer usuarioGrupoId = (Integer) session.getAttribute("usuarioGrupoId");
String tituloPainel = "Painel Principal";
boolean exibirTodosGrupos = "ADM".equals(usuarioPerfil) || "REP".equals(usuarioPerfil) || "EXT".equals(usuarioPerfil);

if ("REP".equals(usuarioPerfil)) {
    tituloPainel = "Painel do Representante - " + (usuarioRegiao != null ? usuarioRegiao : "");
} else if ("FIN".equals(usuarioPerfil)) {
    tituloPainel = "Representante financeiro";
}
%>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Clerical</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">

    <link rel="stylesheet" href="css/style.css?v=20260824-1">
</head>
<body>

<jsp:include page="includes/header.jsp"/>

<!-- CONTEÚDO -->
<div class="container py-4">

    <h1 class="fw-bold"><%= tituloPainel %></h1>
    <p class="text-muted">Arquidiocese de Fortaleza</p>

    <!-- RESUMO PESSOAL -->
    <section id="resumoPessoal" class="personal-summary-card my-4">
        <div class="personal-summary-profile">
            <div class="personal-summary-photo-wrap">
            <img src="fotos/foto_<%= usuarioId %>.jpg?v=1" class="personal-summary-photo" alt="Foto de <%= html(usuarioNome) %>"
                 onerror="this.classList.add('d-none');this.nextElementSibling.classList.remove('d-none')">
            <span class="personal-summary-avatar d-none"><%= html(usuarioNome != null && !usuarioNome.isEmpty() ? usuarioNome.substring(0,1) : "?") %></span>
            <button type="button" id="trocarFotoInicialBtn" class="personal-summary-photo-edit d-none" title="Alterar minha foto" aria-label="Alterar minha foto"><i class="bi bi-camera-fill"></i></button>
            <input type="file" id="trocarFotoInicialInput" accept="image/jpeg,image/png,image/webp" class="d-none">
            </div>
            <div class="personal-summary-info">
                <span class="personal-summary-label">Meu perfil</span>
                <h2><%= html(usuarioNome) %></h2>
                <div class="personal-summary-group" data-grupo-id="<%= usuarioGrupoId != null ? usuarioGrupoId.toString() : "" %>"><i class="bi bi-people-fill"></i> <%= html(usuarioGrupo != null && !usuarioGrupo.isEmpty() ? usuarioGrupo : "Grupo não informado") %></div>
                <div class="personal-summary-location"><i class="bi bi-church"></i><div><small>Paróquia</small><strong><%= html(usuarioParoquia != null && !usuarioParoquia.isEmpty() ? usuarioParoquia : "Não informada") %></strong></div></div>
                <div class="personal-summary-location"><i class="bi bi-geo-alt-fill"></i><div><small>Região episcopal</small><strong><%= html(usuarioRegiao != null && !usuarioRegiao.isEmpty() ? usuarioRegiao : "Não informada") %></strong></div></div>
            </div>
        </div>
        <div class="personal-summary-metrics without-formation">
            <button type="button" class="personal-metric personal-metric-presence" data-abrir-resumo="presencas"><i class="bi bi-calendar2-check"></i><div><span>Presença em <%= java.time.Year.now().getValue() %></span><strong id="resumoPresencaAtual">—</strong><small>Ver detalhes</small></div></button>
            <button type="button" class="personal-metric personal-metric-contribution" data-abrir-resumo="contribuicoes"><i class="bi bi-cash-coin"></i><div><span>Contribuições em <%= java.time.Year.now().getValue() %></span><strong id="resumoContribuicaoAtual">—</strong><small>Ver detalhes</small></div></button>
            <button type="button" id="cardResumoFormacao" class="personal-metric personal-metric-formation d-none" onclick="window.location.href='formacoes.jsp'"><i class="bi bi-journal-check"></i><div><span>Formações ativas</span><strong id="resumoFormacaoAtual">—</strong><small id="resumoFormacaoDetalhe">Ver programas</small></div></button>
        </div>
    </section>

    <section id="documentosPendentesInicial" class="profile-card mb-4 d-none">
        <div class="d-flex justify-content-between align-items-center gap-3 mb-3">
            <div>
                <h4 class="mb-1"><i class="bi bi-folder-check me-1"></i> Minhas documentações</h4>
                <p id="documentosResumoInicial" class="text-muted mb-0"></p>
            </div>
            <a href="documentacoes.jsp" class="btn btn-sm btn-outline-secondary">Ver detalhes</a>
        </div>
        <div id="documentosListaInicial" class="list-group list-group-flush"></div>
    </section>

    <% if (exibirTodosGrupos) { %>
    <!-- CARDS DE GRUPOS -->
    <div id="cardsGruposPainel" class="row g-3 my-4">
        <div class="col-12 text-muted">Carregando grupos...</div>
    </div>
    <% } %>

    <!-- EVENTOS -->
    <h3 class="mb-3">Últimos Encontros</h3>

    <div id="eventos-container" class="list-group">
        <div class="list-group-item text-muted">Carregando encontros...</div>
    </div>

</div>

<div class="modal fade" id="modalResumoAnual" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <div><h5 class="modal-title">Presença e contribuições</h5><div class="text-muted small"><%= html(usuarioNome) %></div></div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Fechar"></button>
            </div>
            <div class="modal-body">
                <div class="d-flex align-items-center gap-3 mb-4">
                    <label for="anoResumoPessoal" class="form-label fw-bold mb-0">Ano</label>
                    <select id="anoResumoPessoal" class="form-select" style="max-width:160px"></select>
                </div>
                <div class="row g-4">
                    <div class="col-lg-7" id="secaoResumoPresencas">
                        <div class="personal-detail-panel h-100">
                            <div class="d-flex justify-content-between align-items-center mb-3"><h5 class="mb-0"><i class="bi bi-calendar2-check"></i> Encontros</h5><strong id="detalhePercentualPresenca" class="personal-detail-percent">0%</strong></div>
                            <div class="table-responsive"><table class="table align-middle"><thead><tr><th>Data</th><th>Encontro</th><th>Situação</th><th>Justificativa</th></tr></thead><tbody id="detalhePresencas"></tbody></table></div>
                        </div>
                    </div>
                    <div class="col-lg-5" id="secaoResumoContribuicoes">
                        <div class="personal-detail-panel h-100">
                            <div class="d-flex justify-content-between align-items-center mb-3"><h5 class="mb-0"><i class="bi bi-cash-coin"></i> Contribuições</h5><strong id="detalhePercentualContribuicao" class="personal-detail-percent">0%</strong></div>
                            <div class="table-responsive"><table class="table align-middle"><thead><tr><th>Mês</th><th>Pagamento</th><th>Valor</th><th>Situação</th></tr></thead><tbody id="detalheContribuicoes"></tbody></table></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="js/grupos-catalogo.js?v=20260821-2"></script>
<script>
GruposCatalogo.carregar().then(function () {
    var grupo = document.querySelector(".personal-summary-group[data-grupo-id]");
    if (grupo && grupo.dataset.grupoId !== "") {
        var cor = GruposCatalogo.cor(grupo.dataset.grupoId);
        grupo.style.backgroundColor = cor;
        grupo.style.borderColor = cor;
        grupo.style.color = "#ffffff";
    }
});
</script>
<script>window.usuarioIdAtual=<%= usuarioId %>;</script>
<script src="js/index.js?v=20260821-2"></script>
</body>
</html>
