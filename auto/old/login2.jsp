<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.sql.*" %>
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
    String fone1 = request.getParameter("fone1");
    String dtNascimento = request.getParameter("dtNascimento");
    String nome = "";
    String idPessoa = "";
    boolean logado = false;

    if (fone1 != null && dtNascimento != null) {
        // Conexão com o banco
        Connection con = null;

        try {
            con = cad.db.Database.getConnection();

            String sql = "SELECT IdPessoa, Nome FROM pessoas WHERE Fone1 LIKE ? AND DATE_FORMAT(DtNascimento, '%Y%m%d') = ?";
            PreparedStatement stmt = con.prepareStatement(sql);
            stmt.setString(1, "%" + fone1 + "%");
            stmt.setString(2, dtNascimento);

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                idPessoa = rs.getString("IdPessoa");
                nome = rs.getString("Nome");
                logado = true;
            }

            rs.close();
            stmt.close();
            con.close();
        } catch (Exception e) {
            out.println("<p>Erro de conexão: " + e.getMessage() + "</p>");
        }
    }
%>

<% if (!logado) { %>
<!-- Tela de Login -->
<div data-role="page" id="loginPage">
    <div data-role="header">
        <h1>Login</h1>
    </div>
    <div role="main" class="ui-content">
        <form method="post" action="login2.jsp">
            <label for="fone1">Telefone:</label>
            <input type="text" name="fone1" id="fone1" placeholder="Digite seu telefone">

            <label for="dtNascimento">Data de Nascimento (YYYYMMDD):</label>
            <input type="text" name="dtNascimento" id="dtNascimento" placeholder="Ex: 19900101">

            <input type="submit" value="Entrar" data-role="button" data-theme="b"/>

            <% if (fone1 != null) { %>
                <div style="color:red; margin-top:15px;">
                    Usuário não encontrado. Tente novamente.
                </div>
            <% } %>
        </form>
    </div>
</div>

<% } else { %>
<!-- Tela de Sucesso -->
<div data-role="page" id="sucessoPage">
    <div data-role="header">
        <h1><%= nome %></h1>
    </div>
    <div role="main" class="ui-content" style="text-align:center;">
        <p>Foto atual:</p>
        <img src="../fotos/foto_<%= idPessoa %>.jpg" alt="Foto" style="width:200px;height:auto;border-radius:10px;border:1px solid #ccc;" onerror="this.src='img/placeholder.jpg';"/>

        <form action="uploadFotoServlet" method="post" enctype="multipart/form-data">
            <input type="hidden" name="idPessoa" value="<%= idPessoa %>"/>
            <input type="hidden" name="classe" value="foto"/>

           <a href="upload_arquivo.jsp?idPessoa=<%= idPessoa %>" 
           class="ui-btn ui-corner-all ui-icon-arrow-u ui-btn-icon-left">Selecionar Foto do Arquivo</a>

        <a href="captura_foto.jsp?idPessoa=<%= idPessoa %>" 
           class="ui-btn ui-corner-all ui-icon-camera ui-btn-icon-left">Tirar Selfie com a Câmera</a>
		   
        </form>
    </div>
</div>
<% } %>

</body>
</html>
