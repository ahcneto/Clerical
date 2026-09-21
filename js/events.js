const eventos = [
    {
        id: 1,
        titulo: "Retiro Espiritual - Candidatos",
        descricao: "Retiro de preparação para a próxima etapa formativa.",
        data: "2025-08-02",
        hora: "07:30",
        local: "Casa de Retiros São José",
        grupo: "Candidato",
        status: "Agendado"
    },
    {
        id: 2,
        titulo: "Encontro de Formação Litúrgica",
        descricao: "Estudo sobre a liturgia diaconal.",
        data: "2025-07-19",
        hora: "08:00",
        local: "Centro Pastoral",
        grupo: "Todos",
        status: "Agendado"
    }
];

function getStatusClass(status){
    if(status === "Agendado") return "tag-blue";
    if(status === "Realizado") return "tag-green";
    return "tag-yellow";
}

function renderEvents(lista){
    const container = document.getElementById("eventsContainer");
    container.innerHTML = "";

    document.getElementById("total-encontros").innerText =
        `${lista.length} encontros`;

    lista.forEach(ev => {
        container.innerHTML += `
            <div class="member-card">
                <div>
                    <div class="member-name">
                        ${ev.titulo}
                        <span class="badge-tag ${getStatusClass(ev.status)}">${ev.status}</span>
                        <span class="badge-tag tag-gray">${ev.grupo}</span>
                    </div>

                    <div class="member-sub">
                        ${ev.data} às ${ev.hora} • ${ev.local}
                    </div>

                    <div class="mt-2 text-muted">${ev.descricao}</div>
                </div>

                <div class="member-actions">
                    <i class="bi bi-people text-primary" onclick="openParticipants(${ev.id})"></i>
                    <i class="bi bi-pencil" onclick="editEvent(${ev.id})"></i>
                    <i class="bi bi-trash text-danger"></i>
                </div>
            </div>
        `;
    });
}

function editEvent(id){
    const evento = eventos.find(e => e.id === id);
    openEventModal(evento);
}

function openParticipants(eventId) {
    window.location.href = `participantes.html?id=${eventId}`;
}

function popularAnos() {
    const select = document.getElementById("filterAno");
    const anos = new Set();

    eventos.forEach(ev => {
        const ano = new Date(ev.data).getFullYear();
        anos.add(ano);
    });

    Array.from(anos).sort().forEach(ano => {
        const option = document.createElement("option");
        option.value = ano;
        option.textContent = ano;
        select.appendChild(option);
    });
}

function popularMeses() {
    const select = document.getElementById("filterMes");

    const meses = [
        "Janeiro", "Fevereiro", "Março", "Abril",
        "Maio", "Junho", "Julho", "Agosto",
        "Setembro", "Outubro", "Novembro", "Dezembro"
    ];

    meses.forEach((mes, index) => {
        const option = document.createElement("option");
        option.value = index + 1;
        option.textContent = mes;
        select.appendChild(option);
    });
}

function filtrarEventos() {
    const termo = document.getElementById("searchEvent").value.toLowerCase();
    const grupo = document.getElementById("filterEventGrupo").value;
    const ano = document.getElementById("filterAno").value;
    const mes = document.getElementById("filterMes").value;

    const filtrado = eventos.filter(ev => {
        const data = new Date(ev.data);

        const busca =
            ev.titulo.toLowerCase().includes(termo) ||
            ev.local.toLowerCase().includes(termo);

        const filtroGrupo =
            grupo === "" || ev.grupo === grupo;

        const filtroAno =
            ano === "" || data.getFullYear() == ano;

        const filtroMes =
            mes === "" || (data.getMonth() + 1) == mes;

        return busca && filtroGrupo && filtroAno && filtroMes;
    });

    renderEvents(filtrado);
}




/*document.getElementById("searchEvent")
    .addEventListener("keyup", filtrarEventos);*/

document.getElementById("filterAno")
    .addEventListener("change", filtrarEventos);

document.getElementById("filterMes")
    .addEventListener("change", filtrarEventos);

document.getElementById("filterEventGrupo")
    .addEventListener("change", filtrarEventos);
	
popularAnos();
popularMeses();
renderEvents(eventos);