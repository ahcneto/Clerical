<%@ page import="java.sql.*" %>
<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%
String perfil = (String) session.getAttribute("usuarioPerfil");
Integer usuarioId = (Integer) session.getAttribute("usuarioId");

if (!"ADM".equals(perfil) || usuarioId == null) {
    response.setStatus(403);
    out.print("{\"ok\":false,\"mensagem\":\"Apenas administradores podem alterar presenças.\"}");
    return;
}

try {
    int encontro = Integer.parseInt(request.getParameter("idEncontro"));
    int pessoa = Integer.parseInt(request.getParameter("idPessoa"));
    int presenca = Integer.parseInt(request.getParameter("flgPresenca"));
    String justificativa = request.getParameter("justificativa");

    if (presenca != 1 && presenca != 2) {
        throw new IllegalArgumentException();
    }
    if (presenca == 2 && (justificativa == null || justificativa.trim().isEmpty())) {
        throw new IllegalArgumentException();
    }
    try (Connection conexao = cad.db.Database.getConnection()) {

        String sqlValidacao =
            "SELECT 1 " +
            "FROM participanteEncontro pe " +
            "JOIN Encontros e ON e.IdEncontro = pe.IdEncontro " +
            "JOIN pessoas p ON p.IdPessoa = pe.IdPessoa AND p.Classe = e.Classe " +
            "WHERE pe.IdEncontro = ? AND pe.IdPessoa = ? AND e.Checklist = 0";

        try (PreparedStatement validacao = conexao.prepareStatement(sqlValidacao)) {
            validacao.setInt(1, encontro);
            validacao.setInt(2, pessoa);

            try (ResultSet resultado = validacao.executeQuery()) {
                if (!resultado.next()) {
                    response.setStatus(409);
                    out.print("{\"ok\":false,\"mensagem\":\"O registro do participante não foi criado para este encontro.\"}");
                    return;
                }
            }
        }

        String sqlAtualizacao =
            "UPDATE participanteEncontro " +
            "SET flgPresenca = ?, Justificativa = ?, IdUsuario = ?, " +
            "flgRegistroManual = 1, latPessoa = NULL, lonPessoa = NULL, distancia = NULL, data_atualizacao = NOW() " +
            "WHERE IdEncontro = ? AND IdPessoa = ?";

        try (PreparedStatement atualizacao = conexao.prepareStatement(sqlAtualizacao)) {
            atualizacao.setInt(1, presenca);
            atualizacao.setString(2, presenca == 2 ? justificativa.trim() : "");
            atualizacao.setInt(3, usuarioId);
            atualizacao.setInt(4, encontro);
            atualizacao.setInt(5, pessoa);
            atualizacao.executeUpdate();
        }
    }

    out.print("{\"ok\":true}");
} catch (Exception erro) {
    response.setStatus(400);
    out.print("{\"ok\":false,\"mensagem\":\"Não foi possível registrar a presença.\"}");
}
%>
