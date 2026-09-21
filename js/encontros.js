let encontros = [];
const esc = value => { const e = document.createElement("div"); e.textContent = value || ""; return e.innerHTML; };
const grupo = classe => window.GruposCatalogo ? GruposCatalogo.nome(classe) : `Grupo ${classe}`;
const classeTagGrupo = () => "";

async function carregarEncontros() {
    const resposta = await fetch("gerenciarEncontros.jsp", { cache: "no-store" });
    const dados = await resposta.json();
    if (!resposta.ok || !dados.ok) throw new Error(dados.mensagem || "Erro ao carregar encontros.");
    encontros = dados.encontros;
    popularAnos(); filtrarEncontros();
}
function popularAnos() {
    const select = document.getElementById("filtroAno"), atual = select.value;
    select.innerHTML = '<option value="">Todos os anos</option>';
    [...new Set(encontros.map(e => e.data.slice(0,4)).filter(Boolean))].sort().forEach(ano => select.add(new Option(ano, ano)));
    select.value = atual;
}
function filtrarEncontros() {
    const texto = document.getElementById("buscaEncontro").value.toLowerCase(), ano = document.getElementById("filtroAno").value, classe = document.getElementById("filtroGrupo").value;
    const lista = encontros.filter(e => (!texto || `${e.descricao} ${e.local}`.toLowerCase().includes(texto)) && (!ano || e.data.startsWith(ano)) && (!classe || e.classe == classe));
    document.getElementById("total-encontros").textContent = `${lista.length} ${lista.length === 1 ? "encontro" : "encontros"}`;
    const container = document.getElementById("eventsContainer");
    container.innerHTML = lista.length ? lista.map(e => `<div class="member-card"><div><div class="member-name">${esc(e.descricao)} <span class="badge-tag ${classeTagGrupo(e.classe)}">${grupo(e.classe)}</span></div><div class="member-sub">${esc(e.dataFormatada)}${e.local ? ` · ${esc(e.local)}` : ""}</div>${e.detalhe ? `<div class="mt-2 text-muted">${esc(e.detalhe)}</div>` : ""}<div class="mt-2 small">${e.flgEnviado ? "Registro de presença habilitado" : "Registro de presença indisponível"}${e.flgEsposa ? " · Esposas participam" : ""}</div></div><div class="member-actions">${window.podeVerParticipantes ? `<button class="btn btn-sm btn-outline-primary" onclick="window.location.href='participantesEncontro.jsp?id=${e.id}'" title="Participantes"><i class="bi bi-people"></i></button>` : ""}${window.podeGerenciarEncontros ? `<button class="btn btn-sm ${e.flgEnviado ? "btn-success" : "btn-outline-secondary"}" onclick="alternarEnvio(${e.id}, ${e.flgEnviado ? 0 : 1})" title="${e.flgEnviado ? "Desabilitar" : "Habilitar"} registro de presença"><i class="bi bi-check2-square"></i></button><button class="btn btn-sm btn-outline-secondary" onclick="abrirModalEncontro(${e.id})" title="Editar"><i class="bi bi-pencil"></i></button><button class="btn btn-sm btn-outline-primary" onclick="copiarEncontro(${e.id})" title="Criar cópia"><i class="bi bi-copy"></i></button>` : ""}</div></div>`).join("") : '<div class="text-muted">Nenhum encontro encontrado.</div>';
}
function abrirModalEncontro(id) { const seletor=document.getElementById("eventClasse");const e = encontros.find(x => x.id == id) || { id:"", classe:seletor.value, descricao:"", data:"", detalhe:"", local:"", latitude:"", longitude:"", flgEnviado:false, flgEsposa:false }; document.getElementById("tituloModalEncontro").textContent = id ? "Editar Encontro" : "Novo Encontro"; document.getElementById("eventId").value=e.id; seletor.value=e.classe; document.getElementById("eventData").value=e.data; document.getElementById("eventDescricao").value=e.descricao; document.getElementById("eventDetalhe").value=e.detalhe; document.getElementById("eventLocal").value=e.local; document.getElementById("eventLatitude").value=e.latitude; document.getElementById("eventLongitude").value=e.longitude; document.getElementById("eventEnviado").checked=e.flgEnviado; document.getElementById("eventEsposa").checked=e.flgEsposa; document.getElementById("eventModal").classList.add("show"); }
function copiarEncontro(id) { const e = encontros.find(x => x.id == id); abrirModalEncontro(); document.getElementById("tituloModalEncontro").textContent="Copiar Encontro"; document.getElementById("eventClasse").value=e.classe; document.getElementById("eventDescricao").value=`Cópia - ${e.descricao}`; document.getElementById("eventDetalhe").value=e.detalhe; document.getElementById("eventLocal").value=e.local; document.getElementById("eventEnviado").checked=e.flgEnviado; document.getElementById("eventEsposa").checked=e.flgEsposa; }
function fecharModalEncontro() { document.getElementById("eventModal").classList.remove("show"); }
async function salvarEncontro() { const dados = new URLSearchParams({ id:document.getElementById("eventId").value, classe:document.getElementById("eventClasse").value, data:document.getElementById("eventData").value, descricao:document.getElementById("eventDescricao").value.trim(), detalhe:document.getElementById("eventDetalhe").value.trim(), local:document.getElementById("eventLocal").value.trim(), latitude:document.getElementById("eventLatitude").value, longitude:document.getElementById("eventLongitude").value, flgEnviado:document.getElementById("eventEnviado").checked ? 1 : 0, flgEsposa:document.getElementById("eventEsposa").checked ? 1 : 0 }); if(!dados.get("descricao")){alert("Informe a descrição.");return;} const r=await fetch("gerenciarEncontros.jsp",{method:"POST",headers:{"Content-Type":"application/x-www-form-urlencoded;charset=UTF-8"},body:dados}); const d=await r.json(); if(!r.ok||!d.ok){alert(d.mensagem||"Erro ao salvar.");return;} fecharModalEncontro(); carregarEncontros(); }
async function alternarEnvio(id, flgEnviado) { const r=await fetch("gerenciarEncontros.jsp",{method:"POST",headers:{"Content-Type":"application/x-www-form-urlencoded;charset=UTF-8"},body:new URLSearchParams({acao:"envio",id,flgEnviado})}); const d=await r.json(); if(!r.ok||!d.ok){alert(d.mensagem||"Erro ao atualizar.");return;} carregarEncontros(); }
document.getElementById("buscaEncontro").addEventListener("input",filtrarEncontros); document.getElementById("filtroAno").addEventListener("change",filtrarEncontros); document.getElementById("filtroGrupo").addEventListener("change",filtrarEncontros);
carregarEncontros().catch(e=>{console.error(e);document.getElementById("eventsContainer").textContent="Não foi possível carregar os encontros.";});
