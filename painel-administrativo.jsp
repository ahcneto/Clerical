<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="includes/auth.jsp" %>
<% if(!"ADM".equals((String)session.getAttribute("usuarioPerfil"))){response.sendRedirect("index.jsp");return;} %>
<!doctype html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Painel Administrativo por Grupo</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
    <style>
        .painel-grupo-card { height: 100%; padding: 1.15rem; border: 1px solid #e8edf3; border-top: 4px solid var(--grupo-cor); border-radius: 16px; background: #fff; box-shadow: 0 2px 8px rgba(15,23,42,.05); }
        .painel-grupo-titulo { color: var(--grupo-cor); font-weight: 750; }
        .painel-indicador { min-height: 104px; height: 100%; padding: .9rem; border-radius: 12px; background: #f8fafc; }
        .painel-indicador small { display: block; color: #64748b; line-height: 1.35; }
        .painel-indicador strong { display: block; margin: .3rem 0; color: #1e293b; font-size: 1.45rem; line-height: 1.1; }
        .painel-indicador i { color: var(--grupo-cor); }
    </style>
</head>
<body>
<jsp:include page="includes/header.jsp"/>
<main class="container py-4">
    <div class="mb-4">
        <h1 class="fw-bold mb-1">Painel Administrativo</h1>
        <p class="text-muted mb-0">Indicadores de membros, presença e contribuições por grupo. Competência: mês do último encontro concluído; histórico: lançamentos vencidos registrados como não pagos.</p>
    </div>
    <div id="painelGrupos" class="row g-3">
        <div class="col-12 text-muted">Carregando indicadores...</div>
    </div>
</main>
<jsp:include page="includes/footer.jsp"/>
<script src="js/painel-administrativo.js"></script>
</body>
</html>