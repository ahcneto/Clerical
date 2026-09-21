<%@ page import="java.sql.*" %>
<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%
String perfilUsuario = (String) session.getAttribute("usuarioPerfil");
Integer usuarioId = (Integer) session.getAttribute("usuarioId");

if (!"ADM".equals(perfilUsuario) || usuarioId == null) {
    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
    out.print("{\"ok\":false,\"mensagem\":\"Apenas administradores podem atualizar presenças.\"}");
    return;
}

String idPessoaParam = request.getParameter("idPessoa");
String idEncontroParam = request.getParameter("idEncontro");
String flgPresencaParam = request.getParameter("flgPresenca");
String justificativa = request.getParameter("justificativa");

try {
    int idPessoa = Integer.parseInt(idPessoaParam);
    int idEncontro = Integer.parseInt(idEncontroParam);
    int flgPresenca = Integer.parseInt(flgPresencaParam);

    if (flgPresenca != 1 && flgPresenca != 2) {
        throw new IllegalArgumentException("Status de presença inválido.");
    }
    if (flgPresenca == 2 && (justificativa == null || justificativa.trim().isEmpty())) {
        throw new IllegalArgumentException("A justificativa é obrigatória.");
    }
    try (Connection conexao = cad.db.Database.getConnection();
         PreparedStatement comando = conexao.prepareStatement(
            "UPDATE participanteEncontro " +
            "SET flgPresenca = ?, justificativa = ?, IdUsuario = ?, " +
            "flgRegistroManual = 1, latPessoa = NULL, lonPessoa = NULL, distancia = NULL, data_atualizacao = NOW() " +
            "WHERE IdEncontro = ? AND IdPessoa = ? AND flgPresenca = 0")) {

        comando.setInt(1, flgPresenca);
        comando.setString(2, flgPresenca == 2 ? justificativa.trim() : "");
        comando.setInt(3, usuarioId);
        comando.setInt(4, idEncontro);
        comando.setInt(5, idPessoa);

        if (comando.executeUpdate() != 1) {
            response.setStatus(HttpServletResponse.SC_CONFLICT);
            out.print("{\"ok\":false,\"mensagem\":\"A falta não está mais disponível para atualização.\"}");
            return;
        }
    }

    out.print("{\"ok\":true}");
} catch (IllegalArgumentException erro) {
    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
    out.print("{\"ok\":false,\"mensagem\":\"Dados da presença inválidos.\"}");
} catch (Exception erro) {
    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
    out.print("{\"ok\":false,\"mensagem\":\"Erro ao atualizar a presença.\"}");
}
%>
