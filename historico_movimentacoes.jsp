<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%!
private String jsonHistorico(String valor) {
    if (valor == null) return "";
    return valor.replace("\\", "\\\\").replace("\"", "\\\"")
        .replace("\r", "\\r").replace("\n", "\\n").replace("\t", "\\t");
}
%>
<%
response.setHeader("Cache-Control", "no-store");
if (session.getAttribute("usuarioId") == null || !"ADM".equals((String) session.getAttribute("usuarioPerfil"))) {
    response.setStatus(403);
    out.print("{\"ok\":false,\"mensagem\":\"Acesso permitido apenas para administradores.\"}");
    return;
}

int idPessoa;
try { idPessoa = Integer.parseInt(request.getParameter("idPessoa")); }
catch (Exception e) {
    response.setStatus(400);
    out.print("{\"ok\":false,\"mensagem\":\"Membro inválido.\"}");
    return;
}

StringBuilder itens = new StringBuilder();
try {
    try (Connection con = cad.db.Database.getConnection();
         PreparedStatement ps = con.prepareStatement(
            "SELECT h.TipoMovimentacao, DATE_FORMAT(h.DataMovimentacao,'%d/%m/%Y') DataMovimentacao, " +
            "h.ClasseAnterior,h.ClasseNova,h.StatusAnterior,h.StatusNovo,h.Motivo, " +
            "IFNULL(ga.NomeSingular,CAST(h.ClasseAnterior AS CHAR)) GrupoAnterior,IFNULL(gn.NomeSingular,CAST(h.ClasseNova AS CHAR)) GrupoNovo, " +
            "DATE_FORMAT(h.DataRegistro,'%d/%m/%Y %H:%i') DataRegistro, IFNULL(u.Nome,'Usuário não encontrado') Usuario " +
            "FROM HistoricoMovimentacaoMembro h LEFT JOIN pessoas u ON u.IdPessoa=h.IdUsuarioRegistro " +
            "LEFT JOIN grupos ga ON ga.IdGrupo=h.ClasseAnterior LEFT JOIN grupos gn ON gn.IdGrupo=h.ClasseNova " +
            "WHERE h.IdPessoa=? ORDER BY h.DataMovimentacao DESC,h.DataRegistro DESC,h.IdMovimentacao DESC")) {
        ps.setInt(1, idPessoa);
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                if (itens.length() > 0) itens.append(',');
                Integer classeAnterior = (Integer) rs.getObject("ClasseAnterior");
                Integer classeNova = (Integer) rs.getObject("ClasseNova");
                Integer statusAnterior = (Integer) rs.getObject("StatusAnterior");
                Integer statusNovo = (Integer) rs.getObject("StatusNovo");
                String mudanca = "Sem alteração cadastral";
                if (classeAnterior != null && classeNova != null && !classeAnterior.equals(classeNova))
                    mudanca = rs.getString("GrupoAnterior") + " → " + rs.getString("GrupoNovo");
                else if (statusAnterior != null && statusNovo != null && !statusAnterior.equals(statusNovo))
                    mudanca = statusNovo == 0 ? "Membro inativado" : "Status alterado";

                itens.append("{\"tipo\":\"").append(jsonHistorico(rs.getString("TipoMovimentacao")))
                    .append("\",\"data\":\"").append(jsonHistorico(rs.getString("DataMovimentacao")))
                    .append("\",\"movimentacao\":\"").append(jsonHistorico(mudanca))
                    .append("\",\"motivo\":\"").append(jsonHistorico(rs.getString("Motivo")))
                    .append("\",\"usuario\":\"").append(jsonHistorico(rs.getString("Usuario")))
                    .append("\",\"dataRegistro\":\"").append(jsonHistorico(rs.getString("DataRegistro"))).append("\"}");
            }
        }
    }
    out.print("{\"ok\":true,\"movimentacoes\":[" + itens + "]}");
} catch (SQLSyntaxErrorException e) {
    response.setStatus(500);
    out.print("{\"ok\":false,\"mensagem\":\"Execute primeiro o script sql/movimentacao_membros.sql.\"}");
} catch (Exception e) {
    response.setStatus(500);
    out.print("{\"ok\":false,\"mensagem\":\"Não foi possível carregar o histórico de movimentações.\"}");
}
%>
