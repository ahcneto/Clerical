<%@ page import="java.sql.*" %>
<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
private String json(String valor) {
    if (valor == null) return "";
    return valor.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "\\r")
                .replace("\n", "\\n");
}
%>
<%
String perfil = (String) session.getAttribute("usuarioPerfil");
Integer usuarioId = (Integer) session.getAttribute("usuarioId");
Integer grupoId = (Integer) session.getAttribute("usuarioGrupoId");

if (perfil == null || usuarioId == null || grupoId == null) {
    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
    out.print("{\"ok\":false,\"mensagem\":\"Sessão inválida.\"}");
    return;
}

String escopoRepEncontros="NENHUM";
if("REP".equals(perfil))try(Connection ce=cad.db.Database.getConnection();PreparedStatement pe=ce.prepareStatement("SELECT EscopoRepEncontros FROM grupos WHERE IdGrupo=?")){pe.setInt(1,grupoId);try(ResultSet re=pe.executeQuery()){if(re.next()&&re.getString(1)!=null)escopoRepEncontros=re.getString(1);}}
boolean podeVerTodos = "ADM".equals(perfil)
    || "EXT".equals(perfil)
    || ("REP".equals(perfil) && ("TODOS".equals(escopoRepEncontros)||"REGIAO_TODOS".equals(escopoRepEncontros)));
StringBuilder sql = new StringBuilder(
    "SELECT e.IdEncontro, DATE_FORMAT(e.DtEncontro, '%d/%m/%Y') AS Data, IFNULL(e.Descricao, '') AS Descricao, IFNULL(e.Local, '') AS Local, e.Classe, e.flgEnviado, " +
    "g.NomePlural AS Grupo, g.ModuloContribuicoes, g.ContribuicaoAtiva, g.ContribuicaoPeriodicidade, " +
    "CASE pe.flgPresenca WHEN 1 THEN 'Presente' WHEN 2 THEN 'Justificado' WHEN 0 THEN 'Faltou' ELSE ' - ' END AS Presenca, " +
    "IFNULL(pe.Justificativa, '') AS Justificativa, " +
    "CASE WHEN EXISTS (SELECT 1 FROM lancamentos l WHERE l.idPessoa=? AND l.tipoLancamento='1.1' AND l.status=1 AND YEAR(l.dtVencimento)=YEAR(e.DtEncontro) AND MONTH(l.dtVencimento)=MONTH(e.DtEncontro)) THEN 1 ELSE 0 END AS ContribuicaoRealizada " +
    "FROM Encontros e JOIN grupos g ON g.IdGrupo=e.Classe AND g.StatusGrupo='ATIVO' AND g.GrupoOperacional=1 AND g.ModuloEncontros=1 LEFT JOIN participanteEncontro pe " +
    "ON pe.IdEncontro = e.IdEncontro AND pe.IdPessoa = ? " +
    "WHERE e.Checklist = 0");

if (podeVerTodos)
    sql.append(
        " AND (e.IdEncontro = (" +
        "SELECT e2.IdEncontro FROM Encontros e2 " +
        "WHERE e2.Checklist = 0 AND e2.Classe = e.Classe " +
        "ORDER BY e2.DtEncontro DESC, e2.IdEncontro DESC LIMIT 1) " +
        "OR (e.Classe = ? AND e.flgEnviado = 1))"
    );
else
    sql.append(
        " AND e.Classe = ? AND (e.flgEnviado = 1 OR e.IdEncontro = (" +
        "SELECT e2.IdEncontro FROM Encontros e2 " +
        "WHERE e2.Checklist = 0 AND e2.Classe = e.Classe " +
        "ORDER BY e2.DtEncontro DESC, e2.IdEncontro DESC LIMIT 1))"
    );

sql.append(" ORDER BY e.DtEncontro DESC, e.IdEncontro DESC");

try {
    try (Connection conexao = cad.db.Database.getConnection();
         PreparedStatement comando = conexao.prepareStatement(sql.toString())) {

        comando.setInt(1, usuarioId);
        comando.setInt(2, usuarioId);
        comando.setInt(3, grupoId);

        try (ResultSet resultado = comando.executeQuery()) {
            StringBuilder json = new StringBuilder("{\"ok\":true,\"encontros\":[");
            boolean primeiro = true;
            while (resultado.next()) {
                if (!primeiro) json.append(",");
                primeiro = false;
                boolean podeRegistrar = resultado.getInt("Classe") == grupoId.intValue()
                    && resultado.getInt("flgEnviado") == 1;
                String periodicidade = resultado.getString("ContribuicaoPeriodicidade");
                boolean contribuicaoAplicavel = resultado.getInt("Classe") == grupoId.intValue()
                    && resultado.getBoolean("ModuloContribuicoes")
                    && resultado.getBoolean("ContribuicaoAtiva")
                    && ("MENSAL".equals(periodicidade) || "ENCONTRO".equals(periodicidade));
                json.append("{\"id\":").append(resultado.getInt("IdEncontro"))
                    .append(",\"data\":\"").append(json(resultado.getString("Data"))).append("\"")
                    .append(",\"descricao\":\"").append(json(resultado.getString("Descricao"))).append("\"")
                    .append(",\"local\":\"").append(json(resultado.getString("Local"))).append("\"")
                    .append(",\"grupo\":\"").append(json(resultado.getString("Grupo"))).append("\"")
                    .append(",\"presenca\":\"").append(json(resultado.getString("Presenca"))).append("\"")
                    .append(",\"justificativa\":\"").append(json(resultado.getString("Justificativa"))).append("\"")
                    .append(",\"contribuicaoAplicavel\":").append(contribuicaoAplicavel)
                    .append(",\"contribuicaoRealizada\":").append(resultado.getInt("ContribuicaoRealizada")==1)
                    .append(",\"podeRegistrar\":").append(podeRegistrar).append("}");
            }
            json.append("]}");
            out.print(json.toString());
        }
    }
} catch (Exception erro) {
    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
    out.print("{\"ok\":false,\"mensagem\":\"Não foi possível carregar os encontros.\"}");
}
%>
