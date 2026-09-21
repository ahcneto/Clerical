<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Gerenciar Pessoas</title>
    <link rel="stylesheet" href="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.js"></script>
</head>
<body>

<%


    // Configuração do Banco de Dados
    Connection con = null;

    try {
        con = cad.db.Database.getConnection();
    } catch (Exception e) {
        out.println("Erro de conexão: " + e.getMessage());
    }
%>

<div data-role="page" id="home">
    <div data-role="header">
        <h1>Gerenciar Pessoas</h1>
    </div>

    <div data-role="content">
        <a href="#addPessoa" data-role="button">Adicionar Pessoa</a>
        <ul data-role="listview" data-inset="true">
            <%
                if (con != null) {
                    Statement stmt = con.createStatement();
                    ResultSet rs = stmt.executeQuery("SELECT * FROM pessoas");
                    while (rs.next()) {
            %>
            <li>
                <h2><%= rs.getString("Nome") %></h2>
                <p>Email: <%= rs.getString("Email") %></p>
            </li>
            <%
                    }
                    rs.close();
                    stmt.close();
                }
            %>
        </ul>
    </div>
</div>

<%
    // Fechar conexão
    if (con != null) {
        con.close();
    }
%>

</body>
</html>
