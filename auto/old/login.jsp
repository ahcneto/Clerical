<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Login</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet"
          href="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.css">
    <script src="https://code.jquery.com/jquery-1.11.3.min.js"></script>
    <script src="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.js"></script>
</head>
<body>
<%
    String nome = "";
    String idPessoa = request.getParameter("idPessoa");
    if (idPessoa != null && !idPessoa.isEmpty()) {
        // Dados do banco

        try {
            Connection con = cad.db.Database.getConnection();
            String sql = "SELECT Nome FROM pessoas WHERE IdPessoa = ?";
            PreparedStatement stmt = con.prepareStatement(sql);
            stmt.setString(1, idPessoa);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                nome = rs.getString("Nome");
            }
            rs.close(); stmt.close(); con.close();
        } catch (Exception e) {
            out.println("Erro: " + e.getMessage());
        }
    }
%>

<div data-role="page" id="mainPage">
    <div data-role="header">
        <h1>Bem-vindo</h1>
    </div>

    <div role="main" class="ui-content" style="text-align:center;">
        <h3><%= nome %></h3>

        <img src="fotos/foto_<%= idPessoa %>.jpg?ts=<%= System.currentTimeMillis() %>" 
             alt="Foto" width="200" height="200" style="border-radius: 50%; border: 2px solid #ccc; margin-bottom: 20px;" />

        <a href="upload_arquivo.jsp?idPessoa=<%= idPessoa %>" 
           class="ui-btn ui-corner-all ui-icon-arrow-u ui-btn-icon-left">Selecionar Foto do Arquivo</a>

        <a href="captura_foto.jsp?idPessoa=<%= idPessoa %>" 
           class="ui-btn ui-corner-all ui-icon-camera ui-btn-icon-left">Tirar Selfie com a Câmera</a>
    </div>
</div>
</body>
</html>
