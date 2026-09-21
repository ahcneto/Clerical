<%@ page import="java.sql.*, java.util.*, java.text.*" %>
<%
    if ("EXT".equals((String)session.getAttribute("usuarioPerfil"))) {
        response.setStatus(403);
        out.print("Perfil autorizado apenas para consulta.");
        return;
    }

    // Configuração do banco de dados

    Connection con = null;
    PreparedStatement pstmt = null;
    
    // Obtendo os parâmetros da URL
    String idPessoa = request.getParameter("IdPessoa");
    String nome = request.getParameter("Nome");
    String fone1 = request.getParameter("Fone1");
    String email = request.getParameter("Email");
    String endereco = request.getParameter("Endereco");
    String profissao = request.getParameter("Profissao");
    String nomeEsposa = request.getParameter("NomeEsposa");
    String profissaoEsposa = request.getParameter("ProfissaoEsposa");
    String idParoquia = request.getParameter("IdParoquia");

    // Parâmetros do tipo DATA (podem ser nulos)
    String dtNascimento = request.getParameter("DtNascimento");
    String dtNascEsposa = request.getParameter("DtNascEsposa");
    String dtCasamento = request.getParameter("DtCasamento");
	
	String novaURL ="";

    // Função para converter String para java.sql.Date (ou null)
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    java.sql.Date sqlDtNascimento = null;
    java.sql.Date sqlDtNascEsposa = null;
    java.sql.Date sqlDtCasamento = null;
    
    try {
        if (dtNascimento != null && !dtNascimento.isEmpty()) {
            sqlDtNascimento = new java.sql.Date(sdf.parse(dtNascimento).getTime());
        }
        if (dtNascEsposa != null && !dtNascEsposa.isEmpty()) {
            sqlDtNascEsposa = new java.sql.Date(sdf.parse(dtNascEsposa).getTime());
        }
        if (dtCasamento != null && !dtCasamento.isEmpty()) {
            sqlDtCasamento = new java.sql.Date(sdf.parse(dtCasamento).getTime());
        }
    } catch (ParseException e) {
        e.printStackTrace();
    }

    try {
        // Conectar ao banco de dados
        con = cad.db.Database.getConnection();

        if (idPessoa != null && idPessoa.equals("0")) {
            // INSERT
            String sql = "INSERT INTO pessoas (Nome, Endereco, Fone1, Email, Profissao, NomeEsposa, DtNascimento, DtNascEsposa, DtCasamento, ProfissaoEsposa, IdParoquia) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            pstmt = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
        } else {
            // UPDATE
            String sql = "UPDATE pessoas SET Nome=?, Endereco=?, Fone1=?, Email=?, Profissao=?, NomeEsposa=?, DtNascimento=?, DtNascEsposa=?, DtCasamento=?, ProfissaoEsposa=?, IdParoquia=? WHERE IdPessoa=?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(12, Integer.parseInt(idPessoa)); // ID apenas no update
        }

        // Definir os parâmetros
        pstmt.setString(1, nome);
        pstmt.setString(2, endereco);
        pstmt.setString(3, fone1);
        pstmt.setString(4, email);
        pstmt.setString(5, profissao);
        pstmt.setString(6, nomeEsposa);
        pstmt.setDate(7, sqlDtNascimento);
        pstmt.setDate(8, sqlDtNascEsposa);
        pstmt.setDate(9, sqlDtCasamento);
        pstmt.setString(10, profissaoEsposa);
        pstmt.setString(11, idParoquia);

        // Executar a consulta
        int affectedRows = pstmt.executeUpdate();
        if (affectedRows > 0) {
            if (idPessoa.equals("0")) {
                // Obter o ID gerado no INSERT
                ResultSet generatedKeys = pstmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    idPessoa = String.valueOf(generatedKeys.getInt(1));
                }
            }
        }

        // Fechar conexão
        pstmt.close();
        con.close();

       

    } catch (Exception e) {
        e.printStackTrace();
        out.println("Erro ao gravar os dados: " + e.getMessage());
    } finally {
        try {
            if (pstmt != null) pstmt.close();
            if (con != null) con.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
	
	 // Redirecionar para a página de exibição com o ID da pessoa
        //response.sendRedirect("ExibePessoa.xsql?IdPessoa=" + idPessoa);
		novaURL = "ExibePessoa.xsql?IdPessoa=" + idPessoa;
		response.sendRedirect(novaURL);
	
%>
