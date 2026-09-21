<%@ page import="java.sql.*,java.util.*" %>
<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
private String jg(String s){return s==null?"":s.replace("\\","\\\\").replace("\"","\\\"").replace("\r","\\r").replace("\n","\\n");}
private int ig(String s,int d){try{return Integer.parseInt(s);}catch(Exception e){return d;}}
private boolean bg(HttpServletRequest r,String n){return "1".equals(r.getParameter(n))||"true".equalsIgnoreCase(r.getParameter(n));}
private String eg(String v,String d,String...permitidos){if(v!=null)for(String p:permitidos)if(p.equals(v))return v;return d;}
private void setb(PreparedStatement p,int i,boolean v)throws SQLException{p.setInt(i,v?1:0);}
%>
<%
String perfilGrupo=(String)session.getAttribute("usuarioPerfil");
Integer usuarioGrupoAdmin=(Integer)session.getAttribute("usuarioId");
Integer grupoSessaoCatalogo=(Integer)session.getAttribute("usuarioGrupoId");
String acaoGrupo=request.getParameter("acao");if(acaoGrupo==null)acaoGrupo="listar";
boolean somenteAtivos="ativos".equals(acaoGrupo);
if(usuarioGrupoAdmin==null){response.setStatus(401);out.print("{\"ok\":false,\"mensagem\":\"Sessão inválida.\"}");return;}
if(!somenteAtivos&&!"ADM".equals(perfilGrupo)){response.setStatus(403);out.print("{\"ok\":false,\"mensagem\":\"Acesso exclusivo para administradores.\"}");return;}

try(Connection c=cad.db.Database.getConnection()){
 if(somenteAtivos){
  String escM="TODOS",escE="TODOS",escC="TODOS",escR="TODOS";if("REP".equals(perfilGrupo)){escM=escE=escC=escR="NENHUM";if(grupoSessaoCatalogo!=null)try(PreparedStatement pe=c.prepareStatement("SELECT EscopoRepMembros,EscopoRepEncontros,EscopoRepContribuicoes,EscopoRepRelatorios FROM grupos WHERE IdGrupo=?")){pe.setInt(1,grupoSessaoCatalogo);try(ResultSet re=pe.executeQuery()){if(re.next()){escM=re.getString(1);escE=re.getString(2);escC=re.getString(3);escR=re.getString(4);}}}}
  StringBuilder b=new StringBuilder("{\"ok\":true,\"perfil\":\"").append(jg(perfilGrupo)).append("\",\"grupoUsuario\":").append(grupoSessaoCatalogo==null?"null":grupoSessaoCatalogo).append(",\"escopos\":{\"membros\":\"").append(jg(escM)).append("\",\"encontros\":\"").append(jg(escE)).append("\",\"contribuicoes\":\"").append(jg(escC)).append("\",\"relatorios\":\"").append(jg(escR)).append("\"},\"grupos\":[");boolean f=true;
  try(PreparedStatement p=c.prepareStatement("SELECT IdGrupo,NomeSingular,NomePlural,Sigla,Cor,GrupoOperacional,DisponivelUsuarios,ModuloMembros,ModuloEncontros,ModuloPresencas,ModuloContribuicoes,ModuloFormacao,ModuloAvaliacoes,ModuloDocumentacao,ModuloRelatorios,ContribuicaoAtiva FROM grupos WHERE StatusGrupo='ATIVO' ORDER BY Ordem,NomePlural");ResultSet r=p.executeQuery()){
   while(r.next()){if(!f)b.append(',');f=false;b.append("{\"id\":").append(r.getInt(1)).append(",\"singular\":\"").append(jg(r.getString(2))).append("\",\"plural\":\"").append(jg(r.getString(3))).append("\",\"sigla\":\"").append(jg(r.getString(4))).append("\",\"cor\":\"").append(jg(r.getString(5))).append("\",\"operacional\":").append(r.getBoolean(6)).append(",\"usuarios\":").append(r.getBoolean(7)).append(",\"contribuicaoAtiva\":").append(r.getBoolean(16)).append(",\"modulos\":{\"membros\":").append(r.getBoolean(8)).append(",\"encontros\":").append(r.getBoolean(9)).append(",\"presencas\":").append(r.getBoolean(10)).append(",\"contribuicoes\":").append(r.getBoolean(11)).append(",\"formacao\":").append(r.getBoolean(12)).append(",\"avaliacoes\":").append(r.getBoolean(13)).append(",\"documentacao\":").append(r.getBoolean(14)).append(",\"relatorios\":").append(r.getBoolean(15)).append("}}");
   }
  }
  out.print(b.append("]}"));return;
 }

 if("POST".equalsIgnoreCase(request.getMethod())&&"salvar".equals(acaoGrupo)){
  int id=ig(request.getParameter("id"),-1);boolean novo=id<0;
  String singular=request.getParameter("singular"),plural=request.getParameter("plural"),sigla=request.getParameter("sigla"),descricao=request.getParameter("descricao"),cor=request.getParameter("cor");
  int ordem=ig(request.getParameter("ordem"),1),dia=ig(request.getParameter("contribuicaoDia"),10),meta=ig(request.getParameter("presencaMeta"),75),qtd=ig(request.getParameter("presencaQuantidade"),-1);
  double valor;try{valor=Double.parseDouble(request.getParameter("contribuicaoValor").replace(',','.'));}catch(Exception e){valor=0;}
  String status=eg(request.getParameter("status"),"ATIVO","ATIVO","INATIVO"),contexto=eg(request.getParameter("contexto"),"ESCOLA","CAD","ESCOLA","OUTRO");
  String periodicidade=eg(request.getParameter("contribuicaoPeriodicidade"),"NENHUMA","MENSAL","ENCONTRO","MANUAL","NENHUMA");
  String fonte=eg(request.getParameter("presencaFonte"),"ENCONTROS","ENCONTROS","MENSAL","FIXA","NAO");
  String escM=eg(request.getParameter("escopoRepMembros"),"PROPRIO","PROPRIO","REGIAO_TODOS","TODOS","NENHUM"),escE=eg(request.getParameter("escopoRepEncontros"),"PROPRIO","PROPRIO","REGIAO_TODOS","TODOS","NENHUM"),escC=eg(request.getParameter("escopoRepContribuicoes"),"PROPRIO","PROPRIO","REGIAO_TODOS","TODOS","NENHUM"),escR=eg(request.getParameter("escopoRepRelatorios"),"PROPRIO","PROPRIO","REGIAO_TODOS","TODOS","NENHUM");
  if(singular==null||singular.trim().isEmpty()||plural==null||plural.trim().isEmpty()||ordem<1||dia<1||dia>28||meta<0||meta>100||cor==null||!cor.matches("#[0-9a-fA-F]{6}")){response.setStatus(400);out.print("{\"ok\":false,\"mensagem\":\"Revise os campos obrigatórios e os valores informados.\"}");return;}
  singular=singular.trim();plural=plural.trim();sigla=sigla==null?"":sigla.trim().toUpperCase();descricao=descricao==null?"":descricao.trim();
  c.setAutoCommit(false);
  try{
   String campos="NomeSingular=?,NomePlural=?,Sigla=?,Descricao=?,Cor=?,Ordem=?,StatusGrupo=?,ContextoInstitucional=?,GrupoOperacional=?,DisponivelUsuarios=?,ModuloMembros=?,ModuloEncontros=?,ModuloPresencas=?,ModuloContribuicoes=?,ModuloFormacao=?,ModuloAvaliacoes=?,ModuloDocumentacao=?,ModuloRelatorios=?,ContribuicaoAtiva=?,ContribuicaoValor=?,ContribuicaoPeriodicidade=?,ContribuicaoDiaVencimento=?,ContribuicaoValorEditavel=?,ContribuicaoAteMesAtual=?,PresencaAtiva=?,PresencaFonteEsperada=?,PresencaQuantidadeAnual=?,PresencaMetaMinima=?,PresencaJustificadaConta=?,PermiteParticipacaoEsposas=?,AcompanhaTeologia=?,AcompanhaSeminarioLeitor=?,AcompanhaSeminarioAcolito=?,AcompanhaOrdemSacra=?,AcompanhaLeitor=?,AcompanhaAcolito=?,AcompanhaAptidaoMinisterial=?,AcompanhaAptidaoOrdenacao=?,AcompanhaPastoral=?,AcompanhaProvisao=?,AcompanhaOrdenacao=?,EscopoRepMembros=?,EscopoRepEncontros=?,EscopoRepContribuicoes=?,EscopoRepRelatorios=?";
   String sql=novo?"INSERT INTO grupos SET "+campos+",IdUsuarioCriacao=?":"UPDATE grupos SET "+campos+",IdUsuarioAtualizacao=?,DtAtualizacao=NOW() WHERE IdGrupo=?";
   try(PreparedStatement p=c.prepareStatement(sql,Statement.RETURN_GENERATED_KEYS)){int i=1;
    p.setString(i++,singular);p.setString(i++,plural);p.setString(i++,sigla);p.setString(i++,descricao);p.setString(i++,cor);p.setInt(i++,ordem);p.setString(i++,status);p.setString(i++,contexto);
    setb(p,i++,bg(request,"operacional"));setb(p,i++,bg(request,"usuarios"));setb(p,i++,bg(request,"moduloMembros"));setb(p,i++,bg(request,"moduloEncontros"));setb(p,i++,bg(request,"moduloPresencas"));setb(p,i++,bg(request,"moduloContribuicoes"));setb(p,i++,bg(request,"moduloFormacao"));setb(p,i++,bg(request,"moduloAvaliacoes"));setb(p,i++,bg(request,"moduloDocumentacao"));setb(p,i++,bg(request,"moduloRelatorios"));
    setb(p,i++,bg(request,"contribuicaoAtiva"));p.setDouble(i++,valor);p.setString(i++,periodicidade);p.setInt(i++,dia);setb(p,i++,bg(request,"contribuicaoValorEditavel"));setb(p,i++,bg(request,"contribuicaoAteAtual"));
    setb(p,i++,bg(request,"presencaAtiva"));p.setString(i++,fonte);if(qtd<1)p.setNull(i++,Types.INTEGER);else p.setInt(i++,qtd);p.setInt(i++,meta);setb(p,i++,bg(request,"presencaJustificada"));setb(p,i++,bg(request,"permiteEsposas"));
    for(String n:new String[]{"teologia","seminarioLeitor","seminarioAcolito","ordemSacra","leitor","acolito","aptidaoMinisterial","aptidaoOrdenacao","pastoral","provisao","ordenacao"})setb(p,i++,bg(request,n));
    p.setString(i++,escM);p.setString(i++,escE);p.setString(i++,escC);p.setString(i++,escR);p.setInt(i++,usuarioGrupoAdmin);if(!novo)p.setInt(i++,id);
    int alterados=p.executeUpdate();if(!novo&&alterados==0)throw new SQLException("Grupo não encontrado.");if(novo)try(ResultSet k=p.getGeneratedKeys()){if(k.next())id=k.getInt(1);}
   }
   try(PreparedStatement p=c.prepareStatement("DELETE FROM grupo_transicoes WHERE IdGrupoOrigem=?")){p.setInt(1,id);p.executeUpdate();}
   String[] acoes=request.getParameterValues("transicaoAcao"),destinos=request.getParameterValues("transicaoDestino"),efeitos=request.getParameterValues("transicaoEfeito"),camposData=request.getParameterValues("transicaoCampoData"),exigeMotivo=request.getParameterValues("transicaoExigeMotivo");
   if(acoes!=null)try(PreparedStatement p=c.prepareStatement("INSERT INTO grupo_transicoes(IdGrupoOrigem,IdGrupoDestino,NomeAcao,EfeitoAdicional,CampoDataAtualizar,ExigeData,ExigeMotivo,InativaPessoa,Ordem) VALUES(?,?,?,?,?,1,?,0,?)")){
    for(int x=0;x<acoes.length;x++){String ac=acoes[x]==null?"":acoes[x].trim();if(ac.isEmpty())continue;int destino=destinos!=null&&x<destinos.length?ig(destinos[x],-1):-1;if(destino<0||destino==id)throw new SQLException("Destino inválido na transição "+ac+".");p.setInt(1,id);p.setInt(2,destino);p.setString(3,ac);p.setString(4,efeitos!=null&&x<efeitos.length?efeitos[x]:"");String campo=camposData!=null&&x<camposData.length?camposData[x]:"";if(campo==null||campo.trim().isEmpty())p.setNull(5,Types.VARCHAR);else p.setString(5,campo.trim());p.setInt(6,exigeMotivo!=null&&x<exigeMotivo.length&&"1".equals(exigeMotivo[x])?1:0);p.setInt(7,x+1);p.addBatch();}p.executeBatch();
   }
   c.commit();cad.grupos.GrupoCatalogo.invalidar();out.print("{\"ok\":true,\"id\":"+id+",\"mensagem\":\"Grupo salvo com sucesso.\"}");return;
  }catch(Exception e){c.rollback();throw e;}finally{c.setAutoCommit(true);}
 }

 StringBuilder b=new StringBuilder("{\"ok\":true,\"grupos\":[");boolean f=true;
 String sql="SELECT * FROM grupos ORDER BY Ordem,NomePlural";
 try(PreparedStatement p=c.prepareStatement(sql);ResultSet r=p.executeQuery()){
  while(r.next()){if(!f)b.append(',');f=false;int id=r.getInt("IdGrupo");
   b.append("{\"id\":").append(id).append(",\"singular\":\"").append(jg(r.getString("NomeSingular"))).append("\",\"plural\":\"").append(jg(r.getString("NomePlural"))).append("\",\"sigla\":\"").append(jg(r.getString("Sigla"))).append("\",\"descricao\":\"").append(jg(r.getString("Descricao"))).append("\",\"cor\":\"").append(jg(r.getString("Cor"))).append("\",\"ordem\":").append(r.getInt("Ordem")).append(",\"status\":\"").append(r.getString("StatusGrupo")).append("\",\"contexto\":\"").append(r.getString("ContextoInstitucional")).append("\",\"operacional\":").append(r.getBoolean("GrupoOperacional")).append(",\"usuarios\":").append(r.getBoolean("DisponivelUsuarios"));
   b.append(",\"modulos\":{\"membros\":").append(r.getBoolean("ModuloMembros")).append(",\"encontros\":").append(r.getBoolean("ModuloEncontros")).append(",\"presencas\":").append(r.getBoolean("ModuloPresencas")).append(",\"contribuicoes\":").append(r.getBoolean("ModuloContribuicoes")).append(",\"formacao\":").append(r.getBoolean("ModuloFormacao")).append(",\"avaliacoes\":").append(r.getBoolean("ModuloAvaliacoes")).append(",\"documentacao\":").append(r.getBoolean("ModuloDocumentacao")).append(",\"relatorios\":").append(r.getBoolean("ModuloRelatorios")).append("}");
   b.append(",\"contribuicao\":{\"ativa\":").append(r.getBoolean("ContribuicaoAtiva")).append(",\"valor\":").append(r.getBigDecimal("ContribuicaoValor")).append(",\"periodicidade\":\"").append(r.getString("ContribuicaoPeriodicidade")).append("\",\"dia\":").append(r.getInt("ContribuicaoDiaVencimento")).append(",\"valorEditavel\":").append(r.getBoolean("ContribuicaoValorEditavel")).append(",\"ateAtual\":").append(r.getBoolean("ContribuicaoAteMesAtual")).append("}");
   b.append(",\"presenca\":{\"ativa\":").append(r.getBoolean("PresencaAtiva")).append(",\"fonte\":\"").append(r.getString("PresencaFonteEsperada")).append("\",\"quantidade\":").append(r.getObject("PresencaQuantidadeAnual")==null?"null":r.getInt("PresencaQuantidadeAnual")).append(",\"meta\":").append(r.getInt("PresencaMetaMinima")).append(",\"justificada\":").append(r.getBoolean("PresencaJustificadaConta")).append(",\"esposas\":").append(r.getBoolean("PermiteParticipacaoEsposas")).append("}");
   b.append(",\"ministerial\":{\"teologia\":").append(r.getBoolean("AcompanhaTeologia")).append(",\"seminarioLeitor\":").append(r.getBoolean("AcompanhaSeminarioLeitor")).append(",\"seminarioAcolito\":").append(r.getBoolean("AcompanhaSeminarioAcolito")).append(",\"ordemSacra\":").append(r.getBoolean("AcompanhaOrdemSacra")).append(",\"leitor\":").append(r.getBoolean("AcompanhaLeitor")).append(",\"acolito\":").append(r.getBoolean("AcompanhaAcolito")).append(",\"aptidaoMinisterial\":").append(r.getBoolean("AcompanhaAptidaoMinisterial")).append(",\"aptidaoOrdenacao\":").append(r.getBoolean("AcompanhaAptidaoOrdenacao")).append(",\"pastoral\":").append(r.getBoolean("AcompanhaPastoral")).append(",\"provisao\":").append(r.getBoolean("AcompanhaProvisao")).append(",\"ordenacao\":").append(r.getBoolean("AcompanhaOrdenacao")).append("}");
   b.append(",\"escopos\":{\"membros\":\"").append(r.getString("EscopoRepMembros")).append("\",\"encontros\":\"").append(r.getString("EscopoRepEncontros")).append("\",\"contribuicoes\":\"").append(r.getString("EscopoRepContribuicoes")).append("\",\"relatorios\":\"").append(r.getString("EscopoRepRelatorios")).append("\"},\"transicoes\":[");
   boolean ft=true;try(PreparedStatement pt=c.prepareStatement("SELECT IdTransicao,IdGrupoDestino,NomeAcao,IFNULL(EfeitoAdicional,''),IFNULL(CampoDataAtualizar,''),ExigeMotivo FROM grupo_transicoes WHERE IdGrupoOrigem=? AND StatusTransicao='ATIVO' ORDER BY Ordem,IdTransicao")){pt.setInt(1,id);try(ResultSet rt=pt.executeQuery()){while(rt.next()){if(!ft)b.append(',');ft=false;b.append("{\"id\":").append(rt.getInt(1)).append(",\"destino\":").append(rt.getInt(2)).append(",\"acao\":\"").append(jg(rt.getString(3))).append("\",\"efeito\":\"").append(jg(rt.getString(4))).append("\",\"campoData\":\"").append(jg(rt.getString(5))).append("\",\"exigeMotivo\":").append(rt.getBoolean(6)).append("}");}}}
   b.append("]}");
  }
 }
 out.print(b.append("]}"));
}catch(SQLIntegrityConstraintViolationException e){response.setStatus(409);out.print("{\"ok\":false,\"mensagem\":\"Já existe um grupo com esse nome ou uma referência inválida.\"}");}
catch(Exception e){getServletContext().log("Erro na administração de grupos",e);response.setStatus(500);out.print("{\"ok\":false,\"mensagem\":\"Não foi possível processar o cadastro de grupos.\"}");}
%>
