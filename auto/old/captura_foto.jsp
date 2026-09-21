<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String idPessoa = request.getParameter("idPessoa");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Capturar Selfie</title>
    <link rel="stylesheet" href="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.css">
    <script src="https://code.jquery.com/jquery-1.11.3.min.js"></script>
    <script src="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.js"></script>
</head>
<body>
<div data-role="page">
    <div data-role="header"><h1>Capturar Selfie</h1></div>
    <div role="main" class="ui-content">
        <form action="uploadFotoServlet" method="post" enctype="multipart/form-data">
            <input type="hidden" name="idPessoa" value="<%= idPessoa %>">
            <input type="file" name="fotoCamera" accept="image/*" capture="user">
            <input type="submit" value="Enviar Selfie" data-role="button" data-theme="b">
        </form>
    </div>
</div>
</body>
</html>
