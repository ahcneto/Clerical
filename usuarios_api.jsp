<%@ page import="java.sql.*" %>
<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
private String ju(String s){return s==null?"":s.replace("\\","\\\\").replace("\"","\\\"").replace("\r","\\r").replace("\n","\\n");}
%>
<%
String perfilSessao=(String)session.getAttribute("usuarioPerfil");Integer usuarioId=(Integer)session.getAttribute("usuarioId");
if(!"ADM".equals(perfilSessao)||usuarioId==null){response.setStatus(403);out.print("{\"ok\":false,\"mensagem\":\"Acesso exclusivo para administradores.\"}");return;}
try{
 try(Connection c=cad.db.Database.getConnection()){
  if("POST".equalsIgnoreCase(request.getMethod())){
   int pessoa=Integer.parseInt(request.getParameter("idPessoa"));String novoPerfil=request.getParameter("profile");
   if(!"ADM".equals(novoPerfil)&&!"REP".equals(novoPerfil)&&!"FIN".equals(novoPerfil)&&!"USR".equals(novoPerfil)&&!"EXT".equals(novoPerfil)){response.setStatus(400);out.print("{\"ok\":false,\"mensagem\":\"Perfil inválido.\"}");return;}
   try(PreparedStatement valida=c.prepareStatement("SELECT 1 FROM pessoas WHERE IdPessoa=?")){valida.setInt(1,pessoa);try(ResultSet r=valida.executeQuery()){if(!r.next()){response.setStatus(404);out.print("{\"ok\":false,\"mensagem\":\"Pessoa não encontrada.\"}");return;}}}
   boolean existe=false;try(PreparedStatement p=c.prepareStatement("SELECT 1 FROM usuarios WHERE IdPessoa=?")){p.setInt(1,pessoa);try(ResultSet r=p.executeQuery()){existe=r.next();}}
   if(existe){try(PreparedStatement p=c.prepareStatement("UPDATE usuarios SET Profile=? WHERE IdPessoa=?")){p.setString(1,novoPerfil);p.setInt(2,pessoa);p.executeUpdate();}}
   else{try(PreparedStatement p=c.prepareStatement("INSERT INTO usuarios(IdPessoa,Profile) VALUES(?,?)")){p.setInt(1,pessoa);p.setString(2,novoPerfil);p.executeUpdate();}}
   out.print("{\"ok\":true,\"mensagem\":\"Perfil atualizado com sucesso.\"}");return;
  }
  String status=request.getParameter("status");if(!"0".equals(status))status="1";
  String sql="SELECT p.IdPessoa,p.Nome,p.Classe,g.NomePlural,IFNULL(p.Paroquia,''),IFNULL(p.Regiao,''),IFNULL(u.Profile,'USR') Profile FROM sqlPessoas p JOIN grupos g ON g.IdGrupo=p.Classe AND g.StatusGrupo='ATIVO' AND g.DisponivelUsuarios=1 LEFT JOIN usuarios u ON u.IdPessoa=p.IdPessoa WHERE p.status=? ORDER BY p.Nome";
  StringBuilder b=new StringBuilder("{\"ok\":true,\"usuarios\":[");boolean first=true;
  try(PreparedStatement p=c.prepareStatement(sql)){p.setInt(1,Integer.parseInt(status));try(ResultSet r=p.executeQuery()){while(r.next()){if(!first)b.append(',');first=false;b.append("{\"id\":").append(r.getInt(1)).append(",\"nome\":\"").append(ju(r.getString(2))).append("\",\"classe\":").append(r.getInt(3)).append(",\"grupo\":\"").append(ju(r.getString(4))).append("\",\"paroquia\":\"").append(ju(r.getString(5))).append("\",\"regiao\":\"").append(ju(r.getString(6))).append("\",\"profile\":\"").append(ju(r.getString(7))).append("\"}");}}}
  out.print(b.append("]}"));
 }
}catch(Exception e){response.setStatus(500);out.print("{\"ok\":false,\"mensagem\":\"Não foi possível processar os perfis de usuários.\"}");}
%>
