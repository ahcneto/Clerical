-- Módulo de evolução acadêmica/formativa.
-- Executar uma única vez no banco andrezaalmeida_cad.

CREATE TABLE formacao_programa (
    IdPrograma INT NOT NULL AUTO_INCREMENT,
    Nome VARCHAR(200) NOT NULL,
    DtInicio DATE NULL,
    StatusPrograma ENUM('ATIVO','INATIVO') NOT NULL DEFAULT 'ATIVO',
    IdUsuarioCriacao INT NULL,
    DtCriacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    IdUsuarioAtualizacao INT NULL,
    DtAtualizacao DATETIME NULL,
    PRIMARY KEY (IdPrograma),
    INDEX idx_formacao_programa_status (StatusPrograma, Nome)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE formacao_programa_grupo (
    IdPrograma INT NOT NULL,
    Classe INT NOT NULL COMMENT '1=Diáconos, 2=Candidatos, 3=Vocacionados',
    PRIMARY KEY (IdPrograma, Classe),
    INDEX idx_formacao_programa_grupo_classe (Classe, IdPrograma),
    CONSTRAINT fk_formacao_programa_grupo_programa FOREIGN KEY (IdPrograma)
        REFERENCES formacao_programa (IdPrograma)
        ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE formacao_disciplina (
    IdDisciplina INT NOT NULL AUTO_INCREMENT,
    IdPrograma INT NOT NULL,
    Descricao VARCHAR(250) NOT NULL,
    CargaHoraria INT NULL,
    TipoDisciplina ENUM('OBRIGATORIA','OPCIONAL') NOT NULL,
    Bloco VARCHAR(80) NULL,
    Ordem INT NOT NULL DEFAULT 0,
    IdUsuarioCriacao INT NULL,
    DtCriacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    IdUsuarioAtualizacao INT NULL,
    DtAtualizacao DATETIME NULL,
    PRIMARY KEY (IdDisciplina),
    INDEX idx_formacao_disciplina_programa (IdPrograma, Ordem, Descricao),
    CONSTRAINT fk_formacao_disciplina_programa FOREIGN KEY (IdPrograma)
        REFERENCES formacao_programa (IdPrograma)
        ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE formacao_pessoa_disciplina (
    IdPessoa INT NOT NULL,
    IdDisciplina INT NOT NULL,
    StatusDisciplina ENUM('PENDENTE','EM_ANDAMENTO','CONCLUIDA') NOT NULL DEFAULT 'PENDENTE',
    ClasseRegistro INT NULL COMMENT 'Classe da pessoa quando iniciou esta disciplina',
    DtInicio DATE NULL,
    DtConclusao DATE NULL,
    Observacao VARCHAR(1000) NULL,
    IdUsuarioAtualizacao INT NULL,
    DtAtualizacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (IdPessoa, IdDisciplina),
    INDEX idx_formacao_pessoa_status (IdPessoa, StatusDisciplina),
    CONSTRAINT fk_formacao_pessoa_disciplina FOREIGN KEY (IdDisciplina)
        REFERENCES formacao_disciplina (IdDisciplina)
        ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE formacao_pessoa_historico (
    IdHistorico BIGINT NOT NULL AUTO_INCREMENT,
    IdPessoa INT NOT NULL,
    IdDisciplina INT NOT NULL,
    StatusAnterior VARCHAR(20) NULL,
    StatusNovo VARCHAR(20) NOT NULL,
    ClasseRegistro INT NULL,
    IdUsuario INT NULL,
    DtAlteracao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (IdHistorico),
    INDEX idx_formacao_historico_pessoa (IdPessoa, DtAlteracao),
    INDEX idx_formacao_historico_disciplina (IdDisciplina)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Programas iniciais. Podem ser alterados posteriormente pelo ADM.
INSERT INTO formacao_programa (Nome, DtInicio, StatusPrograma)
VALUES ('Curso de Teologia', '2023-01-01', 'ATIVO');
SET @programa_teologia = LAST_INSERT_ID();
INSERT INTO formacao_programa_grupo (IdPrograma, Classe)
VALUES (@programa_teologia, 2), (@programa_teologia, 3);

INSERT INTO formacao_programa (Nome, DtInicio, StatusPrograma)
VALUES ('Formação Complementar', CURDATE(), 'ATIVO');
SET @programa_complementar = LAST_INSERT_ID();
INSERT INTO formacao_programa_grupo (IdPrograma, Classe)
VALUES (@programa_complementar, 1);

-- Depois deste arquivo, executar formacao_grade_teologia_2023.sql.
