let paroquiasMembroCarregadas = false;

async function carregarParoquiasMembro() {
    if (paroquiasMembroCarregadas) return;
    const select = document.getElementById("paroquia");
    const resposta = await fetch("membros_api.jsp?acao=paroquias", { credentials: "same-origin" });
    const dados = await resposta.json();
    if (!resposta.ok || !dados.ok) throw new Error(dados.mensagem || "Não foi possível carregar as paróquias.");
    select.innerHTML = '<option value="">Selecione uma paróquia</option>' + dados.paroquias.map(paroquia => {
        const complemento = [paroquia.bairro, paroquia.regiao].filter(Boolean).join(" · ");
        return `<option value="${Number(paroquia.id)}">${escapeHtml(paroquia.nome)}${complemento ? ` — ${escapeHtml(complemento)}` : ""}</option>`;
    }).join("");
    paroquiasMembroCarregadas = true;
}

async function openMemberModal() {
    if (window.usuarioPerfil !== "ADM") return;
    clearModal();
    document.getElementById("modalTitle").innerText = "Novo Membro";
    document.getElementById("memberModal").classList.add("show");
    try {
        await Promise.all([carregarParoquiasMembro(), window.GruposCatalogo ? GruposCatalogo.carregar() : Promise.resolve()]);
    } catch (erro) {
        alert(erro.message);
    }
}

function closeMemberModal() {
    document.getElementById("memberModal").classList.remove("show");
}

function clearModal() {
    ["nome", "telefone", "dataNascimento"].forEach(id => document.getElementById(id).value = "");
    const paroquia = document.getElementById("paroquia");
    if (paroquia) paroquia.value = "";
}

function formatarTelefoneMembro(evento) {
    let valor = evento.target.value.replace(/\D/g, "").slice(0, 11);
    if (valor.length > 10) valor = valor.replace(/^(\d{2})(\d{5})(\d{0,4}).*/, "($1) $2-$3");
    else if (valor.length > 6) valor = valor.replace(/^(\d{2})(\d{4})(\d{0,4}).*/, "($1) $2-$3");
    else if (valor.length > 2) valor = valor.replace(/^(\d{2})(\d+)/, "($1) $2");
    evento.target.value = valor;
}

async function saveMember() {
    const campos = {
        nome: document.getElementById("nome").value.trim(), telefone: document.getElementById("telefone").value.trim(),
        nascimento: document.getElementById("dataNascimento").value, grupo: document.getElementById("grupo").value,
        paroquia: document.getElementById("paroquia").value
    };
    if (!campos.nome || !campos.telefone || !campos.nascimento || !campos.grupo || !campos.paroquia) {
        alert("Preencha todos os campos obrigatórios."); return;
    }
    const botao = document.getElementById("salvarMembroBtn");
    botao.disabled = true; botao.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> Salvando...';
    try {
        const resposta = await fetch("membros_api.jsp?acao=cadastrar", { method: "POST", credentials: "same-origin",
            headers: { "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8" }, body: new URLSearchParams(campos) });
        const dados = await resposta.json();
        if (!resposta.ok || !dados.ok) throw new Error(dados.mensagem || "Não foi possível cadastrar o membro.");
        closeMemberModal(); await carregarMembros(); alert(dados.mensagem);
    } catch (erro) { alert(erro.message); }
    finally { botao.disabled = false; botao.innerHTML = "Salvar"; }
}

document.getElementById("telefone").addEventListener("input", formatarTelefoneMembro);
