<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="includes/auth.jsp" %>
<%@ include file="includes/access.jsp" %>

<%
String usuarioPerfil = (String) session.getAttribute("usuarioPerfil");
Integer usuarioGrupoId = (Integer) session.getAttribute("usuarioGrupoId");
Integer usuarioRegiaoId = (Integer) session.getAttribute("usuarioRegiaoId");
%>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Membros</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">

    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/avaliacoes.css">
</head>
<body>
<jsp:include page="includes/header.jsp"/>


<!-- CONTEÚDO -->
<div class="container py-4">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h1 class="fw-bold">Membros</h1>
            <p class="text-muted" id="total-membros">0 listados</p>
        </div>

        <div class="d-flex flex-wrap gap-2">
            <% if ("ADM".equals(usuarioPerfil)) { %>
            <a class="btn btn-outline-secondary" href="grupos.jsp">
                <i class="bi bi-diagram-3"></i> Gerenciar grupos
            </a>
            <% } %>
            <button class="btn btn-orange <%= "ADM".equals(usuarioPerfil) ? "" : "d-none" %>" onclick="openMemberModal()">
                <i class="bi bi-plus-lg"></i> Novo Membro
            </button>
        </div>
    </div>

    <!-- filtros -->
    <div class="row g-3 mb-4">
        <div class="col-md-3">
            <input type="text" id="searchInput" class="form-control search-box"
                   placeholder="Buscar por nome, paróquia ou bairro...">
        </div>

        <div class="col-md-3">
            <select id="filterGrupo" class="form-select" data-catalogo-grupos
                    data-grupos-modulo="membros" data-grupos-operacionais="true" data-grupos-todos="true"
                    data-grupos-valor="singular" data-grupos-forma="singular">
                <option value="">Carregando grupos...</option>
            </select>
        </div>
        <div class="col-md-3">
            <select id="filterRegiao" class="form-select" aria-label="Filtrar por região episcopal">
                <option value="">Todas as regiões</option>
            </select>
        </div>
        <div class="col-md-3">
            <select id="filterStatus" class="form-select" aria-label="Filtrar por status">
                <option value="1">Membros ativos</option>
                <option value="0">Membros inativos</option>
            </select>
        </div>
    </div>

    <!-- lista -->
    <div id="membersContainer" class="row g-3"></div>

</div>

<div id="memberModal" class="custom-modal-overlay">

    <div class="custom-modal">

        <div class="modal-header-custom">
            <h3 id="modalTitle">Novo Membro</h3>
            <button onclick="closeMemberModal()" class="close-btn">×</button>
        </div>

        <div class="modal-body-custom">
            <div class="row g-3">

                <div class="col-md-6">
                    <label for="nome">Nome completo</label>
                    <input id="nome" type="text" class="form-control" maxlength="200" autocomplete="name">
                </div>

                <div class="col-md-6">
                    <label for="telefone">Telefone</label>
                    <input id="telefone" type="tel" class="form-control" maxlength="15" autocomplete="tel" placeholder="(85) 99999-9999">
                </div>

                <div class="col-md-6">
                    <label for="dataNascimento">Data de nascimento</label>
                    <input id="dataNascimento" type="date" class="form-control">
                </div>

                <div class="col-md-6">
                    <label>Grupo</label>
                    <select id="grupo" class="form-select" data-catalogo-grupos
                            data-grupos-modulo="membros" data-grupos-operacionais="true"
                            data-grupos-forma="singular">
                        <option value="">Carregando grupos...</option>
                    </select>
                </div>

                <div class="col-md-6">
                    <label for="paroquia">Paróquia</label>
                    <select id="paroquia" class="form-select"><option value="">Carregando paróquias...</option></select>
                </div>

            </div>
        </div>

        <div class="modal-footer-custom">
            <button class="btn btn-light" onclick="closeMemberModal()">Cancelar</button>
            <button type="button" id="salvarMembroBtn" class="btn btn-orange" onclick="saveMember()">Salvar</button>
        </div>

    </div>

</div>

<jsp:include page="includes/footer.jsp"/>

<script>
window.usuarioPerfil = "<%= usuarioPerfil %>";
window.usuarioGrupoId = "<%= usuarioGrupoId %>";
window.usuarioRegiaoId = "<%= usuarioRegiaoId %>";

console.log(
    "Sessão:",
    window.usuarioPerfil,
    window.usuarioGrupoId,
    window.usuarioRegiaoId
);
</script>

<script src="js/member-modal.js?v=20260821-1"></script>
<script src="js/members.js?v=20260824-2"></script>

</body>
</html>
