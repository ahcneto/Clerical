<%@ page import="java.sql.*, java.util.*, java.text.*" %>
<%
if ("EXT".equals((String)session.getAttribute("usuarioPerfil"))) {
    response.setStatus(403);
    out.print("{\"ok\":false,\"mensagem\":\"Perfil autorizado apenas para consulta.\"}");
    return;
}
    // Configuração do banco de dados

    Connection con = null;
    PreparedStatement pstmt = null;
    
    // Obtendo os parâmetros da URL
    String IdPessoa = request.getParameter("IdPessoa");
    String IdEncontro = request.getParameter("IdEncontro");
    String Justificativa = request.getParameter("Justificativa");
	String IdUsuario = request.getParameter("IdUsuario");
	String flgPresenca = request.getParameter("flgPresenca");
  	
	String novaURL ="";

       
    try {
        // Conectar ao banco de dados
        con = cad.db.Database.getConnection();

            // UPDATE
            String sql = "UPDATE participanteEncontro set flgPresenca= ?, justificativa = ?, IdUsuario = ?, flgRegistroManual = 1, latPessoa = NULL, lonPessoa = NULL, distancia = NULL, data_atualizacao=NOW() WHERE IdEncontro = ? AND IdPessoa = ?";
            pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, Integer.parseInt(flgPresenca));
			pstmt.setString(2, Justificativa);
			pstmt.setInt(3, Integer.parseInt(IdUsuario));
            pstmt.setInt(4, Integer.parseInt(IdEncontro)); // ID apenas no update
			pstmt.setInt(5, Integer.parseInt(IdPessoa));
			pstmt.executeUpdate();
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
        //response.sendRedirect("ExibePessoa.xsql?IdPessoa=" + IdPessoa);
		novaURL = "ExibePessoa.xsql?IdPessoa=" + IdPessoa;
		response.sendRedirect(novaURL);
	
%>
