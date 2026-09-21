<%@ page import="java.sql.*" %>
<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
private String jsonParticipante(String valor) {
    return valor == null ? "" : valor.replace("\\", "\\\\").replace("\"", "\\\"").replace("\r", "\\r").replace("\n", "\\n");
}
%>
<%
String perfil = (String) session.getAttribute("usuarioPerfil");
Integer grupo = (Integer) session.getAttribute("usuarioGrupoId");
if (!"ADM".equals(perfil) && !"REP".equals(perfil) && !"EXT".equals(perfil)) {
    response.setStatus(403); out.print("{\"ok\":false,\"mensagem\":\"Acesso não autorizado.\"}"); return;
}
try {
    int idEncontro = Integer.parseInt(request.getParameter("id"));
    try (Connection conexao = cad.db.Database.getConnection();
         PreparedStatement encontro = conexao.prepareStatement("SELECT Classe,Descricao,DATE_FORMAT(DtEncontro,'%d/%m/%Y') Data FROM Encontros WHERE IdEncontro=? AND Checklist=0")) {
        encontro.setInt(1, idEncontro);
        try (ResultSet dadosEncontro = encontro.executeQuery()) {
            if (!dadosEncontro.next()) { response.setStatus(404); out.print("{\"ok\":false,\"mensagem\":\"Encontro não encontrado.\"}"); return; }
            int classe = dadosEncontro.getInt("Classe");
            String escopoRep="TODOS";if("REP".equals(perfil)){escopoRep="NENHUM";if(grupo!=null)try(PreparedStatement pe=conexao.prepareStatement("SELECT EscopoRepEncontros FROM grupos WHERE IdGrupo=?")){pe.setInt(1,grupo);try(ResultSet re=pe.executeQuery()){if(re.next()&&re.getString(1)!=null)escopoRep=re.getString(1);}}boolean autorizado="TODOS".equals(escopoRep)||"REGIAO_TODOS".equals(escopoRep)||("PROPRIO".equals(escopoRep)&&grupo==classe);if(!autorizado){response.setStatus(403);out.print("{\"ok\":false,\"mensagem\":\"Encontro fora do escopo do representante.\"}");return;}}
String nomeGrupo = cad.grupos.GrupoCatalogo.plural(classe);
            StringBuilder json = new StringBuilder("{\"ok\":true,\"encontro\":{\"descricao\":\"").append(jsonParticipante(dadosEncontro.getString("Descricao"))).append("\",\"data\":\"").append(jsonParticipante(dadosEncontro.getString("Data"))).append("\",\"grupo\":\"").append(nomeGrupo).append("\"},\"participantes\":[");
            boolean restringirRegiao="REP".equals(perfil)&&"REGIAO_TODOS".equals(escopoRep);Integer regiao=(Integer)session.getAttribute("usuarioRegiaoId");
            try (PreparedStatement participantes = conexao.prepareStatement("SELECT p.IdPessoa,p.Nome,CASE pe.flgPresenca WHEN 1 THEN 'Presente' WHEN 2 THEN 'Justificado' ELSE 'Faltou' END Presenca,IFNULL(pe.Justificativa,'') Justificativa,pe.distancia Distancia FROM pessoas p LEFT JOIN paroquia pa ON pa.IdParoquia=p.IdParoquia LEFT JOIN participanteEncontro pe ON pe.IdPessoa=p.IdPessoa AND pe.IdEncontro=? WHERE p.Classe=? AND p.status=1"+(restringirRegiao?" AND IFNULL(pa.IdRegiao,0)=?":"")+" ORDER BY p.Nome")) {
                participantes.setInt(1, idEncontro); participantes.setInt(2, classe);if(restringirRegiao)participantes.setInt(3,regiao==null?-1:regiao);
                try (ResultSet linhas = participantes.executeQuery()) {
                    boolean primeiro = true;
                    while (linhas.next()) {
                        if (!primeiro) json.append(','); primeiro = false;
                        Object distancia = linhas.getObject("Distancia");
                        json.append("{\"id\":").append(linhas.getInt("IdPessoa")).append(",\"nome\":\"").append(jsonParticipante(linhas.getString("Nome"))).append("\",\"presenca\":\"").append(jsonParticipante(linhas.getString("Presenca"))).append("\",\"justificativa\":\"").append(jsonParticipante(linhas.getString("Justificativa"))).append("\",\"distancia\":").append(distancia == null ? "null" : linhas.getDouble("Distancia")).append("}");
                    }
                }
            }
            json.append("]}"); out.print(json.toString());
        }
    }
} catch (Exception erro) {
    response.setStatus(500); out.print("{\"ok\":false,\"mensagem\":\"Não foi possível carregar os participantes.\"}");
}
%>
