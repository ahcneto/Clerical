<%@ page import="java.sql.*,java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="includes/auth.jsp" %>
<%!
private String hul(String v){return v==null?"":v.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");}
private int iul(String v,int d){try{return Integer.parseInt(v);}catch(Exception e){return d;}}
private String gul(int c){return cad.grupos.GrupoCatalogo.plural(c);}
private String mul(int m){String[] n={"Todos","Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"};return m>=0&&m<=12?n[m]:"Todos";}
%>
<%
String perfilUl=(String)session.getAttribute("usuarioPerfil");
if(!"ADM".equals(perfilUl)){response.sendRedirect("index.jsp");return;}
int classeUl=iul(request.getParameter("classe"),-1);if(classeUl < -1)classeUl=-1;
int statusUl=iul(request.getParameter("status"),1);if(statusUl < -1 || statusUl > 1)statusUl=1;
int anoUl=iul(request.getParameter("ano"),0);if(anoUl < 0 || anoUl > 9999)anoUl=0;
int mesUl=iul(request.getParameter("mes"),0);if(mesUl < 0 || mesUl > 12)mesUl=0;
String acessoUl=request.getParameter("acesso");if(!"ACESSOU".equals(acessoUl)&&!"NUNCA".equals(acessoUl))acessoUl="TODOS";
class LoginUl{int classe,status,total;String nome,perfil,ultimo,ip;}
List<LoginUl> usuariosUl=new ArrayList<LoginUl>();List<Integer> anosUl=new ArrayList<Integer>();String erroUl=null;int acessaramUl=0,nuncaUl=0;
try{
 try(Connection c=cad.db.Database.getConnection()){
  try(PreparedStatement py=c.prepareStatement("SELECT DISTINCT YEAR(DataLogin) Ano FROM LogLogin ORDER BY Ano DESC");ResultSet ry=py.executeQuery()){while(ry.next())anosUl.add(ry.getInt(1));}
  String sql="SELECT p.Nome,p.Classe,IFNULL(p.Status,1) Status,IFNULL(u.Profile,'USR') Profile,"+
   "DATE_FORMAT(MAX(l.DataLogin),'%d/%m/%Y %H:%i') UltimoLogin,COUNT(l.IdLogLogin) TotalAcessos,"+
   "(SELECT l2.EnderecoIp FROM LogLogin l2 WHERE l2.IdPessoa=p.IdPessoa AND (?=0 OR YEAR(l2.DataLogin)=?) AND (?=0 OR MONTH(l2.DataLogin)=?) ORDER BY l2.DataLogin DESC,l2.IdLogLogin DESC LIMIT 1) UltimoIp "+
   "FROM pessoas p JOIN grupos g ON g.IdGrupo=p.Classe AND g.StatusGrupo='ATIVO' AND g.DisponivelUsuarios=1 LEFT JOIN usuarios u ON u.IdPessoa=p.IdPessoa "+
   "LEFT JOIN LogLogin l ON l.IdPessoa=p.IdPessoa AND (?=0 OR YEAR(l.DataLogin)=?) AND (?=0 OR MONTH(l.DataLogin)=?) "+
   "WHERE (?=-1 OR IFNULL(p.Status,1)=?) AND (?=-1 OR p.Classe=?) "+
   "GROUP BY p.IdPessoa,p.Nome,p.Classe,p.Status,IFNULL(u.Profile,'USR')";
  if("ACESSOU".equals(acessoUl))sql+=" HAVING COUNT(l.IdLogLogin)>0";
  else if("NUNCA".equals(acessoUl))sql+=" HAVING COUNT(l.IdLogLogin)=0";
  sql+=" ORDER BY MAX(l.DataLogin) IS NULL,MAX(l.DataLogin) DESC,p.Nome";
  try(PreparedStatement ps=c.prepareStatement(sql)){int q=1;ps.setInt(q++,anoUl);ps.setInt(q++,anoUl);ps.setInt(q++,mesUl);ps.setInt(q++,mesUl);ps.setInt(q++,anoUl);ps.setInt(q++,anoUl);ps.setInt(q++,mesUl);ps.setInt(q++,mesUl);ps.setInt(q++,statusUl);ps.setInt(q++,statusUl);ps.setInt(q++,classeUl);ps.setInt(q++,classeUl);try(ResultSet r=ps.executeQuery()){while(r.next()){LoginUl x=new LoginUl();x.nome=r.getString("Nome");x.classe=r.getInt("Classe");x.status=r.getInt("Status");x.perfil=r.getString("Profile");x.ultimo=r.getString("UltimoLogin");x.total=r.getInt("TotalAcessos");x.ip=r.getString("UltimoIp");usuariosUl.add(x);if(x.ultimo==null)nuncaUl++;else acessaramUl++;}}}
 }
}catch(SQLSyntaxErrorException e){erroUl="Execute primeiro o script sql/log_login.sql.";}catch(Exception e){application.log("Erro no relatório de último login",e);erroUl="Não foi possível carregar o relatório de acessos.";}
%>
<!DOCTYPE html><html lang="pt-br"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Último login dos usuários</title><link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet"><link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet"><link rel="stylesheet" href="css/style.css"><style>
.ul-filter{background:#fff;border:1px solid #e8edf3;border-radius:16px;padding:20px}.ul-table th{font-size:11px;text-transform:uppercase;color:#64748b}.ul-table td{vertical-align:middle}.ul-never{color:#b45309;font-weight:600}.ul-date{white-space:nowrap;font-weight:600}@media print{.navbar,footer,.no-print{display:none!important}.container{max-width:none!important}.profile-card,.dashboard-card{box-shadow:none!important}.ul-table{font-size:9pt}}
</style></head><body><jsp:include page="includes/header.jsp"/><main class="container py-4">
<div class="d-flex justify-content-between align-items-start gap-3 flex-wrap mb-4"><div><a href="relatorios.jsp" class="btn btn-link px-0 no-print"><i class="bi bi-arrow-left"></i> Voltar aos relatórios</a><h1 class="fw-bold mb-1">Último login dos usuários</h1><p class="text-muted mb-0">Auditoria dos acessos realizados no sistema</p></div><button class="btn btn-outline-secondary no-print" onclick="window.print()"><i class="bi bi-printer"></i> Imprimir</button></div>
<form method="get" class="ul-filter mb-4 no-print"><div class="row g-3 align-items-end"><div class="col-md-2"><label class="form-label">Grupo</label><select name="classe" class="form-select"><option value="-1" <%= classeUl==-1?"selected":"" %>>Todos</option><option value="0" <%= classeUl==0?"selected":"" %>>Clero</option><option value="1" <%= classeUl==1?"selected":"" %>>Diáconos</option><option value="2" <%= classeUl==2?"selected":"" %>>Candidatos</option><option value="3" <%= classeUl==3?"selected":"" %>>Vocacionados</option></select></div><div class="col-md-2"><label class="form-label">Status</label><select name="status" class="form-select"><option value="1" <%= statusUl==1?"selected":"" %>>Ativos</option><option value="0" <%= statusUl==0?"selected":"" %>>Inativos</option><option value="-1" <%= statusUl==-1?"selected":"" %>>Todos</option></select></div><div class="col-md-2"><label class="form-label">Acesso</label><select name="acesso" class="form-select"><option value="TODOS" <%= "TODOS".equals(acessoUl)?"selected":"" %>>Todos</option><option value="ACESSOU" <%= "ACESSOU".equals(acessoUl)?"selected":"" %>>Já acessou</option><option value="NUNCA" <%= "NUNCA".equals(acessoUl)?"selected":"" %>><%= anoUl==0&&mesUl==0?"Nunca acessou":"Sem acesso no período" %></option></select></div><div class="col-md-2"><label class="form-label">Ano</label><select name="ano" class="form-select"><option value="0">Todos</option><% for(Integer a:anosUl){ %><option value="<%= a %>" <%= a==anoUl?"selected":"" %>><%= a %></option><% } %></select></div><div class="col-md-2"><label class="form-label">Mês</label><select name="mes" class="form-select"><% for(int m=0;m<=12;m++){ %><option value="<%= m %>" <%= m==mesUl?"selected":"" %>><%= mul(m) %></option><% } %></select></div><div class="col-md-2"><button class="btn btn-orange w-100"><i class="bi bi-funnel"></i> Aplicar</button></div></div></form>
<% if(erroUl!=null){ %><div class="alert alert-danger"><%= hul(erroUl) %></div><% } %>
<div class="row g-3 mb-4"><div class="col-md-4"><div class="dashboard-card"><h5>Usuários</h5><div class="card-number"><%= usuariosUl.size() %></div></div></div><div class="col-md-4"><div class="dashboard-card"><h5>Acessaram no período</h5><div class="card-number text-success"><%= acessaramUl %></div></div></div><div class="col-md-4"><div class="dashboard-card"><h5>Sem acesso no período</h5><div class="card-number text-warning"><%= nuncaUl %></div></div></div></div>
<section class="profile-card"><div class="table-responsive"><table class="table table-hover ul-table"><thead><tr><th>Grupo</th><th>Nome</th><th>Perfil</th><th>Situação</th><th>Último login</th><th>Último IP</th><th>Acessos</th></tr></thead><tbody>
<% for(LoginUl x:usuariosUl){ %><tr><td><span class="badge-tag <%= x.classe==1?"tag-green":x.classe==2?"tag-yellow":x.classe==3?"tag-blue":"" %>"><%= hul(gul(x.classe)) %></span></td><td><strong><%= hul(x.nome) %></strong></td><td><span class="badge text-bg-secondary"><%= hul(x.perfil) %></span></td><td><span class="badge <%= x.status==1?"text-bg-success":"text-bg-light" %>"><%= x.status==1?"Ativo":"Inativo" %></span></td><td class="<%= x.ultimo==null?"ul-never":"ul-date" %>"><%= x.ultimo==null?(anoUl==0&&mesUl==0?"Nunca acessou":"Sem acesso no período"):hul(x.ultimo) %></td><td><%= x.ip==null||x.ip.isEmpty()?"—":hul(x.ip) %></td><td><%= x.total %></td></tr><% } %>
<% if(usuariosUl.isEmpty()&&erroUl==null){ %><tr><td colspan="7" class="text-center text-muted py-5">Nenhum usuário encontrado para o grupo selecionado.</td></tr><% } %></tbody></table></div></section>
</main><jsp:include page="includes/footer.jsp"/></body></html>
