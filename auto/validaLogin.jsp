<%@ page import="java.sql.*, java.text.*" %>
<%
    String fone = request.getParameter("fone1");
    String nascimento = request.getParameter("nascimento");
	
	String ano = request.getParameter("ano");
	String mes = request.getParameter("mes");
	String dia = request.getParameter("dia");
	
	String profile;

    String nome = "";
    int idPessoa = 0;
	int sClasse = 0;
	
	double latUsuario = 0.0;
	double lonUsuario = 0.0;

	String latParam = request.getParameter("latitude");
	String lonParam = request.getParameter("longitude");

if(latParam != null && !latParam.isEmpty() &&
   lonParam != null && !lonParam.isEmpty()){

    try{
        latUsuario = Double.parseDouble(latParam);
        lonUsuario = Double.parseDouble(lonParam);
    }catch(NumberFormatException e){
        latUsuario = 0.0;
        lonUsuario = 0.0;
    }
}

	HttpSession sessao = request.getSession();
	
	if (sessao == null) {
    response.sendRedirect("login.jsp?erro=GetSession");
    return;
}
	
	 Integer idLogin = (sessao != null ? (Integer) sessao.getAttribute("idLogin") : null);
	 
	 if( idLogin != null){
		 response.sendRedirect("paginaFoto.jsp");
	 }
	
    try {
        Connection con = cad.db.Database.getConnection();

         String sql = "SELECT p.IdPessoa, p.Nome, p.Classe as sClasse,IFNULL(u.Profile,'USER') AS profile from pessoas p left join usuarios u on p.IdPessoa = u.IdPessoa WHERE p.Fone1 LIKE ? AND DATE_FORMAT(p.DtNascimento, '%Y-%m-%d') = ?";
		
        PreparedStatement stmt = con.prepareStatement(sql);
       stmt.setString(1, "%" + fone + "%");
        stmt.setString(2, ano+"-"+mes+"-"+dia);
		
	   // out.println("SQL: " +sql);
        ResultSet rs = stmt.executeQuery();

        if (rs.next()) {
            idPessoa = rs.getInt("IdPessoa");
            nome = rs.getString("Nome");
			profile = rs.getString("profile");
			sClasse = rs.getInt("sClasse");
		    sessao.setAttribute("idLogin",idPessoa);
			sessao.setAttribute("Profile",profile);
			sessao.setAttribute("sClasse",sClasse);
			
			sessao.setAttribute("latUsuario",latUsuario);
			sessao.setAttribute("lonUsuario",lonUsuario);
			
		    //out.println("idLogin:"+sessao.getAttribute("idLogin"));
		    //out.println("profile:"+sessao.getAttribute("Profile"));
			//out.println("classe:"+sessao.getAttribute("sClasse"));
			//out.println("latitude:"+sessao.getAttribute("latUsuario"));
			//out.println("longitude:"+sessao.getAttribute("lonUsuario"));
    
			response.sendRedirect("paginaFoto.jsp");
        } else {
           response.sendRedirect("login.jsp?erro=2");
		   //out.println("opss: ");
        }

        con.close();
    } catch (Exception e) {
        out.println("Erro: " + e.getMessage());
    }
%>
