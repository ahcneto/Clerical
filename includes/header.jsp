<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
String perfil = (String) session.getAttribute("usuarioPerfil");
if (perfil == null) perfil = "USR";
Integer grupoCabecalhoId = (Integer) session.getAttribute("usuarioGrupoId");
String tituloCabecalho = grupoCabecalhoId != null && grupoCabecalhoId.intValue() == 1
    ? "CAD - Comissão Arquidiocesana dos Diáconos"
    : "Escola Diaconal";
String tituloCabecalhoFixo = "Clerical";    
%>
<script>window.usuarioCatalogoPerfil="<%= perfil %>";window.usuarioCatalogoGrupo=<%= grupoCabecalhoId==null?"null":grupoCabecalhoId.toString() %>;</script>

<style>
body { padding-left: 4.25rem; transition: padding-left .2s ease; }
body.admin-menu-expanded { padding-left: 15rem; }
.admin-sidebar { position: fixed; z-index: 1040; left: 0; top: 72px; bottom: 0; width: 4.25rem; overflow: auto hidden; background: #fff; border-right: 1px solid #e2e8f0; box-shadow: 4px 0 12px rgba(15,23,42,.06); transition: width .2s ease; }
body.admin-menu-expanded .admin-sidebar { width: 15rem; }
.admin-sidebar-toggle { width: 100%; border: 0; background: transparent; padding: 1rem; text-align: center; color: #475569; }
.admin-sidebar ul { list-style: none; padding: .25rem .5rem; margin: 0; }
.admin-sidebar a { display: flex; align-items: center; gap: .85rem; min-height: 2.8rem; padding: .55rem .8rem; border-radius: .5rem; color: #334155; text-decoration: none; white-space: nowrap; }
.admin-sidebar a:hover { background: #f1f5f9; color: #0f172a; }
.admin-sidebar a i { width: 1.35rem; text-align: center; font-size: 1.1rem; }
.admin-sidebar-label { display: none; }
body.admin-menu-expanded .admin-sidebar-label { display: inline; }
@media (max-width: 991px) { body { padding-left: 0; } .admin-sidebar { top: 64px; } }
@media (max-width: 991px) {
    #mainMenu.navbar-collapse {
        background: #ffffff !important;
        opacity: 1 !important;
        margin: 0 -1.5rem;
        padding: 0 1.5rem 1.25rem;
        position: relative;
        z-index: 1050;
        border-top: 1px solid #e2e8f0;
        box-shadow: 0 12px 20px rgba(15, 23, 42, .14);
    }

    .navbar { height: auto; }
}
</style>

<nav class="navbar navbar-expand-lg bg-white shadow-sm px-4">
    <div class="container-fluid">

        <a class="navbar-brand fw-bold" href="index.jsp">
            <i class="bi bi-bank"></i> <%= tituloCabecalhoFixo %>
        </a>

        <button class="navbar-toggler" type="button"
                data-bs-toggle="collapse"
                data-bs-target="#mainMenu">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="mainMenu">

           <ul class="navbar-nav mx-auto">
    <li class="nav-item"><a class="nav-link" href="index.jsp"><i class="bi bi-house"></i> Início</a></li>
    <% if ("ADM".equals(perfil) || "REP".equals(perfil) || "USR".equals(perfil) || "FIN".equals(perfil) || "EXT".equals(perfil)) { %>
    <li class="nav-item"><a class="nav-link" href="encontros.jsp"><i class="bi bi-calendar-event"></i> Encontros</a></li>
    <% } %>
    <% if ("ADM".equals(perfil) || "REP".equals(perfil) || "USR".equals(perfil) || "FIN".equals(perfil) || "EXT".equals(perfil)) { %>
    <li class="nav-item"><a class="nav-link" href="formacoes.jsp"><i class="bi bi-journal-check"></i> Formação</a></li>
    <li class="nav-item"><a class="nav-link" href="documentacoes.jsp"><i class="bi bi-folder-check"></i> Documentação</a></li>
    <% } %>
    <% if ("ADM".equals(perfil) || "REP".equals(perfil) || "USR".equals(perfil) || "FIN".equals(perfil) || "EXT".equals(perfil)) { %>
    <li class="nav-item"><a class="nav-link" href="dashboard.html"><i class="bi bi-bar-chart"></i> Painel</a></li>
    <% } %>
</ul>

            <div class="user-menu-container">

    <div class="user-info" onclick="toggleUserMenu()">
        <span class="avatar">
            <%= session.getAttribute("usuarioNome") != null
                ? session.getAttribute("usuarioNome").toString().substring(0,1)
                : "?" %>
        </span>

        <%= session.getAttribute("usuarioNome") %>

        <i class="bi bi-chevron-down ms-2"></i>
    </div>

    <div id="userMenu" class="user-dropdown">

        <div class="user-dropdown-header">
            <strong>Resumo Pessoal</strong>
        </div>

        <div class="dropdown-metric">
            <span>Participação Encontros</span>
            <strong>82%</strong>
        </div>

        <div class="dropdown-metric">
            <span>Contribuições</span>
            <strong id="resumoContribuicoesPct">0%</strong>
        </div>

        <div class="dropdown-metric d-none" id="resumoFormacaoMenuLinha">
            <span>Formações ativas</span>
            <strong id="resumoFormacaoMenuPct">0%</strong>
        </div>

        <hr>

        <div class="dropdown-item-custom"
             onclick="window.location.href='perfil.jsp'">
            <i class="bi bi-person"></i> Meu Perfil
        </div>

        <div class="dropdown-item-custom logout"
             onclick="window.location.href='logout.jsp'">
            <i class="bi bi-box-arrow-right"></i> Sair
        </div>

    </div>

</div>

        </div>
    </div>
</nav>
<aside class="admin-sidebar" aria-label="Menu administrativo">
    <button class="admin-sidebar-toggle" type="button" onclick="toggleAdminMenu()" aria-label="Expandir ou recolher menu administrativo" title="Expandir ou recolher menu"><i class="bi bi-layout-sidebar-inset"></i><span class="admin-sidebar-label ms-2">Menu administrativo</span></button>
    <ul>
        <% if ("ADM".equals(perfil) || "REP".equals(perfil) || "EXT".equals(perfil)) { %><li><a href="membros.jsp" title="Membros"><i class="bi bi-people"></i><span class="admin-sidebar-label">Membros</span></a></li><% } %>
        <% if ("ADM".equals(perfil) || "FIN".equals(perfil) || "REP".equals(perfil) || "EXT".equals(perfil)) { %><li><a href="contribuicoes.jsp" title="Contribuições"><i class="bi bi-cash"></i><span class="admin-sidebar-label">Contribuições</span></a></li><% } %>
        <% if ("ADM".equals(perfil) || "EXT".equals(perfil)) { %><li><a href="avaliacoes.jsp" title="Avaliações"><i class="bi bi-clipboard2-check"></i><span class="admin-sidebar-label">Avaliações</span></a></li><% } %>
        <% if ("ADM".equals(perfil) || "REP".equals(perfil) || "EXT".equals(perfil)) { %><li><a href="relatorios.jsp" title="Relatórios"><i class="bi bi-file-earmark-text"></i><span class="admin-sidebar-label">Relatórios</span></a></li><% } %>
        <% if ("ADM".equals(perfil) || "FIN".equals(perfil)) { %><li><a href="financeiro.jsp" title="Financeiro"><i class="bi bi-wallet2"></i><span class="admin-sidebar-label">Financeiro</span></a></li><% } %>
        <% if ("ADM".equals(perfil)) { %><li><a href="paroquias.jsp" title="Paróquias"><i class="bi bi-building"></i><span class="admin-sidebar-label">Paróquias</span></a></li><li><a href="usuarios.jsp" title="Usuários"><i class="bi bi-shield-lock"></i><span class="admin-sidebar-label">Usuários</span></a></li><% } %>
    </ul>
</aside>
<script>function toggleAdminMenu(){var aberto=document.body.classList.toggle('admin-menu-expanded');try{localStorage.setItem('adminMenuExpanded',aberto?'1':'0');}catch(e){}}(function(){try{if(localStorage.getItem('adminMenuExpanded')==='1')document.body.classList.add('admin-menu-expanded');}catch(e){}})();</script>
<script>
(function(){try{var contexto='<%= request.getContextPath() %>',caminho=location.pathname;if(contexto&&caminho.indexOf(contexto+'/')===0)caminho=caminho.substring(contexto.length+1);else caminho=caminho.replace(/^\/+/, '');if(!/\.(jsp|html)$/i.test(caminho))return;var dados='pagina='+encodeURIComponent(caminho)+'&titulo='+encodeURIComponent(document.title||'');fetch(contexto+'/registrarAcesso.jsp',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded;charset=UTF-8'},body:dados,credentials:'same-origin',keepalive:true}).catch(function(){});}catch(e){}})();
</script>
