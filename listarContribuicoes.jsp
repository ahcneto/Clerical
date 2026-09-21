<%@ page import="java.sql.*" %>
<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
private String jc(String s){return s==null?"":s.replace("\\","\\\\").replace("\"","\\\"").replace("\r","\\r").replace("\n","\\n");}
%>
<%
String perfil=(String)session.getAttribute("usuarioPerfil");
String mes=request.getParameter("mes"),ano=request.getParameter("ano"),classe=request.getParameter("classe");
Integer grupoUsuario=(Integer)session.getAttribute("usuarioGrupoId");
if(!"ADM".equals(perfil)&&!"FIN".equals(perfil)&&!"REP".equals(perfil)&&!"EXT".equals(perfil)){response.setStatus(403);out.print("{\"ok\":false,\"mensagem\":\"Acesso não autorizado.\"}");return;}
if("FIN".equals(perfil)){if(grupoUsuario==null){response.setStatus(403);out.print("{\"ok\":false,\"mensagem\":\"Grupo do usuário não identificado.\"}");return;}classe=String.valueOf(grupoUsuario);}
try{
 int m=Integer.parseInt(mes),a=Integer.parseInt(ano);if(m<1||m>12)throw new IllegalArgumentException();
 try(Connection c=cad.db.Database.getConnection()){
  String escopoRep="TODOS";Integer regiaoUsuario=(Integer)session.getAttribute("usuarioRegiaoId");if("REP".equals(perfil)){escopoRep="NENHUM";if(grupoUsuario!=null)try(PreparedStatement pe=c.prepareStatement("SELECT EscopoRepContribuicoes FROM grupos WHERE IdGrupo=?")){pe.setInt(1,grupoUsuario);try(ResultSet re=pe.executeQuery()){if(re.next()&&re.getString(1)!=null)escopoRep=re.getString(1);}}}
  String restricaoRep=!"REP".equals(perfil)?"":"NENHUM".equals(escopoRep)?" AND 1=0":"PROPRIO".equals(escopoRep)?" AND p.Classe=?":"REGIAO_TODOS".equals(escopoRep)?" AND p.IdRegiao=?":"";
  String sql="SELECT p.IdPessoa,p.Nome,p.Classe,g.NomePlural Grupo,p.Paroquia,p.Regiao,g.ContribuicaoValor,g.ContribuicaoValorEditavel,g.ContribuicaoPeriodicidade,g.ContribuicaoDiaVencimento,IFNULL(l.status,0) status,IFNULL(l.valorPago,g.ContribuicaoValor) ValorLancamento FROM sqlPessoas p JOIN grupos g ON g.IdGrupo=p.Classe AND g.StatusGrupo='ATIVO' AND g.GrupoOperacional=1 AND g.ModuloContribuicoes=1 AND g.ContribuicaoAtiva=1 LEFT JOIN lancamentos l ON l.idLancamento=(SELECT MAX(x.idLancamento) FROM lancamentos x WHERE x.idPessoa=p.IdPessoa AND x.tipoLancamento='1.1' AND YEAR(x.dtVencimento)=? AND MONTH(x.dtVencimento)=?) WHERE p.status=1 AND ((g.ContribuicaoPeriodicidade='MENSAL' AND (g.ContribuicaoAteMesAtual=0 OR STR_TO_DATE(CONCAT(?, '-', LPAD(?,2,'0'), '-01'),'%Y-%m-%d')<=LAST_DAY(CURDATE()))) OR (g.ContribuicaoPeriodicidade='ENCONTRO' AND EXISTS(SELECT 1 FROM Encontros e WHERE e.Classe=p.Classe AND e.Checklist=0 AND YEAR(e.DtEncontro)=? AND MONTH(e.DtEncontro)=?)) OR g.ContribuicaoPeriodicidade='MANUAL')"+restricaoRep+(classe==null||classe.isEmpty()?"":" AND p.Classe=?")+" ORDER BY p.Nome";
  try(PreparedStatement p=c.prepareStatement(sql)){int i=1;p.setInt(i++,a);p.setInt(i++,m);p.setInt(i++,a);p.setInt(i++,m);p.setInt(i++,a);p.setInt(i++,m);if("REP".equals(perfil)&&"PROPRIO".equals(escopoRep))p.setInt(i++,grupoUsuario==null?-1:grupoUsuario);else if("REP".equals(perfil)&&"REGIAO_TODOS".equals(escopoRep))p.setInt(i++,regiaoUsuario==null?-1:regiaoUsuario);if(classe!=null&&!classe.isEmpty())p.setInt(i++,Integer.parseInt(classe));try(ResultSet r=p.executeQuery()){
   StringBuilder b=new StringBuilder("{\"ok\":true,\"membros\":[");boolean first=true;
   while(r.next()){if(!first)b.append(',');first=false;int cl=r.getInt("Classe");b.append("{\"id\":").append(r.getInt("IdPessoa")).append(",\"nome\":\"").append(jc(r.getString("Nome"))).append("\",\"classe\":").append(cl).append(",\"grupo\":\"").append(jc(r.getString("Grupo"))).append("\",\"paroquia\":\"").append(jc(r.getString("Paroquia"))).append("\",\"regiao\":\"").append(jc(r.getString("Regiao"))).append("\",\"valor\":").append(r.getBigDecimal("ValorLancamento")).append(",\"valorEditavel\":").append(r.getBoolean("ContribuicaoValorEditavel")).append(",\"periodicidade\":\"").append(r.getString("ContribuicaoPeriodicidade")).append("\",\"status\":").append(r.getInt("status")).append('}');}
   out.print(b.append("]}"));
  }}
 }
}catch(Exception e){response.setStatus(500);out.print("{\"ok\":false,\"mensagem\":\"Não foi possível carregar as contribuições.\"}");}
%>
