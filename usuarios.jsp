<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="includes/auth.jsp" %>
<%@ include file="includes/access.jsp" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Perfis de usuários</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css?v=20260726-1">
    <link rel="stylesheet" href="css/avaliacoes.css?v=20260726-1">
</head>
<body>
<jsp:include page="includes/header.jsp"/>
<main class="container py-4">
    <div id="alertaUsuarios" class="alert d-none" role="alert"></div>
    <div class="mb-4"><h1 class="fw-bold mb-1">Perfis de usuários</h1><p class="text-muted mb-0">Defina as permissões de acesso vinculadas a cada pessoa.</p></div>
    <div class="profile-card mb-4"><div class="row g-3">
        <div class="col-md-5"><label for="buscaUsuario" class="form-label">Nome</label><input id="buscaUsuario" class="form-control" placeholder="Buscar por nome"></div>
        <div class="col-md-3"><label for="grupoUsuarioFiltro" class="form-label">Grupo</label><select id="grupoUsuarioFiltro" class="form-select" data-catalogo-grupos data-grupos-usuarios="true" data-grupos-todos="true"><option value="">Carregando grupos...</option></select></div>
        <div class="col-md-2"><label for="perfilUsuarioFiltro" class="form-label">Perfil</label><select id="perfilUsuarioFiltro" class="form-select"><option value="">Todos</option><option>ADM</option><option>REP</option><option>FIN</option><option>USR</option><option>EXT</option></select></div>
        <div class="col-md-2"><label for="statusUsuarioFiltro" class="form-label">Situação</label><select id="statusUsuarioFiltro" class="form-select"><option value="1">Ativos</option><option value="0">Inativos</option></select></div>
    </div></div>
    <div class="d-flex justify-content-between align-items-center mb-3"><span id="totalUsuarios" class="text-muted">Carregando...</span><small class="text-muted"><i class="bi bi-info-circle"></i> Salve o perfil em cada card.</small></div>
    <div id="listaUsuarios" class="row g-3"></div>
</main>
<jsp:include page="includes/footer.jsp"/>
<script>window.usuarioLogadoId=<%= session.getAttribute("usuarioId") %>;</script>
<script src="js/usuarios.js?v=20260726-1"></script>
</body></html>
