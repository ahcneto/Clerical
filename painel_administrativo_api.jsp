<%@ page import="java.sql.*" %>
<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="includes/auth.jsp" %>
<%!
private String jpa(String v){return v==null?"":v.replace("\\","\\\\").replace("\"","\\\"").replace("\r","\\r").replace("\n","\\n").replace("\t","\\t");}
private int pctpa(int parte,int total){return total>0?(int)Math.round(parte*100.0/total):0;}
%>
<%
String perfilPainel=(String)session.getAttribute("usuarioPerfil");
if(!"ADM".equals(perfilPainel)){response.setStatus(HttpServletResponse.SC_FORBIDDEN);out.print("{\"ok\":false,\"mensagem\":\"Acesso não autorizado.\"}");return;}
response.setHeader("Cache-Control","no-store");
try(Connection c=cad.db.Database.getConnection()){
 String sqlGrupos="SELECT g.IdGrupo,g.NomePlural,g.Cor,g.ModuloEncontros,g.ModuloPresencas,g.PresencaAtiva,g.ModuloFormacao,g.PresencaJustificadaConta,g.ModuloContribuicoes,g.ContribuicaoAtiva,g.ContribuicaoPeriodicidade,COUNT(p.IdPessoa) MembrosAtivos FROM grupos g LEFT JOIN sqlPessoas p ON p.Classe=g.IdGrupo AND p.status=1 WHERE g.StatusGrupo='ATIVO' AND g.GrupoOperacional=1 AND g.ModuloMembros=1 GROUP BY g.IdGrupo,g.NomePlural,g.Cor,g.ModuloEncontros,g.ModuloPresencas,g.PresencaAtiva,g.ModuloFormacao,g.PresencaJustificadaConta,g.ModuloContribuicoes,g.ContribuicaoAtiva,g.ContribuicaoPeriodicidade,g.Ordem ORDER BY g.Ordem,g.NomePlural";
 StringBuilder json=new StringBuilder("{\"ok\":true,\"grupos\":[");boolean primeiro=true;
 try(PreparedStatement pg=c.prepareStatement(sqlGrupos);ResultSet rg=pg.executeQuery()){
  while(rg.next()){
   int id=rg.getInt("IdGrupo"),membros=rg.getInt("MembrosAtivos");
   String nome=rg.getString("NomePlural"),cor=rg.getString("Cor"),periodicidade=rg.getString("ContribuicaoPeriodicidade");
   boolean moduloEncontros=rg.getBoolean("ModuloEncontros"),moduloPresencas=rg.getBoolean("ModuloPresencas"),presencaAtiva=rg.getBoolean("PresencaAtiva"),moduloFormacao=rg.getBoolean("ModuloFormacao"),justificadaConta=rg.getBoolean("PresencaJustificadaConta");
   boolean contribuicaoAtiva=rg.getBoolean("ModuloContribuicoes")&&rg.getBoolean("ContribuicaoAtiva")&&("MENSAL".equals(periodicidade)||"ENCONTRO".equals(periodicidade)||"MANUAL".equals(periodicidade));
   int idEncontro=0;String dataEncontro="",mesReferencia="";
   if(moduloEncontros){
    try(PreparedStatement pe=c.prepareStatement("SELECT IdEncontro,DATE_FORMAT(DtEncontro,'%d/%m/%Y') Data,DATE_FORMAT(DtEncontro,'%m/%Y') Mes FROM Encontros WHERE Classe=? AND Checklist=0 AND DtEncontro<=CURDATE() ORDER BY DtEncontro DESC,IdEncontro DESC LIMIT 1")){
     pe.setInt(1,id);try(ResultSet re=pe.executeQuery()){if(re.next()){idEncontro=re.getInt("IdEncontro");dataEncontro=re.getString("Data");mesReferencia=re.getString("Mes");}}
    }
   }
   boolean presencaDisponivel=moduloPresencas&&presencaAtiva&&idEncontro>0&&membros>0;int presentes=0,percentualPresenca=0;
   if(presencaDisponivel){
    String qp="SELECT SUM(CASE WHEN pe.flgPresenca=1 OR (?=1 AND pe.flgPresenca=2) THEN 1 ELSE 0 END) Presentes FROM sqlPessoas p LEFT JOIN participanteEncontro pe ON pe.IdPessoa=p.IdPessoa AND pe.IdEncontro=? WHERE p.Classe=? AND p.status=1";
    try(PreparedStatement pp=c.prepareStatement(qp)){pp.setInt(1,justificadaConta?1:0);pp.setInt(2,idEncontro);pp.setInt(3,id);try(ResultSet rp=pp.executeQuery()){if(rp.next())presentes=rp.getInt("Presentes");}}
    percentualPresenca=pctpa(presentes,membros);
   }
   String competenciaContribuicao="";boolean contribuicaoMensal="MENSAL".equals(periodicidade);if(contribuicaoMensal){try(PreparedStatement pmc=c.prepareStatement("SELECT DATE_FORMAT(CURDATE(),'%m/%Y')");ResultSet rmc=pmc.executeQuery()){if(rmc.next())competenciaContribuicao=rmc.getString(1);}}else competenciaContribuicao=mesReferencia;
   boolean contribuicaoDisponivel=contribuicaoAtiva&&(contribuicaoMensal||idEncontro>0)&&membros>0;int pagaram=0,percentualContribuicao=0,inadimplentesCompetencia=0,percentualInadimplenciaCompetencia=0;boolean semContribuicaoAnoDisponivel=contribuicaoAtiva&&membros>0;int semContribuicaoAnoAtual=0,percentualSemContribuicaoAnoAtual=0;
   if(semContribuicaoAnoDisponivel){String qsa="SELECT COUNT(*) SemContribuicao FROM sqlPessoas p WHERE p.Classe=? AND p.status=1 AND NOT EXISTS(SELECT 1 FROM lancamentos l WHERE l.idPessoa=p.IdPessoa AND l.idClasse=? AND l.tipoLancamento='1.1' AND l.status=1 AND YEAR(l.dtVencimento)=YEAR(CURDATE()))";try(PreparedStatement psa=c.prepareStatement(qsa)){psa.setInt(1,id);psa.setInt(2,id);try(ResultSet rsa=psa.executeQuery()){if(rsa.next())semContribuicaoAnoAtual=rsa.getInt("SemContribuicao");}}percentualSemContribuicaoAnoAtual=pctpa(semContribuicaoAnoAtual,membros);}
   if(contribuicaoDisponivel){
    String qc="SELECT COUNT(DISTINCT p.IdPessoa) Pagaram FROM sqlPessoas p JOIN lancamentos l ON l.idPessoa=p.IdPessoa AND l.idClasse=? AND l.tipoLancamento='1.1' AND l.status=1 AND YEAR(l.dtVencimento)=? AND MONTH(l.dtVencimento)=? WHERE p.Classe=? AND p.status=1";
    int mes=Integer.parseInt(competenciaContribuicao.substring(0,2)),ano=Integer.parseInt(competenciaContribuicao.substring(3));
    try(PreparedStatement pc=c.prepareStatement(qc)){pc.setInt(1,id);pc.setInt(2,ano);pc.setInt(3,mes);pc.setInt(4,id);try(ResultSet rc=pc.executeQuery()){if(rc.next())pagaram=rc.getInt("Pagaram");}}
    percentualContribuicao=pctpa(pagaram,membros);inadimplentesCompetencia=Math.max(0,membros-pagaram);percentualInadimplenciaCompetencia=pctpa(inadimplentesCompetencia,membros);
   }
       boolean formacao100Disponivel=false;int membrosFormacao100=0,membrosFormacaoAvaliados=0,membrosFormacaoNaoIniciada=0;long disciplinasObrigatoriasAtivas=0;
    if(moduloFormacao&&membros>0){
     String qf="SELECT COALESCE(SUM(CASE WHEN x.Obrigatorias>0 AND x.Concluidas=x.Obrigatorias THEN 1 ELSE 0 END),0) Completas,COALESCE(SUM(CASE WHEN x.Obrigatorias>0 THEN 1 ELSE 0 END),0) MembrosAvaliados,COALESCE(SUM(CASE WHEN x.Obrigatorias>0 AND x.Iniciadas=0 THEN 1 ELSE 0 END),0) NaoIniciadas,COALESCE(SUM(x.Obrigatorias),0) TotalObrigatorias FROM (SELECT p.IdPessoa,COUNT(DISTINCT d.IdDisciplina) Obrigatorias,COUNT(DISTINCT CASE WHEN fp.StatusDisciplina='CONCLUIDA' THEN d.IdDisciplina END) Concluidas,COUNT(DISTINCT CASE WHEN fp.StatusDisciplina IN('EM_ANDAMENTO','CONCLUIDA') THEN d.IdDisciplina END) Iniciadas FROM sqlPessoas p LEFT JOIN formacao_programa_grupo pg ON pg.Classe=p.Classe LEFT JOIN formacao_programa pr ON pr.IdPrograma=pg.IdPrograma AND pr.StatusPrograma='ATIVO' LEFT JOIN formacao_disciplina d ON d.IdPrograma=pr.IdPrograma AND d.TipoDisciplina='OBRIGATORIA' LEFT JOIN formacao_pessoa_disciplina fp ON fp.IdPessoa=p.IdPessoa AND fp.IdDisciplina=d.IdDisciplina WHERE p.Classe=? AND p.status=1 GROUP BY p.IdPessoa) x";
     try(PreparedStatement pf=c.prepareStatement(qf)){pf.setInt(1,id);try(ResultSet rf=pf.executeQuery()){if(rf.next()){membrosFormacao100=rf.getInt("Completas");disciplinasObrigatoriasAtivas=rf.getLong("TotalObrigatorias");membrosFormacaoAvaliados=rf.getInt("MembrosAvaliados");membrosFormacaoNaoIniciada=rf.getInt("NaoIniciadas");}}}
     formacao100Disponivel=disciplinasObrigatoriasAtivas>0;
    }
    boolean presencaAbaixo50Disponivel=false;int membrosAbaixo50=0,membrosAvaliadosPresenca=0;
    if(moduloPresencas&&presencaAtiva&&membros>0){
     String qp50="SELECT COUNT(*) Avaliados,COALESCE(SUM(CASE WHEN x.Presentes*2<x.Total THEN 1 ELSE 0 END),0) Abaixo50 FROM (SELECT p.IdPessoa,COUNT(*) Total,SUM(CASE WHEN pe.flgPresenca=1 THEN 1 ELSE 0 END) Presentes FROM sqlPessoas p JOIN participanteEncontro pe ON pe.IdPessoa=p.IdPessoa JOIN Encontros e ON e.IdEncontro=pe.IdEncontro AND e.Classe=p.Classe AND e.Checklist=0 AND YEAR(e.DtEncontro)=YEAR(CURDATE()) AND e.DtEncontro<=CURDATE() WHERE p.Classe=? AND p.status=1 GROUP BY p.IdPessoa) x";
     try(PreparedStatement pp50=c.prepareStatement(qp50)){pp50.setInt(1,id);try(ResultSet rp50=pp50.executeQuery()){if(rp50.next()){membrosAvaliadosPresenca=rp50.getInt("Avaliados");membrosAbaixo50=rp50.getInt("Abaixo50");}}}
     presencaAbaixo50Disponivel=membrosAvaliadosPresenca>0;
    }
   if(!primeiro)json.append(',');primeiro=false;
   json.append("{\"id\":").append(id).append(",\"nome\":\"").append(jpa(nome)).append("\",\"cor\":\"").append(jpa(cor)).append("\",\"membrosAtivos\":").append(membros)
    .append(",\"encontroId\":").append(idEncontro).append(",\"dataEncontro\":\"").append(jpa(dataEncontro)).append("\",\"mesReferencia\":\"").append(jpa(mesReferencia)).append("\",\"competenciaContribuicao\":\"").append(jpa(competenciaContribuicao)).append("\",\"contribuicaoMensal\":").append(contribuicaoMensal)
    .append(",\"presencaDisponivel\":").append(presencaDisponivel).append(",\"presentes\":").append(presentes).append(",\"percentualPresenca\":").append(percentualPresenca)
    .append(",\"contribuicaoDisponivel\":").append(contribuicaoDisponivel).append(",\"pagaram\":").append(pagaram).append(",\"percentualContribuicao\":").append(percentualContribuicao).append(",\"inadimplentesCompetencia\":").append(inadimplentesCompetencia).append(",\"percentualInadimplenciaCompetencia\":").append(percentualInadimplenciaCompetencia).append(",\"semContribuicaoAnoDisponivel\":").append(semContribuicaoAnoDisponivel).append(",\"semContribuicaoAnoAtual\":").append(semContribuicaoAnoAtual).append(",\"percentualSemContribuicaoAnoAtual\":").append(percentualSemContribuicaoAnoAtual)
     .append(",\"formacao100Disponivel\":").append(formacao100Disponivel).append(",\"membrosFormacao100\":").append(membrosFormacao100).append(",\"membrosFormacaoAvaliados\":").append(membrosFormacaoAvaliados).append(",\"membrosFormacaoNaoIniciada\":").append(membrosFormacaoNaoIniciada)
     .append(",\"presencaAbaixo50Configurada\":").append(moduloPresencas&&presencaAtiva).append(",\"presencaAbaixo50Disponivel\":").append(presencaAbaixo50Disponivel).append(",\"membrosAbaixo50\":").append(membrosAbaixo50).append(",\"membrosAvaliadosPresenca\":").append(membrosAvaliadosPresenca).append('}');
  }
 }
 int mesAniversarios=0;try(PreparedStatement pm=c.prepareStatement("SELECT MONTH(CURDATE())");ResultSet rm=pm.executeQuery()){if(rm.next())mesAniversarios=rm.getInt(1);}
 json.append("],\"mes\":").append(mesAniversarios).append(",\"aniversariantes\":[");boolean primeiroAniversario=true;
 String sqlAniversarios="SELECT p.Classe,p.Nome,IFNULL(p.NomeEsposa,'') NomeEsposa,p.DtNascimento,p.DtOrdenacao,p.DtCasamento,p.DtNascEsposa,g.NomePlural,g.Cor FROM pessoas p JOIN grupos g ON g.IdGrupo=p.Classe AND g.StatusGrupo='ATIVO' AND g.GrupoOperacional=1 AND g.ModuloMembros=1 WHERE p.Status=1 AND (MONTH(p.DtNascimento)=? OR MONTH(p.DtOrdenacao)=? OR MONTH(p.DtCasamento)=? OR MONTH(p.DtNascEsposa)=?) ORDER BY p.Nome";
 String[] tiposAniversario={"NASCIMENTO","ORDENACAO","CASAMENTO","ESPOSA"};
 try(PreparedStatement pa=c.prepareStatement(sqlAniversarios)){for(int i=1;i<=4;i++)pa.setInt(i,mesAniversarios);try(ResultSet ra=pa.executeQuery()){while(ra.next()){
  java.sql.Date[] datas={ra.getDate("DtNascimento"),ra.getDate("DtOrdenacao"),ra.getDate("DtCasamento"),ra.getDate("DtNascEsposa")};
  for(int i=0;i<datas.length;i++){java.sql.Date data=datas[i];if(data==null||data.toLocalDate().getMonthValue()!=mesAniversarios)continue;if(!primeiroAniversario)json.append(',');primeiroAniversario=false;
   json.append("{\"grupoId\":").append(ra.getInt("Classe")).append(",\"grupo\":\"").append(jpa(ra.getString("NomePlural"))).append("\",\"cor\":\"").append(jpa(ra.getString("Cor"))).append("\",\"nome\":\"").append(jpa(ra.getString("Nome"))).append("\",\"nomeEsposa\":\"").append(jpa(ra.getString("NomeEsposa"))).append("\",\"tipo\":\"").append(tiposAniversario[i]).append("\",\"data\":\"").append(new java.text.SimpleDateFormat("dd/MM").format(data)).append("\",\"dia\":").append(data.toLocalDate().getDayOfMonth()).append('}');
  }
 }}} out.print(json.append("]}"));
}catch(Exception e){getServletContext().log("Erro ao carregar painel administrativo por grupo",e);response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);out.print("{\"ok\":false,\"mensagem\":\"Não foi possível carregar os indicadores dos grupos.\"}");}
%>