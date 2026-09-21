<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="includes/auth.jsp" %>
<%@ include file="includes/access.jsp" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Avaliações</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css"><link rel="stylesheet" href="css/avaliacoes.css">
</head>
<body>
<jsp:include page="includes/header.jsp"/>
<main class="container py-4">
    <div id="alerta" class="alert d-none" role="alert"></div>
    <section id="telaCiclos">
        <div class="d-flex justify-content-between align-items-start gap-3 mb-4">
            <div><h1 class="fw-bold mb-1">Ciclos de avaliação</h1><p class="text-muted mb-0">Acompanhe e registre as avaliações dos membros.</p></div>
            <button class="btn btn-orange <%= "EXT".equals((String)session.getAttribute("usuarioPerfil")) ? "d-none" : "" %>" id="novoCiclo"><i class="bi bi-plus-lg"></i> Novo ciclo</button>
        </div>
        <div class="evaluation-panel mb-4"><div class="row g-3">
            <div class="col-md-6"><label for="filtroAnoCiclo" class="form-label">Ano</label><select id="filtroAnoCiclo" class="form-select"><option value="">Todos os anos</option></select></div>
            <div class="col-md-6"><label for="filtroGrupoCiclo" class="form-label">Grupo</label><select id="filtroGrupoCiclo" class="form-select" data-catalogo-grupos data-grupos-modulo="avaliacoes" data-grupos-operacionais="true" data-grupos-todos="true"><option value="">Carregando grupos...</option></select></div>
        </div></div>
        <div id="listaCiclos" class="row g-3"></div>
    </section>
    <section id="telaMembros" class="d-none">
        <button class="btn btn-link ps-0 text-decoration-none mb-3" data-voltar="ciclos"><i class="bi bi-arrow-left"></i> Voltar aos ciclos</button>
        <div class="d-flex justify-content-between align-items-start gap-3 mb-4">
            <div><h1 class="fw-bold mb-1" id="cicloTitulo"></h1><p class="text-muted mb-0" id="cicloResumo"></p></div>
            <button class="btn btn-outline-secondary <%= "EXT".equals((String)session.getAttribute("usuarioPerfil")) ? "d-none" : "" %>" id="editarCiclo"><i class="bi bi-pencil"></i> Editar ciclo</button>
        </div>
        <div class="evaluation-panel mb-4"><div class="row g-3">
            <div class="col-md-6"><label for="filtroNome" class="form-label">Nome</label><input id="filtroNome" class="form-control" placeholder="Buscar membro pelo nome"></div>
            <div class="col-md-3"><label for="filtroRegiao" class="form-label">Região episcopal</label><select id="filtroRegiao" class="form-select"><option value="">Todas as regiões</option></select></div>
            <div class="col-md-3"><label for="filtroSituacao" class="form-label">Situação</label><select id="filtroSituacao" class="form-select"><option value="">Todos</option><option value="PENDENTE">Pendentes</option><option value="AVALIADO">Avaliados</option></select></div>
        </div></div>
        <div id="totalMembros" class="text-muted mb-3"></div><div id="listaMembros" class="row g-3"></div>
    </section>
    <section id="telaPessoa" class="d-none">
        <button class="btn btn-link ps-0 text-decoration-none mb-3" data-voltar="membros"><i class="bi bi-arrow-left"></i> Voltar aos membros</button>
        <div id="pessoaCabecalho" class="evaluation-panel mb-4"></div>
        <div class="evaluation-panel mb-4">
            <div class="d-flex justify-content-between align-items-center gap-3 flex-wrap mb-3">
                <div><h4 class="mb-1">Participação, contribuições e formação</h4><span class="text-muted">Indicadores referentes a <strong id="anoIndicadores"></strong></span></div>
                <button type="button" class="btn btn-outline-secondary" id="abrirIndicadores"><i class="bi bi-eye"></i> Ver detalhes</button>
            </div>
            <div class="row g-3">
                <div class="col-md-4"><button type="button" class="indicator-summary w-100" data-abrir-indicadores><span><i class="bi bi-calendar-check"></i> Participação nos encontros</span><strong id="percentualPresenca">—</strong></button></div>
                <div class="col-md-4"><button type="button" class="indicator-summary w-100" data-abrir-indicadores><span><i class="bi bi-cash-coin"></i> Contribuições</span><strong id="percentualContribuicao">—</strong></button></div>
                <div class="col-md-4"><div class="indicator-summary w-100"><span><i class="bi bi-journal-check"></i> Formações ativas</span><strong id="percentualFormacao">—</strong></div></div>
            </div>
        </div>
        <div class="row g-4">
            <div class="col-lg-7 <%= "EXT".equals((String)session.getAttribute("usuarioPerfil")) ? "d-none" : "" %>"><div class="evaluation-panel h-100">
                <h4 class="mb-4" id="formAvaliacaoTitulo">Realizar avaliação</h4>
                <form id="formAvaliacao">
                    <input type="hidden" id="idAvaliacao">
                    <div class="mb-3"><label for="dataAvaliacao" class="form-label">Data da avaliação *</label><input type="date" id="dataAvaliacao" class="form-control" required></div>
                    <div class="mb-3"><label for="textoAvaliacao" class="form-label">Avaliação *</label><textarea id="textoAvaliacao" class="form-control" rows="5" maxlength="10000" required></textarea></div>
                    <fieldset class="mb-4"><legend class="form-label fs-6">Resultado *</legend><div class="result-options">
                        <input type="radio" class="btn-check" name="resultado" id="resultadoNegativa" value="NEGATIVA" required><label class="btn result-negative" for="resultadoNegativa"><i class="bi bi-hand-thumbs-down"></i> Negativa</label>
                        <input type="radio" class="btn-check" name="resultado" id="resultadoNeutra" value="NEUTRA"><label class="btn result-neutral" for="resultadoNeutra"><i class="bi bi-dash-circle"></i> Neutra</label>
                        <input type="radio" class="btn-check" name="resultado" id="resultadoPositiva" value="POSITIVA"><label class="btn result-positive" for="resultadoPositiva"><i class="bi bi-hand-thumbs-up"></i> Positiva</label>
                    </div></fieldset>
                    <div class="action-box"><h6>Ação a ser tomada <span class="text-muted fw-normal">(opcional)</span></h6>
                        <div class="mb-3"><label for="acaoTexto" class="form-label">Descrição da ação</label><textarea id="acaoTexto" class="form-control" rows="3" maxlength="5000"></textarea></div>
                        <div class="row g-3"><div class="col-md-7"><label for="acaoResponsavel" class="form-label">Responsável</label><input id="acaoResponsavel" class="form-control" maxlength="200"></div>
                        <div class="col-md-5"><label for="acaoStatus" class="form-label">Status</label><select id="acaoStatus" class="form-select"><option value="PENDENTE">Pendente</option><option value="CONCLUIDA">Concluída</option></select></div></div>
                    </div>
                    <div class="d-flex justify-content-end gap-2 mt-4"><button type="button" class="btn btn-light d-none" id="cancelarEdicao">Cancelar edição</button><button type="submit" class="btn btn-orange" id="salvarAvaliacao"><i class="bi bi-check-lg"></i> Salvar avaliação</button></div>
                </form>
            </div></div>
            <div class="<%= "EXT".equals((String)session.getAttribute("usuarioPerfil")) ? "col-12" : "col-lg-5" %>"><div class="evaluation-panel"><h4 class="mb-4">Avaliações anteriores</h4><div id="historicoAvaliacoes"></div></div></div>
        </div>
    </section>
</main>
<div class="modal fade" id="modalCiclo" tabindex="-1" aria-hidden="true"><div class="modal-dialog modal-dialog-centered"><div class="modal-content"><form id="formCiclo">
    <div class="modal-header"><h5 class="modal-title" id="modalCicloTitulo">Novo ciclo de avaliação</h5><button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Fechar"></button></div>
    <div class="modal-body"><input type="hidden" id="idCiclo">
        <div class="mb-3"><label for="dataCiclo" class="form-label">Data *</label><input type="date" id="dataCiclo" class="form-control" required></div>
        <div class="mb-3"><label for="grupoCiclo" class="form-label">Grupo *</label><select id="grupoCiclo" class="form-select" required data-catalogo-grupos data-grupos-modulo="avaliacoes" data-grupos-operacionais="true" data-grupos-todos="true" data-grupos-todos-texto="Selecione"><option value="">Carregando grupos...</option></select></div>
        <div><label for="descricaoCiclo" class="form-label">Descrição *</label><textarea id="descricaoCiclo" class="form-control" rows="4" maxlength="500" required></textarea></div>
    </div><div class="modal-footer"><button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancelar</button><button type="submit" class="btn btn-orange">Salvar ciclo</button></div>
</form></div></div></div>
<div class="modal fade" id="modalIndicadores" tabindex="-1" aria-hidden="true"><div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable"><div class="modal-content">
    <div class="modal-header"><div><h5 class="modal-title">Participação e contribuições</h5><div class="text-muted small" id="indicadoresPessoa"></div></div><button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Fechar"></button></div>
    <div class="modal-body">
        <div class="d-flex align-items-center gap-3 mb-4"><label for="anoDetalhes" class="form-label mb-0 fw-bold">Ano</label><select id="anoDetalhes" class="form-select" style="max-width:160px"></select></div>
        <div class="row g-4">
            <div class="col-lg-7"><div class="detail-section h-100"><div class="d-flex justify-content-between align-items-center mb-3"><h5 class="mb-0"><i class="bi bi-calendar-check"></i> Encontros</h5><span class="indicator-percent" id="modalPercentualPresenca">0%</span></div>
                <div class="table-responsive"><table class="table align-middle"><thead><tr><th>Data</th><th>Encontro</th><th>Situação</th><th>Justificativa</th></tr></thead><tbody id="tabelaPresencas"></tbody></table></div>
            </div></div>
            <div class="col-lg-5"><div class="detail-section h-100"><div class="d-flex justify-content-between align-items-center mb-3"><h5 class="mb-0"><i class="bi bi-cash-coin"></i> Contribuições</h5><span class="indicator-percent" id="modalPercentualContribuicao">0%</span></div>
                <div class="table-responsive"><table class="table align-middle"><thead><tr><th>Competência</th><th>Pagamento</th><th>Valor</th><th>Situação</th></tr></thead><tbody id="tabelaContribuicoes"></tbody></table></div>
            </div></div>
        </div>
    </div>
</div></div></div>
<jsp:include page="includes/footer.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>window.avaliacoesSomenteLeitura=<%= "EXT".equals((String)session.getAttribute("usuarioPerfil")) %>;</script>
<script src="js/avaliacoes.js?v=20260729-13"></script>
</body></html>
