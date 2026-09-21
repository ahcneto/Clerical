<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="javax.servlet.*" %>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Gerenciar Pessoas</title>
     <link rel="stylesheet" href="jquery/jquery.mobile-1.4.5.min.css"/>
				<script src="jquery/jquery.min.js"></script>
				<script src="jquery/jquery.mobile-1.4.5.min.js"></script>
</head>
<body>

<div data-role="page" id="home">
    <div data-role="header">
        <h1>Gerenciar Pessoas</h1>
    </div>

<%


    // Configuração do Banco de Dados
    Connection con = null;

    try {
        con = cad.db.Database.getConnection();
    } catch (Exception e) {
        out.println("Erro de conexão: " + e.getMessage());
    }
%>

    <div data-role="content">
        <a href="#addPessoa" data-role="button">Adicionar Pessoa</a>
        <ul data-role="listview" data-inset="true">
			
            <%
		
                Statement stmt = con.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT * FROM pessoas");
                while (rs.next()) {
            %>
            <li>
                <a href="#editPessoa" 
                   onclick="editarPessoa('<%= rs.getInt("IdPessoa") %>', '<%= rs.getString("Nome") %>', 
                                        '<%= rs.getString("Endereco") %>', '<%= rs.getString("fone1") %>', 
                                        '<%= rs.getString("Email") %>', '<%= rs.getString("NomeEsposa") %>')">
                    <h2><%= rs.getString("Nome") %></h2>
                    <p>Email: <%= rs.getString("Email") %></p>
                </a>
            </li>
            <%
                }
                con.close();
            %>
        </ul>
    </div>
</div>

<div data-role="page" id="addPessoa">
    <div data-role="header">
        <h1>Adicionar Pessoa</h1>
    </div>
    <div data-role="content">
        <form action="pessoas.jsp" method="post">
            <input type="hidden" name="action" value="insert">
            <label for="nome">Nome:</label>
            <input type="text" name="nome" required>
            
            <label for="endereco">Endereço:</label>
            <input type="text" name="endereco">
            
            <label for="telefone">Telefone:</label>
            <input type="text" name="fone1">
            
            <label for="email">Email:</label>
            <input type="email" name="email">
            
            <label for="nomeEsposa">Nome da Esposa:</label>
            <input type="text" name="nomeEsposa">
            
            <input type="submit" value="Salvar">
        </form>
    </div>
</div>

<div data-role="page" id="editPessoa">
    <div data-role="header">
        <h1>Editar Pessoa</h1>
    </div>
    <div data-role="content">
        <form action="pessoas.jsp" method="post">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="idPessoa" id="editIdPessoa">
            
            <label for="editNome">Nome:</label>
            <input type="text" name="nome" id="editNome" required>
            
            <label for="editEndereco">Endereço:</label>
            <input type="text" name="endereco" id="editEndereco">
            
            <label for="editTelefone">Telefone:</label>
            <input type="text" name="fone1" id="editTelefone">
            
            <label for="editEmail">Email:</label>
            <input type="email" name="email" id="editEmail">
            
            <label for="editNomeEsposa">Nome da Esposa:</label>
            <input type="text" name="nomeEsposa" id="editNomeEsposa">
            
            <input type="submit" value="Atualizar">
        </form>
    </div>
</div>

<script>
    function editarPessoa(id, nome, endereco, telefone, email, nomeEsposa) {
        $("#editIdPessoa").val(id);
        $("#editNome").val(nome);
        $("#editEndereco").val(endereco);
        $("#editTelefone").val(fone1);
        $("#editEmail").val(email);
        $("#editNomeEsposa").val(nomeEsposa);
    }
</script>

<%
    if (request.getMethod().equalsIgnoreCase("post")) {
        String action = request.getParameter("action");
        
        PreparedStatement pstmt;

        if ("insert".equals(action)) {
            pstmt = con.prepareStatement("INSERT INTO pessoas (Nome, Endereco, Fone1, Email, NomeEsposa) VALUES (?, ?, ?, ?, ?)");
            pstmt.setString(1, request.getParameter("nome"));
            pstmt.setString(2, request.getParameter("endereco"));
            pstmt.setString(3, request.getParameter("telefone"));
            pstmt.setString(4, request.getParameter("email"));
            pstmt.setString(5, request.getParameter("nomeEsposa"));
            pstmt.executeUpdate();
        } else if ("update".equals(action)) {
            pstmt = con.prepareStatement("UPDATE pessoas SET Nome=?, Endereco=?, fone1=?, Email=?, NomeEsposa=? WHERE IdPessoa=?");
            pstmt.setString(1, request.getParameter("nome"));
            pstmt.setString(2, request.getParameter("endereco"));
            pstmt.setString(3, request.getParameter("fone1"));
            pstmt.setString(4, request.getParameter("email"));
            pstmt.setString(5, request.getParameter("nomeEsposa"));
            pstmt.setInt(6, Integer.parseInt(request.getParameter("idPessoa")));
            pstmt.executeUpdate();
        }

        con.close();
        response.sendRedirect("cadPessoas.jsp");
    }
%>

</body>
</html>
