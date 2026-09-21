CREATE TABLE IF NOT EXISTS grupos (
    IdGrupo INT NOT NULL AUTO_INCREMENT,
    NomeSingular VARCHAR(100) NOT NULL,
    NomePlural VARCHAR(100) NOT NULL,
    Sigla VARCHAR(10) NULL,
    Descricao VARCHAR(1000) NULL,
    Cor VARCHAR(7) NOT NULL DEFAULT '#475569',
    Ordem INT NOT NULL DEFAULT 1,
    StatusGrupo VARCHAR(10) NOT NULL DEFAULT 'ATIVO',
    ContextoInstitucional VARCHAR(20) NOT NULL DEFAULT 'ESCOLA',
    GrupoOperacional TINYINT(1) NOT NULL DEFAULT 1,
    DisponivelUsuarios TINYINT(1) NOT NULL DEFAULT 1,

    ModuloMembros TINYINT(1) NOT NULL DEFAULT 1,
    ModuloEncontros TINYINT(1) NOT NULL DEFAULT 1,
    ModuloPresencas TINYINT(1) NOT NULL DEFAULT 1,
    ModuloContribuicoes TINYINT(1) NOT NULL DEFAULT 0,
    ModuloFormacao TINYINT(1) NOT NULL DEFAULT 1,
    ModuloAvaliacoes TINYINT(1) NOT NULL DEFAULT 1,
    ModuloDocumentacao TINYINT(1) NOT NULL DEFAULT 1,
    ModuloRelatorios TINYINT(1) NOT NULL DEFAULT 1,

    ContribuicaoAtiva TINYINT(1) NOT NULL DEFAULT 0,
    ContribuicaoValor DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    ContribuicaoPeriodicidade VARCHAR(20) NOT NULL DEFAULT 'NENHUMA',
    ContribuicaoDiaVencimento INT NOT NULL DEFAULT 10,
    ContribuicaoValorEditavel TINYINT(1) NOT NULL DEFAULT 0,
    ContribuicaoAteMesAtual TINYINT(1) NOT NULL DEFAULT 1,

    PresencaAtiva TINYINT(1) NOT NULL DEFAULT 0,
    PresencaFonteEsperada VARCHAR(20) NOT NULL DEFAULT 'ENCONTROS',
    PresencaQuantidadeAnual INT NULL,
    PresencaMetaMinima INT NOT NULL DEFAULT 75,
    PresencaJustificadaConta TINYINT(1) NOT NULL DEFAULT 0,
    PermiteParticipacaoEsposas TINYINT(1) NOT NULL DEFAULT 1,

    AcompanhaTeologia TINYINT(1) NOT NULL DEFAULT 0,
    AcompanhaSeminarioLeitor TINYINT(1) NOT NULL DEFAULT 0,
    AcompanhaSeminarioAcolito TINYINT(1) NOT NULL DEFAULT 0,
    AcompanhaOrdemSacra TINYINT(1) NOT NULL DEFAULT 0,
    AcompanhaLeitor TINYINT(1) NOT NULL DEFAULT 0,
    AcompanhaAcolito TINYINT(1) NOT NULL DEFAULT 0,
    AcompanhaAptidaoMinisterial TINYINT(1) NOT NULL DEFAULT 0,
    AcompanhaAptidaoOrdenacao TINYINT(1) NOT NULL DEFAULT 0,
    AcompanhaPastoral TINYINT(1) NOT NULL DEFAULT 0,
    AcompanhaProvisao TINYINT(1) NOT NULL DEFAULT 0,
    AcompanhaOrdenacao TINYINT(1) NOT NULL DEFAULT 0,

    EscopoRepMembros VARCHAR(20) NOT NULL DEFAULT 'PROPRIO',
    EscopoRepEncontros VARCHAR(20) NOT NULL DEFAULT 'PROPRIO',
    EscopoRepContribuicoes VARCHAR(20) NOT NULL DEFAULT 'PROPRIO',
    EscopoRepRelatorios VARCHAR(20) NOT NULL DEFAULT 'PROPRIO',

    IdUsuarioCriacao INT NULL,
    DtCriacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    IdUsuarioAtualizacao INT NULL,
    DtAtualizacao DATETIME NULL,
    PRIMARY KEY (IdGrupo),
    UNIQUE KEY uk_grupos_nome_plural (NomePlural),
    KEY idx_grupos_status_ordem (StatusGrupo, Ordem)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS grupo_transicoes (
    IdTransicao INT NOT NULL AUTO_INCREMENT,
    IdGrupoOrigem INT NOT NULL,
    IdGrupoDestino INT NULL,
    NomeAcao VARCHAR(120) NOT NULL,
    EfeitoAdicional VARCHAR(255) NULL,
    CampoDataAtualizar VARCHAR(60) NULL,
    ExigeData TINYINT(1) NOT NULL DEFAULT 1,
    ExigeMotivo TINYINT(1) NOT NULL DEFAULT 0,
    InativaPessoa TINYINT(1) NOT NULL DEFAULT 0,
    Ordem INT NOT NULL DEFAULT 1,
    StatusTransicao VARCHAR(10) NOT NULL DEFAULT 'ATIVO',
    PRIMARY KEY (IdTransicao),
    KEY idx_transicoes_origem (IdGrupoOrigem, StatusTransicao, Ordem),
    CONSTRAINT fk_grupo_transicao_origem FOREIGN KEY (IdGrupoOrigem) REFERENCES grupos (IdGrupo),
    CONSTRAINT fk_grupo_transicao_destino FOREIGN KEY (IdGrupoDestino) REFERENCES grupos (IdGrupo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET @GRUPOS_SQL_MODE_ANTERIOR = @@SESSION.sql_mode;
SET SESSION sql_mode = CONCAT_WS(',', @@SESSION.sql_mode, 'NO_AUTO_VALUE_ON_ZERO');

INSERT INTO grupos (
    IdGrupo, NomeSingular, NomePlural, Sigla, Descricao, Cor, Ordem, StatusGrupo,
    ContextoInstitucional, GrupoOperacional, DisponivelUsuarios,
    ModuloMembros, ModuloEncontros, ModuloPresencas, ModuloContribuicoes,
    ModuloFormacao, ModuloAvaliacoes, ModuloDocumentacao, ModuloRelatorios,
    ContribuicaoAtiva, ContribuicaoValor, ContribuicaoPeriodicidade,
    PresencaAtiva, PresencaFonteEsperada, PresencaMetaMinima, PermiteParticipacaoEsposas,
    AcompanhaTeologia, AcompanhaSeminarioLeitor, AcompanhaSeminarioAcolito,
    AcompanhaOrdemSacra, AcompanhaLeitor, AcompanhaAcolito,
    AcompanhaAptidaoMinisterial, AcompanhaAptidaoOrdenacao,
    AcompanhaPastoral, AcompanhaProvisao, AcompanhaOrdenacao,
    EscopoRepMembros, EscopoRepEncontros, EscopoRepContribuicoes, EscopoRepRelatorios
) VALUES
    (0, 'Clérigo', 'Clero', 'CLR', 'Grupo institucional disponível para usuários.', '#7c3aed', 4, 'ATIVO',
     'OUTRO', 0, 1, 0,0,0,0,0,0,0,1, 0,0.00,'NENHUMA', 0,'NAO',0,0,
     0,0,0,0,0,0,0,0,0,0,0, 'PROPRIO','PROPRIO','PROPRIO','PROPRIO'),
    (1, 'Diácono', 'Diáconos', 'DIA', 'Diáconos permanentes vinculados à Arquidiocese.', '#16a34a', 1, 'ATIVO',
     'CAD', 1, 1, 1,1,1,1,1,1,1,1, 1,162.10,'MENSAL', 1,'ENCONTROS',75,1,
     0,0,0,0,0,0,0,0,1,1,1, 'REGIAO_TODOS','TODOS','PROPRIO','REGIAO_TODOS'),
    (2, 'Candidato', 'Candidatos', 'CAN', 'Membros em etapa de candidatura e preparação ministerial.', '#d97706', 2, 'ATIVO',
     'ESCOLA', 1, 1, 1,1,1,1,1,1,1,1, 1,10.00,'ENCONTRO', 1,'ENCONTROS',75,1,
     1,1,1,1,1,1,1,1,1,0,0, 'PROPRIO','PROPRIO','PROPRIO','PROPRIO'),
    (3, 'Vocacionado', 'Vocacionados', 'VOC', 'Pessoas em discernimento vocacional e acompanhamento inicial.', '#2563eb', 3, 'ATIVO',
     'ESCOLA', 1, 1, 1,1,1,1,1,1,1,1, 1,10.00,'ENCONTRO', 1,'ENCONTROS',75,1,
     1,0,0,0,0,0,0,0,0,0,0, 'PROPRIO','PROPRIO','PROPRIO','PROPRIO')
ON DUPLICATE KEY UPDATE
    IdGrupo=IdGrupo;

SET SESSION sql_mode = @GRUPOS_SQL_MODE_ANTERIOR;

ALTER TABLE grupos AUTO_INCREMENT = 4;

INSERT INTO grupo_transicoes
    (IdGrupoOrigem, IdGrupoDestino, NomeAcao, EfeitoAdicional, CampoDataAtualizar, ExigeData, ExigeMotivo, InativaPessoa, Ordem)
SELECT 3, 2, 'Mudança de estágio', 'Passar de Vocacionado para Candidato', NULL, 1, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM grupo_transicoes WHERE IdGrupoOrigem=3 AND IdGrupoDestino=2 AND NomeAcao='Mudança de estágio');

INSERT INTO grupo_transicoes
    (IdGrupoOrigem, IdGrupoDestino, NomeAcao, EfeitoAdicional, CampoDataAtualizar, ExigeData, ExigeMotivo, InativaPessoa, Ordem)
SELECT 2, 1, 'Ordenação Diaconal', 'Gravar a data de ordenação', 'DtOrdenacao', 1, 0, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM grupo_transicoes WHERE IdGrupoOrigem=2 AND IdGrupoDestino=1 AND NomeAcao='Ordenação Diaconal');
