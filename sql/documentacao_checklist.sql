-- Checklist de documentos por grupo e acompanhamento individual das entregas.

CREATE TABLE IF NOT EXISTS documentacao_checklist (
    IdChecklist INT NOT NULL AUTO_INCREMENT,
    Nome VARCHAR(150) NOT NULL,
    Classe INT NOT NULL,
    StatusChecklist ENUM('ATIVO','INATIVO') NOT NULL DEFAULT 'ATIVO',
    IdUsuarioCriacao INT NULL,
    DtCriacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    IdUsuarioAtualizacao INT NULL,
    DtAtualizacao DATETIME NULL,
    PRIMARY KEY (IdChecklist),
    KEY idx_documentacao_checklist_classe_status (Classe, StatusChecklist)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS documentacao_checklist_item (
    IdItem INT NOT NULL AUTO_INCREMENT,
    IdChecklist INT NOT NULL,
    Descricao VARCHAR(255) NOT NULL,
    ExibirMembro TINYINT(1) NOT NULL DEFAULT 1,
    StatusItem ENUM('ATIVO','INATIVO') NOT NULL DEFAULT 'ATIVO',
    Ordem INT NOT NULL DEFAULT 0,
    IdUsuarioCriacao INT NULL,
    DtCriacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    IdUsuarioAtualizacao INT NULL,
    DtAtualizacao DATETIME NULL,
    PRIMARY KEY (IdItem),
    KEY idx_documentacao_item_checklist (IdChecklist, StatusItem, Ordem),
    CONSTRAINT fk_documentacao_item_checklist
        FOREIGN KEY (IdChecklist) REFERENCES documentacao_checklist (IdChecklist)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS documentacao_pessoa_item (
    IdPessoa INT NOT NULL,
    IdItem INT NOT NULL,
    StatusEntrega ENUM('PENDENTE','CONCLUIDO') NOT NULL DEFAULT 'PENDENTE',
    DtConclusao DATE NULL,
    Observacao VARCHAR(500) NULL,
    IdUsuarioAtualizacao INT NULL,
    DtAtualizacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (IdPessoa, IdItem),
    KEY idx_documentacao_pessoa_status (IdPessoa, StatusEntrega),
    CONSTRAINT fk_documentacao_pessoa_item
        FOREIGN KEY (IdItem) REFERENCES documentacao_checklist_item (IdItem)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE documentacao_checklist_item
    ADD COLUMN IF NOT EXISTS PermiteUpload TINYINT(1) NOT NULL DEFAULT 0 AFTER ExibirMembro,
    ADD COLUMN IF NOT EXISTS PrefixoArquivo VARCHAR(40) NULL AFTER PermiteUpload;

CREATE TABLE IF NOT EXISTS documentacao_pessoa_arquivo (
    IdPessoa INT NOT NULL,
    IdItem INT NOT NULL,
    NomeArquivo VARCHAR(255) NOT NULL,
    NomeOriginal VARCHAR(255) NULL,
    TipoMime VARCHAR(100) NOT NULL,
    TamanhoBytes INT NOT NULL,
    DtUpload DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    IdUsuarioUpload INT NOT NULL,
    PRIMARY KEY (IdPessoa, IdItem),
    KEY idx_documentacao_arquivo_pessoa (IdPessoa, DtUpload),
    CONSTRAINT fk_documentacao_arquivo_item
        FOREIGN KEY (IdItem) REFERENCES documentacao_checklist_item (IdItem)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
