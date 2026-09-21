<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="includes/auth.jsp" %>
<%@ include file="includes/escopoRelatorios.jspf" %>
<%
String perfilRelatorios=(String)session.getAttribute("usuarioPerfil");
if(!"ADM".equals(perfilRelatorios)&&!"REP".equals(perfilRelatorios)&&!"EXT".equals(perfilRelatorios)){response.sendRedirect("index.jsp");return;}
if("REP".equals(perfilRelatorios)&&"NENHUM".equals(cadEscopoRelatorios(session))){response.sendRedirect("index.jsp");return;}
boolean somenteJspRelatorios="REP".equals(perfilRelatorios);
%>
<!DOCTYPE html><html lang="pt-br"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Relatórios</title><link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet"><link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet"><link rel="stylesheet" href="css/style.css"><style>.report-theme{margin-bottom:22px}.legacy-reports{border-style:dashed;background:#fafbfc}.legacy-label{font-size:.75rem;text-transform:uppercase;letter-spacing:.05em;color:#94a3b8}</style></head><body><jsp:include page="includes/header.jsp"/>
<main class="container py-4"><div class="mb-4"><h1 class="fw-bold">Relatórios</h1><p class="text-muted"><%= somenteJspRelatorios?"Relatórios dos membros da sua região episcopal":"Consultas e relatórios do sistema" %></p></div>

<section class="profile-card report-theme"><h4 class="mb-1"><i class="bi bi-people me-1"></i> Pessoas e Regiões</h4><p class="text-muted mb-3">Distribuição dos membros por região episcopal e paróquia</p><div class="row g-3">
<div class="col-md-6"><a class="member-card text-decoration-none" href="relatorioListagemPorRegiao.jsp"><div><div class="member-name">Listagem por Região</div><div class="member-sub"><%= somenteJspRelatorios?"Membros ativos da sua região episcopal":"Detalhamento dos membros por região e paróquia" %></div></div><i class="bi bi-list-ul"></i></a></div>
<div class="col-md-6"><a class="member-card text-decoration-none" href="relatorioResumoPorRegiao.jsp"><div><div class="member-name">Resumo por Região</div><div class="member-sub"><%= somenteJspRelatorios?"Totais de membros e paróquias da sua região":"Visão consolidada por grupo, região e paróquia" %></div></div><i class="bi bi-geo-alt"></i></a></div>
<div class="col-md-6"><a class="member-card text-decoration-none" href="relatorioAniversarios.jsp"><div><div class="member-name">Aniversários e Datas Comemorativas</div><div class="member-sub"><%= somenteJspRelatorios?"Datas dos membros da sua região episcopal":"Nascimentos, casamentos e ordenações" %></div></div><i class="bi bi-gift"></i></a></div>
</div></section>

<section class="profile-card report-theme"><h4 class="mb-1"><i class="bi bi-calendar-check me-1"></i> Encontros e Presença</h4><p class="text-muted mb-3">Participação dos membros nos encontros</p><div class="row g-3">
<div class="col-md-6"><a class="member-card text-decoration-none" href="relatorioMapaPresenca.jsp"><div><div class="member-name">Mapa de Presença</div><div class="member-sub"><%= somenteJspRelatorios?"Participação dos membros da sua região":"Mapa anual com presenças, justificativas e ausências" %></div></div><i class="bi bi-calendar-check"></i></a></div>
</div></section>

<section class="profile-card report-theme"><h4 class="mb-1"><i class="bi bi-journal-check me-1"></i> Formação</h4><p class="text-muted mb-3">Evolução acadêmica, formativa e ministerial</p><div class="row g-3">
<div class="col-md-6"><a class="member-card text-decoration-none" href="relatorioFormacao.jsp"><div><div class="member-name">Evolução da Formação</div><div class="member-sub"><%= somenteJspRelatorios?"Progresso acadêmico dos membros da sua região":"Progresso acadêmico e etapas ministeriais" %></div></div><i class="bi bi-mortarboard"></i></a></div>
</div></section>

<section class="profile-card report-theme"><h4 class="mb-1"><i class="bi bi-folder-check me-1"></i> Documentação</h4><p class="text-muted mb-3">Entrega e pendência de documentos dos membros</p><div class="row g-3">
<div class="col-md-6"><a class="member-card text-decoration-none" href="relatorioDocumentacoes.jsp"><div><div class="member-name">Checklist de Documentações</div><div class="member-sub"><%= somenteJspRelatorios?"Documentações dos membros da sua região":"Membros em linhas e documentos em colunas" %></div></div><i class="bi bi-ui-checks-grid"></i></a></div>
</div></section>

<% if("ADM".equals(perfilRelatorios)){ %>
<section class="profile-card report-theme"><h4 class="mb-1"><i class="bi bi-shield-lock me-1"></i> Administração e Auditoria</h4><p class="text-muted mb-3">Acompanhamento do acesso dos usuários ao sistema</p><div class="row g-3">
<div class="col-md-6"><a class="member-card text-decoration-none" href="relatorioUltimoLogin.jsp"><div><div class="member-name">Último login dos usuários</div><div class="member-sub">Data do último acesso por usuário e grupo</div></div><i class="bi bi-box-arrow-in-right"></i></a></div>
<div class="col-md-6"><a class="member-card text-decoration-none" href="relatorioAcessos.jsp"><div><div class="member-name">Páginas mais acessadas</div><div class="member-sub">Visualizações, usuários únicos e evolução dos acessos</div></div><i class="bi bi-bar-chart-line"></i></a></div>
</div></section>
<% } %>

<section class="profile-card report-theme"><h4 class="mb-1"><i class="bi bi-sliders me-1"></i> Relatório Personalizado</h4><p class="text-muted mb-3">Monte uma consulta escolhendo campos, filtros e formato de apresentação</p><div class="row g-3"><div class="col-md-6"><a class="member-card text-decoration-none" href="relatorioDinamico.jsp"><div><div class="member-name">Relatório Dinâmico</div><div class="member-sub">Seleção de campos, filtros, agrupamento e impressão</div></div><i class="bi bi-layout-three-columns"></i></a></div></div></section>
</main><jsp:include page="includes/footer.jsp"/></body></html>
