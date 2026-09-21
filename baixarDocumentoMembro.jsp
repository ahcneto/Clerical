<%@ page import="java.sql.*,java.io.*,java.nio.file.*" %><%@ include file="includes/escopoMembroApi.jspf" %><%
Integer usuario=(Integer)session.getAttribute("usuarioId");if(usuario==null){response.setStatus(401);return;}
int pessoa=usuario,item=0;try{String v=request.getParameter("pessoa");if(v!=null&&!v.isEmpty())pessoa=Integer.parseInt(v);item=Integer.parseInt(request.getParameter("item"));}catch(Exception e){response.sendError(400);return;}
try(Connection c=cad.db.Database.getConnection()){
 if(!cadPodeVerMembro(c,session,pessoa)){response.sendError(403);return;}
 try(PreparedStatement p=c.prepareStatement("SELECT NomeArquivo,TipoMime FROM documentacao_pessoa_arquivo WHERE IdPessoa=? AND IdItem=?")){p.setInt(1,pessoa);p.setInt(2,item);try(ResultSet r=p.executeQuery()){
  if(!r.next()){response.sendError(404);return;}String nome=r.getString(1),mime=r.getString(2);File pasta=new File(application.getRealPath("/WEB-INF"),"documentos_membros"),arquivo=new File(pasta,nome);String raiz=pasta.getCanonicalPath()+File.separator;
  if(!arquivo.isFile()||!arquivo.getCanonicalPath().startsWith(raiz)){response.sendError(404);return;}response.reset();response.setContentType(mime);response.setHeader("Content-Disposition","inline; filename=\""+nome+"\"");response.setContentLengthLong(arquivo.length());OutputStream fluxo=response.getOutputStream();Files.copy(arquivo.toPath(),fluxo);fluxo.flush();return;
 }}
}catch(Exception e){response.sendError(500);}
%>
