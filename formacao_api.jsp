<%@ page import="java.sql.*,java.time.LocalDate" %>
<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="includes/escopoMembroApi.jspf" %>
<%!
private String jf(String valor) {
    return valor == null ? "" : valor.replace("\\","\\\\").replace("\"","\\\"")
        .replace("\r","\\r").replace("\n","\\n").replace("\t","\\t");
}
private int inteiro(String valor) {
    try { return Integer.parseInt(valor); } catch(Exception erro) { return 0; }
}
private String nomeGrupo(int classe) {
return cad.grupos.GrupoCatalogo.plural(classe);
}
%>
<%
response.setHeader("Cache-Control","no-store");
String perfil=(String)session.getAttribute("usuarioPerfil");
Integer usuarioId=(Integer)session.getAttribute("usuarioId");
if(usuarioId==null){response.setStatus(401);out.print("{\"ok\":false,\"mensagem\":\"Sessão inválida.\"}");return;}
String acao=request.getParameter("acao");if(acao==null)acao="programas";

try{
 try(Connection c=cad.db.Database.getConnection()){

  if("programas".equals(acao)){
   int pessoa=inteiro(request.getParameter("pessoa"));if(pessoa==0)pessoa=usuarioId;
   if(!cadPodeVerMembro(c,session,pessoa)){response.setStatus(403);out.print("{\"ok\":false,\"mensagem\":\"Acesso não autorizado.\"}");return;}
   int classe=0;String nome="";
   try(PreparedStatement p=c.prepareStatement("SELECT Classe,Nome FROM pessoas WHERE IdPessoa=?")){p.setInt(1,pessoa);try(ResultSet r=p.executeQuery()){if(!r.next()){response.setStatus(404);out.print("{\"ok\":false,\"mensagem\":\"Pessoa não encontrada.\"}");return;}classe=r.getInt(1);nome=r.getString(2);}}
   String sql="SELECT pr.IdPrograma,pr.Nome,DATE_FORMAT(pr.DtInicio,'%d/%m/%Y') DtInicio,pr.StatusPrograma,"+
    "(SELECT GROUP_CONCAT(pg.Classe ORDER BY pg.Classe) FROM formacao_programa_grupo pg WHERE pg.IdPrograma=pr.IdPrograma) Grupos,"+
    "(SELECT COUNT(*) FROM formacao_disciplina d WHERE d.IdPrograma=pr.IdPrograma AND d.TipoDisciplina='OBRIGATORIA') Obrigatorias,"+
    "(SELECT COUNT(*) FROM formacao_disciplina d JOIN formacao_pessoa_disciplina fp ON fp.IdDisciplina=d.IdDisciplina AND fp.IdPessoa=? AND fp.StatusDisciplina='CONCLUIDA' WHERE d.IdPrograma=pr.IdPrograma AND d.TipoDisciplina='OBRIGATORIA') Concluidas,"+
    "(SELECT COUNT(*) FROM formacao_disciplina d JOIN formacao_pessoa_disciplina fp ON fp.IdDisciplina=d.IdDisciplina AND fp.IdPessoa=? AND fp.StatusDisciplina='EM_ANDAMENTO' WHERE d.IdPrograma=pr.IdPrograma) Andamento "+
    "FROM formacao_programa pr WHERE (pr.StatusPrograma='ATIVO' AND EXISTS(SELECT 1 FROM formacao_programa_grupo pg JOIN grupos g ON g.IdGrupo=pg.Classe AND g.StatusGrupo='ATIVO' AND g.GrupoOperacional=1 AND g.ModuloFormacao=1 WHERE pg.IdPrograma=pr.IdPrograma AND pg.Classe=?)) OR EXISTS(SELECT 1 FROM formacao_disciplina d JOIN formacao_pessoa_disciplina fp ON fp.IdDisciplina=d.IdDisciplina WHERE d.IdPrograma=pr.IdPrograma AND fp.IdPessoa=? AND fp.StatusDisciplina<>'PENDENTE') OR EXISTS(SELECT 1 FROM formacao_disciplina d JOIN formacao_pessoa_historico h ON h.IdDisciplina=d.IdDisciplina WHERE d.IdPrograma=pr.IdPrograma AND h.IdPessoa=? AND h.StatusNovo IN('EM_ANDAMENTO','CONCLUIDA')) ORDER BY pr.StatusPrograma='ATIVO' DESC,pr.DtInicio DESC,pr.Nome";
   StringBuilder b=new StringBuilder("{\"ok\":true,\"pessoa\":").append(pessoa).append(",\"nome\":\"").append(jf(nome)).append("\",\"classe\":").append(classe).append(",\"programas\":[");boolean primeiro=true;
   try(PreparedStatement p=c.prepareStatement(sql)){p.setInt(1,pessoa);p.setInt(2,pessoa);p.setInt(3,classe);p.setInt(4,pessoa);p.setInt(5,pessoa);try(ResultSet r=p.executeQuery()){while(r.next()){int obrig=r.getInt("Obrigatorias"),concl=r.getInt("Concluidas"),pct=obrig>0?(int)Math.round(concl*100.0/obrig):0;if(!primeiro)b.append(',');primeiro=false;b.append("{\"id\":").append(r.getInt("IdPrograma")).append(",\"nome\":\"").append(jf(r.getString("Nome"))).append("\",\"dataInicio\":\"").append(jf(r.getString("DtInicio"))).append("\",\"status\":\"").append(r.getString("StatusPrograma")).append("\",\"grupos\":\"").append(jf(r.getString("Grupos"))).append("\",\"obrigatorias\":").append(obrig).append(",\"concluidas\":").append(concl).append(",\"emAndamento\":").append(r.getInt("Andamento")).append(",\"percentual\":").append(pct).append('}');}}}
   out.print(b.append("]}"));return;
  }

  if("disciplinas".equals(acao)){
   int pessoa=inteiro(request.getParameter("pessoa"));if(pessoa==0)pessoa=usuarioId;int programa=inteiro(request.getParameter("programa"));
   if(!cadPodeVerMembro(c,session,pessoa)){response.setStatus(403);out.print("{\"ok\":false,\"mensagem\":\"Acesso não autorizado.\"}");return;}
   int classe=0;String pessoaNome="";
   try(PreparedStatement p=c.prepareStatement("SELECT Classe,Nome FROM pessoas WHERE IdPessoa=?")){p.setInt(1,pessoa);try(ResultSet r=p.executeQuery()){if(r.next()){classe=r.getInt(1);pessoaNome=r.getString(2);}}}
   String programaNome="",programaStatus="",dataInicio="";
   String validar="SELECT pr.Nome,pr.StatusPrograma,DATE_FORMAT(pr.DtInicio,'%d/%m/%Y') FROM formacao_programa pr WHERE pr.IdPrograma=? AND ((pr.StatusPrograma='ATIVO' AND EXISTS(SELECT 1 FROM formacao_programa_grupo pg JOIN grupos g ON g.IdGrupo=pg.Classe AND g.StatusGrupo='ATIVO' AND g.GrupoOperacional=1 AND g.ModuloFormacao=1 WHERE pg.IdPrograma=pr.IdPrograma AND pg.Classe=?)) OR EXISTS(SELECT 1 FROM formacao_disciplina d JOIN formacao_pessoa_disciplina fp ON fp.IdDisciplina=d.IdDisciplina WHERE d.IdPrograma=pr.IdPrograma AND fp.IdPessoa=? AND fp.StatusDisciplina<>'PENDENTE') OR EXISTS(SELECT 1 FROM formacao_disciplina d JOIN formacao_pessoa_historico h ON h.IdDisciplina=d.IdDisciplina WHERE d.IdPrograma=pr.IdPrograma AND h.IdPessoa=? AND h.StatusNovo IN('EM_ANDAMENTO','CONCLUIDA')))";
   try(PreparedStatement p=c.prepareStatement(validar)){p.setInt(1,programa);p.setInt(2,classe);p.setInt(3,pessoa);p.setInt(4,pessoa);try(ResultSet r=p.executeQuery()){if(!r.next()){response.setStatus(404);out.print("{\"ok\":false,\"mensagem\":\"Programa não disponível para esta pessoa.\"}");return;}programaNome=r.getString(1);programaStatus=r.getString(2);dataInicio=r.getString(3);}}
   String sql="SELECT d.IdDisciplina,d.Descricao,d.CargaHoraria,d.TipoDisciplina,IFNULL(d.Bloco,'') Bloco,d.Ordem,IFNULL(fp.StatusDisciplina,'PENDENTE') StatusDisciplina,DATE_FORMAT(fp.DtInicio,'%Y-%m-%d') DtInicio,DATE_FORMAT(fp.DtConclusao,'%Y-%m-%d') DtConclusao,IFNULL(fp.Observacao,'') Observacao FROM formacao_disciplina d LEFT JOIN formacao_pessoa_disciplina fp ON fp.IdDisciplina=d.IdDisciplina AND fp.IdPessoa=? WHERE d.IdPrograma=? ORDER BY d.Ordem,d.Descricao";
   StringBuilder itens=new StringBuilder();boolean primeiro=true;int obrig=0,opcionais=0,concl=0,andamento=0;
   try(PreparedStatement p=c.prepareStatement(sql)){p.setInt(1,pessoa);p.setInt(2,programa);try(ResultSet r=p.executeQuery()){while(r.next()){String status=r.getString("StatusDisciplina");if("OBRIGATORIA".equals(r.getString("TipoDisciplina"))){obrig++;if("CONCLUIDA".equals(status))concl++;}else opcionais++;if("EM_ANDAMENTO".equals(status))andamento++;if(!primeiro)itens.append(',');primeiro=false;itens.append("{\"id\":").append(r.getInt("IdDisciplina")).append(",\"descricao\":\"").append(jf(r.getString("Descricao"))).append("\",\"cargaHoraria\":").append(r.getObject("CargaHoraria")==null?"null":r.getInt("CargaHoraria")).append(",\"tipo\":\"").append(r.getString("TipoDisciplina")).append("\",\"bloco\":\"").append(jf(r.getString("Bloco"))).append("\",\"ordem\":").append(r.getInt("Ordem")).append(",\"status\":\"").append(status).append("\",\"inicio\":\"").append(jf(r.getString("DtInicio"))).append("\",\"conclusao\":\"").append(jf(r.getString("DtConclusao"))).append("\",\"observacao\":\"").append(jf(r.getString("Observacao"))).append("\"}");}}}
   int pct=obrig>0?(int)Math.round(concl*100.0/obrig):0;
   out.print(new StringBuilder("{\"ok\":true,\"pessoa\":").append(pessoa).append(",\"pessoaNome\":\"").append(jf(pessoaNome)).append("\",\"programa\":{\"id\":").append(programa).append(",\"nome\":\"").append(jf(programaNome)).append("\",\"status\":\"").append(programaStatus).append("\",\"dataInicio\":\"").append(jf(dataInicio)).append("\"},\"percentual\":").append(pct).append(",\"obrigatorias\":").append(obrig).append(",\"opcionais\":").append(opcionais).append(",\"concluidas\":").append(concl).append(",\"emAndamento\":").append(andamento).append(",\"disciplinas\":[").append(itens).append("]}"));return;
  }

  if("salvarProgresso".equals(acao)){
   if(!"POST".equalsIgnoreCase(request.getMethod())){response.setStatus(405);out.print("{\"ok\":false,\"mensagem\":\"Método não permitido.\"}");return;}
   int pessoa=inteiro(request.getParameter("pessoa"));if(pessoa==0)pessoa=usuarioId;int disciplina=inteiro(request.getParameter("disciplina"));
   if(!(usuarioId.intValue()==pessoa||"ADM".equals(perfil))||"EXT".equals(perfil)){response.setStatus(403);out.print("{\"ok\":false,\"mensagem\":\"Acesso não autorizado.\"}");return;}
   String status=request.getParameter("status");if(!"PENDENTE".equals(status)&&!"EM_ANDAMENTO".equals(status)&&!"CONCLUIDA".equals(status)){response.setStatus(400);out.print("{\"ok\":false,\"mensagem\":\"Status inválido.\"}");return;}
   int classe=0;String anterior=null;
   try(PreparedStatement p=c.prepareStatement("SELECT Classe FROM pessoas WHERE IdPessoa=?")){p.setInt(1,pessoa);try(ResultSet r=p.executeQuery()){if(r.next())classe=r.getInt(1);}}
   String validar="SELECT fp.StatusDisciplina FROM formacao_disciplina d JOIN formacao_programa pr ON pr.IdPrograma=d.IdPrograma LEFT JOIN formacao_pessoa_disciplina fp ON fp.IdDisciplina=d.IdDisciplina AND fp.IdPessoa=? WHERE d.IdDisciplina=? AND ((pr.StatusPrograma='ATIVO' AND EXISTS(SELECT 1 FROM formacao_programa_grupo pg WHERE pg.IdPrograma=pr.IdPrograma AND pg.Classe=?)) OR EXISTS(SELECT 1 FROM formacao_disciplina dx JOIN formacao_pessoa_disciplina fx ON fx.IdDisciplina=dx.IdDisciplina WHERE dx.IdPrograma=pr.IdPrograma AND fx.IdPessoa=? AND fx.StatusDisciplina<>'PENDENTE') OR EXISTS(SELECT 1 FROM formacao_disciplina dx JOIN formacao_pessoa_historico hx ON hx.IdDisciplina=dx.IdDisciplina WHERE dx.IdPrograma=pr.IdPrograma AND hx.IdPessoa=? AND hx.StatusNovo IN('EM_ANDAMENTO','CONCLUIDA')))";
   try(PreparedStatement p=c.prepareStatement(validar)){p.setInt(1,pessoa);p.setInt(2,disciplina);p.setInt(3,classe);p.setInt(4,pessoa);p.setInt(5,pessoa);try(ResultSet r=p.executeQuery()){if(!r.next()){response.setStatus(400);out.print("{\"ok\":false,\"mensagem\":\"Disciplina não disponível.\"}");return;}anterior=r.getString(1);}}
   String inicio="EM_ANDAMENTO".equals(status)||"CONCLUIDA".equals(status)?LocalDate.now().toString():null,conclusao="CONCLUIDA".equals(status)?LocalDate.now().toString():null;
   String upsert="INSERT INTO formacao_pessoa_disciplina(IdPessoa,IdDisciplina,StatusDisciplina,ClasseRegistro,DtInicio,DtConclusao,IdUsuarioAtualizacao) VALUES(?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE StatusDisciplina=VALUES(StatusDisciplina),DtInicio=CASE WHEN VALUES(StatusDisciplina)='PENDENTE' THEN NULL ELSE IFNULL(DtInicio,VALUES(DtInicio)) END,DtConclusao=VALUES(DtConclusao),IdUsuarioAtualizacao=VALUES(IdUsuarioAtualizacao),DtAtualizacao=NOW()";
   try(PreparedStatement p=c.prepareStatement(upsert)){p.setInt(1,pessoa);p.setInt(2,disciplina);p.setString(3,status);p.setInt(4,classe);if(inicio==null)p.setNull(5,Types.DATE);else p.setDate(5,Date.valueOf(inicio));if(conclusao==null)p.setNull(6,Types.DATE);else p.setDate(6,Date.valueOf(conclusao));p.setInt(7,usuarioId);p.executeUpdate();}
   try(PreparedStatement p=c.prepareStatement("INSERT INTO formacao_pessoa_historico(IdPessoa,IdDisciplina,StatusAnterior,StatusNovo,ClasseRegistro,IdUsuario) VALUES(?,?,?,?,?,?)")){p.setInt(1,pessoa);p.setInt(2,disciplina);p.setString(3,anterior);p.setString(4,status);p.setInt(5,classe);p.setInt(6,usuarioId);p.executeUpdate();}
   out.print("{\"ok\":true}");return;
  }

  if("adminProgramas".equals(acao)){
   if(!"ADM".equals(perfil)){response.setStatus(403);out.print("{\"ok\":false,\"mensagem\":\"Acesso não autorizado.\"}");return;}
   String sql="SELECT pr.IdPrograma,pr.Nome,DATE_FORMAT(pr.DtInicio,'%Y-%m-%d'),pr.StatusPrograma,GROUP_CONCAT(DISTINCT pg.Classe ORDER BY pg.Classe),COUNT(DISTINCT d.IdDisciplina) FROM formacao_programa pr LEFT JOIN formacao_programa_grupo pg ON pg.IdPrograma=pr.IdPrograma LEFT JOIN formacao_disciplina d ON d.IdPrograma=pr.IdPrograma GROUP BY pr.IdPrograma ORDER BY pr.StatusPrograma='ATIVO' DESC,pr.Nome";
   StringBuilder b=new StringBuilder("{\"ok\":true,\"programas\":[");boolean primeiro=true;
   try(PreparedStatement p=c.prepareStatement(sql);ResultSet r=p.executeQuery()){while(r.next()){if(!primeiro)b.append(',');primeiro=false;String grupos=r.getString(5);b.append("{\"id\":").append(r.getInt(1)).append(",\"nome\":\"").append(jf(r.getString(2))).append("\",\"dataInicio\":\"").append(jf(r.getString(3))).append("\",\"status\":\"").append(r.getString(4)).append("\",\"grupos\":[").append(grupos==null?"":grupos).append("],\"totalDisciplinas\":").append(r.getInt(6)).append('}');}}
   out.print(b.append("]}"));return;
  }

  if("salvarPrograma".equals(acao)){
   if(!"ADM".equals(perfil)||!"POST".equalsIgnoreCase(request.getMethod())){response.setStatus(403);out.print("{\"ok\":false,\"mensagem\":\"Acesso não autorizado.\"}");return;}
   int id=inteiro(request.getParameter("id"));String nome=request.getParameter("nome"),data=request.getParameter("dataInicio"),status=request.getParameter("status"),grupos=request.getParameter("grupos");
   if(nome==null||nome.trim().isEmpty()||(!"ATIVO".equals(status)&&!"INATIVO".equals(status))||grupos==null||grupos.trim().isEmpty()){response.setStatus(400);out.print("{\"ok\":false,\"mensagem\":\"Informe nome, status e ao menos um grupo.\"}");return;}
   try(PreparedStatement valida=c.prepareStatement("SELECT 1 FROM grupos WHERE IdGrupo=? AND StatusGrupo='ATIVO' AND GrupoOperacional=1 AND ModuloFormacao=1")){for(String valorGrupo:grupos.split(",")){valida.setInt(1,inteiro(valorGrupo));try(ResultSet r=valida.executeQuery()){if(!r.next()){response.setStatus(400);out.print("{\"ok\":false,\"mensagem\":\"Há um grupo indisponível para formação.\"}");return;}}}}
   c.setAutoCommit(false);try{
    if(id==0){try(PreparedStatement p=c.prepareStatement("INSERT INTO formacao_programa(Nome,DtInicio,StatusPrograma,IdUsuarioCriacao) VALUES(?,?,?,?)",Statement.RETURN_GENERATED_KEYS)){p.setString(1,nome.trim());if(data==null||data.isEmpty())p.setNull(2,Types.DATE);else p.setDate(2,Date.valueOf(data));p.setString(3,status);p.setInt(4,usuarioId);p.executeUpdate();try(ResultSet r=p.getGeneratedKeys()){if(r.next())id=r.getInt(1);}}}
    else{try(PreparedStatement p=c.prepareStatement("UPDATE formacao_programa SET Nome=?,DtInicio=?,StatusPrograma=?,IdUsuarioAtualizacao=?,DtAtualizacao=NOW() WHERE IdPrograma=?")){p.setString(1,nome.trim());if(data==null||data.isEmpty())p.setNull(2,Types.DATE);else p.setDate(2,Date.valueOf(data));p.setString(3,status);p.setInt(4,usuarioId);p.setInt(5,id);p.executeUpdate();}try(PreparedStatement p=c.prepareStatement("DELETE FROM formacao_programa_grupo WHERE IdPrograma=?")){p.setInt(1,id);p.executeUpdate();}}
try(PreparedStatement p=c.prepareStatement("INSERT INTO formacao_programa_grupo(IdPrograma,Classe) SELECT ?,IdGrupo FROM grupos WHERE IdGrupo=? AND StatusGrupo='ATIVO' AND GrupoOperacional=1 AND ModuloFormacao=1")){for(String g:grupos.split(",")){int classe=inteiro(g);if(classe>=0){p.setInt(1,id);p.setInt(2,classe);p.addBatch();}}p.executeBatch();}
    c.commit();out.print("{\"ok\":true,\"id\":"+id+"}");return;
   }catch(Exception e){c.rollback();throw e;}finally{c.setAutoCommit(true);}
  }

  if("adminDisciplinas".equals(acao)){
   if(!"ADM".equals(perfil)){response.setStatus(403);out.print("{\"ok\":false,\"mensagem\":\"Acesso não autorizado.\"}");return;}int programa=inteiro(request.getParameter("programa"));
   StringBuilder b=new StringBuilder("{\"ok\":true,\"disciplinas\":[");boolean primeiro=true;
   try(PreparedStatement p=c.prepareStatement("SELECT IdDisciplina,Descricao,CargaHoraria,TipoDisciplina,IFNULL(Bloco,''),Ordem FROM formacao_disciplina WHERE IdPrograma=? ORDER BY Ordem,Descricao")){p.setInt(1,programa);try(ResultSet r=p.executeQuery()){while(r.next()){if(!primeiro)b.append(',');primeiro=false;b.append("{\"id\":").append(r.getInt(1)).append(",\"descricao\":\"").append(jf(r.getString(2))).append("\",\"cargaHoraria\":").append(r.getObject(3)==null?"null":r.getInt(3)).append(",\"tipo\":\"").append(r.getString(4)).append("\",\"bloco\":\"").append(jf(r.getString(5))).append("\",\"ordem\":").append(r.getInt(6)).append('}');}}}
   out.print(b.append("]}"));return;
  }

  if("salvarDisciplina".equals(acao)){
   if(!"ADM".equals(perfil)||!"POST".equalsIgnoreCase(request.getMethod())){response.setStatus(403);out.print("{\"ok\":false,\"mensagem\":\"Acesso não autorizado.\"}");return;}
   int id=inteiro(request.getParameter("id")),programa=inteiro(request.getParameter("programa")),carga=inteiro(request.getParameter("cargaHoraria")),ordem=inteiro(request.getParameter("ordem"));String descricao=request.getParameter("descricao"),tipo=request.getParameter("tipo"),bloco=request.getParameter("bloco");
   if(programa==0||descricao==null||descricao.trim().isEmpty()||(!"OBRIGATORIA".equals(tipo)&&!"OPCIONAL".equals(tipo))){response.setStatus(400);out.print("{\"ok\":false,\"mensagem\":\"Informe programa, descrição e tipo.\"}");return;}
   if(id==0){try(PreparedStatement p=c.prepareStatement("INSERT INTO formacao_disciplina(IdPrograma,Descricao,CargaHoraria,TipoDisciplina,Bloco,Ordem,IdUsuarioCriacao) VALUES(?,?,?,?,?,?,?)")){p.setInt(1,programa);p.setString(2,descricao.trim());if(carga==0)p.setNull(3,Types.INTEGER);else p.setInt(3,carga);p.setString(4,tipo);p.setString(5,bloco);p.setInt(6,ordem);p.setInt(7,usuarioId);p.executeUpdate();}}
   else{try(PreparedStatement p=c.prepareStatement("UPDATE formacao_disciplina SET Descricao=?,CargaHoraria=?,TipoDisciplina=?,Bloco=?,Ordem=?,IdUsuarioAtualizacao=?,DtAtualizacao=NOW() WHERE IdDisciplina=? AND IdPrograma=?")){p.setString(1,descricao.trim());if(carga==0)p.setNull(2,Types.INTEGER);else p.setInt(2,carga);p.setString(3,tipo);p.setString(4,bloco);p.setInt(5,ordem);p.setInt(6,usuarioId);p.setInt(7,id);p.setInt(8,programa);p.executeUpdate();}}
   out.print("{\"ok\":true}");return;
  }
  response.setStatus(400);out.print("{\"ok\":false,\"mensagem\":\"Ação inválida.\"}");
 }
}catch(Exception erro){response.setStatus(500);out.print("{\"ok\":false,\"mensagem\":\"Não foi possível processar a formação. Verifique se as tabelas foram criadas.\"}");}
%>
