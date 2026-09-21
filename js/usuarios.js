let usuarios = [];
const perfis = ["ADM", "REP", "FIN", "USR", "EXT"];
const escUsuario = valor => String(valor ?? "").replace(/[&<>"']/g, c => ({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#039;"})[c]);
const classeGrupoUsuario = () => "";

function alertaUsuarios(mensagem, tipo = "danger") {
    const alerta = document.getElementById("alertaUsuarios");
    alerta.className = `alert alert-${tipo}`;
    alerta.textContent = mensagem;
    setTimeout(() => alerta.classList.add("d-none"), 4500);
}

async function carregarUsuarios() {
    const status = document.getElementById("statusUsuarioFiltro").value;
    const resposta = await fetch(`usuarios_api.jsp?status=${status}`, { cache: "no-store" });
    const dados = await resposta.json();
    if (!resposta.ok || !dados.ok) throw new Error(dados.mensagem || "Não foi possível carregar os usuários.");
    usuarios = dados.usuarios;
    filtrarUsuarios();
}

function filtrarUsuarios() {
    const nome = document.getElementById("buscaUsuario").value.trim().toLowerCase();
    const classe = document.getElementById("grupoUsuarioFiltro").value;
    const profile = document.getElementById("perfilUsuarioFiltro").value;
    const lista = usuarios.filter(u => (!nome || u.nome.toLowerCase().includes(nome)) && (!classe || u.classe === Number(classe)) && (!profile || u.profile === profile));
    document.getElementById("totalUsuarios").textContent = `${lista.length} ${lista.length === 1 ? "pessoa encontrada" : "pessoas encontradas"}`;
    document.getElementById("listaUsuarios").innerHTML = lista.length ? lista.map(u => `
        <div class="col-md-6"><article class="evaluation-member-card d-flex align-items-center gap-3">
            <img src="fotos/foto_${u.id}.jpg" class="evaluation-member-photo" alt="" onerror="this.classList.add('d-none');this.nextElementSibling.classList.remove('d-none')">
            <span class="evaluation-avatar d-none">${escUsuario(u.nome.charAt(0))}</span>
            <div class="flex-grow-1 min-width-0">
                <div class="d-flex align-items-center gap-2 flex-wrap"><h5 class="mb-0">${escUsuario(u.nome)}</h5><span class="badge-tag ${classeGrupoUsuario(u.classe)}">${escUsuario(u.grupo || "Clero")}</span></div>
                <div class="text-muted small mt-1">${escUsuario(u.paroquia || "Paróquia não informada")}${u.regiao ? ` · ${escUsuario(u.regiao)}` : ""}</div>
            </div>
            <div class="user-profile-control">
                <select class="form-select form-select-sm" id="profile-${u.id}" aria-label="Perfil de ${escUsuario(u.nome)}">${perfis.map(p => `<option value="${p}" ${p === u.profile ? "selected" : ""}>${p}</option>`).join("")}</select>
                <button class="btn btn-sm btn-orange mt-2 w-100" data-salvar-profile="${u.id}"><i class="bi bi-check-lg"></i> Salvar</button>
            </div>
        </article></div>`).join("") : '<div class="col-12"><div class="profile-card text-center text-muted">Nenhuma pessoa encontrada.</div></div>';
}

async function salvarPerfil(id, botao) {
    const profile = document.getElementById(`profile-${id}`).value;
    if (id === Number(window.usuarioLogadoId) && profile !== "ADM" && !confirm("Você está alterando o seu próprio perfil administrativo. Deseja continuar?")) return;
    botao.disabled = true;
    try {
        const resposta = await fetch("usuarios_api.jsp", { method: "POST", headers: {"Content-Type":"application/x-www-form-urlencoded;charset=UTF-8"}, body: new URLSearchParams({ idPessoa: id, profile }) });
        const dados = await resposta.json();
        if (!resposta.ok || !dados.ok) throw new Error(dados.mensagem || "Não foi possível salvar o perfil.");
        const usuario = usuarios.find(u => u.id === id); if (usuario) usuario.profile = profile;
        alertaUsuarios(dados.mensagem, "success");
    } catch (erro) { alertaUsuarios(erro.message); }
    finally { botao.disabled = false; }
}

document.getElementById("buscaUsuario").addEventListener("input", filtrarUsuarios);
document.getElementById("grupoUsuarioFiltro").addEventListener("change", filtrarUsuarios);
document.getElementById("perfilUsuarioFiltro").addEventListener("change", filtrarUsuarios);
document.getElementById("statusUsuarioFiltro").addEventListener("change", () => carregarUsuarios().catch(e => alertaUsuarios(e.message)));
document.addEventListener("click", event => { const botao = event.target.closest("[data-salvar-profile]"); if (botao) salvarPerfil(Number(botao.dataset.salvarProfile), botao); });
carregarUsuarios().catch(erro => alertaUsuarios(erro.message));
