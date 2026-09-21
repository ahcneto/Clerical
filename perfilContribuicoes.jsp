<%@ page import="java.sql.*" %>
<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="includes/escopoMembroApi.jspf" %>
<%!
private String jpc(String s){return s==null?"":s.replace("\\","\\\\").replace("\"","\\\"");}
%>
<%
Integer usuario=(Integer)session.getAttribute("usuarioId");String perfil=(String)session.getAttribute("usuarioPerfil");int pessoa=usuario==null?0:usuario;
if(usuario==null){response.setStatus(401);out.print("{\"ok\":false,\"mensagem\":\"Sessão inválida.\"}");return;}
try{
 String id=request.getParameter("id"),anoParam=request.getParameter("ano");
 if(id!=null&&("ADM".equals(perfil)||"REP".equals(perfil)||"EXT".equals(perfil)))pessoa=Integer.parseInt(id);
 if(pessoa==0)throw new IllegalArgumentException();
 int ano=anoParam==null||anoParam.isEmpty()?java.time.Year.now().getValue():Integer.parseInt(anoParam);
 try(Connection c=cad.db.Database.getConnection()){
  if(!cadPodeVerMembro(c,session,pessoa)){response.setStatus(403);out.print("{\"ok\":false,\"mensagem\":\"Membro fora do escopo de acesso.\"}");return;}
  int classe=0;try(PreparedStatement p=c.prepareStatement("SELECT Classe FROM pessoas WHERE IdPessoa=?")){p.setInt(1,pessoa);try(ResultSet r=p.executeQuery()){if(r.next())classe=r.getInt(1);}}
  boolean[] mesesEsperados=new boolean[13];int esperadas=0;String periodicidade="NENHUMA";boolean ateAtual=true;
  try(PreparedStatement p=c.prepareStatement("SELECT ContribuicaoPeriodicidade,ContribuicaoAteMesAtual FROM grupos WHERE IdGrupo=? AND StatusGrupo='ATIVO' AND ModuloContribuicoes=1 AND ContribuicaoAtiva=1")){p.setInt(1,classe);try(ResultSet r=p.executeQuery()){if(r.next()){periodicidade=r.getString(1);ateAtual=r.getBoolean(2);}}}
  if("MENSAL".equals(periodicidade)){int anoAtual=java.time.Year.now().getValue();int limite=!ateAtual||ano<anoAtual?12:ano==anoAtual?java.time.LocalDate.now().getMonthValue():0;for(int m=1;m<=limite;m++){mesesEsperados[m]=true;esperadas++;}}
  else if("ENCONTRO".equals(periodicidade)){try(PreparedStatement p=c.prepareStatement("SELECT DISTINCT MONTH(DtEncontro) FROM Encontros WHERE Classe=? AND Checklist=0 AND YEAR(DtEncontro)=?"+(ateAtual?" AND DtEncontro<=CURDATE()":""))){p.setInt(1,classe);p.setInt(2,ano);try(ResultSet r=p.executeQuery()){while(r.next()){int m=r.getInt(1);if(m>=1&&m<=12&&!mesesEsperados[m]){mesesEsperados[m]=true;esperadas++;}}}}}
  else if("MANUAL".equals(periodicidade)){try(PreparedStatement p=c.prepareStatement("SELECT DISTINCT MONTH(dtVencimento) FROM lancamentos WHERE idPessoa=? AND tipoLancamento='1.1' AND YEAR(dtVencimento)=?")){p.setInt(1,pessoa);p.setInt(2,ano);try(ResultSet r=p.executeQuery()){while(r.next()){int m=r.getInt(1);if(m>=1&&m<=12&&!mesesEsperados[m]){mesesEsperados[m]=true;esperadas++;}}}}}
  StringBuilder b=new StringBuilder("{\"ok\":true,\"anos\":[");boolean first=true;
  try(PreparedStatement p=c.prepareStatement("SELECT DISTINCT YEAR(dtVencimento) ano FROM lancamentos WHERE idPessoa=? AND tipoLancamento='1.1' ORDER BY ano DESC")){p.setInt(1,pessoa);try(ResultSet r=p.executeQuery()){while(r.next()){if(!first)b.append(',');first=false;b.append(r.getInt(1));}}}
  b.append("],\"anoSelecionado\":").append(ano).append(",\"lancamentos\":[");double total=0;int pagos=0;boolean[] mesesPagos=new boolean[13];first=true;
  try(PreparedStatement p=c.prepareStatement("SELECT MONTH(dtVencimento) mes,DATE_FORMAT(dtVencimento,'%m/%Y') competencia,DATE_FORMAT(dtPagamento,'%d/%m/%Y') pagamento,IFNULL(valorPago,0) valor,status FROM lancamentos WHERE idPessoa=? AND tipoLancamento='1.1' AND YEAR(dtVencimento)=? ORDER BY dtVencimento DESC")){p.setInt(1,pessoa);p.setInt(2,ano);try(ResultSet r=p.executeQuery()){while(r.next()){if(!first)b.append(',');first=false;double valor=r.getDouble("valor");int mes=r.getInt("mes");if(r.getInt("status")==1){total+=valor;if(mes>=1&&mes<=12&&mesesEsperados[mes]&&!mesesPagos[mes]){mesesPagos[mes]=true;pagos++;}}b.append("{\"competencia\":\"").append(jpc(r.getString("competencia"))).append("\",\"dataPagamento\":\"").append(jpc(r.getString("pagamento"))).append("\",\"valor\":\"R$ ").append(String.format(java.util.Locale.US,"%.2f",valor).replace('.',',')).append("\"}");}}}
  b.append("],\"totalAno\":\"R$ ").append(String.format(java.util.Locale.US,"%.2f",total).replace('.',',')).append("\",\"percentual\":").append(esperadas>0?Math.round(pagos*100.0/esperadas):0).append("}");out.print(b);
 }
}catch(Exception e){response.setStatus(400);out.print("{\"ok\":false,\"mensagem\":\"Não foi possível carregar as contribuições.\"}");}
%>
