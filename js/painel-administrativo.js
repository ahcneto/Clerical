function textoSeguro(valor) {
    const elemento = document.createElement("div");
    elemento.textContent = valor == null ? "" : String(valor);
    return elemento.innerHTML;
}

let painelDados = null;
let grupoSelecionado = null;
let tipoAniversarioSelecionado = "TODOS";

function numero(item, chave) { return Number(item[chave] || 0); }
function percentual(parte, total) { return total > 0 ? Math.round(parte * 100 / total) : 0; }
function gruposVisiveis() { return (painelDados?.grupos || []).filter(g => grupoSelecionado === null || Number(g.id) === grupoSelecionado); }

function renderizarFiltroGrupos() {
    const container = document.getElementById("filtroGrupos");
    const grupos = painelDados.grupos || [];
    const ativosTotal = grupos.reduce((s,g) => s + numero(g,"membrosAtivos"), 0);
    const itens = [{ id:null, nome:"Todos os grupos", cor:"#334155", membrosAtivos:ativosTotal }, ...grupos];
    container.innerHTML = itens.map(g => {
        const cor = /^#[0-9a-f]{6}$/i.test(g.cor || "") ? g.cor : "#64748b";
        const ativo = grupoSelecionado === (g.id == null ? null : Number(g.id));
        return `<div class="col-6 col-md-4 col-xl-3"><button type="button" class="grupo-filtro ${ativo ? "ativo" : ""}" style="--grupo-cor:${cor}" data-grupo="${g.id == null ? "todos" : Number(g.id)}" aria-pressed="${ativo}"><span class="d-block fw-semibold">${textoSeguro(g.nome)}</span><strong>${numero(g,"membrosAtivos")}</strong><small>membros ativos</small></button></div>`;
    }).join("");
    container.querySelectorAll("[data-grupo]").forEach(btn => btn.addEventListener("click", () => {
        grupoSelecionado = btn.dataset.grupo === "todos" ? null : Number(btn.dataset.grupo);
        renderizarPainel();
    }));
}

function indicadorPainel(icone, titulo, valor, detalhe) {
    return `<div class="painel-indicador"><small><i class="bi ${icone} me-1"></i>${textoSeguro(titulo)}</small><strong>${textoSeguro(valor)}</strong><small>${textoSeguro(detalhe || "")}</small></div>`;
}
function somar(grupos, chave, disponibilidade) {
    const elegiveis = disponibilidade ? grupos.filter(g => g[disponibilidade]) : grupos;
    return { parte: elegiveis.reduce((s,g) => s + numero(g,chave), 0), total: elegiveis.reduce((s,g) => s + numero(g,"membrosAtivos"), 0), n:elegiveis.length };
}
function renderizarIndicadores() {
    const grupos = gruposVisiveis();
    const container = document.getElementById("painelGrupos");
    const titulo = grupoSelecionado === null ? "Todos os grupos" : (grupos[0]?.nome || "Grupo");
    document.getElementById("painelFiltroTitulo").textContent = titulo;
    if (!grupos.length) { container.innerHTML = '<div class="col-12 text-muted">Nenhum grupo dispon\u00edvel.</div>'; return; }
    const p = somar(grupos,"presentes","presencaDisponivel");
    const c = somar(grupos,"pagaram","contribuicaoDisponivel");
    const semAno = somar(grupos,"semContribuicaoAnoAtual","semContribuicaoAnoDisponivel");
    const form = somar(grupos,"membrosFormacao100","formacao100Disponivel");
    const formNaoIniciada = somar(grupos,"membrosFormacaoNaoIniciada","formacao100Disponivel");
    const formDen = grupos.filter(g=>g.formacao100Disponivel).reduce((s,g)=>s+numero(g,"membrosFormacaoAvaliados"),0);
    const pres = grupos.filter(g=>g.presencaAbaixo50Disponivel);
    const presCount = pres.reduce((s,g)=>s+numero(g,"membrosAbaixo50"),0);
    const presDen = pres.reduce((s,g)=>s+numero(g,"membrosAvaliadosPresenca"),0);
    const dataEncontros = [...new Set(grupos.filter(g=>g.presencaDisponivel).map(g=>g.dataEncontro).filter(Boolean))];
    const compMensal = [...new Set(grupos.filter(g=>g.contribuicaoDisponivel&&g.contribuicaoMensal).map(g=>g.competenciaContribuicao).filter(Boolean))];
    const compEncontro = [...new Set(grupos.filter(g=>g.contribuicaoDisponivel&&!g.contribuicaoMensal).map(g=>g.competenciaContribuicao).filter(Boolean))];
    const detalheCompetencia = [compMensal.length ? `Mensal: ${compMensal.join(", ")}` : "", compEncontro.length ? `\u00daltimo encontro: ${compEncontro.join(", ")}` : ""].filter(Boolean).join(" \u00b7 ");
    const dash = "\u2014";
    const coluna = cartoes => `<div class="col-12 col-lg-4"><div class="d-grid gap-3">${cartoes.join("")}</div></div>`;
    container.innerHTML = [
      coluna([
        indicadorPainel("bi-calendar2-check","Presen\u00e7a no \u00faltimo encontro",p.n?`${percentual(p.parte,p.total)}%`:dash,p.n?`${p.parte} presentes \u00b7 ${dataEncontros.join(", ") || "\u00faltimos encontros"}`:"Sem presen\u00e7a dispon\u00edvel"),
        indicadorPainel("bi-graph-down-arrow","Presen\u00e7a abaixo de 50%",pres.length?presCount:dash,pres.length?`de ${presDen} avaliados \u00b7 ano atual`:"Sem registros de presen\u00e7a no ano atual")
      ]),
      coluna([
        indicadorPainel("bi-cash-coin","Contribui\u00e7\u00f5es na compet\u00eancia",c.n?`${percentual(c.parte,c.total)}%`:dash,c.n?`${c.parte} membros pagaram \u00b7 ${detalheCompetencia}`:"Sem compet\u00eancia dispon\u00edvel"),
        indicadorPainel("bi-exclamation-circle","Sem contribui\u00e7\u00f5es no ano atual",semAno.n?`${semAno.parte} (${percentual(semAno.parte,semAno.total)}%)`:dash,semAno.n?"Sem contribui\u00e7\u00e3o paga no ano atual":"N\u00e3o calculado")
      ]),
      coluna([
        indicadorPainel("bi-journal-check","Forma\u00e7\u00e3o 100% conclu\u00edda",form.n?form.parte:dash,form.n?`de ${formDen} membros avaliados \u00b7 disciplinas obrigat\u00f3rias`:"Sem forma\u00e7\u00e3o obrigat\u00f3ria ativa"),
        indicadorPainel("bi-journal-x","Forma\u00e7\u00e3o n\u00e3o iniciada",formNaoIniciada.n?formNaoIniciada.parte:dash,formNaoIniciada.n?`de ${formDen} membros avaliados`:"Sem forma\u00e7\u00e3o obrigat\u00f3ria ativa")
      ])
    ].join("");
}

const nomesTipos = { NASCIMENTO:"Nascimento", ORDENACAO:"Ordenação", CASAMENTO:"Casamento", ESPOSA:"Aniversário da esposa" };
function renderizarAniversariantes() {
    const dados = painelDados || {};
    const grupos = gruposVisiveis();
    const ids = new Set(grupos.map(g=>Number(g.id)));
    const eventos = (dados.aniversariantes || []).filter(p => ids.has(Number(p.grupoId)) && (tipoAniversarioSelecionado === "TODOS" || p.tipo === tipoAniversarioSelecionado)).sort((a,b)=>Number(a.dia)-Number(b.dia)||String(a.nome).localeCompare(String(b.nome),"pt-BR"));
    const numeroMes = Number(dados.mes);
    const nomeMes = numeroMes>=1&&numeroMes<=12?new Intl.DateTimeFormat("pt-BR",{month:"long"}).format(new Date(2020,numeroMes-1,1)):"mês";
    document.getElementById("aniversariantesTitulo").innerHTML = `<i class="bi bi-gift me-1"></i> Aniversariantes de ${textoSeguro(nomeMes)}`;
    document.getElementById("aniversariantesTotal").textContent = `${eventos.length} comemoração(ões)`;
    const lista=document.getElementById("aniversariantesLista");
    lista.innerHTML=eventos.length?eventos.map(p=>{
      const cor=/^#[0-9a-f]{6}$/i.test(p.cor||"")?p.cor:"#64748b";
      const nome=p.tipo==="ESPOSA"?(p.nomeEsposa||`Esposa de ${p.nome}`):p.nome;
      const detalhe=p.tipo==="ESPOSA"?`Esposa de ${p.nome}`:nomesTipos[p.tipo]||"";
      return `<div class="birthday-row"><div class="birthday-date">${textoSeguro(String(p.dia||"").padStart(2,"0"))}<small>${textoSeguro(nomeMes.slice(0,3))}</small></div><div class="birthday-name"><strong>${textoSeguro(nome)}</strong><div class="small text-muted">${textoSeguro(detalhe)}</div></div><span class="badge rounded-pill birthday-group" style="--grupo-cor:${cor}">${textoSeguro(p.grupo)}</span></div>`;
    }).join(""):'<div class="text-center text-muted py-4"><i class="bi bi-balloon me-1"></i>Não há comemorações para os filtros selecionados.</div>';
    document.querySelectorAll(".aniversario-filtro").forEach(btn=>btn.classList.toggle("ativo",btn.dataset.tipo===tipoAniversarioSelecionado));
}
function renderizarPainel(){ renderizarFiltroGrupos(); renderizarIndicadores(); renderizarAniversariantes(); }
async function carregarPainelAdministrativo(){
    try {
      const resposta=await fetch("painel_administrativo_api.jsp",{cache:"no-store"});
      const dados=await resposta.json();
      if(!resposta.ok||!dados.ok) throw new Error(dados.mensagem||"Não foi possível carregar o painel.");
      painelDados=dados; renderizarPainel();
    } catch(erro){
      console.error("Erro ao carregar painel administrativo:",erro);
      document.getElementById("filtroGrupos").innerHTML='<div class="col-12"><div class="alert alert-danger mb-0">Não foi possível carregar os grupos.</div></div>';
      document.getElementById("painelGrupos").innerHTML='<div class="col-12"><div class="alert alert-danger mb-0">Não foi possível carregar os indicadores.</div></div>';
      document.getElementById("aniversariantesLista").innerHTML='<div class="text-muted">Não foi possível carregar as comemorações.</div>';
    }
}
document.getElementById("filtrosAniversario").addEventListener("click",event=>{const btn=event.target.closest("[data-tipo]");if(!btn)return;tipoAniversarioSelecionado=btn.dataset.tipo;renderizarAniversariantes();});
carregarPainelAdministrativo();
