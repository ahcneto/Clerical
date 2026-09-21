<%@ page import="java.sql.*,java.util.*,java.io.*,java.nio.file.*" %>
<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="includes/escopoMembroApi.jspf" %>
<%!
private String jd(String valor){
    return valor==null?"":valor.replace("\\","\\\\").replace("\"","\\\"")
        .replace("\r","\\r").replace("\n","\\n").replace("\t","\\t");
}
private int idoc(String valor){try{return Integer.parseInt(valor);}catch(Exception erro){return 0;}}
private String grupoDoc(int classe){return cad.grupos.GrupoCatalogo.plural(classe);}
private boolean colunaDoc(Connection c,String tabela,String nome)throws SQLException{try(ResultSet r=c.getMetaData().getColumns(c.getCatalog(),null,tabela,nome)){return r.next();}}
private void prepararDoc(Connection c)throws SQLException{
 try(Statement s=c.createStatement()){
  if(!colunaDoc(c,"documentacao_checklist_item","PermiteUpload"))s.executeUpdate("ALTER TABLE documentacao_checklist_item ADD COLUMN PermiteUpload TINYINT(1) NOT NULL DEFAULT 0 AFTER ExibirMembro");
  if(!colunaDoc(c,"documentacao_checklist_item","PrefixoArquivo"))s.executeUpdate("ALTER TABLE documentacao_checklist_item ADD COLUMN PrefixoArquivo VARCHAR(40) NULL AFTER PermiteUpload");
  s.executeUpdate("CREATE TABLE IF NOT EXISTS documentacao_pessoa_arquivo (IdPessoa INT NOT NULL,IdItem INT NOT NULL,NomeArquivo VARCHAR(255) NOT NULL,NomeOriginal VARCHAR(255) NULL,TipoMime VARCHAR(100) NOT NULL,TamanhoBytes INT NOT NULL,DtUpload DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,IdUsuarioUpload INT NOT NULL,PRIMARY KEY(IdPessoa,IdItem),KEY idx_documentacao_arquivo_pessoa(IdPessoa,DtUpload),CONSTRAINT fk_documentacao_arquivo_item FOREIGN KEY(IdItem) REFERENCES documentacao_checklist_item(IdItem)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
 }
}
%>
<%
response.setHeader("Cache-Control","no-store");
String perfilDoc=(String)session.getAttribute("usuarioPerfil");
Integer usuarioDoc=(Integer)session.getAttribute("usuarioId");
if(usuarioDoc==null){response.setStatus(401);out.print("{\"ok\":false,\"mensagem\":\"Sessão inválida.\"}");return;}
boolean admDoc="ADM".equals(perfilDoc),consultaDoc=admDoc||"EXT".equals(perfilDoc);
String acaoDoc=request.getParameter("acao");if(acaoDoc==null)acaoDoc="meus";

try{
 try(Connection c=cad.db.Database.getConnection()){
  prepararDoc(c);
  if("meus".equals(acaoDoc)){
   String sql="SELECT ch.IdChecklist,ch.Nome,i.IdItem,i.Descricao,i.PermiteUpload,IFNULL(i.PrefixoArquivo,'') PrefixoArquivo,"+
    "CASE WHEN ch.StatusChecklist='ATIVO' AND i.StatusItem='ATIVO' THEN 1 ELSE 0 END DisponivelEnvio,"+
    "IFNULL(pi.StatusEntrega,'PENDENTE') StatusEntrega,DATE_FORMAT(pi.DtConclusao,'%d/%m/%Y') DtConclusao,a.NomeArquivo "+
    "FROM pessoas p JOIN grupos g ON g.IdGrupo=p.Classe AND g.StatusGrupo='ATIVO' AND g.GrupoOperacional=1 AND g.ModuloDocumentacao=1 JOIN documentacao_checklist ch ON ch.Classe=p.Classe "+
    "JOIN documentacao_checklist_item i ON i.IdChecklist=ch.IdChecklist AND i.ExibirMembro=1 "+
    "LEFT JOIN documentacao_pessoa_item pi ON pi.IdPessoa=p.IdPessoa AND pi.IdItem=i.IdItem "+
    "LEFT JOIN documentacao_pessoa_arquivo a ON a.IdPessoa=p.IdPessoa AND a.IdItem=i.IdItem "+
    "WHERE p.IdPessoa=? AND ((ch.StatusChecklist='ATIVO' AND i.StatusItem='ATIVO') OR pi.StatusEntrega='CONCLUIDO') ORDER BY ch.StatusChecklist='ATIVO' DESC,ch.Nome,i.Ordem,i.Descricao";
   StringBuilder b=new StringBuilder("{\"ok\":true,\"documentos\":[");boolean primeiro=true;int total=0,concluidos=0;
   try(PreparedStatement p=c.prepareStatement(sql)){p.setInt(1,usuarioDoc);try(ResultSet r=p.executeQuery()){while(r.next()){total++;if("CONCLUIDO".equals(r.getString("StatusEntrega")))concluidos++;if(!primeiro)b.append(',');primeiro=false;b.append("{\"checklistId\":").append(r.getInt("IdChecklist")).append(",\"checklist\":\"").append(jd(r.getString("Nome"))).append("\",\"itemId\":").append(r.getInt("IdItem")).append(",\"descricao\":\"").append(jd(r.getString("Descricao"))).append("\",\"permiteUpload\":").append(r.getBoolean("PermiteUpload")).append(",\"disponivelEnvio\":").append(r.getBoolean("DisponivelEnvio")).append(",\"prefixo\":\"").append(jd(r.getString("PrefixoArquivo"))).append("\",\"arquivo\":\"").append(jd(r.getString("NomeArquivo"))).append("\",\"status\":\"").append(r.getString("StatusEntrega")).append("\",\"conclusao\":\"").append(jd(r.getString("DtConclusao"))).append("\"}");}}}
   b.append("],\"total\":").append(total).append(",\"concluidos\":").append(concluidos).append(",\"pendentes\":").append(total-concluidos).append('}');out.print(b);return;
  }

  if("checklists".equals(acaoDoc)){
   if(!consultaDoc){response.setStatus(403);out.print("{\"ok\":false,\"mensagem\":\"Acesso não autorizado.\"}");return;}
String sql="SELECT ch.IdChecklist,ch.Nome,ch.Classe,ch.StatusChecklist,COUNT(DISTINCT i.IdItem) TotalItens,COUNT(DISTINCT CASE WHEN p.status=1 THEN p.IdPessoa END) TotalMembros FROM documentacao_checklist ch JOIN grupos g ON g.IdGrupo=ch.Classe AND g.StatusGrupo='ATIVO' AND g.GrupoOperacional=1 AND g.ModuloDocumentacao=1 LEFT JOIN documentacao_checklist_item i ON i.IdChecklist=ch.IdChecklist LEFT JOIN pessoas p ON p.Classe=ch.Classe GROUP BY ch.IdChecklist ORDER BY ch.StatusChecklist='ATIVO' DESC,ch.Classe,ch.Nome";
   StringBuilder b=new StringBuilder("{\"ok\":true,\"checklists\":[");boolean primeiro=true;
   try(PreparedStatement p=c.prepareStatement(sql);ResultSet r=p.executeQuery()){while(r.next()){if(!primeiro)b.append(',');primeiro=false;b.append("{\"id\":").append(r.getInt(1)).append(",\"nome\":\"").append(jd(r.getString(2))).append("\",\"classe\":").append(r.getInt(3)).append(",\"grupo\":\"").append(jd(grupoDoc(r.getInt(3)))).append("\",\"status\":\"").append(r.getString(4)).append("\",\"itens\":").append(r.getInt(5)).append(",\"membros\":").append(r.getInt(6)).append('}');}}
   out.print(b.append("]}"));return;
  }

  if("salvarChecklist".equals(acaoDoc)){
   if(!admDoc||!"POST".equalsIgnoreCase(request.getMethod())){response.setStatus(403);out.print("{\"ok\":false,\"mensagem\":\"Apenas administradores podem salvar checklists.\"}");return;}
   int id=idoc(request.getParameter("id")),classe=idoc(request.getParameter("classe"));String nome=request.getParameter("nome"),status=request.getParameter("status");
if(nome==null||nome.trim().isEmpty()||(!"ATIVO".equals(status)&&!"INATIVO".equals(status))){response.setStatus(400);out.print("{\"ok\":false,\"mensagem\":\"Informe nome, grupo e status válidos.\"}");return;}
try(PreparedStatement valida=c.prepareStatement("SELECT 1 FROM grupos WHERE IdGrupo=? AND StatusGrupo='ATIVO' AND GrupoOperacional=1 AND ModuloDocumentacao=1")){valida.setInt(1,classe);try(ResultSet r=valida.executeQuery()){if(!r.next()){response.setStatus(400);out.print("{\"ok\":false,\"mensagem\":\"Grupo indisponível para documentação.\"}");return;}}}
   if(id==0){try(PreparedStatement p=c.prepareStatement("INSERT INTO documentacao_checklist(Nome,Classe,StatusChecklist,IdUsuarioCriacao) VALUES(?,?,?,?)",Statement.RETURN_GENERATED_KEYS)){p.setString(1,nome.trim());p.setInt(2,classe);p.setString(3,status);p.setInt(4,usuarioDoc);p.executeUpdate();try(ResultSet r=p.getGeneratedKeys()){if(r.next())id=r.getInt(1);}}}
   else{try(PreparedStatement p=c.prepareStatement("UPDATE documentacao_checklist SET Nome=?,Classe=?,StatusChecklist=?,IdUsuarioAtualizacao=?,DtAtualizacao=NOW() WHERE IdChecklist=?")){p.setString(1,nome.trim());p.setInt(2,classe);p.setString(3,status);p.setInt(4,usuarioDoc);p.setInt(5,id);p.executeUpdate();}}
   out.print("{\"ok\":true,\"id\":"+id+"}");return;
  }

  if("itens".equals(acaoDoc)){
   if(!consultaDoc){response.setStatus(403);out.print("{\"ok\":false,\"mensagem\":\"Acesso não autorizado.\"}");return;}int checklist=idoc(request.getParameter("checklist"));
   StringBuilder b=new StringBuilder("{\"ok\":true,\"itens\":[");boolean primeiro=true;
   try(PreparedStatement p=c.prepareStatement("SELECT IdItem,Descricao,ExibirMembro,StatusItem,Ordem,PermiteUpload,IFNULL(PrefixoArquivo,'') PrefixoArquivo FROM documentacao_checklist_item WHERE IdChecklist=? ORDER BY Ordem,Descricao")){p.setInt(1,checklist);try(ResultSet r=p.executeQuery()){while(r.next()){if(!primeiro)b.append(',');primeiro=false;b.append("{\"id\":").append(r.getInt(1)).append(",\"descricao\":\"").append(jd(r.getString(2))).append("\",\"exibirMembro\":").append(r.getInt(3)==1).append(",\"status\":\"").append(r.getString(4)).append("\",\"ordem\":").append(r.getInt(5)).append(",\"permiteUpload\":").append(r.getBoolean(6)).append(",\"prefixo\":\"").append(jd(r.getString(7))).append("\"}");}}}
   out.print(b.append("]}"));return;
  }

  if("salvarItem".equals(acaoDoc)){
   if(!admDoc||!"POST".equalsIgnoreCase(request.getMethod())){response.setStatus(403);out.print("{\"ok\":false,\"mensagem\":\"Apenas administradores podem salvar itens.\"}");return;}
   int id=idoc(request.getParameter("id")),checklist=idoc(request.getParameter("checklist")),ordem=idoc(request.getParameter("ordem")),exibir=idoc(request.getParameter("exibirMembro")),permiteUpload=idoc(request.getParameter("permiteUpload"));String descricao=request.getParameter("descricao"),status=request.getParameter("status"),prefixo=request.getParameter("prefixo");
   prefixo=prefixo==null?"":prefixo.trim().toUpperCase(Locale.ROOT).replaceAll("[^A-Z0-9_-]","");
   if(checklist==0||descricao==null||descricao.trim().isEmpty()||(!"ATIVO".equals(status)&&!"INATIVO".equals(status))||(permiteUpload==1&&prefixo.isEmpty())){response.setStatus(400);out.print("{\"ok\":false,\"mensagem\":\"Informe descrição, status e prefixo válidos.\"}");return;}
   if(id==0){try(PreparedStatement p=c.prepareStatement("INSERT INTO documentacao_checklist_item(IdChecklist,Descricao,ExibirMembro,PermiteUpload,PrefixoArquivo,StatusItem,Ordem,IdUsuarioCriacao) VALUES(?,?,?,?,?,?,?,?)")){p.setInt(1,checklist);p.setString(2,descricao.trim());p.setInt(3,exibir==1?1:0);p.setInt(4,permiteUpload==1?1:0);if(permiteUpload==1)p.setString(5,prefixo);else p.setNull(5,Types.VARCHAR);p.setString(6,status);p.setInt(7,ordem);p.setInt(8,usuarioDoc);p.executeUpdate();}}
   else{try(PreparedStatement p=c.prepareStatement("UPDATE documentacao_checklist_item SET Descricao=?,ExibirMembro=?,PermiteUpload=?,PrefixoArquivo=?,StatusItem=?,Ordem=?,IdUsuarioAtualizacao=?,DtAtualizacao=NOW() WHERE IdItem=? AND IdChecklist=?")){p.setString(1,descricao.trim());p.setInt(2,exibir==1?1:0);p.setInt(3,permiteUpload==1?1:0);if(permiteUpload==1)p.setString(4,prefixo);else p.setNull(4,Types.VARCHAR);p.setString(5,status);p.setInt(6,ordem);p.setInt(7,usuarioDoc);p.setInt(8,id);p.setInt(9,checklist);p.executeUpdate();}}
   out.print("{\"ok\":true}");return;
  }

  if("acompanhamento".equals(acaoDoc)){
   if(!consultaDoc){response.setStatus(403);out.print("{\"ok\":false,\"mensagem\":\"Acesso não autorizado.\"}");return;}int checklist=idoc(request.getParameter("checklist"));
   String nome="",status="";int classe=0;
   try(PreparedStatement p=c.prepareStatement("SELECT Nome,Classe,StatusChecklist FROM documentacao_checklist WHERE IdChecklist=?")){p.setInt(1,checklist);try(ResultSet r=p.executeQuery()){if(!r.next()){response.setStatus(404);out.print("{\"ok\":false,\"mensagem\":\"Checklist não encontrado.\"}");return;}nome=r.getString(1);classe=r.getInt(2);status=r.getString(3);}}
   StringBuilder b=new StringBuilder("{\"ok\":true,\"checklist\":{\"id\":").append(checklist).append(",\"nome\":\"").append(jd(nome)).append("\",\"classe\":").append(classe).append(",\"grupo\":\"").append(jd(grupoDoc(classe))).append("\",\"status\":\"").append(status).append("\"},\"registros\":[");boolean primeiro=true;
   String sql="SELECT p.IdPessoa,p.Nome,IFNULL(pa.Regiao,'') Regiao,IFNULL(pa.Descricao,'') Paroquia,IFNULL(pa.Bairro,'') Bairro,IFNULL(p.Turma,'') Turma,i.IdItem,i.Descricao,i.ExibirMembro,i.PermiteUpload,IFNULL(i.PrefixoArquivo,'') PrefixoArquivo,IFNULL(pi.StatusEntrega,'PENDENTE') StatusEntrega,DATE_FORMAT(pi.DtConclusao,'%Y-%m-%d') DtConclusao,IFNULL(pi.Observacao,'') Observacao,a.NomeArquivo FROM pessoas p LEFT JOIN paroquia pa ON pa.IdParoquia=p.IdParoquia JOIN documentacao_checklist_item i ON i.IdChecklist=? AND i.StatusItem='ATIVO' LEFT JOIN documentacao_pessoa_item pi ON pi.IdPessoa=p.IdPessoa AND pi.IdItem=i.IdItem LEFT JOIN documentacao_pessoa_arquivo a ON a.IdPessoa=p.IdPessoa AND a.IdItem=i.IdItem WHERE p.Classe=? AND p.status=1 ORDER BY p.Nome,i.Ordem,i.Descricao";
   try(PreparedStatement p=c.prepareStatement(sql)){p.setInt(1,checklist);p.setInt(2,classe);try(ResultSet r=p.executeQuery()){while(r.next()){if(!primeiro)b.append(',');primeiro=false;b.append("{\"pessoa\":").append(r.getInt("IdPessoa")).append(",\"nome\":\"").append(jd(r.getString("Nome"))).append("\",\"regiao\":\"").append(jd(r.getString("Regiao"))).append("\",\"paroquia\":\"").append(jd(r.getString("Paroquia"))).append("\",\"bairro\":\"").append(jd(r.getString("Bairro"))).append("\",\"turma\":\"").append(jd(r.getString("Turma"))).append("\",\"item\":").append(r.getInt("IdItem")).append(",\"descricao\":\"").append(jd(r.getString("Descricao"))).append("\",\"visivel\":").append(r.getInt("ExibirMembro")==1).append(",\"permiteUpload\":").append(r.getBoolean("PermiteUpload")).append(",\"prefixo\":\"").append(jd(r.getString("PrefixoArquivo"))).append("\",\"arquivo\":\"").append(jd(r.getString("NomeArquivo"))).append("\",\"status\":\"").append(r.getString("StatusEntrega")).append("\",\"conclusao\":\"").append(jd(r.getString("DtConclusao"))).append("\",\"observacao\":\"").append(jd(r.getString("Observacao"))).append("\"}");}}}
   out.print(b.append("]}"));return;
  }

  if("marcar".equals(acaoDoc)){
   if(!admDoc||!"POST".equalsIgnoreCase(request.getMethod())){response.setStatus(403);out.print("{\"ok\":false,\"mensagem\":\"Apenas administradores podem registrar entregas.\"}");return;}
   int pessoa=idoc(request.getParameter("pessoa")),item=idoc(request.getParameter("item"));String status=request.getParameter("status"),observacao=request.getParameter("observacao");
   if(pessoa==0||item==0||(!"PENDENTE".equals(status)&&!"CONCLUIDO".equals(status))){response.setStatus(400);out.print("{\"ok\":false,\"mensagem\":\"Dados da entrega inválidos.\"}");return;}
   String sql="INSERT INTO documentacao_pessoa_item(IdPessoa,IdItem,StatusEntrega,DtConclusao,Observacao,IdUsuarioAtualizacao) VALUES(?,?,?,IF(?='CONCLUIDO',CURDATE(),NULL),?,?) ON DUPLICATE KEY UPDATE StatusEntrega=VALUES(StatusEntrega),DtConclusao=VALUES(DtConclusao),Observacao=VALUES(Observacao),IdUsuarioAtualizacao=VALUES(IdUsuarioAtualizacao),DtAtualizacao=NOW()";
   try(PreparedStatement p=c.prepareStatement(sql)){p.setInt(1,pessoa);p.setInt(2,item);p.setString(3,status);p.setString(4,status);p.setString(5,observacao==null?"":observacao.trim());p.setInt(6,usuarioDoc);p.executeUpdate();}
   out.print("{\"ok\":true}");return;
  }

  if("excluirArquivo".equals(acaoDoc)){
   if(!admDoc||!"POST".equalsIgnoreCase(request.getMethod())){response.setStatus(403);out.print("{\"ok\":false,\"mensagem\":\"Apenas administradores podem excluir arquivos.\"}");return;}
   int pessoa=idoc(request.getParameter("pessoa")),item=idoc(request.getParameter("item"));if(pessoa==0||item==0){response.setStatus(400);out.print("{\"ok\":false,\"mensagem\":\"Arquivo inválido.\"}");return;}
   String nomeArquivo=null;try(PreparedStatement p=c.prepareStatement("SELECT NomeArquivo FROM documentacao_pessoa_arquivo WHERE IdPessoa=? AND IdItem=?")){p.setInt(1,pessoa);p.setInt(2,item);try(ResultSet r=p.executeQuery()){if(r.next())nomeArquivo=r.getString(1);}}
   if(nomeArquivo==null){response.setStatus(404);out.print("{\"ok\":false,\"mensagem\":\"Arquivo não encontrado.\"}");return;}
   File pasta=new File(application.getRealPath("/WEB-INF"),"documentos_membros"),origem=new File(pasta,nomeArquivo),excluidos=new File(pasta,"excluidos");if(!excluidos.exists())excluidos.mkdirs();File backup=new File(excluidos,Calendar.getInstance().getTimeInMillis()+"_"+nomeArquivo);
   c.setAutoCommit(false);try{if(origem.isFile())Files.move(origem.toPath(),backup.toPath(),StandardCopyOption.REPLACE_EXISTING);try(PreparedStatement p=c.prepareStatement("DELETE FROM documentacao_pessoa_arquivo WHERE IdPessoa=? AND IdItem=?")){p.setInt(1,pessoa);p.setInt(2,item);p.executeUpdate();}try(PreparedStatement p=c.prepareStatement("UPDATE documentacao_pessoa_item SET StatusEntrega='PENDENTE',DtConclusao=NULL,Observacao='',IdUsuarioAtualizacao=?,DtAtualizacao=NOW() WHERE IdPessoa=? AND IdItem=?")){p.setInt(1,usuarioDoc);p.setInt(2,pessoa);p.setInt(3,item);p.executeUpdate();}c.commit();}catch(Exception e){c.rollback();if(backup.isFile())Files.move(backup.toPath(),origem.toPath(),StandardCopyOption.REPLACE_EXISTING);throw e;}finally{c.setAutoCommit(true);}
   out.print("{\"ok\":true}");return;
  }

  if("arquivosPerfil".equals(acaoDoc)){
   int pessoa=idoc(request.getParameter("pessoa"));
   boolean autorizado=cadPodeVerMembro(c,session,pessoa);
   if(pessoa==0||!autorizado){response.setStatus(403);out.print("{\"ok\":false,\"mensagem\":\"Acesso não autorizado.\"}");return;}
   StringBuilder b=new StringBuilder("{\"ok\":true,\"arquivos\":[");boolean primeiro=true;
   String sql="SELECT a.IdItem,a.NomeArquivo,a.NomeOriginal,a.TipoMime,a.TamanhoBytes,DATE_FORMAT(a.DtUpload,'%d/%m/%Y %H:%i') DtUpload,i.Descricao,ch.Nome Checklist FROM documentacao_pessoa_arquivo a JOIN documentacao_checklist_item i ON i.IdItem=a.IdItem JOIN documentacao_checklist ch ON ch.IdChecklist=i.IdChecklist WHERE a.IdPessoa=? ORDER BY a.DtUpload DESC,i.Descricao";
   try(PreparedStatement p=c.prepareStatement(sql)){p.setInt(1,pessoa);try(ResultSet r=p.executeQuery()){while(r.next()){if(!primeiro)b.append(',');primeiro=false;b.append("{\"item\":").append(r.getInt("IdItem")).append(",\"nome\":\"").append(jd(r.getString("NomeArquivo"))).append("\",\"original\":\"").append(jd(r.getString("NomeOriginal"))).append("\",\"tipo\":\"").append(jd(r.getString("TipoMime"))).append("\",\"tamanho\":").append(r.getInt("TamanhoBytes")).append(",\"data\":\"").append(jd(r.getString("DtUpload"))).append("\",\"descricao\":\"").append(jd(r.getString("Descricao"))).append("\",\"checklist\":\"").append(jd(r.getString("Checklist"))).append("\",\"url\":\"baixarDocumentoMembro.jsp?pessoa=").append(pessoa).append("&item=").append(r.getInt("IdItem")).append("\"}");}}}
   out.print(b.append("]}"));return;
  }
  response.setStatus(400);out.print("{\"ok\":false,\"mensagem\":\"Ação inválida.\"}");
 }
}catch(Exception erro){erro.printStackTrace();response.setStatus(500);out.print("{\"ok\":false,\"mensagem\":\"Não foi possível processar os documentos. Verifique se as tabelas foram criadas.\"}");}
%>
