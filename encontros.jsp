<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="includes/auth.jsp" %>
<%
String perfil = (String) session.getAttribute("usuarioPerfil");
boolean podeGerenciar = "ADM".equals(perfil);
%>
<!DOCTYPE html>
<html lang="pt-br"><head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Encontros</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
</head><body>
<jsp:include page="includes/header.jsp"/>
<div class="container py-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div><h1 class="fw-bold">Encontros Formativos</h1><p id="total-encontros" class="text-muted">0 encontros</p></div>
        <% if (podeGerenciar) { %><button class="btn btn-orange" onclick="abrirModalEncontro()"><i class="bi bi-plus-lg"></i> Novo Encontro</button><% } %>
    </div>
    <div class="row mb-4 g-2">
        <div class="col-md-4"><input id="buscaEncontro" class="form-control" placeholder="Buscar por descrição ou local"></div>
        <div class="col-md-2"><select id="filtroAno" class="form-select"><option value="">Todos os anos</option></select></div>
        <div class="col-md-2"><select id="filtroGrupo" class="form-select" data-catalogo-grupos data-grupos-modulo="encontros" data-grupos-operacionais="true" data-grupos-todos="true"><option value="">Carregando grupos...</option></select></div>
    </div>
    <div id="eventsContainer"><div class="text-muted">Carregando encontros...</div></div>
</div>
<% if (podeGerenciar) { %>
<div id="eventModal" class="custom-modal-overlay"><div class="custom-modal">
    <div class="modal-header-custom"><h3 id="tituloModalEncontro">Novo Encontro</h3><button class="close-btn" onclick="fecharModalEncontro()">×</button></div>
    <div class="modal-body-custom"><input type="hidden" id="eventId"><div class="row g-3">
        <div class="col-md-6"><label>Grupo *</label><select id="eventClasse" class="form-select" data-catalogo-grupos data-grupos-modulo="encontros" data-grupos-operacionais="true"><option value="">Carregando grupos...</option></select></div>
        <div class="col-md-6"><label>Data</label><input id="eventData" type="date" class="form-control"></div>
        <div class="col-12"><label>Descrição *</label><input id="eventDescricao" class="form-control"></div>
        <div class="col-12"><label>Detalhes</label><textarea id="eventDetalhe" class="form-control"></textarea></div>
        <div class="col-12"><label>Local</label><input id="eventLocal" class="form-control"></div>
        <div class="col-md-6"><label>Latitude</label><input id="eventLatitude" type="number" step="any" class="form-control"></div>
        <div class="col-md-6"><label>Longitude</label><input id="eventLongitude" type="number" step="any" class="form-control"></div>
        <div class="col-md-6 form-check ms-2"><input id="eventEnviado" class="form-check-input" type="checkbox"><label class="form-check-label" for="eventEnviado">Permite registro de presença</label></div>
        <div class="col-md-5 form-check"><input id="eventEsposa" class="form-check-input" type="checkbox"><label class="form-check-label" for="eventEsposa">Participação da esposa</label></div>
    </div></div>
    <div class="modal-footer-custom"><button class="btn btn-light" onclick="fecharModalEncontro()">Cancelar</button><button class="btn btn-orange" onclick="salvarEncontro()">Salvar</button></div>
</div></div>
<% } %>
<script>window.podeGerenciarEncontros = <%= podeGerenciar %>; window.podeVerParticipantes = <%= "ADM".equals(perfil) || "REP".equals(perfil) || "EXT".equals(perfil) %>;</script>
<jsp:include page="includes/footer.jsp"/>
<script src="js/encontros.js?v=20260821-1"></script>
</body></html>
