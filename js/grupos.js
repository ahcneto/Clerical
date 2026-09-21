const grupo$=id=>document.getElementById(id);
const grupoEsc=v=>String(v??"").replace(/[&<>\"]/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;"}[c]));
const definicoesModulos=[
 ["membros","moduloMembros","bi-people","Membros","Cadastro, listagem e perfil"],
 ["encontros","moduloEncontros","bi-calendar-event","Encontros","Agenda e atividades do grupo"],
 ["presencas","moduloPresencas","bi-person-check","Presenças","Registro e participação"],
 ["contribuicoes","moduloContribuicoes","bi-cash-coin","Contribuições","Competências e pagamentos"],
 ["formacao","moduloFormacao","bi-mortarboard","Formação","Programas e disciplinas"],
 ["avaliacoes","moduloAvaliacoes","bi-clipboard2-check","Avaliações","Ciclos de acompanhamento"],
 ["documentacao","moduloDocumentacao","bi-folder-check","Documentação","Checklists do grupo"],
 ["relatorios","moduloRelatorios","bi-bar-chart","Relatórios","Filtros e consolidações"]
];
const definicoesMinisteriais=[
 ["teologia","Teologia"],["seminarioLeitor","Seminário de Leitor"],["seminarioAcolito","Seminário de Acólito"],
 ["ordemSacra","Ordens Sacras"],["leitor","Ministério de Leitor"],["acolito","Ministério de Acólito"],
 ["aptidaoMinisterial","Aptidão ministerial"],["aptidaoOrdenacao","Aptidão para ordenação"],
 ["pastoral","Pastoral"],["provisao","Provisão"],["ordenacao","Ordenação"]
];
let gruposCad=[],grupoAtual=null,grupoOriginal=null;

function grupoAlerta(mensagem,tipo="success"){
 const a=grupo$("gruposAlerta");a.className=`alert alert-${tipo}`;a.textContent=mensagem;a.classList.remove("d-none");window.scrollTo({top:0,behavior:"smooth"});
}
async function grupoApi(url,opcoes={}){
 const r=await fetch(url,{cache:"no-store",...opcoes});let d;try{d=await r.json();}catch(e){throw new Error("Resposta inválida do servidor.");}
 if(!r.ok||!d.ok)throw new Error(d.mensagem||"Não foi possível processar a solicitação.");return d;
}
function renderModulos(ativos={}){
 grupo$("modulosGrupo").innerHTML=definicoesModulos.map(([chave,id,icone,nome,descricao])=>`<label class="group-option"><span class="group-option-icon"><i class="bi ${icone}"></i></span><span class="group-option-copy"><strong>${nome}</strong><small>${descricao}</small></span><input id="${id}" class="form-check-input modulo-grupo" type="checkbox" ${ativos[chave]?'checked':''}></label>`).join("");
}
function renderMinisterial(ativos={}){
 grupo$("ministerialGrupo").innerHTML=definicoesMinisteriais.map(([chave,nome])=>`<div class="col-md-4"><label class="border rounded-3 p-3 d-flex gap-2 align-items-center w-100 h-100"><input class="form-check-input ministerial-grupo mt-0" data-chave="${chave}" type="checkbox" ${ativos[chave]?'checked':''}><span class="small fw-semibold">${nome}</span></label></div>`).join("");
}
function opcoesDestino(selecionado,idOrigem){
 return `<option value="">Selecione</option>`+gruposCad.filter(g=>g.id!==idOrigem).map(g=>`<option value="${g.id}" ${Number(selecionado)===g.id?'selected':''}>${grupoEsc(g.plural)}${g.status==='INATIVO'?' (inativo)':''}</option>`).join("");
}
function renderTransicoes(){
 const lista=grupoAtual?.transicoes||[];
 grupo$("transicoesGrupo").innerHTML=lista.length?lista.map((t,i)=>`<div class="group-transition" data-transicao="${i}"><div><label class="form-label">Nome da ação</label><input class="form-control transicao-acao" value="${grupoEsc(t.acao)}" maxlength="120"></div><div><label class="form-label">Grupo de destino</label><select class="form-select transicao-destino">${opcoesDestino(t.destino,grupoAtual.id)}</select></div><div><label class="form-label">Efeito adicional</label><input class="form-control transicao-efeito" value="${grupoEsc(t.efeito)}" maxlength="255"><select class="form-select form-select-sm mt-2 transicao-campo-data"><option value="">Sem atualizar data específica</option><option value="DtOrdenacao" ${t.campoData==='DtOrdenacao'?'selected':''}>Gravar data de ordenação</option></select><div class="form-check mt-2"><input class="form-check-input transicao-motivo" type="checkbox" ${t.exigeMotivo?'checked':''}><label class="form-check-label small">Exigir motivo</label></div></div><button type="button" class="btn btn-outline-danger remover-transicao" title="Remover"><i class="bi bi-trash"></i></button></div>`).join(""):`<div class="group-empty"><i class="bi bi-signpost-split fs-2 d-block mb-2"></i>Nenhuma transição de saída configurada.</div>`;
}
function preencherEscopos(){
 const opcoes=[["PROPRIO","Próprio grupo"],["REGIAO_TODOS","Todos os grupos da região"],["TODOS","Todos os grupos"],["NENHUM","Sem acesso"]];
 document.querySelectorAll("select.escopo").forEach(s=>s.innerHTML=opcoes.map(x=>`<option value="${x[0]}">${x[1]}</option>`).join(""));
}
function renderLista(){
 const termo=grupo$("buscaGrupo").value.trim().toLowerCase();
 const lista=gruposCad.filter(g=>`${g.singular} ${g.plural} ${g.sigla}`.toLowerCase().includes(termo));
 grupo$("listaGrupos").innerHTML=lista.length?lista.map(g=>`<button type="button" class="group-list-item ${grupoAtual&&grupoAtual.id===g.id?'active':''}" data-grupo-id="${g.id}"><span class="group-color" style="background:${grupoEsc(g.cor)}"></span><span class="group-list-copy"><strong>${grupoEsc(g.plural)}</strong><small>${g.status==='ATIVO'?'Ativo':'Inativo'} · código ${g.id}</small></span><i class="bi bi-chevron-right text-muted"></i></button>`).join(""):'<div class="text-muted text-center py-4">Nenhum grupo encontrado.</div>';
 document.querySelectorAll("[data-grupo-id]").forEach(b=>b.onclick=()=>selecionarGrupo(Number(b.dataset.grupoId)));
}
function valorDecimal(v){return Number(v||0).toLocaleString("pt-BR",{minimumFractionDigits:2,maximumFractionDigits:2});}
function preencherFormulario(g){
 grupo$("grupoId").value=g.id??"";grupo$("grupoTitulo").textContent=g.id==null?"Novo grupo":g.plural;grupo$("grupoSubtitulo").textContent=g.id==null?"Ainda não salvo":`Código ${g.id} · ${g.status==='ATIVO'?'ativo':'inativo'}`;
 grupo$("statusGrupo").checked=g.status==='ATIVO';grupo$("nomeSingular").value=g.singular||"";grupo$("nomePlural").value=g.plural||"";grupo$("siglaGrupo").value=g.sigla||"";grupo$("ordemGrupo").value=g.ordem||1;grupo$("corGrupo").value=g.cor||"#475569";grupo$("contextoGrupo").value=g.contexto||"ESCOLA";grupo$("descricaoGrupo").value=g.descricao||"";grupo$("grupoOperacional").checked=!!g.operacional;grupo$("disponivelUsuarios").checked=!!g.usuarios;
 renderModulos(g.modulos);grupo$("contribuicaoAtiva").checked=!!g.contribuicao?.ativa;grupo$("contribuicaoValor").value=valorDecimal(g.contribuicao?.valor);grupo$("contribuicaoPeriodicidade").value=g.contribuicao?.periodicidade||"NENHUMA";grupo$("contribuicaoDia").value=g.contribuicao?.dia||10;grupo$("contribuicaoEditavel").checked=!!g.contribuicao?.valorEditavel;grupo$("contribuicaoAteAtual").checked=g.contribuicao?.ateAtual!==false;
 grupo$("presencaAtiva").checked=!!g.presenca?.ativa;grupo$("presencaFonte").value=g.presenca?.fonte||"ENCONTROS";grupo$("presencaQuantidade").value=g.presenca?.quantidade??"";grupo$("presencaMeta").value=g.presenca?.meta??75;grupo$("presencaJustificada").checked=!!g.presenca?.justificada;grupo$("permiteEsposas").checked=!!g.presenca?.esposas;
 renderMinisterial(g.ministerial);grupo$("escopoMembros").value=g.escopos?.membros||"PROPRIO";grupo$("escopoEncontros").value=g.escopos?.encontros||"PROPRIO";grupo$("escopoContribuicoes").value=g.escopos?.contribuicoes||"PROPRIO";grupo$("escopoRelatorios").value=g.escopos?.relatorios||"PROPRIO";renderTransicoes();atualizarCampos();renderLista();
}
function selecionarGrupo(id){const g=gruposCad.find(x=>x.id===id);if(!g)return;grupoAtual=structuredCloneCompat(g);grupoOriginal=structuredCloneCompat(g);preencherFormulario(grupoAtual);}
function structuredCloneCompat(v){return JSON.parse(JSON.stringify(v));}
function novoGrupo(){
 const ordem=Math.max(0,...gruposCad.map(g=>g.ordem))+1;grupoAtual={id:null,singular:"",plural:"",sigla:"",descricao:"",cor:"#475569",ordem,status:"ATIVO",contexto:"ESCOLA",operacional:true,usuarios:true,modulos:{membros:true,encontros:true,presencas:true,contribuicoes:false,formacao:true,avaliacoes:true,documentacao:true,relatorios:true},contribuicao:{ativa:false,valor:0,periodicidade:"NENHUMA",dia:10,valorEditavel:false,ateAtual:true},presenca:{ativa:true,fonte:"ENCONTROS",quantidade:null,meta:75,justificada:false,esposas:true},ministerial:{},escopos:{membros:"PROPRIO",encontros:"PROPRIO",contribuicoes:"PROPRIO",relatorios:"PROPRIO"},transicoes:[]};grupoOriginal=structuredCloneCompat(grupoAtual);preencherFormulario(grupoAtual);document.querySelector('[data-bs-target="#tabIdentificacao"]').click();grupo$("nomeSingular").focus();
}
function sincronizarTransicoes(){
 grupoAtual.transicoes=[...document.querySelectorAll("[data-transicao]")].map(l=>({acao:l.querySelector(".transicao-acao").value.trim(),destino:Number(l.querySelector(".transicao-destino").value),efeito:l.querySelector(".transicao-efeito").value.trim(),campoData:l.querySelector(".transicao-campo-data").value,exigeMotivo:l.querySelector(".transicao-motivo").checked}));
}
function atualizarCampos(){
 grupo$("camposContribuicao").disabled=!grupo$("contribuicaoAtiva").checked;grupo$("camposPresenca").disabled=!grupo$("presencaAtiva").checked;grupo$("presencaQuantidade").disabled=grupo$("presencaFonte").value!=="FIXA";
 const ativa=grupo$("contribuicaoAtiva").checked,p=grupo$("contribuicaoPeriodicidade").value,v=grupo$("contribuicaoValor").value||"0,00";grupo$("previaContribuicao").innerHTML=!ativa?'<i class="bi bi-info-circle me-1"></i> Este grupo não terá controle de contribuição.':p==='MENSAL'?`<i class="bi bi-lightbulb text-warning me-1"></i> R$ ${grupoEsc(v)} em todos os meses decorridos.`:p==='ENCONTRO'?`<i class="bi bi-lightbulb text-warning me-1"></i> R$ ${grupoEsc(v)} somente nos meses com encontro.`:`<i class="bi bi-lightbulb text-warning me-1"></i> Regra: ${grupoEsc(p.toLowerCase())}.`;
}
function montarBody(){
 sincronizarTransicoes();const b=new URLSearchParams({id:grupo$("grupoId").value,singular:grupo$("nomeSingular").value.trim(),plural:grupo$("nomePlural").value.trim(),sigla:grupo$("siglaGrupo").value.trim(),descricao:grupo$("descricaoGrupo").value.trim(),cor:grupo$("corGrupo").value,ordem:grupo$("ordemGrupo").value,status:grupo$("statusGrupo").checked?"ATIVO":"INATIVO",contexto:grupo$("contextoGrupo").value,operacional:grupo$("grupoOperacional").checked?1:0,usuarios:grupo$("disponivelUsuarios").checked?1:0,contribuicaoAtiva:grupo$("contribuicaoAtiva").checked?1:0,contribuicaoValor:grupo$("contribuicaoValor").value,contribuicaoPeriodicidade:grupo$("contribuicaoPeriodicidade").value,contribuicaoDia:grupo$("contribuicaoDia").value,contribuicaoValorEditavel:grupo$("contribuicaoEditavel").checked?1:0,contribuicaoAteAtual:grupo$("contribuicaoAteAtual").checked?1:0,presencaAtiva:grupo$("presencaAtiva").checked?1:0,presencaFonte:grupo$("presencaFonte").value,presencaQuantidade:grupo$("presencaQuantidade").value,presencaMeta:grupo$("presencaMeta").value,presencaJustificada:grupo$("presencaJustificada").checked?1:0,permiteEsposas:grupo$("permiteEsposas").checked?1:0,escopoRepMembros:grupo$("escopoMembros").value,escopoRepEncontros:grupo$("escopoEncontros").value,escopoRepContribuicoes:grupo$("escopoContribuicoes").value,escopoRepRelatorios:grupo$("escopoRelatorios").value});
 definicoesModulos.forEach(([,id])=>b.set(id,grupo$(id).checked?1:0));definicoesMinisteriais.forEach(([chave])=>b.set(chave,document.querySelector(`[data-chave="${chave}"]`).checked?1:0));grupoAtual.transicoes.forEach(t=>{b.append("transicaoAcao",t.acao);b.append("transicaoDestino",t.destino||"");b.append("transicaoEfeito",t.efeito||"");b.append("transicaoCampoData",t.campoData||"");b.append("transicaoExigeMotivo",t.exigeMotivo?1:0);});return b;
}
async function carregarGrupos(selecionar){const d=await grupoApi("grupos_api.jsp?acao=listar");gruposCad=d.grupos;const id=selecionar??grupoAtual?.id??gruposCad[0]?.id;if(id!=null&&gruposCad.some(g=>g.id===id))selecionarGrupo(id);else novoGrupo();}

grupo$("buscaGrupo").addEventListener("input",renderLista);grupo$("novoGrupo").onclick=novoGrupo;grupo$("descartarGrupo").onclick=()=>{grupoAtual=structuredCloneCompat(grupoOriginal);preencherFormulario(grupoAtual);};
grupo$("adicionarTransicao").onclick=()=>{sincronizarTransicoes();grupoAtual.transicoes.push({acao:"",destino:null,efeito:"",campoData:"",exigeMotivo:false});renderTransicoes();};
grupo$("transicoesGrupo").addEventListener("click",e=>{const b=e.target.closest(".remover-transicao");if(!b)return;sincronizarTransicoes();const i=Number(b.closest("[data-transicao]").dataset.transicao);grupoAtual.transicoes.splice(i,1);renderTransicoes();});
["contribuicaoAtiva","contribuicaoPeriodicidade","contribuicaoValor","presencaAtiva","presencaFonte"].forEach(id=>grupo$(id).addEventListener("input",atualizarCampos));
grupo$("grupoForm").addEventListener("submit",async e=>{e.preventDefault();if(!grupo$("nomeSingular").value.trim()||!grupo$("nomePlural").value.trim()){grupoAlerta("Informe os nomes do grupo.","warning");return;}try{const d=await grupoApi("grupos_api.jsp?acao=salvar",{method:"POST",headers:{"Content-Type":"application/x-www-form-urlencoded;charset=UTF-8"},body:montarBody()});grupoAlerta(d.mensagem);await carregarGrupos(d.id);}catch(erro){grupoAlerta(erro.message,"danger");}});

preencherEscopos();carregarGrupos().catch(e=>grupoAlerta(e.message,"danger"));
