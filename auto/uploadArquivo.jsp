<%
    String idPessoa = request.getParameter("idPessoa");
    String nome = request.getParameter("nome");
	
	if (idPessoa == null) {
		response.sendRedirect("login.jsp?erro=1");
	}
%>
<html>

<head>
    <title>Upload de Foto</title>
    <link rel="stylesheet" href="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.css">
    <script src="https://code.jquery.com/jquery-1.11.3.min.js"></script>
    <script src="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.js"></script>
</head>

<body>
<div data-role="page">
    <div data-role="header">
        <h1>Envio de Foto</h1>
    </div>
	<p><strong>Nome:</strong> <%= nome %></p>
<h3>Selecionar Arquivo</h3>
<form action="/cad/UploadFotoServlet" method="post" enctype="multipart/form-data" data-ajax="false">
    <input type="hidden" name="idPessoa" value="<%=idPessoa%>" />
    <input type="hidden" name="nome" value="<%=nome%>" />
    <input type="file" name="foto" accept="image/*"><br>
    <input type="submit" value="Enviar">
</form>
</div>
</body>
</html>