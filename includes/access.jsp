<%
String perfil = (String) session.getAttribute("usuarioPerfil");
String pagina = request.getRequestURI();

boolean permitido = true;

// Membros -> ADM ou REP
if (pagina.contains("membros.jsp")) {
    permitido = "ADM".equals(perfil) || "REP".equals(perfil) || "EXT".equals(perfil);
}

// Encontros -> ADM, REP ou USR
if (pagina.contains("encontros.jsp")) {
    permitido = "ADM".equals(perfil) || "REP".equals(perfil) || "USR".equals(perfil) || "EXT".equals(perfil);
}

// Contribuições -> ADM ou FIN
if (pagina.contains("contribuicoes.jsp")) {
    permitido = "ADM".equals(perfil) || "FIN".equals(perfil) || "REP".equals(perfil) || "EXT".equals(perfil);
}

if (pagina.contains("avaliacoes.jsp")) {
    permitido = "ADM".equals(perfil) || "EXT".equals(perfil);
}

if (pagina.contains("financeiro.jsp") || pagina.contains("relatorioFinanceiro.jsp")) {
    permitido = "ADM".equals(perfil) || "FIN".equals(perfil);
}

if (pagina.contains("usuarios.jsp") || pagina.contains("grupos.jsp")) {
    permitido = "ADM".equals(perfil);
}

if (!permitido) {
    response.sendRedirect("index.jsp");
    return;
}
%>
