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
 String sqlGrupos="SELECT g.IdGrupo,g.NomePlural,g.Cor,g.ModuloEncontros,g.ModuloPresencas,g.PresencaAtiva,g.PresencaJustificadaConta,g.ModuloContribuicoes,g.ContribuicaoAtiva,g.ContribuicaoPeriodicidade,COUNT(p.IdPessoa) MembrosAtivos FROM grupos g LEFT JOIN sqlPessoas p ON p.Classe=g.IdGrupo AND p.status=1 WHERE g.StatusGrupo='ATIVO' AND g.GrupoOperacional=1 AND g.ModuloMembros=1 GROUP BY g.IdGrupo,g.NomePlural,g.Cor,g.ModuloEncontros,g.ModuloPresencas,g.PresencaAtiva,g.PresencaJustificadaConta,g.ModuloContribuicoes,g.ContribuicaoAtiva,g.ContribuicaoPeriodicidade,g.Ordem ORDER BY g.Ordem,g.NomePlural";
 StringBuilder json=new StringBuilder("{\"ok\":true,\"grupos\":[");boolean primeiro=true;
 try(PreparedStatement pg=c.prepareStatement(sqlGrupos);ResultSet rg=pg.executeQuery()){
  while(rg.next()){
   int id=rg.getInt("IdGrupo"),membros=rg.getInt("MembrosAtivos");
   String nome=rg.getString("NomePlural"),cor=rg.getString("Cor"),periodicidade=rg.getString("ContribuicaoPeriodicidade");
   boolean moduloEncontros=rg.getBoolean("ModuloEncontros"),moduloPresencas=rg.getBoolean("ModuloPresencas"),presencaAtiva=rg.getBoolean("PresencaAtiva"),justificadaConta=rg.getBoolean("PresencaJustificadaConta");
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
   boolean contribuicaoDisponivel=contribuicaoAtiva&&idEncontro>0&&membros>0;int pagaram=0,percentualContribuicao=0,inadimplentesCompetencia=0,percentualInadimplenciaCompetencia=0;
   if(contribuicaoDisponivel){
    String qc="SELECT COUNT(DISTINCT p.IdPessoa) Pagaram FROM sqlPessoas p JOIN lancamentos l ON l.idPessoa=p.IdPessoa AND l.idClasse=? AND l.tipoLancamento='1.1' AND l.status=1 AND YEAR(l.dtVencimento)=? AND MONTH(l.dtVencimento)=? WHERE p.Classe=? AND p.status=1";
    int mes=Integer.parseInt(mesReferencia.substring(0,2)),ano=Integer.parseInt(mesReferencia.substring(3));
    try(PreparedStatement pc=c.prepareStatement(qc)){pc.setInt(1,id);pc.setInt(2,ano);pc.setInt(3,mes);pc.setInt(4,id);try(ResultSet rc=pc.executeQuery()){if(rc.next())pagaram=rc.getInt("Pagaram");}}
    percentualContribuicao=pctpa(pagaram,membros);inadimplentesCompetencia=Math.max(0,membros-pagaram);percentualInadimplenciaCompetencia=pctpa(inadimplentesCompetencia,membros);
   }
   boolean inadimplenciaHistoricaDisponivel=contribuicaoAtiva&&membros>0;int inadimplentesHistoricos=0,percentualInadimplenciaHistorica=0;
   if(inadimplenciaHistoricaDisponivel){
    String qh="SELECT COUNT(DISTINCT p.IdPessoa) Inadimplentes FROM sqlPessoas p WHERE p.Classe=? AND p.status=1 AND EXISTS(SELECT 1 FROM lancamentos l WHERE l.idPessoa=p.IdPessoa AND l.idClasse=? AND l.tipoLancamento='1.1' AND l.status=0 AND l.dtVencimento<CURDATE())";
    try(PreparedStatement ph=c.prepareStatement(qh)){ph.setInt(1,id);ph.setInt(2,id);try(ResultSet rh=ph.executeQuery()){if(rh.next())inadimplentesHistoricos=rh.getInt("Inadimplentes");}}
    percentualInadimplenciaHistorica=pctpa(inadimplentesHistoricos,membros);
   }
   if(!primeiro)json.append(',');primeiro=false;
   json.append("{\"id\":").append(id).append(",\"nome\":\"").append(jpa(nome)).append("\",\"cor\":\"").append(jpa(cor)).append("\",\"membrosAtivos\":").append(membros)
    .append(",\"encontroId\":").append(idEncontro).append(",\"dataEncontro\":\"").append(jpa(dataEncontro)).append("\",\"mesReferencia\":\"").append(jpa(mesReferencia)).append("\"")
    .append(",\"presencaDisponivel\":").append(presencaDisponivel).append(",\"presentes\":").append(presentes).append(",\"percentualPresenca\":").append(percentualPresenca)
    .append(",\"contribuicaoDisponivel\":").append(contribuicaoDisponivel).append(",\"pagaram\":").append(pagaram).append(",\"percentualContribuicao\":").append(percentualContribuicao).append(",\"inadimplentesCompetencia\":").append(inadimplentesCompetencia).append(",\"percentualInadimplenciaCompetencia\":").append(percentualInadimplenciaCompetencia)
    .append(",\"inadimplenciaHistoricaDisponivel\":").append(inadimplenciaHistoricaDisponivel).append(",\"inadimplentesHistoricos\":").append(inadimplentesHistoricos).append(",\"percentualInadimplenciaHistorica\":").append(percentualInadimplenciaHistorica).append('}');
  }
 }
 out.print(json.append("]}"));
}catch(Exception e){getServletContext().log("Erro ao carregar painel administrativo por grupo",e);response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);out.print("{\"ok\":false,\"mensagem\":\"Não foi possível carregar os indicadores dos grupos.\"}");}
%>