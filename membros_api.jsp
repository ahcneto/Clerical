<%@ page import="java.sql.*,java.time.LocalDate" %>
<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
private String jm(String s){return s==null?"":s.replace("\\","\\\\").replace("\"","\\\"").replace("\r","\\r").replace("\n","\\n");}
private String somenteDigitos(String s){return s==null?"":s.replaceAll("\\D","");}
%>
<%
String perfil=(String)session.getAttribute("usuarioPerfil");
Integer usuarioId=(Integer)session.getAttribute("usuarioId");
if(!"ADM".equals(perfil)||usuarioId==null){response.setStatus(403);out.print("{\"ok\":false,\"mensagem\":\"Acesso exclusivo para administradores.\"}");return;}
try(Connection c=cad.db.Database.getConnection()){
 String acao=request.getParameter("acao");
 if("paroquias".equals(acao)&&"GET".equalsIgnoreCase(request.getMethod())){
  StringBuilder b=new StringBuilder("{\"ok\":true,\"paroquias\":[");boolean primeiro=true;
  String sql="SELECT IdParoquia,Descricao,IFNULL(Bairro,''),IFNULL(Regiao,'') FROM paroquia WHERE Descricao IS NOT NULL AND Descricao<>'' ORDER BY Descricao";
  try(PreparedStatement p=c.prepareStatement(sql);ResultSet r=p.executeQuery()){while(r.next()){if(!primeiro)b.append(',');primeiro=false;b.append("{\"id\":").append(r.getInt(1)).append(",\"nome\":\"").append(jm(r.getString(2))).append("\",\"bairro\":\"").append(jm(r.getString(3))).append("\",\"regiao\":\"").append(jm(r.getString(4))).append("\"}");}}
  out.print(b.append("]}"));return;
 }
 if("cadastrar".equals(acao)&&"POST".equalsIgnoreCase(request.getMethod())){
  String nome=request.getParameter("nome"),telefone=request.getParameter("telefone"),nascimento=request.getParameter("nascimento");
  nome=nome==null?"":nome.trim();telefone=telefone==null?"":telefone.trim();String digitos=somenteDigitos(telefone);
  int grupo,paroquia;LocalDate data;
  try{grupo=Integer.parseInt(request.getParameter("grupo"));paroquia=Integer.parseInt(request.getParameter("paroquia"));data=LocalDate.parse(nascimento);}catch(Exception e){response.setStatus(400);out.print("{\"ok\":false,\"mensagem\":\"Preencha corretamente todos os campos.\"}");return;}
  if(nome.length()<3||nome.length()>200){response.setStatus(400);out.print("{\"ok\":false,\"mensagem\":\"Informe o nome completo.\"}");return;}
  if(digitos.length()<10||digitos.length()>11){response.setStatus(400);out.print("{\"ok\":false,\"mensagem\":\"Informe um telefone válido com DDD.\"}");return;}
  if(data.isAfter(LocalDate.now())){response.setStatus(400);out.print("{\"ok\":false,\"mensagem\":\"A data de nascimento não pode estar no futuro.\"}");return;}
  try(PreparedStatement p=c.prepareStatement("SELECT 1 FROM grupos WHERE IdGrupo=? AND StatusGrupo='ATIVO' AND GrupoOperacional=1 AND ModuloMembros=1")){p.setInt(1,grupo);try(ResultSet r=p.executeQuery()){if(!r.next()){response.setStatus(400);out.print("{\"ok\":false,\"mensagem\":\"O grupo selecionado não está disponível para membros.\"}");return;}}}
  try(PreparedStatement p=c.prepareStatement("SELECT 1 FROM paroquia WHERE IdParoquia=?")){p.setInt(1,paroquia);try(ResultSet r=p.executeQuery()){if(!r.next()){response.setStatus(400);out.print("{\"ok\":false,\"mensagem\":\"Paróquia não encontrada.\"}");return;}}}
  String normalizado="REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Fone1,'(',''),')',''),'-',''),' ',''),'.','')";
  try(PreparedStatement p=c.prepareStatement("SELECT 1 FROM pessoas WHERE "+normalizado+"=? LIMIT 1")){p.setString(1,digitos);try(ResultSet r=p.executeQuery()){if(r.next()){response.setStatus(409);out.print("{\"ok\":false,\"mensagem\":\"Já existe um membro cadastrado com este telefone.\"}");return;}}}
  String sql="INSERT INTO pessoas(Nome,Fone1,DtNascimento,Classe,IdParoquia,Status) VALUES(?,?,?,?,?,1)";
  try(PreparedStatement p=c.prepareStatement(sql,Statement.RETURN_GENERATED_KEYS)){p.setString(1,nome);p.setString(2,digitos);p.setDate(3,java.sql.Date.valueOf(data));p.setInt(4,grupo);p.setInt(5,paroquia);p.executeUpdate();try(ResultSet r=p.getGeneratedKeys()){int id=r.next()?r.getInt(1):0;out.print("{\"ok\":true,\"id\":"+id+",\"mensagem\":\"Membro cadastrado com sucesso.\"}");return;}}
 }
 response.setStatus(400);out.print("{\"ok\":false,\"mensagem\":\"Ação inválida.\"}");
}catch(Exception e){e.printStackTrace();response.setStatus(500);out.print("{\"ok\":false,\"mensagem\":\"Não foi possível cadastrar o membro.\"}");}
%>
