<%@ page import="java.sql.*,java.time.Year,java.time.LocalDate,java.util.TreeSet,java.util.Collections,java.util.Locale" %>
<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
private String jr(String s){return s==null?"":s.replace("\\","\\\\").replace("\"","\\\"").replace("\r","\\r").replace("\n","\\n");}
private String mes(int m){String[] n={"","Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"};return m>=1&&m<=12?n[m]:"";}
%>
<%
Integer usuarioId=(Integer)session.getAttribute("usuarioId");Integer grupoId=(Integer)session.getAttribute("usuarioGrupoId");
if(usuarioId==null||grupoId==null){response.setStatus(401);out.print("{\"ok\":false,\"mensagem\":\"Sessão inválida.\"}");return;}
int ano;try{ano=Integer.parseInt(request.getParameter("ano"));}catch(Exception e){ano=Year.now().getValue();}
try{
 try(Connection c=cad.db.Database.getConnection()){
  TreeSet<Integer> anos=new TreeSet<Integer>(Collections.reverseOrder());anos.add(Year.now().getValue());anos.add(ano);
  try(PreparedStatement p=c.prepareStatement("SELECT YEAR(e.DtEncontro) ano FROM Encontros e JOIN participanteEncontro pe ON pe.IdEncontro=e.IdEncontro WHERE pe.IdPessoa=? UNION SELECT YEAR(dtVencimento) FROM lancamentos WHERE idPessoa=? AND tipoLancamento='1.1'")){p.setInt(1,usuarioId);p.setInt(2,usuarioId);try(ResultSet r=p.executeQuery()){while(r.next())if(r.getInt(1)>0)anos.add(r.getInt(1));}}
  StringBuilder b=new StringBuilder("{\"ok\":true,\"ano\":").append(ano).append(",\"anos\":[");boolean first=true;for(Integer a:anos){if(!first)b.append(',');first=false;b.append(a);}b.append("],\"presencas\":[");
  int total=0,presentes=0;first=true;
  try(PreparedStatement p=c.prepareStatement("SELECT DATE_FORMAT(e.DtEncontro,'%d/%m/%Y'),IFNULL(e.Descricao,''),CASE pe.flgPresenca WHEN 1 THEN 'Presente' WHEN 2 THEN 'Justificado' ELSE 'Faltou' END,IFNULL(pe.Justificativa,'') FROM Encontros e JOIN participanteEncontro pe ON pe.IdEncontro=e.IdEncontro WHERE pe.IdPessoa=? AND YEAR(e.DtEncontro)=? ORDER BY e.DtEncontro DESC")){p.setInt(1,usuarioId);p.setInt(2,ano);try(ResultSet r=p.executeQuery()){while(r.next()){total++;if("Presente".equals(r.getString(3)))presentes++;if(!first)b.append(',');first=false;b.append("{\"data\":\"").append(jr(r.getString(1))).append("\",\"descricao\":\"").append(jr(r.getString(2))).append("\",\"situacao\":\"").append(jr(r.getString(3))).append("\",\"justificativa\":\"").append(jr(r.getString(4))).append("\"}");}}}
  int percentualPresenca=total>0?(int)Math.round(presentes*100.0/total):0;
  boolean[] mesesEsperados=new boolean[13];int esperadas=0;String periodicidade="NENHUMA";boolean ateAtual=true;
  try(PreparedStatement p=c.prepareStatement("SELECT ContribuicaoPeriodicidade,ContribuicaoAteMesAtual FROM grupos WHERE IdGrupo=? AND StatusGrupo='ATIVO' AND ModuloContribuicoes=1 AND ContribuicaoAtiva=1")){p.setInt(1,grupoId);try(ResultSet r=p.executeQuery()){if(r.next()){periodicidade=r.getString(1);ateAtual=r.getBoolean(2);}}}
  if("MENSAL".equals(periodicidade)){int anoAtual=Year.now().getValue();int limite=ateAtual?(ano<anoAtual?12:ano==anoAtual?LocalDate.now().getMonthValue():0):12;for(int m=1;m<=limite;m++){mesesEsperados[m]=true;esperadas++;}}
  else if("ENCONTRO".equals(periodicidade)){String limite=ateAtual?" AND DtEncontro<=CURDATE()":"";try(PreparedStatement p=c.prepareStatement("SELECT DISTINCT MONTH(DtEncontro) mes FROM Encontros WHERE Classe=? AND Checklist=0 AND YEAR(DtEncontro)=?"+limite)){p.setInt(1,grupoId);p.setInt(2,ano);try(ResultSet r=p.executeQuery()){while(r.next()){int m=r.getInt(1);if(m>=1&&m<=12&&!mesesEsperados[m]){mesesEsperados[m]=true;esperadas++;}}}}}
  else if("MANUAL".equals(periodicidade)){try(PreparedStatement p=c.prepareStatement("SELECT DISTINCT MONTH(dtVencimento) mes FROM lancamentos WHERE idPessoa=? AND tipoLancamento='1.1' AND YEAR(dtVencimento)=?")){p.setInt(1,usuarioId);p.setInt(2,ano);try(ResultSet r=p.executeQuery()){while(r.next()){int m=r.getInt(1);if(m>=1&&m<=12&&!mesesEsperados[m]){mesesEsperados[m]=true;esperadas++;}}}}}
  boolean[] pagas=new boolean[13];String[] pagamentos=new String[13];String[] valores=new String[13];
  try(PreparedStatement p=c.prepareStatement("SELECT MONTH(dtVencimento) mes,MAX(status) status,DATE_FORMAT(MAX(dtPagamento),'%d/%m/%Y') pagamento,SUM(CASE WHEN status=1 THEN IFNULL(valorPago,0) ELSE 0 END) valor FROM lancamentos WHERE idPessoa=? AND tipoLancamento='1.1' AND YEAR(dtVencimento)=? GROUP BY MONTH(dtVencimento)")){p.setInt(1,usuarioId);p.setInt(2,ano);try(ResultSet r=p.executeQuery()){while(r.next()){int m=r.getInt("mes");pagas[m]=r.getInt("status")==1;pagamentos[m]=r.getString("pagamento");valores[m]="R$ "+String.format(Locale.US,"%.2f",r.getDouble("valor")).replace('.',',');}}}
  int pagos=0;b.append("],\"percentualPresenca\":").append(percentualPresenca).append(",\"contribuicoes\":[");first=true;
  for(int m=1;m<=12;m++){if(!mesesEsperados[m])continue;if(pagas[m])pagos++;if(!first)b.append(',');first=false;b.append("{\"mes\":\"").append(mes(m)).append("\",\"pagamento\":\"").append(jr(pagamentos[m])).append("\",\"valor\":\"").append(jr(valores[m]==null?"R$ 0,00":valores[m])).append("\",\"paga\":").append(pagas[m]).append('}');}
  int percentualContribuicao=esperadas>0?(int)Math.round(pagos*100.0/esperadas):0;
  b.append("],\"percentualContribuicao\":").append(percentualContribuicao).append("}");out.print(b);
 }
}catch(Exception e){response.setStatus(500);out.print("{\"ok\":false,\"mensagem\":\"Não foi possível carregar os detalhes anuais.\"}");}
%>
