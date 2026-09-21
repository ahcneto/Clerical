<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="includes/auth.jsp" %>

<%
Integer usuarioId = (Integer) session.getAttribute("usuarioId");
String usuarioNome = (String) session.getAttribute("usuarioNome");
String usuarioPerfil = (String) session.getAttribute("usuarioPerfil");

String paramId = request.getParameter("id");
Integer perfilId = usuarioId;

if (paramId != null && !paramId.isEmpty()) {
    try {
        Integer requestedId = Integer.parseInt(paramId);

        if ("ADM".equals(usuarioPerfil) || "EXT".equals(usuarioPerfil)) perfilId = requestedId;
        else if ("REP".equals(usuarioPerfil)) {
            Integer grupoSessao=(Integer)session.getAttribute("usuarioGrupoId"),regiaoSessao=(Integer)session.getAttribute("usuarioRegiaoId");
            try(java.sql.Connection ca=cad.db.Database.getConnection();java.sql.PreparedStatement pa=ca.prepareStatement("SELECT p.Classe,IFNULL(pr.IdRegiao,0),(SELECT EscopoRepMembros FROM grupos WHERE IdGrupo=?) Escopo FROM pessoas p LEFT JOIN paroquia pr ON pr.IdParoquia=p.IdParoquia WHERE p.IdPessoa=?")){
                pa.setInt(1,grupoSessao==null?-1:grupoSessao);pa.setInt(2,requestedId);try(java.sql.ResultSet ra=pa.executeQuery()){if(ra.next()){String ea=ra.getString("Escopo");boolean ok="TODOS".equals(ea)||("PROPRIO".equals(ea)&&grupoSessao!=null&&ra.getInt("Classe")==grupoSessao)||("REGIAO_TODOS".equals(ea)&&regiaoSessao!=null&&ra.getInt(2)==regiaoSessao);if(ok)perfilId=requestedId;}}
            }
        }
    } catch(Exception e) {
        perfilId = usuarioId;
    }
}
%>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title><%= perfilId.equals(usuarioId) ? "Meu Perfil" : "Perfil do membro" %></title>

    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css?v=20260723-5">
</head>
<body>

<jsp:include page="includes/header.jsp"/>

<div class="container py-4">

    <div class="mb-4">
        <h1 class="fw-bold"><%= perfilId.equals(usuarioId) ? "Meu Perfil" : "Perfil do membro" %></h1>
        <p class="text-muted">Informações pessoais e indicadores</p>
    </div>

    <!-- HEADER PERFIL -->
    <div class="profile-card">

        <div class="profile-header d-flex align-items-center gap-5 flex-wrap">

            <div class="profile-photo-editor">
            <img id="profileFoto"
                 src="fotos/foto_<%= perfilId %>.jpg"
                 alt="Foto Perfil"
                 class="profile-photo"
                 onerror="this.style.display='none'; document.getElementById('profileAvatar').style.display='flex';">

            <div id="profileAvatar" class="profile-avatar" style="display:none;">
                <%= usuarioNome.substring(0,1) %>
            </div>
            <% if (perfilId.equals(usuarioId)) { %>
            <button type="button" id="trocarFotoBtn" class="profile-photo-edit-btn" title="Alterar minha foto" aria-label="Alterar minha foto"><i class="bi bi-camera-fill"></i></button>
            <input type="file" id="trocarFotoInput" accept="image/jpeg,image/png,image/webp" class="d-none">
            <% } %>
            </div>

            <div>
				<h2 id="profileNome" class="fw-bold mb-2"><%= usuarioNome %></h2>
				<div id="profileResumo" class="member-sub fs-6"></div>
			</div>

        </div>
		<button class="btn btn-orange <%= "EXT".equals(usuarioPerfil) ? "d-none" : "" %>" onclick="openEditProfileModal()">
			<i class="bi bi-pencil"></i> Editar Dados
		</button>
		<% if ("ADM".equals(usuarioPerfil)) { %>
		<button type="button" class="btn btn-outline-primary ms-2" onclick="openMovimentacaoModal()">
			<i class="bi bi-arrow-left-right"></i> Movimentar membro
		</button>
		<% } %>

    </div>

    <!-- DADOS PESSOAIS -->
    <div class="profile-card mt-4">

        <h4 class="mb-4">Dados Pessoais</h4>

        <div class="row">
            <div class="col-md-6 mb-3">
                <strong>Telefone:</strong> <span id="profileTelefone"></span>
            </div>

            <div class="col-md-6 mb-3">
                <strong>Email:</strong> <span id="profileEmail"></span>
            </div>

            <div class="col-md-6 mb-3">
                <strong>Nascimento:</strong> <span id="profileNascimento"></span>
            </div>

            <div class="col-md-6 mb-3">
                <strong>Idade:</strong> <span id="profileIdade"></span>
            </div>

            <div class="col-md-6 mb-3">
                <strong>Casamento:</strong> <span id="profileCasamento"></span>
            </div>

            <div class="col-md-6 mb-3">
                <strong>Ordenação:</strong> <span id="profileOrdenacao"></span>
            </div>

            <div class="col-md-6 mb-3">
                <strong>Paróquia:</strong> <span id="profileParoquia"></span>
            </div>

            <div class="col-md-6 mb-3">
                <strong>Região:</strong> <span id="profileRegiao"></span>
            </div>

            <div class="col-md-6 mb-3">
                <strong>Profissão:</strong> <span id="profileProfissao"></span>
            </div>

            <div class="col-md-6 mb-3">
                <strong>Pastoral:</strong> <span id="profilePastoral"></span>
            </div>
        </div>

    </div>

    <!-- DADOS FAMILIARES -->
    <div class="profile-card mt-4">

        <h4 class="mb-4">Dados Familiares</h4>

        <div class="row">
            <div class="col-md-6 mb-3">
                <strong>Esposa:</strong> <span id="profileEsposa"></span>
            </div>

            <div class="col-md-6 mb-3">
                <strong>Telefone da Esposa:</strong> <span id="profileFoneEsposa"></span>
            </div>

            <div class="col-md-6 mb-3">
                <strong>Nascimento da Esposa:</strong> <span id="profileNascEsposa"></span>
            </div>
        </div>

    </div>

    <!-- INDICADORES -->
    <div class="profile-card mt-4">
        <h4 class="mb-4">Dados Ministeriais</h4>
        <div class="row">
            <div class="col-md-4 mb-3"><strong>Teologia:</strong> <span id="profileTeologia"></span></div>
            <div class="col-md-4 mb-3"><strong>Seminário de Leitor:</strong> <span id="profileSeminarioLeitor"></span></div>
            <div class="col-md-4 mb-3"><strong>Seminário de Acólito:</strong> <span id="profileSeminarioAcolito"></span></div>
            <div class="col-md-4 mb-3"><strong>Ordens Sacras:</strong> <span id="profileOrdemSacra"></span></div>
            <div class="col-md-4 mb-3"><strong>Ministério de Leitor:</strong> <span id="profileLeitor"></span></div>
            <div class="col-md-4 mb-3"><strong>Ministério de Acólito:</strong> <span id="profileAcolito"></span></div>
        </div>
    </div>

    <!-- INDICADORES -->
    <div class="row mt-4">

        <div class="col-md-4">
           <div class="dashboard-card clickable-card" onclick="openPresencasModal()">
                <h5>Participação no ano atual</h5>
                <div id="profileParticipacao" class="card-number">0%</div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="dashboard-card clickable-card" onclick="openContribuicoesModal()">
                <h5>Contribuições Financeiras</h5>
                <div id="profileContribuicoes" class="card-number">0%</div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="dashboard-card clickable-card" onclick="window.location.href='formacoes.jsp?pessoa=<%= perfilId %>'">
                <h5 id="profileFormacaoTitulo">Formações</h5>
                <div id="profileFormacaoPercentual" class="card-number">—</div>
                <small id="profileFormacaoResumo" class="text-muted">Ver programas formativos</small>
            </div>
        </div>

    </div>

    <section id="arquivosMembroCard" class="profile-card mt-4 d-none">
        <div class="d-flex justify-content-between align-items-center gap-3 mb-3">
            <div><h4 class="mb-1"><i class="bi bi-paperclip"></i> Arquivos do membro</h4><small class="text-muted">Documentos enviados pelo membro</small></div>
            <span id="arquivosMembroTotal" class="badge text-bg-secondary">0</span>
        </div>
        <div id="arquivosMembroLista" class="list-group list-group-flush"></div>
    </section>

    <!-- HISTÓRICO -->
    <div class="profile-card mt-4">

        <h4 class="mb-3">Resumo da Participação por Ano</h4>

        <div class="table-responsive">
            <table class="table table-striped mb-0">
                <thead>
                    <tr>
                        <th>Ano</th>
                        <th>Encontros</th>
                        <th>Participação</th>
                        <th>Presenças</th>
                        <th>Faltas</th>
                        <th>Justificativas</th>
                    </tr>
                </thead>
                <tbody id="profileEncontros">
                    <tr><td colspan="6">Carregando...</td></tr>
                </tbody>
            </table>
        </div>

    </div>

    <% if ("ADM".equals(usuarioPerfil)) { %>
    <div class="profile-card mt-4">
        <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
            <h4 class="mb-0"><i class="bi bi-clock-history"></i> Histórico de Movimentações</h4>
            <span class="text-muted small">Visível somente para administradores</span>
        </div>
        <div class="table-responsive">
            <table class="table table-striped align-middle mb-0">
                <thead>
                    <tr>
                        <th>Data</th>
                        <th>Tipo</th>
                        <th>Movimentação</th>
                        <th>Descrição</th>
                        <th>Registrado por</th>
                        <th>Registro</th>
                    </tr>
                </thead>
                <tbody id="historicoMovimentacoesBody">
                    <tr><td colspan="6">Carregando...</td></tr>
                </tbody>
            </table>
        </div>
    </div>
    <% } %>

</div>

<div id="contribuicoesModal" class="custom-modal-overlay">
    <div class="custom-modal large-modal">
        <div class="modal-header-custom"><h3>Histórico de Contribuições</h3><button class="close-btn" onclick="closeContribuicoesModal()">×</button></div>
        <div class="modal-body-custom"><div class="d-flex justify-content-between align-items-center mb-3"><select id="filterAnoPerfilContrib" class="form-select" style="max-width:180px"></select><strong>Total no ano: <span id="totalAnoPerfilContrib">R$ 0,00</span></strong></div><div class="table-responsive"><table class="table table-striped"><thead><tr><th>Competência</th><th>Data do pagamento</th><th>Valor</th></tr></thead><tbody id="contribuicoesTableBody"></tbody></table></div></div>
    </div>
</div>

<div id="presencasModal" class="custom-modal-overlay">
    <div class="custom-modal large-modal">

        <div class="modal-header-custom">
            <h3>Histórico de Presenças</h3>
            <button class="close-btn" onclick="closePresencasModal()">×</button>
        </div>

        <div class="modal-body-custom">
            <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
                <div class="d-flex align-items-center gap-2">
                    <label for="filterAnoPerfilPresenca" class="fw-semibold mb-0">Ano:</label>
                    <select id="filterAnoPerfilPresenca" class="form-select" style="max-width: 140px"></select>
                </div>
                <strong>Participação no ano: <span id="percentualAnoPerfilPresenca">0%</span></strong>
            </div>
            <div class="table-responsive">
                <table class="table table-striped">
                    <thead>
						<tr>
							<th>Data</th>
							<th>Descrição</th>
							<th>Presença</th>
							<th>Justificativa</th>
							<% if ("ADM".equals(usuarioPerfil)) { %><th>Ações</th><% } %>
						</tr>
					</thead>
                    <tbody id="presencasTableBody"></tbody>
                </table>
            </div>
        </div>

    </div>
</div>

<% if ("ADM".equals(usuarioPerfil)) { %>
<div id="movimentacaoModal" class="custom-modal-overlay">
    <div class="custom-modal" style="max-width: 680px">
        <div class="modal-header-custom">
            <h3><i class="bi bi-arrow-left-right"></i> Movimentação do membro</h3>
            <button type="button" class="close-btn" onclick="closeMovimentacaoModal()">×</button>
        </div>
        <form id="movimentacaoForm" class="modal-body-custom">
            <div id="movimentacaoAlerta" class="alert d-none" role="alert"></div>
            <div class="row g-3">
                <div class="col-md-8">
                    <label class="form-label">Nome do membro</label>
                    <input id="movimentacaoNome" class="form-control" readonly>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Grupo atual</label>
                    <input id="movimentacaoGrupo" class="form-control" readonly>
                </div>
                <div class="col-md-5">
                    <label class="form-label">Turma</label>
                    <input id="movimentacaoTurma" class="form-control" readonly>
                </div>
                <div class="col-md-7">
                    <label for="movimentacaoTipo" class="form-label">Motivo da movimentação</label>
                    <select id="movimentacaoTipo" class="form-select" required>
                        <option value="">Selecione...</option>
                        <option value="INATIVACAO">Inativar Membro</option>
                        <option value="OBSERVACAO">Observação</option>
                    </select>
                    <div id="movimentacaoRegra" class="form-text"></div>
                </div>
                <div class="col-md-5">
                    <label for="movimentacaoData" class="form-label">Data da movimentação</label>
                    <input id="movimentacaoData" type="date" class="form-control" required>
                </div>
                <div class="col-12">
                    <label for="movimentacaoMotivo" class="form-label">Descrição / motivo</label>
                    <textarea id="movimentacaoMotivo" class="form-control" rows="4" maxlength="2000"
                              placeholder="Registre as informações relevantes sobre a movimentação"></textarea>
                    <div id="movimentacaoMotivoAjuda" class="form-text">Campo obrigatório para inativação.</div>
                </div>
            </div>
            <div class="d-flex justify-content-end gap-2 mt-4">
                <button type="button" class="btn btn-outline-secondary" onclick="closeMovimentacaoModal()">Cancelar</button>
                <button id="salvarMovimentacaoBtn" type="submit" class="btn btn-primary">
                    <i class="bi bi-check-circle"></i> Confirmar movimentação
                </button>
            </div>
        </form>
    </div>
</div>
<% } %>

<div id="editProfileModal" class="custom-modal-overlay">

    <div class="custom-modal edit-profile-modal">

        <div class="modal-header-custom">
            <h3>
                <i class="bi bi-person-lines-fill"></i>
                Editar Dados do Membro
            </h3>

            <button class="close-btn"
                    onclick="closeEditProfileModal()">
                ×
            </button>
        </div>

        <div class="modal-body-custom">

            <!-- ===================== -->
            <!-- DADOS PESSOAIS -->
            <!-- ===================== -->

            <div class="profile-card mb-4">

                <h5 class="mb-4">
                    <i class="bi bi-person"></i>
                    Dados Pessoais
                </h5>

                <div class="row">

                    <div class="col-md-6 mb-3">
                        <label class="form-label">Nome</label>
                        <input id="editNome" class="form-control">
                    </div>

                    <div class="col-md-3 mb-3">
                        <label class="form-label">Telefone</label>
                        <input id="editTelefone" class="form-control">
                    </div>

                    <div class="col-md-3 mb-3">
                        <label class="form-label">Telefone 2</label>
                        <input id="editTelefone2" class="form-control">
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="form-label">E-mail</label>
                        <input id="editEmail"
                               type="email"
                               class="form-control">
                    </div>

                    <div class="col-md-3 mb-3">
                        <label class="form-label">Profissão</label>
                        <input id="editProfissao"
                               class="form-control">
                    </div>

                    <div class="col-md-3 mb-3">
                        <label class="form-label">Pastoral</label>
                        <input id="editPastoral"
                               class="form-control">
                    </div>

                    <div class="col-md-3 mb-3">
                        <label class="form-label">Nascimento</label>
                        <input id="editNascimento"
                               type="date"
                               class="form-control">
                    </div>

                    <div class="col-md-3 mb-3">
                        <label class="form-label">Classe</label>
                        <input id="editClasse"
                               readonly
                               class="form-control">
                    </div>

                    <div class="col-md-3 mb-3">
                        <label class="form-label">Matrícula</label>
                        <input id="editMatricula"
                               readonly
                               class="form-control">
                    </div>

                    <div class="col-md-3 mb-3">
                        <label class="form-label">Turma</label>
                        <input id="editTurma"
                               class="form-control">
                    </div>

                </div>

            </div>

            <!-- ===================== -->
            <!-- DADOS FAMILIARES -->
            <!-- ===================== -->

            <div class="profile-card mb-4">

                <h5 class="mb-4">
                    <i class="bi bi-people"></i>
                    Dados Familiares
                </h5>

                <div class="row">

                    <div class="col-md-6 mb-3">
                        <label class="form-label">Nome da Esposa</label>
                        <input id="editEsposa"
                               class="form-control">
                    </div>

                    <div class="col-md-3 mb-3">
                        <label class="form-label">Telefone</label>
                        <input id="editFoneEsposa"
                               class="form-control">
                    </div>

                    <div class="col-md-3 mb-3">
                        <label class="form-label">Profissão</label>
                        <input id="editProfissaoEsposa"
                               class="form-control">
                    </div>

                    <div class="col-md-3 mb-3">
                        <label class="form-label">Nascimento</label>
                        <input id="editNascEsposa"
                               type="date"
                               class="form-control">
                    </div>

                    <div class="col-md-3 mb-3">
                        <label class="form-label">Casamento</label>
                        <input id="editCasamento"
                               type="date"
                               class="form-control">
                    </div>

                </div>

            </div>

            <!-- ===================== -->
            <!-- DADOS MINISTERIAIS -->
            <!-- ===================== -->

            <div class="profile-card mb-4">

                <h5 class="mb-4">
                    <i class="bi bi-bank"></i>
                    Dados Ministeriais
                </h5>

                <div id="ministerialFields" class="row">

                    <div class="col-md-6 mb-3">

                        <label class="form-label">Paróquia</label>

                        <div class="input-group">

                            <input id="editParoquiaNome"
                                   readonly
                                   class="form-control">

                            <button class="btn btn-outline-secondary"
                                    onclick="openParoquiasModal()">

                                <i class="bi bi-search"></i>

                            </button>

                        </div>

                        <input type="hidden"
                               id="editParoquiaId">

                    </div>

                    <div class="col-md-3 mb-3">
                        <label class="form-label">Bairro</label>
                        <input id="editBairro" readonly class="form-control">
                    </div>

                    <div class="col-md-3 mb-3">

                        <label class="form-label">Região</label>

                        <input id="editRegiao"
                               readonly
                               class="form-control">

                    </div>

                    <div class="col-md-4 mb-3">

                        <label class="form-label">Ordenação</label>

                        <input id="editOrdenacao"
                               type="date"
                               class="form-control">

                    </div>

                    <div class="col-md-4 mb-3">

                        <label class="form-label">Provisão</label>

                        <input id="editProvisao"
                               type="date"
                               class="form-control">

                    </div>

                    <div class="col-md-4 mb-3">

                        <label class="form-label">Bispo Ordenante</label>

                        <input id="editBispo"
                               class="form-control">

                    </div>

                    <div class="col-md-4 mb-3"><label class="form-label">Teologia</label><select id="editTeologia" class="form-select"><option value="0">Não iniciado</option><option value="1">Concluído</option><option value="2">Em andamento</option></select></div>
                    <div class="col-md-4 mb-3"><label class="form-label">Seminário de Leitor</label><select id="editSeminarioLeitor" class="form-select"><option value="0">Não</option><option value="1">Sim</option></select></div>
                    <div class="col-md-4 mb-3"><label class="form-label">Seminário de Acólito</label><select id="editSeminarioAcolito" class="form-select"><option value="0">Não</option><option value="1">Sim</option></select></div>
                    <div class="col-md-4 mb-3"><label class="form-label">Ordens Sacras</label><select id="editOrdemSacra" class="form-select"><option value="0">Não</option><option value="1">Sim</option></select></div>
                    <div class="col-md-4 mb-3"><label class="form-label">Ministério de Leitor</label><select id="editLeitor" class="form-select"><option value="0">Não</option><option value="1">Sim</option></select></div>
                    <div class="col-md-4 mb-3"><label class="form-label">Ministério de Acólito</label><select id="editAcolito" class="form-select"><option value="0">Não</option><option value="1">Sim</option></select></div>

                </div>

            </div>

            <!-- ===================== -->
            <!-- OBSERVAÇÕES -->
            <!-- ===================== -->

            <div class="profile-card">

                <h5 class="mb-4">

                    <i class="bi bi-journal-text"></i>

                    Observações

                </h5>

                <textarea id="editObs"
                          rows="5"
                          class="form-control"></textarea>

            </div>

        </div>

        <div class="modal-footer-custom">

            <button class="btn btn-secondary"
                    onclick="closeEditProfileModal()">

                Cancelar

            </button>

            <button class="btn btn-orange"
                    onclick="salvarPerfil()">

                <i class="bi bi-floppy"></i>

                Salvar Alterações

            </button>

        </div>

    </div>

</div>

<div id="paroquiasModal" class="custom-modal-overlay">
    <div class="custom-modal" style="width:800px; max-width:95%;">

        <div class="modal-header-custom">
            <h3>Selecionar Paróquia</h3>
            <button class="close-btn" onclick="closeParoquiasModal()">×</button>
        </div>

        <div class="modal-body-custom">

            <div class="mb-3">
                <input
                    type="text"
                    id="searchParoquia"
                    class="form-control"
                    placeholder="Buscar paróquia..."
                    onkeyup="filtrarParoquias()"
                >
            </div>

            <div id="paroquiasContainer"></div>

        </div>

    </div>
</div>

<jsp:include page="includes/footer.jsp"/>

<script>
window.perfilId = <%= perfilId %>;
window.usuarioPerfil = "<%= usuarioPerfil %>";
</script>
<script src="js/profile.js?v=20260824-2"></script>

</body>
</html>
