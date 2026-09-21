function openEventModal(evento = null) {
    document.getElementById("eventModal").classList.add("show");

    if (evento) {
        document.getElementById("eventModalTitle").innerText = "Editar Encontro";
        document.getElementById("eventTitulo").value = evento.titulo;
        document.getElementById("eventDescricao").value = evento.descricao;
        document.getElementById("eventLocal").value = evento.local;
        document.getElementById("eventGrupo").value = evento.grupo;
        document.getElementById("eventStatus").value = evento.status;
    } else {
        document.getElementById("eventModalTitle").innerText = "Novo Encontro";
    }
}

function closeEventModal() {
    document.getElementById("eventModal").classList.remove("show");
}

function saveEvent() {
    alert("Salvar encontro via XSQL");
    closeEventModal();
}