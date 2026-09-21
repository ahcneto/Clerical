<%@ page import="java.sql.*" %>
<%
Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    String telefone = request.getParameter("telefone");
	String senha = request.getParameter("senha");

    if (telefone == null || senha == null) {
        response.sendRedirect("login.jsp?erro=1");
        return;
    }

// remove tudo que não for número
telefone = telefone.replaceAll("[^0-9]", "");

// Remove o código do país quando informado e só aplica o DDD padrão
// a números locais. Telefones que já possuem DDD devem ser preservados.
if ((telefone.length() == 12 || telefone.length() == 13) && telefone.startsWith("55")) {
    telefone = telefone.substring(2);
}
if (telefone.length() == 8 || telefone.length() == 9) {
    telefone = "85" + telefone;
}
    conn = cad.db.Database.getConnection();

    String sql =
        "select p.IdPessoa as id, p.Nome as nome, p.Classe as idGrupo, " +
        "p.DescClasse as grupo, p.IdRegiao, p.Regiao, p.Paroquia as Paroquia, " +
        "p.Fone1 as telefone, p.DtNascimento, IFNULL(u.Profile, 'USR') as perfil " +
        "from sqlPessoas p " +
        "left join usuarios u on p.IdPessoa = u.IdPessoa " +
        "where status = 1 and p.Fone1 = ?";

    ps = conn.prepareStatement(sql);
    ps.setString(1, telefone);

    rs = ps.executeQuery();

  if(rs.next()) {

    String dataNascimentoTexto = rs.getString("DtNascimento");

    String senhaCompleta = "";
    String senhaCurta = "";

    if (dataNascimentoTexto != null && !dataNascimentoTexto.trim().isEmpty()) {
        dataNascimentoTexto = dataNascimentoTexto.trim();
        java.time.format.DateTimeFormatter formatoNascimento =
            dataNascimentoTexto.contains("/")
                ? java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy")
                : java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd");
        java.time.LocalDate nascimento =
            java.time.LocalDate.parse(dataNascimentoTexto, formatoNascimento);
        senhaCompleta = String.format(
            "%02d%02d%04d",
            nascimento.getDayOfMonth(),
            nascimento.getMonthValue(),
            nascimento.getYear()
        );
        senhaCurta = String.format(
            "%02d%02d%02d",
            nascimento.getDayOfMonth(),
            nascimento.getMonthValue(),
            nascimento.getYear() % 100
        );
    }

    // Aceita DDMMAAAA ou DDMMAA, com ou sem separadores.
    String senhaDigitada = senha.replaceAll("[^0-9]", "");

    if (
        senhaDigitada.equals(senhaCompleta) ||
        senhaDigitada.equals(senhaCurta)
    ) {
        session.setAttribute("usuarioId", rs.getInt("id"));
		session.setAttribute("usuarioNome", rs.getString("nome"));
		session.setAttribute("usuarioPerfil", rs.getString("perfil"));
		session.setAttribute("usuarioGrupoId", rs.getInt("idGrupo"));
		session.setAttribute("usuarioGrupo", rs.getString("grupo"));
		session.setAttribute("usuarioRegiaoId", rs.getInt("IdRegiao"));
		session.setAttribute("usuarioRegiao", rs.getString("Regiao"));
		session.setAttribute("usuarioParoquia", rs.getString("Paroquia"));
		session.setAttribute("usuarioTelefone", rs.getString("telefone"));

        // O log não pode impedir o acesso caso a tabela ainda não tenha sido criada.
        String enderecoIp = request.getHeader("X-Forwarded-For");
        if (enderecoIp != null && enderecoIp.contains(",")) enderecoIp = enderecoIp.split(",")[0].trim();
        if (enderecoIp == null || enderecoIp.trim().isEmpty()) enderecoIp = request.getRemoteAddr();
        String userAgent = request.getHeader("User-Agent");
        if (enderecoIp != null && enderecoIp.length() > 45) enderecoIp = enderecoIp.substring(0, 45);
        if (userAgent != null && userAgent.length() > 500) userAgent = userAgent.substring(0, 500);
        try (PreparedStatement logLogin = conn.prepareStatement(
                "INSERT INTO LogLogin (IdPessoa,DataLogin,EnderecoIp,UserAgent,IdSessao) VALUES (?,NOW(),?,?,?)")) {
            logLogin.setInt(1, rs.getInt("id"));
            logLogin.setString(2, enderecoIp);
            logLogin.setString(3, userAgent);
            logLogin.setString(4, session.getId());
            logLogin.executeUpdate();
        } catch (SQLException erroLog) {
            application.log("Não foi possível registrar o login do usuário " + rs.getInt("id"), erroLog);
        }

		response.sendRedirect("index.jsp");
		return;
    } else {
        response.sendRedirect("login.jsp?erro=1");
		return;
    }

} else {
     response.sendRedirect("login.jsp?erro=1");
		return;
}

} catch(Exception e) {
    out.println("Erro: " + e.getMessage());
} finally {
    if(rs != null) try { rs.close(); } catch(Exception e){}
    if(ps != null) try { ps.close(); } catch(Exception e){}
    if(conn != null) try { conn.close(); } catch(Exception e){}
}
%>
