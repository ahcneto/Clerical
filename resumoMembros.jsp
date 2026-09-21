<%@ page import="java.sql.*" %>
<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
private String jrm(String valor){return valor==null?"":valor.replace("\\","\\\\").replace("\"","\\\"").replace("\r","\\r").replace("\n","\\n");}
%>
<%
String perfil=(String)session.getAttribute("usuarioPerfil");
Integer grupoId=(Integer)session.getAttribute("usuarioGrupoId");
Integer regiaoId=(Integer)session.getAttribute("usuarioRegiaoId");
if(perfil==null){response.setStatus(401);out.print("{\"ok\":false,\"mensagem\":\"Sessão inválida.\"}");return;}

String escopoMembros="TODOS";
if("REP".equals(perfil)){escopoMembros="NENHUM";if(grupoId!=null)try(Connection ce=cad.db.Database.getConnection();PreparedStatement pe=ce.prepareStatement("SELECT EscopoRepMembros FROM grupos WHERE IdGrupo=?")){pe.setInt(1,grupoId);try(ResultSet re=pe.executeQuery()){if(re.next()&&re.getString(1)!=null)escopoMembros=re.getString(1);}}}
boolean filtrarGrupo="REP".equals(perfil)&&"PROPRIO".equals(escopoMembros)&&grupoId!=null;
boolean filtrarRegiao="REP".equals(perfil)&&"REGIAO_TODOS".equals(escopoMembros)&&regiaoId!=null;
boolean semAcesso="REP".equals(perfil)&&"NENHUM".equals(escopoMembros);
StringBuilder sql=new StringBuilder(
    "SELECT g.IdGrupo,g.NomeSingular,g.NomePlural,g.Cor,COUNT(p.IdPessoa) Total " +
    "FROM grupos g LEFT JOIN sqlPessoas p ON p.Classe=g.IdGrupo AND p.status=1");
if(filtrarRegiao)sql.append(" AND p.IdRegiao=?");
if(filtrarGrupo)sql.append(" AND p.Classe=?");
if(semAcesso)sql.append(" AND 1=0");
sql.append(" WHERE g.StatusGrupo='ATIVO' AND g.GrupoOperacional=1 AND g.ModuloMembros=1 GROUP BY g.IdGrupo,g.NomeSingular,g.NomePlural,g.Cor,g.Ordem ORDER BY g.Ordem,g.NomePlural");

try(Connection c=cad.db.Database.getConnection();PreparedStatement p=c.prepareStatement(sql.toString())){
 int i=1;if(filtrarRegiao)p.setInt(i++,regiaoId);if(filtrarGrupo)p.setInt(i++,grupoId);
 StringBuilder b=new StringBuilder("{\"ok\":true,\"grupos\":[");boolean primeiro=true;
 try(ResultSet r=p.executeQuery()){while(r.next()){if(!primeiro)b.append(',');primeiro=false;b.append("{\"id\":").append(r.getInt("IdGrupo")).append(",\"singular\":\"").append(jrm(r.getString("NomeSingular"))).append("\",\"plural\":\"").append(jrm(r.getString("NomePlural"))).append("\",\"cor\":\"").append(jrm(r.getString("Cor"))).append("\",\"total\":").append(r.getInt("Total")).append('}');}}
 out.print(b.append("]}"));
}catch(Exception e){response.setStatus(500);out.print("{\"ok\":false,\"mensagem\":\"Não foi possível carregar os totais.\"}");}
%>
