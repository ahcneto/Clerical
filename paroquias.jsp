<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="includes/auth.jsp" %>
<%@ include file="includes/access.jsp" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Paróquias e regiões episcopais</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">
<link rel="stylesheet" href="css/style.css"><link rel="stylesheet" href="css/paroquias.css">
</head>
<body><jsp:include page="includes/header.jsp"/>
<main class="container-fluid px-lg-5 py-4">
  <div id="alerta" class="alert d-none" role="alert"></div>
  <div class="d-flex flex-wrap justify-content-between align-items-start gap-3 mb-4">
    <div><h1 class="fw-bold mb-1">Paróquias e regiões episcopais</h1><p class="text-muted mb-0">Mantenha os locais usados nos cadastros, filtros e relatórios.</p></div>
    <button id="novaParoquia" class="btn btn-orange"><i class="bi bi-plus-lg"></i> Nova paróquia</button>
  </div>
  <div class="row g-4">
    <div class="col-xl-7">
      <section class="card border-0 shadow-sm h-100">
        <div class="card-body">
          <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3"><h2 class="h5 fw-bold mb-0">Paróquias cadastradas</h2><div class="input-group search-box"><span class="input-group-text bg-white border-end-0"><i class="bi bi-search"></i></span><input id="busca" class="form-control border-start-0" placeholder="Buscar paróquia, cidade ou região"></div></div>
          <div class="table-responsive"><table class="table align-middle table-hover mb-0"><thead><tr><th>Paróquia</th><th>Localização</th><th>Região episcopal</th><th class="text-end">Ações</th></tr></thead><tbody id="lista"><tr><td colspan="4" class="text-muted py-4">Carregando...</td></tr></tbody></table></div>
        </div>
      </section>
    </div>
    <div class="col-xl-5">
      <section class="card border-0 shadow-sm">
        <div class="card-body">
          <div class="d-flex justify-content-between align-items-center mb-3"><div><h2 id="tituloForm" class="h5 fw-bold mb-1">Nova paróquia</h2><p class="text-muted small mb-0">Os campos marcados com * são obrigatórios.</p></div><span id="statusForm" class="badge text-bg-light">Novo cadastro</span></div>
          <form id="formParoquia" novalidate>
            <input type="hidden" id="idParoquia">
            <div class="mb-3"><label for="descricao" class="form-label">Nome da paróquia *</label><input id="descricao" class="form-control" maxlength="150" required></div>
            <div class="row g-3"><div class="col-md-6"><label for="cidade" class="form-label">Cidade</label><input id="cidade" class="form-control" maxlength="100"></div><div class="col-md-6"><label for="estado" class="form-label">Estado</label><input id="estado" class="form-control" maxlength="2" placeholder="CE"></div><div class="col-md-6"><label for="bairro" class="form-label">Bairro</label><input id="bairro" class="form-control" maxlength="100"></div><div class="col-md-6"><label for="idRegiao" class="form-label">Região episcopal *</label><select id="idRegiao" class="form-select" required><option value="">Selecione o código</option></select></div><div class="col-12"><label for="regiaoDescricao" class="form-label">Nome da região</label><input id="regiaoDescricao" class="form-control" readonly placeholder="Selecione o código da região"><div class="form-text">O nome é preenchido automaticamente a partir da tabela de paróquias.</div></div></div>
            <div class="d-flex justify-content-end gap-2 mt-4"><button id="cancelar" type="button" class="btn btn-light">Limpar</button><button type="submit" class="btn btn-orange"><i class="bi bi-check-lg"></i> Salvar</button></div>
          </form>
        </div>
      </section>
      <section class="card border-0 shadow-sm mt-4"><div class="card-body"><h2 class="h5 fw-bold">Regiões episcopais</h2><p class="text-muted small">Edite o código ou nome e aplique a alteração a todas as paróquias da região.</p><form id="formRegiao" class="row g-2 mb-3"><input type="hidden" id="codigoRegiaoOrigem"><div class="col-4"><label class="form-label small">Código</label><input id="codigoRegiao" class="form-control" type="number" min="1" required></div><div class="col-8"><label class="form-label small">Nome</label><input id="nomeRegiao" class="form-control" required></div><div class="col-12 text-end"><button class="btn btn-sm btn-outline-secondary">Salvar região</button></div></form><div id="resumoRegioes" class="region-list"></div></div></section>
    </div>
  </div>
</main><jsp:include page="includes/footer.jsp"/>
<script src="js/paroquias.js?v=20261019-5"></script></body></html>
