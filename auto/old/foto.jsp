<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.net.URLEncoder" %>
<%
  String nome = request.getParameter("nome");
  String id = request.getParameter("id");
  String foto = request.getParameter("foto");
%>
<!DOCTYPE html>
<html>
<head>
  <title>Foto</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.css">
  <script src="https://code.jquery.com/jquery-1.11.3.min.js"></script>
  <script src="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.js"></script>
</head>
<body>
  <div data-role="page" id="fotoPage">
    <div data-role="header"><h1><%= nome %></h1></div>

    <div data-role="content">
      <img src="fotos/<%= foto %>" alt="Foto da Pessoa" style="width:200px;height:auto;"/>

      <form action="uploadFotoServlet" method="post" enctype="multipart/form-data">
        <input type="hidden" name="id" value="<%= id %>">
        <input type="hidden" name="nome" value="<%= nome %>">

        <label for="fotoArquivo">Selecionar Foto:</label>
        <input type="file" accept="image/*" name="fotoArquivo" id="fotoArquivo">

        <label for="fotoCamera">Tirar Selfie:</label>
        <input type="file" accept="image/*" capture="user" name="fotoCamera" id="fotoCamera">

        <input type="submit" value="Enviar Foto">
      </form>
    </div>
  </div>
</body>
</html>
