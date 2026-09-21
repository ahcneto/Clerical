<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.io.*" %>
<%
    String idPessoa = request.getParameter("idPessoa");
    String nome = request.getParameter("nome");
    String caminho = "fotos/foto_" + idPessoa + ".jpg";
%>
<html>
<head>
    <title>Foto do Usuário</title>
    <link rel="stylesheet" href="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.css" />
    <script src="https://code.jquery.com/jquery-1.11.3.min.js"></script>
    <script src="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.js"></script>
</head>
<body>
<div data-role="page">
    <div data-role="header"><h1><%= nome %></h1></div>
    <div data-role="content" style="text-align:center">
        <img src="<%= caminho %>?t=<%= System.currentTimeMillis() %>" width="200" height="200" /><br><br>
        <a href="uploadArquivo.jsp?idPessoa=<%=idPessoa%>&nome=<%=nome%>" class="ui-btn">Selecionar Foto do Arquivo</a>
        <a href="uploadCamera.jsp?idPessoa=<%=idPessoa%>&nome=<%=nome%>" class="ui-btn">Tirar Selfie com a Câmera</a>
    </div>
</div>
</body>
</html>