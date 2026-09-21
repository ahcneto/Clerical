<%@ page import="java.sql.*" %>
<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
private String j(String s){ return s == null ? "" : s.replace("\\","\\\\").replace("\"","\\\"").replace("\r","\\r").replace("\n","\\n"); }
%>
<%
String perfil=(String)session.getAttribute("usuarioPerfil"); Integer grupo=(Integer)session.getAttribute("usuarioGrupoId");
if(perfil==null||grupo==null){response.setStatus(401);out.print("{\"ok\":false,\"mensagem\":\"Sessão inválida.\"}");return;}
boolean adm="ADM".equals(perfil);
try{
 try(Connection c=cad.db.Database.getConnection()){
  String escopoRep="NENHUM";if("REP".equals(perfil))try(PreparedStatement pe=c.prepareStatement("SELECT EscopoRepEncontros FROM grupos WHERE IdGrupo=?")){pe.setInt(1,grupo);try(ResultSet re=pe.executeQuery()){if(re.next()&&re.getString(1)!=null)escopoRep=re.getString(1);}}
  if("POST".equalsIgnoreCase(request.getMethod())){
   if(!adm){response.setStatus(403);out.print("{\"ok\":false,\"mensagem\":\"Apenas administradores podem alterar encontros.\"}");return;}
   if("envio".equals(request.getParameter("acao"))){try(PreparedStatement p=c.prepareStatement("UPDATE Encontros SET flgEnviado=? WHERE IdEncontro=?")){p.setInt(1,Integer.parseInt(request.getParameter("flgEnviado")));p.setInt(2,Integer.parseInt(request.getParameter("id")));p.executeUpdate();}out.print("{\"ok\":true}");return;}
   int id=request.getParameter("id")==null||request.getParameter("id").isEmpty()?0:Integer.parseInt(request.getParameter("id")); int classe=Integer.parseInt(request.getParameter("classe")); String descricao=request.getParameter("descricao"),data=request.getParameter("data"),detalhe=request.getParameter("detalhe"),local=request.getParameter("local"); int enviado=Integer.parseInt(request.getParameter("flgEnviado")),esposa=Integer.parseInt(request.getParameter("flgEsposa"));
   String latitude=request.getParameter("latitude"),longitude=request.getParameter("longitude");
   if(descricao==null||descricao.trim().isEmpty())throw new IllegalArgumentException();
   try(PreparedStatement valida=c.prepareStatement("SELECT 1 FROM grupos WHERE IdGrupo=? AND StatusGrupo='ATIVO' AND GrupoOperacional=1 AND ModuloEncontros=1")){valida.setInt(1,classe);try(ResultSet r=valida.executeQuery()){if(!r.next())throw new IllegalArgumentException("Grupo indisponível para encontros.");}}
   String sql=id==0?"INSERT INTO Encontros (Classe,Descricao,DtEncontro,Detalhe,flgEnviado,flgEsposa,Local,latitude,longitude,Checklist) VALUES (?,?,?,?,?,?,?,?,?,0)":"UPDATE Encontros SET Classe=?,Descricao=?,DtEncontro=?,Detalhe=?,flgEnviado=?,flgEsposa=?,Local=?,latitude=?,longitude=?,Checklist=0 WHERE IdEncontro=?";
   try(PreparedStatement p=c.prepareStatement(sql)){p.setInt(1,classe);p.setString(2,descricao.trim());p.setDate(3,data==null||data.isEmpty()?null:Date.valueOf(data));p.setString(4,detalhe);p.setInt(5,enviado);p.setInt(6,esposa);p.setString(7,local);if(latitude==null||latitude.isEmpty())p.setNull(8,Types.DOUBLE);else p.setDouble(8,Double.parseDouble(latitude));if(longitude==null||longitude.isEmpty())p.setNull(9,Types.DOUBLE);else p.setDouble(9,Double.parseDouble(longitude));if(id!=0)p.setInt(10,id);p.executeUpdate();} out.print("{\"ok\":true}");return;
  }
  boolean todos=adm||"EXT".equals(perfil)||("REP".equals(perfil)&&("TODOS".equals(escopoRep)||"REGIAO_TODOS".equals(escopoRep)));boolean nenhum="REP".equals(perfil)&&"NENHUM".equals(escopoRep); String sql="SELECT e.IdEncontro,e.Classe,e.Descricao,DATE_FORMAT(e.DtEncontro,'%d/%m/%Y') dataFormatada,DATE_FORMAT(e.DtEncontro,'%Y-%m-%d') data,IFNULL(e.Detalhe,'') detalhe,IFNULL(e.Local,'') local,e.latitude,e.longitude,e.flgEnviado,e.flgEsposa FROM Encontros e JOIN grupos g ON g.IdGrupo=e.Classe AND g.StatusGrupo='ATIVO' AND g.GrupoOperacional=1 AND g.ModuloEncontros=1 WHERE e.Checklist=0"+(nenhum?" AND 1=0":todos?"":" AND e.Classe=?")+" ORDER BY e.DtEncontro DESC";
  try(PreparedStatement p=c.prepareStatement(sql)){if(!todos&&!nenhum)p.setInt(1,grupo);try(ResultSet r=p.executeQuery()){StringBuilder b=new StringBuilder("{\"ok\":true,\"encontros\":[");boolean first=true;while(r.next()){if(!first)b.append(',');first=false;b.append("{\"id\":").append(r.getInt("IdEncontro")).append(",\"classe\":").append(r.getInt("Classe")).append(",\"descricao\":\"").append(j(r.getString("Descricao"))).append("\",\"data\":\"").append(j(r.getString("data"))).append("\",\"dataFormatada\":\"").append(j(r.getString("dataFormatada"))).append("\",\"detalhe\":\"").append(j(r.getString("detalhe"))).append("\",\"local\":\"").append(j(r.getString("local"))).append("\",\"latitude\":\"").append(j(r.getString("latitude"))).append("\",\"longitude\":\"").append(j(r.getString("longitude"))).append("\",\"flgEnviado\":").append(r.getInt("flgEnviado")==1).append(",\"flgEsposa\":").append(r.getInt("flgEsposa")==1).append('}');}b.append("]}");out.print(b.toString());}}
 }
}catch(Exception e){response.setStatus(500);out.print("{\"ok\":false,\"mensagem\":\"Não foi possível processar os encontros.\"}");}
%>
