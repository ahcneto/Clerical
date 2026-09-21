<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%!
private String json(String valor) {
    if (valor == null) return "";
    return valor.replace("\\", "\\\\").replace("\"", "\\\"")
        .replace("\r", "\\r").replace("\n", "\\n");
}
%>
<%
response.setHeader("Cache-Control", "no-store");
String perfilUsuario = (String) session.getAttribute("usuarioPerfil");
Integer idUsuario = (Integer) session.getAttribute("usuarioId");
if (idUsuario == null || !"ADM".equals(perfilUsuario)) {
    response.setStatus(403);
    out.print("{\"ok\":false,\"mensagem\":\"Apenas administradores podem movimentar membros.\"}");
    return;
}

int idPessoa;
try { idPessoa = Integer.parseInt(request.getParameter("idPessoa")); }
catch (Exception e) {
    response.setStatus(400);
    out.print("{\"ok\":false,\"mensagem\":\"Membro inválido.\"}");
    return;
}

if (!"POST".equalsIgnoreCase(request.getMethod())) {
    try (Connection con = cad.db.Database.getConnection();
         PreparedStatement ps = con.prepareStatement(
             "SELECT t.IdTransicao,t.NomeAcao,IFNULL(t.EfeitoAdicional,'') Efeito,t.ExigeMotivo," +
             "t.IdGrupoDestino,d.NomeSingular DestinoNome " +
             "FROM pessoas p JOIN grupo_transicoes t ON t.IdGrupoOrigem=p.Classe AND t.StatusTransicao='ATIVO' " +
             "JOIN grupos d ON d.IdGrupo=t.IdGrupoDestino AND d.StatusGrupo='ATIVO' " +
             "WHERE p.IdPessoa=? ORDER BY t.Ordem,t.IdTransicao")) {
        ps.setInt(1, idPessoa);
        StringBuilder itens = new StringBuilder();
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                if (itens.length() > 0) itens.append(',');
                itens.append("{\"id\":").append(rs.getInt("IdTransicao"))
                    .append(",\"acao\":\"").append(json(rs.getString("NomeAcao")))
                    .append("\",\"efeito\":\"").append(json(rs.getString("Efeito")))
                    .append("\",\"destino\":").append(rs.getInt("IdGrupoDestino"))
                    .append(",\"destinoNome\":\"").append(json(rs.getString("DestinoNome")))
                    .append("\",\"exigeMotivo\":").append(rs.getBoolean("ExigeMotivo")).append('}');
            }
        }
        out.print("{\"ok\":true,\"transicoes\":[" + itens + "]}");
    } catch (Exception e) {
        response.setStatus(500);
        out.print("{\"ok\":false,\"mensagem\":\"Não foi possível carregar as transições do grupo.\"}");
    }
    return;
}

String tipo = request.getParameter("tipo");
String dataTexto = request.getParameter("dataMovimentacao");
String motivo = request.getParameter("motivo");
if (motivo == null) motivo = "";
motivo = motivo.trim();
if (!("INATIVACAO".equals(tipo) || "OBSERVACAO".equals(tipo) || (tipo != null && tipo.startsWith("TRANSICAO:")))) {
    response.setStatus(400); out.print("{\"ok\":false,\"mensagem\":\"Tipo de movimentação inválido.\"}"); return;
}

java.sql.Date dataMovimentacao;
try { dataMovimentacao = java.sql.Date.valueOf(dataTexto); }
catch (Exception e) {
    response.setStatus(400); out.print("{\"ok\":false,\"mensagem\":\"Informe uma data válida.\"}"); return;
}
if (("INATIVACAO".equals(tipo) || "OBSERVACAO".equals(tipo)) && motivo.isEmpty()) {
    response.setStatus(400); out.print("{\"ok\":false,\"mensagem\":\"Informe a descrição da movimentação.\"}"); return;
}

Connection con = null;
try {
    con = cad.db.Database.getConnection();
    con.setAutoCommit(false);
    int classeAnterior, statusAnterior;
    String observacaoAnterior;
    try (PreparedStatement ps = con.prepareStatement("SELECT Classe,IFNULL(Status,1) Status,Obs FROM pessoas WHERE IdPessoa=? FOR UPDATE")) {
        ps.setInt(1, idPessoa);
        try (ResultSet rs = ps.executeQuery()) {
            if (!rs.next()) throw new IllegalArgumentException("Membro não encontrado.");
            classeAnterior=rs.getInt("Classe"); statusAnterior=rs.getInt("Status"); observacaoAnterior=rs.getString("Obs");
        }
    }
    if (statusAnterior == 0 && !"OBSERVACAO".equals(tipo)) throw new IllegalArgumentException("Este membro já está inativo.");
    int classeNova=classeAnterior, statusNovo=statusAnterior;
    String tipoHistorico=tipo;

    if (tipo.startsWith("TRANSICAO:")) {
        int transicaoId;
        try { transicaoId=Integer.parseInt(tipo.substring("TRANSICAO:".length())); }
        catch (Exception e) { throw new IllegalArgumentException("Transição inválida."); }
        String campoData=null, nomeAcao=null; boolean exigeMotivo=false;
        try (PreparedStatement ps=con.prepareStatement(
            "SELECT t.IdGrupoDestino,t.NomeAcao,t.CampoDataAtualizar,t.ExigeMotivo FROM grupo_transicoes t " +
            "JOIN grupos d ON d.IdGrupo=t.IdGrupoDestino AND d.StatusGrupo='ATIVO' " +
            "WHERE t.IdTransicao=? AND t.IdGrupoOrigem=? AND t.StatusTransicao='ATIVO' FOR UPDATE")) {
            ps.setInt(1,transicaoId); ps.setInt(2,classeAnterior);
            try(ResultSet rs=ps.executeQuery()) {
                if(!rs.next()) throw new IllegalArgumentException("Esta transição não é permitida para o grupo atual.");
                classeNova=rs.getInt("IdGrupoDestino"); nomeAcao=rs.getString("NomeAcao");
                campoData=rs.getString("CampoDataAtualizar"); exigeMotivo=rs.getBoolean("ExigeMotivo");
            }
        }
        if(exigeMotivo && motivo.isEmpty()) throw new IllegalArgumentException("Informe o motivo desta transição.");
        if(campoData!=null && !campoData.isEmpty() && !"DtOrdenacao".equals(campoData)) throw new IllegalArgumentException("Campo de data não permitido na transição.");
        String sql="DtOrdenacao".equals(campoData)?"UPDATE pessoas SET Classe=?,DtOrdenacao=? WHERE IdPessoa=?":"UPDATE pessoas SET Classe=? WHERE IdPessoa=?";
        try(PreparedStatement ps=con.prepareStatement(sql)) {
            ps.setInt(1,classeNova);
            if("DtOrdenacao".equals(campoData)){ps.setDate(2,dataMovimentacao);ps.setInt(3,idPessoa);}else ps.setInt(2,idPessoa);
            ps.executeUpdate();
        }
        tipoHistorico="TRANSICAO";
        if(motivo.isEmpty()) motivo=nomeAcao;
    } else if ("INATIVACAO".equals(tipo)) {
        statusNovo=0;
        try(PreparedStatement ps=con.prepareStatement("UPDATE pessoas SET Status=0,Obs=? WHERE IdPessoa=?")){ps.setString(1,motivo);ps.setInt(2,idPessoa);ps.executeUpdate();}
    }

    try (PreparedStatement ps = con.prepareStatement(
        "INSERT INTO HistoricoMovimentacaoMembro (IdPessoa,TipoMovimentacao,DataMovimentacao,ClasseAnterior,ClasseNova,StatusAnterior,StatusNovo,ObservacaoAnterior,Motivo,IdUsuarioRegistro) VALUES (?,?,?,?,?,?,?,?,?,?)")) {
        ps.setInt(1,idPessoa);ps.setString(2,tipoHistorico);ps.setDate(3,dataMovimentacao);ps.setInt(4,classeAnterior);ps.setInt(5,classeNova);
        ps.setInt(6,statusAnterior);ps.setInt(7,statusNovo);ps.setString(8,observacaoAnterior);ps.setString(9,motivo);ps.setInt(10,idUsuario);ps.executeUpdate();
    }
    con.commit();
    out.print("{\"ok\":true,\"mensagem\":\"Movimentação registrada com sucesso.\"}");
} catch (IllegalArgumentException e) {
    if(con!=null)try{con.rollback();}catch(SQLException ignored){} response.setStatus(400);
    out.print("{\"ok\":false,\"mensagem\":\""+json(e.getMessage())+"\"}");
} catch (Exception e) {
    if(con!=null)try{con.rollback();}catch(SQLException ignored){} response.setStatus(500);
    out.print("{\"ok\":false,\"mensagem\":\"Não foi possível registrar a movimentação.\"}");
} finally { if(con!=null)try{con.close();}catch(SQLException ignored){} }
%>
