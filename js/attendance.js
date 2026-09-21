const participantes = [
    { id: 1, nome: "José Carlos Souza", status: "Presente" },
    { id: 2, nome: "Francisco Alves Lima", status: "Faltou" },
    { id: 3, nome: "Pedro Henrique Oliveira", status: "Justificou" },
    { id: 4, nome: "Antônio Marcos Ferreira", status: "Presente" }
];
function renderAttendance(lista) {
    const container = document.getElementById("attendanceContainer");
    container.innerHTML = "";

    lista.forEach(p => {
        container.innerHTML += `
            <div class="attendance-card">
                <div class="member-name">${p.nome}</div>

                <div class="status-buttons">
                    <button class="status-btn present ${p.status==='Presente'?'selected':''}"
                        onclick="setStatus(${p.id}, 'Presente')">
                        Presente
                    </button>

                    <button class="status-btn absent ${p.status==='Faltou'?'selected':''}"
                        onclick="setStatus(${p.id}, 'Faltou')">
                        Faltou
                    </button>

                    <button class="status-btn justified ${p.status==='Justificou'?'selected':''}"
                        onclick="setStatus(${p.id}, 'Justificou')">
                        Justificou
                    </button>
                </div>
            </div>
        `;
    });
}

function setStatus(id, status) {
    const participante = participantes.find(p => p.id === id);
    participante.status = status;
    renderAttendance(participantes);
}

function saveAttendance() {
    console.log(participantes);
    alert("Salvar presença via XSQL");
}

document.getElementById("searchParticipant").addEventListener("keyup", function() {
    const termo = this.value.toLowerCase();

    const filtrado = participantes.filter(p =>
        p.nome.toLowerCase().includes(termo)
    );

    renderAttendance(filtrado);
});

renderAttendance(participantes);
