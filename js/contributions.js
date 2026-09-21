const contribuicoes = [
    { id:1, nome:"José Carlos de Souza", grupo:"Diácono", paroquia:"Paróquia São José", pago:true },
    { id:2, nome:"Francisco Alves Lima", grupo:"Candidato", paroquia:"Paróquia Nossa Senhora de Fátima", pago:false },
    { id:3, nome:"Pedro Henrique Oliveira", grupo:"Vocacionado", paroquia:"Paróquia São Francisco", pago:false },
    { id:4, nome:"Antônio Marcos Ferreira", grupo:"Diácono", paroquia:"Paróquia São José", pago:false },
    { id:5, nome:"Luiz Fernando Costa", grupo:"Vocacionado", paroquia:"Paróquia Cristo Rei", pago:false }
];

function renderContributions(lista){
    const container = document.getElementById("contributionsContainer");
    container.innerHTML = "";

    const pagos = lista.filter(x => x.pago).length;

    document.getElementById("resumoContrib").innerText =
        `${pagos}/${lista.length} contribuíram`;

    lista.forEach(m => {
        container.innerHTML += `
            <div class="contribution-row">

                <div class="contribution-left">

                    <div class="member-avatar">
                        ${m.nome.charAt(0)}
                    </div>

                    <div>
                        <div class="fw-bold">${m.nome}</div>
                        <div class="member-sub">
                            ${m.grupo} • ${m.paroquia}
                        </div>
                    </div>
                </div>

                <div class="contrib-status">
                    ${
                        m.pago
                        ? `<span class="badge-tag tag-green">✓ Contribuiu</span>`
                        : `<span class="badge-tag tag-red">✕ Pendente</span>`
                    }

                    <div class="switch ${m.pago ? 'active':''}"
                         onclick="toggleContribution(${m.id})">
                    </div>
                </div>

            </div>
        `;
    });
}

function toggleContribution(id){
    const membro = contribuicoes.find(x => x.id === id);
    membro.pago = !membro.pago;
    renderContributions(contribuicoes);
}

function filtrarContribuicoes() {
    const grupo = document.getElementById("filterGrupoContrib").value;
    const termo = document.getElementById("searchContrib").value.toLowerCase();

    const filtrado = contribuicoes.filter(m => {

        const filtroGrupo =
            grupo === "" || m.grupo === grupo;

        const filtroNome =
            m.nome.toLowerCase().includes(termo);

        return filtroGrupo && filtroNome;
    });

    renderContributions(filtrado);
}

function saveContributions() {
    console.log(contribuicoes);
    alert("Salvar contribuições via XSQL");
}

document.getElementById("filterGrupoContrib")
    .addEventListener("change", filtrarContribuicoes);

document.getElementById("searchContrib")
    .addEventListener("keyup", filtrarContribuicoes);

renderContributions(contribuicoes);