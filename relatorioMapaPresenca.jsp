<%@ page import="java.sql.*,java.util.*,java.time.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="includes/auth.jsp" %>
<%@ include file="includes/escopoRelatorios.jspf" %>
<%!
private String hmp(String v){return v==null?"":v.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");}
private int imp(String v,int d){try{return Integer.parseInt(v);}catch(Exception e){return d;}}
private String gmp(int c){return cad.grupos.GrupoCatalogo.plural(c);}
%>
<%
String perfilMp=(String)session.getAttribute("usuarioPerfil");if(!"ADM".equals(perfilMp)&&!"REP".equals(perfilMp)&&!"EXT".equals(perfilMp)){response.sendRedirect("index.jsp");return;}
boolean repMp="REP".equals(perfilMp);Integer regiaoSessaoMp=(Integer)session.getAttribute("usuarioRegiaoId");
int classeMp=imp(request.getParameter("classe"),1);if(classeMp<0)classeMp=1;
String escopoMp=cadEscopoRelatorios(session);Integer grupoSessaoMp=(Integer)session.getAttribute("usuarioGrupoId");boolean restringeRegiaoMp=repMp&&"REGIAO_TODOS".equals(escopoMp);
int anoMp=imp(request.getParameter("ano"),0),regiaoMp=imp(request.getParameter("regiao"),0);if(repMp&&"PROPRIO".equals(escopoMp))classeMp=grupoSessaoMp==null?-1:grupoSessaoMp;else if(restringeRegiaoMp)regiaoMp=regiaoSessaoMp==null?-1:regiaoSessaoMp;else if(repMp&&"NENHUM".equals(escopoMp))classeMp=-1;
int participacaoMinMp=Math.max(0,Math.min(100,imp(request.getParameter("participacaoMin"),0)));
int participacaoMaxMp=Math.max(participacaoMinMp,Math.min(100,imp(request.getParameter("participacaoMax"),100)));
class EncontroMp{int id;String data,descricao;}
class PessoaMp{int id;String nome,regiao,paroquia;Map<Integer,Integer> status=new HashMap<Integer,Integer>();Map<Integer,String> justificativas=new HashMap<Integer,String>();int presentes=0;}
List<Integer> anosMp=new ArrayList<Integer>();List<EncontroMp> encontrosMp=new ArrayList<EncontroMp>();List<PessoaMp> pessoasMp=new ArrayList<PessoaMp>();LinkedHashMap<Integer,String> regioesMp=new LinkedHashMap<Integer,String>();String erroMp=null,nomeRegiaoMp="";
int totalPresentesMp=0,totalJustificadosMp=0,totalAusentesMp=0;
try{
 try(Connection c=cad.db.Database.getConnection()){
  try(PreparedStatement p=c.prepareStatement("SELECT DISTINCT YEAR(DtEncontro) Ano FROM Encontros WHERE Checklist=0 AND DtEncontro<=CURDATE() ORDER BY Ano DESC");ResultSet r=p.executeQuery()){while(r.next())anosMp.add(r.getInt(1));}
  if(anoMp==0)anoMp=anosMp.isEmpty()?Year.now().getValue():anosMp.get(0);
  try(PreparedStatement p=c.prepareStatement("SELECT DISTINCT IdRegiao,Regiao FROM paroquia WHERE IdRegiao IS NOT NULL AND Regiao IS NOT NULL AND Regiao<>'' ORDER BY Regiao");ResultSet r=p.executeQuery()){while(r.next()){int id=r.getInt(1);String nome=r.getString(2);if(!restringeRegiaoMp||id==regiaoMp)regioesMp.put(id,nome);if(id==regiaoMp)nomeRegiaoMp=nome;}}
  try(PreparedStatement p=c.prepareStatement("SELECT IdEncontro,DATE_FORMAT(DtEncontro,'%d/%m') DataFormatada,IFNULL(Descricao,'') Descricao FROM Encontros WHERE Checklist=0 AND Classe=? AND YEAR(DtEncontro)=? AND DtEncontro<=CURDATE() ORDER BY DtEncontro,IdEncontro")){p.setInt(1,classeMp);p.setInt(2,anoMp);try(ResultSet r=p.executeQuery()){while(r.next()){EncontroMp x=new EncontroMp();x.id=r.getInt(1);x.data=r.getString(2);x.descricao=r.getString(3);encontrosMp.add(x);}}}
  String sql="SELECT p.IdPessoa,p.Nome,IFNULL(pa.Regiao,'') Regiao,IFNULL(pa.Descricao,'') Paroquia,e.IdEncontro,IFNULL(pe.flgPresenca,0) flgPresenca,pe.Justificativa FROM pessoas p JOIN grupos g ON g.IdGrupo=p.Classe AND g.StatusGrupo='ATIVO' AND g.GrupoOperacional=1 AND g.ModuloPresencas=1 LEFT JOIN paroquia pa ON pa.IdParoquia=p.IdParoquia JOIN Encontros e ON e.Classe=p.Classe AND e.Checklist=0 AND YEAR(e.DtEncontro)=? AND e.DtEncontro<=CURDATE() LEFT JOIN participanteEncontro pe ON pe.IdPessoa=p.IdPessoa AND pe.IdEncontro=e.IdEncontro WHERE p.Status=1 AND p.Classe=? AND (?=0 OR IFNULL(pa.IdRegiao,0)=?) ORDER BY p.Nome,e.DtEncontro,e.IdEncontro";
  LinkedHashMap<Integer,PessoaMp> mapa=new LinkedHashMap<Integer,PessoaMp>();
  try(PreparedStatement p=c.prepareStatement(sql)){p.setInt(1,anoMp);p.setInt(2,classeMp);p.setInt(3,regiaoMp);p.setInt(4,regiaoMp);try(ResultSet r=p.executeQuery()){while(r.next()){int id=r.getInt("IdPessoa");PessoaMp pessoa=mapa.get(id);if(pessoa==null){pessoa=new PessoaMp();pessoa.id=id;pessoa.nome=r.getString("Nome");pessoa.regiao=r.getString("Regiao");pessoa.paroquia=r.getString("Paroquia");mapa.put(id,pessoa);}int status=r.getInt("flgPresenca");pessoa.status.put(r.getInt("IdEncontro"),status);pessoa.justificativas.put(r.getInt("IdEncontro"),r.getString("Justificativa"));if(status==1)pessoa.presentes++;}}}
  for(PessoaMp pessoa:mapa.values()){
   double percentual=encontrosMp.isEmpty()?0:pessoa.presentes*100.0/encontrosMp.size();
   if(percentual<participacaoMinMp||percentual>participacaoMaxMp)continue;
   pessoasMp.add(pessoa);
   for(EncontroMp encontro:encontrosMp){int status=pessoa.status.containsKey(encontro.id)?pessoa.status.get(encontro.id):0;if(status==1)totalPresentesMp++;else if(status==2)totalJustificadosMp++;else totalAusentesMp++;}
  }
 }
}catch(Exception erro){erro.printStackTrace();erroMp="Não foi possível carregar o mapa de presença.";}
int totalRegistrosMp=totalPresentesMp+totalJustificadosMp+totalAusentesMp;
%>
<!DOCTYPE html><html lang="pt-br"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Mapa de Presença</title><link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet"><link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet"><link rel="stylesheet" href="css/style.css"><style>
.map-filter{background:#fff;border:1px solid #e8edf3;border-radius:16px;padding:20px}.map-summary .dashboard-card{height:100%}.attendance-wrap{overflow-x:auto}.attendance-table{min-width:760px;margin:0}.attendance-table th,.attendance-table td{text-align:center;vertical-align:middle;border-right:1px solid #e2e8f0;padding:8px}.attendance-table th{font-size:11px;color:#475569;white-space:nowrap}.attendance-table .name-col{text-align:left;min-width:220px;position:sticky;left:0;background:#fff;z-index:1}.attendance-table thead .name-col{background:#f8fafc;z-index:2}.attendance-table .percent-col{min-width:105px}.status-map{display:inline-grid;place-items:center;width:28px;height:28px;border-radius:8px;font-size:12px;font-weight:800}.status-p{background:#dcfce7;color:#15803d}.status-j{background:#fef3c7;color:#b45309}.status-f{background:#fee2e2;color:#b91c1c}.map-legend{font-size:12px;color:#64748b}.map-legend span{margin-left:12px}.map-only-title{display:none}
@media print{@page{size:landscape;margin:7mm}.navbar,footer,.no-print{display:none!important}body{background:#fff!important}.container{max-width:none!important;padding:0!important}.profile-card,.dashboard-card{box-shadow:none!important}.attendance-wrap{overflow:visible}.attendance-table{min-width:0;font-size:7.5pt}.attendance-table th,.attendance-table td{padding:3px 2px}.attendance-table .name-col{position:static;min-width:110px}.attendance-table .percent-col{min-width:60px}.status-map{width:18px;height:18px;border-radius:4px;font-size:7pt}body.print-map-only .map-summary{display:none!important}body.print-map-only .map-only-title{display:block}h1{font-size:18pt}}
</style></head><body><jsp:include page="includes/header.jsp"/><main class="container py-4">
<div class="d-flex justify-content-between align-items-start gap-3 flex-wrap mb-4"><div><a href="relatorios.jsp" class="btn btn-link px-0 no-print"><i class="bi bi-arrow-left"></i> Voltar aos relatórios</a><h1 class="fw-bold mb-1">Mapa de Presença</h1><p class="text-muted mb-0"><%= hmp(gmp(classeMp)) %> · Ano <%= anoMp %><%= regiaoMp!=0?" · "+hmp(nomeRegiaoMp):"" %></p></div><div class="d-flex gap-2 no-print"><button class="btn btn-outline-secondary" onclick="imprimirMapa(false)"><i class="bi bi-printer"></i> Relatório completo</button><button class="btn btn-orange" onclick="imprimirMapa(true)"><i class="bi bi-table"></i> Somente mapa</button></div></div>
<form method="get" class="map-filter mb-4 no-print"><div class="row g-3 align-items-end"><div class="col-md-2"><label class="form-label">Ano</label><select name="ano" class="form-select"><% for(Integer a:anosMp){ %><option value="<%= a %>" <%= a==anoMp?"selected":"" %>><%= a %></option><% } %></select></div><div class="col-md-2"><label class="form-label">Grupo</label><select name="classe" class="form-select"><option value="1" <%= classeMp==1?"selected":"" %>>Diáconos</option><option value="2" <%= classeMp==2?"selected":"" %>>Candidatos</option><option value="3" <%= classeMp==3?"selected":"" %>>Vocacionados</option></select></div><div class="col-md-2"><label class="form-label">Região</label><% if(repMp){ %><input class="form-control" value="<%= hmp(nomeRegiaoMp.isEmpty()?"Região não identificada":nomeRegiaoMp) %>" disabled><% }else{ %><select name="regiao" class="form-select"><option value="0">Todas</option><% for(Map.Entry<Integer,String> r:regioesMp.entrySet()){ %><option value="<%= r.getKey() %>" <%= r.getKey()==regiaoMp?"selected":"" %>><%= hmp(r.getValue()) %></option><% } %></select><% } %></div><div class="col-md-2"><label class="form-label">Participação mínima (%)</label><input name="participacaoMin" type="number" min="0" max="100" value="<%= participacaoMinMp %>" class="form-control"></div><div class="col-md-2"><label class="form-label">Participação máxima (%)</label><input name="participacaoMax" type="number" min="0" max="100" value="<%= participacaoMaxMp %>" class="form-control"></div><div class="col-md-2"><button class="btn btn-orange w-100"><i class="bi bi-funnel"></i> Aplicar</button></div></div></form>
<% if(erroMp!=null){ %><div class="alert alert-danger"><%= hmp(erroMp) %></div><% } %>
<div class="row g-3 mb-4 map-summary"><div class="col"><div class="dashboard-card"><h5>Membros</h5><div class="card-number"><%= pessoasMp.size() %></div><small class="text-muted">membros ativos</small></div></div><div class="col"><div class="dashboard-card"><h5>Encontros</h5><div class="card-number"><%= encontrosMp.size() %></div><small class="text-muted">no ano selecionado</small></div></div><div class="col"><div class="dashboard-card"><h5>Presenças</h5><div class="card-number text-success"><%= totalPresentesMp %></div><small class="text-muted"><%= totalRegistrosMp==0?"0,0":String.format(java.util.Locale.forLanguageTag("pt-BR"),"%.1f",totalPresentesMp*100.0/totalRegistrosMp) %>%</small></div></div><div class="col"><div class="dashboard-card"><h5>Justificadas</h5><div class="card-number text-warning"><%= totalJustificadosMp %></div><small class="text-muted"><%= totalRegistrosMp==0?"0,0":String.format(java.util.Locale.forLanguageTag("pt-BR"),"%.1f",totalJustificadosMp*100.0/totalRegistrosMp) %>%</small></div></div><div class="col"><div class="dashboard-card"><h5>Ausências</h5><div class="card-number text-danger"><%= totalAusentesMp %></div><small class="text-muted"><%= totalRegistrosMp==0?"0,0":String.format(java.util.Locale.forLanguageTag("pt-BR"),"%.1f",totalAusentesMp*100.0/totalRegistrosMp) %>%</small></div></div></div>
<h2 class="map-only-title"><%= hmp(gmp(classeMp)) %> · <%= anoMp %><%= regiaoMp!=0?" · "+hmp(nomeRegiaoMp):"" %></h2>
<section class="profile-card p-0 overflow-hidden"><div class="d-flex justify-content-between align-items-center p-3 border-bottom"><h4 class="mb-0">Participação por encontro</h4><div class="map-legend"><span><b class="text-success">P</b> Presente</span><span><b class="text-warning">J</b> Justificado</span><span><b class="text-danger">F</b> Ausente</span></div></div><% if(pessoasMp.isEmpty()||encontrosMp.isEmpty()){ %><div class="text-center text-muted py-5"><i class="bi bi-calendar-x fs-1 d-block mb-2"></i>Nenhuma informação encontrada para os filtros selecionados.</div><% }else{ %><div class="attendance-wrap"><table class="table table-hover attendance-table"><thead><tr><th class="name-col">Nome</th><th>Paróquia</th><th class="percent-col">Participação</th><% for(EncontroMp e:encontrosMp){ %><th title="<%= hmp(e.descricao) %>"><%= hmp(e.data) %></th><% } %></tr></thead><tbody><% for(PessoaMp pessoa:pessoasMp){double pct=encontrosMp.isEmpty()?0:pessoa.presentes*100.0/encontrosMp.size(); %><tr><td class="name-col"><%= hmp(pessoa.nome) %></td><td><%= hmp(pessoa.paroquia==null||pessoa.paroquia.isEmpty()?"—":pessoa.paroquia) %></td><td class="percent-col"><strong><%= String.format(java.util.Locale.forLanguageTag("pt-BR"),"%.1f",pct) %>%</strong><small class="d-block text-muted"><%= pessoa.presentes %>/<%= encontrosMp.size() %></small></td><% for(EncontroMp e:encontrosMp){int st=pessoa.status.containsKey(e.id)?pessoa.status.get(e.id):0; %><td><button type="button" class="status-map border-0 <%= st==1?"status-p":st==2?"status-j":"status-f" %>" data-bs-toggle="offcanvas" data-bs-target="#detalhesPresencaMp" data-pessoa="<%= pessoa.id %>" data-encontro="<%= e.id %>" aria-controls="detalhesPresencaMp" aria-label="Ver registros de <%= hmp(pessoa.nome) %>, <%= hmp(e.data) %>: <%= st==1?"Presente":st==2?"Justificado":"Ausente" %>" title="Ver registros e justificativas"><%= st==1?"P":st==2?"J":"F" %></button></td><% } %></tr><% } %></tbody></table></div><% } %></section>
<% for(PessoaMp pessoa:pessoasMp){ %>
<template id="registros-mp-<%= pessoa.id %>">
<div class="mb-3"><h3 class="h5"><%= hmp(pessoa.nome) %></h3><p class="text-muted mb-1"><%= hmp(pessoa.paroquia) %></p><p class="small text-muted">Registros do ano <%= anoMp %> · <%= encontrosMp.size() %> encontros</p></div>
<div class="list-group">
<% for(EncontroMp e:encontrosMp){int st=pessoa.status.containsKey(e.id)?pessoa.status.get(e.id):0;String justificativa=pessoa.justificativas.get(e.id); %>
<article class="list-group-item p-3" data-registro-encontro="<%= e.id %>">
<div class="d-flex justify-content-between align-items-center gap-2 mb-2"><strong><%= hmp(e.data) %>/<%= anoMp %></strong><span class="badge <%= st==1?"status-p":st==2?"status-j":"status-f" %>"><%= st==1?"Presente":st==2?"Justificado":"Ausente" %></span></div>
<div class="mb-2"><%= hmp(e.descricao) %></div>
<% if(justificativa!=null&&!justificativa.trim().isEmpty()){ %><div class="small fw-bold">Justificativa</div><div class="mp-justificativa"><%= hmp(justificativa) %></div><% }else{ %><div class="small text-muted">Sem justificativa registrada.</div><% } %>
</article>
<% } %>
</div></template>
<% } %>
<div class="offcanvas offcanvas-end no-print" tabindex="-1" id="detalhesPresencaMp" aria-labelledby="tituloDetalhesMp" style="--bs-offcanvas-width:560px">
<div class="offcanvas-header border-bottom"><h2 class="offcanvas-title h5" id="tituloDetalhesMp">Registros de presença</h2><button type="button" class="btn-close" data-bs-dismiss="offcanvas" aria-label="Fechar"></button></div>
<div class="px-3 py-2 border-bottom"><button type="button" class="btn btn-outline-secondary btn-sm" onclick="imprimirDetalhesMp()"><i class="bi bi-printer" aria-hidden="true"></i> Imprimir registros</button></div>
<div class="offcanvas-body" id="conteudoDetalhesMp"></div>
</div>
<style>.mp-justificativa{white-space:pre-wrap;overflow-wrap:anywhere}.mp-registro-selecionado{border-left:4px solid #fd7e14;background:#fff7ed}.status-map:focus-visible{outline:3px solid #0d6efd;outline-offset:2px}@media print{.offcanvas-backdrop{display:none!important}}</style></main><style>
#impressaoDetalhesMp{display:none}
@media print{
 body.print-member-details{overflow:visible!important;padding-right:0!important}
 body.print-member-details> :not(#impressaoDetalhesMp){display:none!important}
 body.print-member-details #impressaoDetalhesMp{display:block!important;color:#000;font-size:11pt}
 #impressaoDetalhesMp .list-group{display:block}
 #impressaoDetalhesMp .list-group-item{break-inside:avoid;border:1px solid #bbb;margin-bottom:8px;overflow-wrap:anywhere}
 #impressaoDetalhesMp .badge{color:#000!important;border:1px solid #777;white-space:normal}
 #impressaoDetalhesMp .mp-registro-selecionado{background:transparent;border-left:1px solid #bbb}
}
</style>
<section id="impressaoDetalhesMp" aria-hidden="true"></section><jsp:include page="includes/footer.jsp"/><script>const painelMp=document.getElementById('detalhesPresencaMp');
painelMp.addEventListener('show.bs.offcanvas',function(event){
 const botao=event.relatedTarget;
 if(!botao)return;
 const modelo=document.getElementById('registros-mp-'+botao.dataset.pessoa);
 const conteudo=document.getElementById('conteudoDetalhesMp');
 conteudo.replaceChildren(modelo.content.cloneNode(true));
 const registro=conteudo.querySelector('[data-registro-encontro="'+botao.dataset.encontro+'"]');
 if(registro){registro.classList.add('mp-registro-selecionado');registro.setAttribute('aria-current','true');}
});
painelMp.addEventListener('shown.bs.offcanvas',function(){
 const registro=painelMp.querySelector('.mp-registro-selecionado');
 if(registro)registro.scrollIntoView({block:'nearest'});
});function imprimirDetalhesMp(){
 const area=document.getElementById('impressaoDetalhesMp');
 const titulo=document.createElement('h1');
 titulo.className='h4 mb-3';
 titulo.textContent='Registros de presença';
 area.replaceChildren(titulo,document.getElementById('conteudoDetalhesMp').cloneNode(true));
 area.lastElementChild.removeAttribute('id');
 area.lastElementChild.classList.remove('offcanvas-body');
 document.body.classList.remove('print-map-only');
 document.body.classList.add('print-member-details');
 try{window.print();}finally{document.body.classList.remove('print-member-details');area.replaceChildren();}
}function imprimirMapa(apenasMapa){document.body.classList.toggle("print-map-only",apenasMapa);window.print()}window.addEventListener("afterprint",()=>document.body.classList.remove("print-map-only"));</script></body></html>
