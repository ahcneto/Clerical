<%@ page import="java.sql.*" %>
<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%
response.setHeader("Cache-Control","no-store");
Integer usuarioAcesso=(Integer)session.getAttribute("usuarioId");
if(usuarioAcesso==null){response.setStatus(401);out.print("{\"ok\":false}");return;}
String paginaAcesso=request.getParameter("pagina"),tituloAcesso=request.getParameter("titulo");
if(paginaAcesso==null)paginaAcesso="";paginaAcesso=paginaAcesso.trim().replace('\\','/');
while(paginaAcesso.startsWith("/"))paginaAcesso=paginaAcesso.substring(1);
if(paginaAcesso.length()>120||paginaAcesso.indexOf("..")>=0||!paginaAcesso.matches("[A-Za-z0-9_./-]+\\.(jsp|html)")){response.setStatus(400);out.print("{\"ok\":false}");return;}
if(paginaAcesso.endsWith("_api.jsp")||paginaAcesso.endsWith("registrarAcesso.jsp")){out.print("{\"ok\":true}");return;}
if(tituloAcesso==null)tituloAcesso="";tituloAcesso=tituloAcesso.trim();if(tituloAcesso.length()>160)tituloAcesso=tituloAcesso.substring(0,160);
String perfilAcesso=(String)session.getAttribute("usuarioPerfil");Integer grupoAcesso=(Integer)session.getAttribute("usuarioGrupoId");
try(Connection c=cad.db.Database.getConnection()){
 synchronized(application){if(application.getAttribute("cadEstatisticaEstrutura")==null){try(Statement s=c.createStatement()){s.executeUpdate("CREATE TABLE IF NOT EXISTS estatistica_acessos (IdAcesso BIGINT NOT NULL AUTO_INCREMENT,IdPessoa INT NOT NULL,Perfil VARCHAR(10) NOT NULL,IdGrupo INT NULL,Pagina VARCHAR(120) NOT NULL,Titulo VARCHAR(160) NULL,DtAcesso DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,PRIMARY KEY(IdAcesso),KEY ix_estatistica_data(DtAcesso),KEY ix_estatistica_pagina_data(Pagina,DtAcesso),KEY ix_estatistica_pessoa_data(IdPessoa,DtAcesso)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");}application.setAttribute("cadEstatisticaEstrutura",Boolean.TRUE);}}
 try(PreparedStatement p=c.prepareStatement("INSERT INTO estatistica_acessos(IdPessoa,Perfil,IdGrupo,Pagina,Titulo) VALUES(?,?,?,?,?)")){p.setInt(1,usuarioAcesso);p.setString(2,perfilAcesso==null?"USR":perfilAcesso);if(grupoAcesso==null)p.setNull(3,Types.INTEGER);else p.setInt(3,grupoAcesso);p.setString(4,paginaAcesso);p.setString(5,tituloAcesso);p.executeUpdate();}
 out.print("{\"ok\":true}");
}catch(Exception erro){erro.printStackTrace();response.setStatus(500);out.print("{\"ok\":false}");}
%>
