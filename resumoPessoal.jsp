<%@ page import="java.sql.*,java.time.Year,java.time.LocalDate" %>
<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%
Integer usuarioId=(Integer)session.getAttribute("usuarioId");
Integer grupoId=(Integer)session.getAttribute("usuarioGrupoId");
if(usuarioId==null||grupoId==null){response.setStatus(401);out.print("{\"ok\":false,\"mensagem\":\"Sessão inválida.\"}");return;}
int ano=Year.now().getValue();
try{
 try(Connection c=cad.db.Database.getConnection()){
  int total=0,presentes=0;
  try(PreparedStatement p=c.prepareStatement("SELECT COUNT(*) total,SUM(CASE WHEN pe.flgPresenca=1 THEN 1 ELSE 0 END) presentes FROM participanteEncontro pe JOIN Encontros e ON e.IdEncontro=pe.IdEncontro WHERE pe.IdPessoa=? AND YEAR(e.DtEncontro)=?")){p.setInt(1,usuarioId);p.setInt(2,ano);try(ResultSet r=p.executeQuery()){if(r.next()){total=r.getInt("total");presentes=r.getInt("presentes");}}}
  int esperadas=0;String periodicidade="NENHUMA";boolean ateAtual=true;
  try(PreparedStatement p=c.prepareStatement("SELECT ContribuicaoPeriodicidade,ContribuicaoAteMesAtual FROM grupos WHERE IdGrupo=? AND StatusGrupo='ATIVO' AND ModuloContribuicoes=1 AND ContribuicaoAtiva=1")){p.setInt(1,grupoId);try(ResultSet r=p.executeQuery()){if(r.next()){periodicidade=r.getString(1);ateAtual=r.getBoolean(2);}}}
  if("MENSAL".equals(periodicidade)){int anoAtual=Year.now().getValue();esperadas=!ateAtual||ano<anoAtual?12:ano==anoAtual?LocalDate.now().getMonthValue():0;}
  else if("ENCONTRO".equals(periodicidade)){try(PreparedStatement p=c.prepareStatement("SELECT COUNT(DISTINCT MONTH(DtEncontro)) FROM Encontros WHERE Classe=? AND Checklist=0 AND YEAR(DtEncontro)=?"+(ateAtual?" AND DtEncontro<=CURDATE()":""))){p.setInt(1,grupoId);p.setInt(2,ano);try(ResultSet r=p.executeQuery()){if(r.next())esperadas=r.getInt(1);}}}
  else if("MANUAL".equals(periodicidade)){try(PreparedStatement p=c.prepareStatement("SELECT COUNT(DISTINCT MONTH(dtVencimento)) FROM lancamentos WHERE idPessoa=? AND tipoLancamento='1.1' AND YEAR(dtVencimento)=?")){p.setInt(1,usuarioId);p.setInt(2,ano);try(ResultSet r=p.executeQuery()){if(r.next())esperadas=r.getInt(1);}}}
  int pagos=0;
  String sqlPagos="SELECT COUNT(DISTINCT MONTH(l.dtVencimento)) FROM lancamentos l WHERE l.idPessoa=? AND l.tipoLancamento='1.1' AND l.status=1 AND YEAR(l.dtVencimento)=?"+(ateAtual?" AND l.dtVencimento<=LAST_DAY(CURDATE())":"")+("ENCONTRO".equals(periodicidade)?" AND EXISTS(SELECT 1 FROM Encontros e WHERE e.Classe=? AND e.Checklist=0 AND YEAR(e.DtEncontro)=YEAR(l.dtVencimento) AND MONTH(e.DtEncontro)=MONTH(l.dtVencimento))":"");
  try(PreparedStatement p=c.prepareStatement(sqlPagos)){p.setInt(1,usuarioId);p.setInt(2,ano);if("ENCONTRO".equals(periodicidade))p.setInt(3,grupoId);try(ResultSet r=p.executeQuery()){if(r.next())pagos=r.getInt(1);}}
  int percentualPresenca=total>0?(int)Math.round(presentes*100.0/total):0;
  int percentualContribuicao=esperadas>0?(int)Math.round(pagos*100.0/esperadas):0;
  out.print("{\"ok\":true,\"ano\":"+ano+",\"percentualPresenca\":"+percentualPresenca+",\"percentualContribuicao\":"+percentualContribuicao+"}");
 }
}catch(Exception e){response.setStatus(500);out.print("{\"ok\":false,\"mensagem\":\"Não foi possível carregar o resumo pessoal.\"}");}
%>
