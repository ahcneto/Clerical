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
    <li class="nav-item">
        <a class="nav-link" href="index.jsp">
            <i class="bi bi-house"></i> Início
        </a>
    </li>

			<% if ("ADM".equals(perfil) || "REP".equals(perfil) || "EXT".equals(perfil)) { %>
		<li class="nav-item">
			<a class="nav-link" href="membros.jsp">
				<i class="bi bi-people"></i> Membros
			</a>
		</li>
		<% } %>

				 <% if ("ADM".equals(perfil) || "REP".equals(perfil) || "USR".equals(perfil) || "FIN".equals(perfil) || "EXT".equals(perfil)) { %>
		<li class="nav-item">
			<a class="nav-link" href="encontros.jsp">
				<i class="bi bi-calendar-event"></i> Encontros
			</a>
		</li>
		<% } %>

			<% if ("ADM".equals(perfil) || "FIN".equals(perfil) || "REP".equals(perfil) || "EXT".equals(perfil)) { %>
		<li class="nav-item">
			<a class="nav-link" href="contribuicoes.jsp">
				<i class="bi bi-cash"></i> Contribuições
			</a>
		</li>
		<% } %>

        <% if ("ADM".equals(perfil) || "REP".equals(perfil) || "USR".equals(perfil) || "FIN".equals(perfil) || "EXT".equals(perfil)) { %>
        <li class="nav-item">
            <a class="nav-link" href="formacoes.jsp">
                <i class="bi bi-journal-check"></i> Formação
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link" href="documentacoes.jsp">
                <i class="bi bi-folder-check"></i> Documentação
            </a>
        </li>
        <% } %>

		<% if ("ADM".equals(perfil) || "EXT".equals(perfil)) { %>
		<li class="nav-item">
			<a class="nav-link" href="avaliacoes.jsp">
				<i class="bi bi-clipboard2-check"></i> Avaliações
			</a>
		</li>
		<% } %>

        	<% if ("ADM".equals(perfil) || "REP".equals(perfil) || "EXT".equals(perfil)) { %>
		<li class="nav-item">
			<a class="nav-link" href="relatorios.jsp">
				<i class="bi bi-file-earmark-text "></i> Relatórios
			</a>
		</li>
		<% } %>

        <% if ("ADM".equals(perfil) || "FIN".equals(perfil)) { %>
        <li class="nav-item"><a class="nav-link" href="financeiro.jsp"><i class="bi bi-wallet2"></i> Financeiro</a></li>
        <% } %>

        <% if ("ADM".equals(perfil) || "REP".equals(perfil) || "USR".equals(perfil) || "FIN".equals(perfil) || "EXT".equals(perfil)) { %>
          <li class="nav-item"><a class="nav-link" href="dashboard.html"><i class="bi bi-bar-chart"></i> Painel</a></li>
        <% } %>

        <% if ("ADM".equals(perfil)) { %>
        <li class="nav-item">
            <a class="nav-link" href="usuarios.jsp">
                <i class="bi bi-shield-lock"></i> Usuários
            </a>
        </li>
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
<script>
(function(){try{var contexto='<%= request.getContextPath() %>',caminho=location.pathname;if(contexto&&caminho.indexOf(contexto+'/')===0)caminho=caminho.substring(contexto.length+1);else caminho=caminho.replace(/^\/+/, '');if(!/\.(jsp|html)$/i.test(caminho))return;var dados='pagina='+encodeURIComponent(caminho)+'&titulo='+encodeURIComponent(document.title||'');fetch(contexto+'/registrarAcesso.jsp',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded;charset=UTF-8'},body:dados,credentials:'same-origin',keepalive:true}).catch(function(){});}catch(e){}})();
</script>
