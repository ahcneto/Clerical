<%@ page import="java.sql.*,java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="includes/auth.jsp" %>
<%@ include file="includes/escopoRelatorios.jspf" %>
<%!
private String hrf(String valor){
    if(valor==null)return "";
    return valor.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
        .replace("\"","&quot;").replace("'","&#39;");
}
private int irf(String valor,int padrao){
    try{return Integer.parseInt(valor);}catch(Exception erro){return padrao;}
}
private String grupoRf(int classe){
    return cad.grupos.GrupoCatalogo.plural(classe);
}
private String tagGrupoRf(int classe){
    return "";
}
%>
<%
String perfilRf=(String)session.getAttribute("usuarioPerfil");
if(!"ADM".equals(perfilRf)&&!"REP".equals(perfilRf)&&!"EXT".equals(perfilRf)){response.sendRedirect("index.jsp");return;}
Integer regiaoSessaoRf=(Integer)session.getAttribute("usuarioRegiaoId");
int grupo=irf(request.getParameter("grupo"),0),ordem=irf(request.getParameter("ordem"),-1);
String escopoRf=cadEscopoRelatorios(session);Integer grupoSessaoRf=(Integer)session.getAttribute("usuarioGrupoId");int regiaoRestritaRf="REP".equals(perfilRf)&&"REGIAO_TODOS".equals(escopoRf)?(regiaoSessaoRf==null?-1:regiaoSessaoRf.intValue()):0;if("REP".equals(perfilRf)&&"PROPRIO".equals(escopoRf))grupo=grupoSessaoRf==null?-1:grupoSessaoRf;else if("REP".equals(perfilRf)&&"NENHUM".equals(escopoRf))grupo=-1;
int semLeitor=irf(request.getParameter("semLeitor"),-1),semAcolito=irf(request.getParameter("semAcolito"),-1);
int leitor=irf(request.getParameter("leitor"),-1),acolito=irf(request.getParameter("acolito"),-1);
int minimo=Math.max(0,Math.min(100,irf(request.getParameter("minimo"),0)));
int maximo=Math.max(minimo,Math.min(100,irf(request.getParameter("maximo"),100)));
String nome=request.getParameter("nome");if(nome==null)nome="";nome=nome.trim();
class LinhaRf{
 int id,classe,percentual,ordem,semLeitor,semAcolito,leitor,acolito;String nome,paroquia;
}
List<LinhaRf> linhasRf=new ArrayList<LinhaRf>();int somaRf=0,concluidosRf=0;
try{
 try(Connection c=cad.db.Database.getConnection()){
  String sql="SELECT dados.* FROM ("+
   "SELECT p.IdPessoa,p.Nome,IFNULL(s.Paroquia,'') Paroquia,p.Classe,"+
   "IFNULL(p.flgOrdemSacra,0) flgOrdemSacra,IFNULL(p.flgSeminarioLeitor,0) flgSeminarioLeitor,IFNULL(p.flgSeminarioAcolito,0) flgSeminarioAcolito,IFNULL(p.flgLeitor,0) flgLeitor,IFNULL(p.flgAcolito,0) flgAcolito,"+
   "CASE WHEN IFNULL(ft.TotalObrigatorias,0)=0 THEN 0 ELSE ROUND(100.0*IFNULL(fc.Concluidas,0)/ft.TotalObrigatorias) END Percentual "+
   "FROM pessoas p JOIN grupos g ON g.IdGrupo=p.Classe AND g.StatusGrupo='ATIVO' AND g.GrupoOperacional=1 AND g.ModuloRelatorios=1 AND g.ModuloFormacao=1 LEFT JOIN sqlPessoas s ON s.IdPessoa=p.IdPessoa "+
   "LEFT JOIN (SELECT pg.Classe,COUNT(DISTINCT d.IdDisciplina) TotalObrigatorias "+
   "FROM formacao_programa pr JOIN formacao_programa_grupo pg ON pg.IdPrograma=pr.IdPrograma "+
   "JOIN formacao_disciplina d ON d.IdPrograma=pr.IdPrograma AND d.TipoDisciplina='OBRIGATORIA' "+
   "WHERE pr.StatusPrograma='ATIVO' GROUP BY pg.Classe) ft ON ft.Classe=p.Classe "+
   "LEFT JOIN (SELECT fp.IdPessoa,pg.Classe,COUNT(DISTINCT d.IdDisciplina) Concluidas "+
   "FROM formacao_pessoa_disciplina fp JOIN formacao_disciplina d ON d.IdDisciplina=fp.IdDisciplina AND d.TipoDisciplina='OBRIGATORIA' "+
   "JOIN formacao_programa pr ON pr.IdPrograma=d.IdPrograma AND pr.StatusPrograma='ATIVO' "+
   "JOIN formacao_programa_grupo pg ON pg.IdPrograma=pr.IdPrograma "+
   "WHERE fp.StatusDisciplina='CONCLUIDA' GROUP BY fp.IdPessoa,pg.Classe) fc ON fc.IdPessoa=p.IdPessoa AND fc.Classe=p.Classe "+
   "WHERE p.Status=1 "+
   "AND (?=0 OR p.Classe=?) AND (?='' OR p.Nome LIKE CONCAT('%',?,'%')) AND (?=0 OR IFNULL(s.IdRegiao,0)=?) "+
   "AND (?=-1 OR IFNULL(p.flgOrdemSacra,0)=?) AND (?=-1 OR IFNULL(p.flgSeminarioLeitor,0)=?) "+
   "AND (?=-1 OR IFNULL(p.flgSeminarioAcolito,0)=?) AND (?=-1 OR IFNULL(p.flgLeitor,0)=?) "+
   "AND (?=-1 OR IFNULL(p.flgAcolito,0)=?)) dados WHERE dados.Percentual BETWEEN ? AND ? ORDER BY dados.Classe,dados.Nome";
  try(PreparedStatement p=c.prepareStatement(sql)){
   int i=1;p.setInt(i++,grupo);p.setInt(i++,grupo);p.setString(i++,nome);p.setString(i++,nome);p.setInt(i++,regiaoRestritaRf);p.setInt(i++,regiaoRestritaRf);
   p.setInt(i++,ordem);p.setInt(i++,ordem);p.setInt(i++,semLeitor);p.setInt(i++,semLeitor);
   p.setInt(i++,semAcolito);p.setInt(i++,semAcolito);p.setInt(i++,leitor);p.setInt(i++,leitor);
   p.setInt(i++,acolito);p.setInt(i++,acolito);p.setInt(i++,minimo);p.setInt(i++,maximo);
   try(ResultSet r=p.executeQuery()){while(r.next()){LinhaRf l=new LinhaRf();l.id=r.getInt("IdPessoa");l.nome=r.getString("Nome");l.paroquia=r.getString("Paroquia");l.classe=r.getInt("Classe");l.percentual=r.getInt("Percentual");l.ordem=r.getInt("flgOrdemSacra");l.semLeitor=r.getInt("flgSeminarioLeitor");l.semAcolito=r.getInt("flgSeminarioAcolito");l.leitor=r.getInt("flgLeitor");l.acolito=r.getInt("flgAcolito");linhasRf.add(l);somaRf+=l.percentual;if(l.percentual==100)concluidosRf++;}}
  }
 }
}catch(Exception erro){
 erro.printStackTrace();
 request.setAttribute("erroRelatorioFormacao","Não foi possível carregar o relatório. Consulte o log do servidor para identificar o erro.");
}
int mediaRf=linhasRf.isEmpty()?0:Math.round(somaRf/(float)linhasRf.size());
%>
<!DOCTYPE html><html lang="pt-br"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Relatório de Formação</title><link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet"><link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet"><link rel="stylesheet" href="css/style.css"><style>
.report-photo{width:54px;height:54px;border-radius:50%;object-fit:cover;background:#f1f5f9}.report-filter{background:#fff;border:1px solid #e8edf3;border-radius:16px;padding:20px}.flag-ok{color:#15803d;font-size:19px}.flag-no{color:#cbd5e1;font-size:19px}.progress-cell{min-width:150px}.mini-progress{height:7px;border-radius:99px;background:#e9eef4;overflow:hidden}.mini-progress div{height:100%;background:#c96a0a}.ministerial-flags{white-space:nowrap}.report-table th{font-size:11px;text-transform:uppercase;color:#64748b;vertical-align:middle}.report-table td{vertical-align:middle}
@media print{@page{size:landscape;margin:9mm}.navbar,.no-print,footer{display:none!important}.container{max-width:none!important;padding:0!important}.profile-card{box-shadow:none!important;border:0!important;padding:0!important}.report-photo{width:38px;height:38px}.report-table{font-size:9pt}.report-table th,.report-table td{padding:5px}.mini-progress{print-color-adjust:exact;-webkit-print-color-adjust:exact}}
</style></head><body><jsp:include page="includes/header.jsp"/><main class="container py-4"><div class="d-flex justify-content-between align-items-start gap-3 mb-4"><div><a href="relatorios.jsp" class="btn btn-link px-0 no-print"><i class="bi bi-arrow-left"></i> Voltar aos relatórios</a><h1 class="fw-bold mb-1">Evolução da Formação</h1><p class="text-muted mb-0">Progresso acadêmico e etapas ministeriais dos membros</p></div><button class="btn btn-outline-secondary no-print" onclick="window.print()"><i class="bi bi-printer"></i> Imprimir</button></div>
<form class="report-filter mb-4 no-print" method="get"><div class="row g-3"><div class="col-md-3"><label class="form-label">Nome</label><input name="nome" value="<%= hrf(nome) %>" class="form-control" placeholder="Pesquisar membro"></div><div class="col-md-3"><label class="form-label">Grupo</label><select name="grupo" class="form-select"><option value="0">Todos</option><option value="1" <%= grupo==1?"selected":"" %>>Diáconos</option><option value="2" <%= grupo==2?"selected":"" %>>Candidatos</option><option value="3" <%= grupo==3?"selected":"" %>>Vocacionados</option></select></div><div class="col-md-3"><label class="form-label">Conclusão mínima (%)</label><input name="minimo" type="number" min="0" max="100" value="<%= minimo %>" class="form-control"></div><div class="col-md-3"><label class="form-label">Conclusão máxima (%)</label><input name="maximo" type="number" min="0" max="100" value="<%= maximo %>" class="form-control"></div>
<% String[] fn={"ordem","semLeitor","semAcolito","leitor","acolito"};String[] fl={"Ordem Sacra","Seminário de Leitor","Seminário de Acólito","Ministério de Leitor","Ministério de Acólito"};int[] fv={ordem,semLeitor,semAcolito,leitor,acolito};for(int x=0;x<fn.length;x++){ %><div class="col-md"><label class="form-label"><%= fl[x] %></label><select name="<%= fn[x] %>" class="form-select"><option value="-1">Todos</option><option value="1" <%= fv[x]==1?"selected":"" %>>Sim</option><option value="0" <%= fv[x]==0?"selected":"" %>>Não</option></select></div><% } %><div class="col-12 d-flex justify-content-end gap-2"><a href="relatorioFormacao.jsp" class="btn btn-light">Limpar</a><button class="btn btn-orange"><i class="bi bi-funnel"></i> Aplicar filtros</button></div></div></form>
<% if(request.getAttribute("erroRelatorioFormacao")!=null){ %><div class="alert alert-danger"><%= request.getAttribute("erroRelatorioFormacao") %></div><% } %>
<div class="row g-3 mb-4"><div class="col-md-4"><div class="dashboard-card"><h5>Membros encontrados</h5><div class="card-number"><%= linhasRf.size() %></div></div></div><div class="col-md-4"><div class="dashboard-card"><h5>Conclusão média</h5><div class="card-number"><%= mediaRf %>%</div></div></div><div class="col-md-4"><div class="dashboard-card"><h5>Formação concluída</h5><div class="card-number text-success"><%= concluidosRf %></div></div></div></div>
<section class="profile-card"><div class="table-responsive"><table class="table table-hover report-table"><thead><tr><th>Foto</th><th>Nome</th><th>Paróquia</th><th>Grupo</th><th>Formação</th><th>Ordem Sacra</th><th>Sem. Leitor</th><th>Sem. Acólito</th><th>Min. Leitor</th><th>Min. Acólito</th></tr></thead><tbody>
<% for(LinhaRf l:linhasRf){ %><tr><td><img src="fotos/foto_<%= l.id %>.jpg" class="report-photo" alt="" onerror="this.style.visibility='hidden'"></td><td><strong><%= hrf(l.nome) %></strong></td><td><%= hrf(l.paroquia) %></td><td><span class="badge-tag <%= tagGrupoRf(l.classe) %>"><%= grupoRf(l.classe) %></span></td><td class="progress-cell"><strong><%= l.percentual %>%</strong><div class="mini-progress mt-1"><div style="width:<%= l.percentual %>%"></div></div></td><% int[] flags={l.ordem,l.semLeitor,l.semAcolito,l.leitor,l.acolito};for(int flag:flags){ %><td class="text-center ministerial-flags"><i class="bi <%= flag==1?"bi-check-circle-fill flag-ok":"bi-dash-circle flag-no" %>"></i></td><% } %></tr><% } %>
<% if(linhasRf.isEmpty()){ %><tr><td colspan="10" class="text-center text-muted py-5">Nenhum membro encontrado para os filtros selecionados.</td></tr><% } %></tbody></table></div></section></main><jsp:include page="includes/footer.jsp"/></body></html>
