function login() {
    const telefone = document.getElementById("telefone").value;
    const senha = document.getElementById("senha").value;
    const erro = document.getElementById("loginError");

    erro.style.display = "none";
    erro.innerHTML = "";

    if (!telefone || !senha) {
        erro.innerHTML = "Preencha telefone e senha.";
        erro.style.display = "block";
        return;
    }

    window.location.href =
        `login_action.jsp?telefone=${encodeURIComponent(telefone)}&senha=${encodeURIComponent(senha)}`;
}
