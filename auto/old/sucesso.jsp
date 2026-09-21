<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.net.URLEncoder" %>
<%
  String id = request.getParameter("id");
  String nome = request.getParameter("nome");
  if (nome == null) nome = "";
  String classe = "pessoa"; // ou qualquer outro valor fixo que você use
  String nomeFoto = classe + "_" + id + ".jpg";
%>
<!DOCTYPE html>
<html>
<head>
  <title>Bem-vindo</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.css">
  <script src="https://code.jquery.com/jquery-1.11.3.min.js"></script>
  <script src="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.js"></script>
</head>
<body>
  <div data-role="page" id="sucessoPage">
    <div data-role="header">
      <h1><%= nome %></h1>
    </div>

    <div role="main" class="ui-content" style="text-align:center;">
      <p>Foto atual:</p>
      <img src="fotos/<%= nomeFoto %>" alt="Foto" style="width:200px;height:auto;border-radius:10px;border:1px solid #ccc;" onerror="this.src='img/placeholder.jpg';"/>

      <form action="uploadFotoServlet" method="post" enctype="multipart/form-data">
        <input type="hidden" name="id" value="<%= id %>"/>
        <input type="hidden" name="classe" value="<%= classe %>"/>

        <div style="margin-top:20px;">
          <label for="fotoArquivo">Selecionar Foto do Arquivo:</label>
          <input type="file" name="fotoArquivo" accept="image/*">
        </div>

        <div style="margin-top:20px;">
          <label for="fotoCamera">Tirar Selfie com a Câmera:</label>
          <input type="file" name="fotoCamera" accept="image/*" capture="user">
        </div>

        <input type="submit" value="Enviar Foto" data-role="button" data-theme="b" style="margin-top:20px;"/>
      </form>
    </div>
  </div>
</body>
</html>
