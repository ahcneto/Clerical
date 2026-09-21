-- Módulo de avaliações. Executar uma única vez no banco andrezaalmeida_cad.
CREATE TABLE IF NOT EXISTS ciclos_avaliacao (
    IdCiclo INT NOT NULL AUTO_INCREMENT,
    DtCiclo DATE NOT NULL,
    Classe INT NOT NULL,
    Descricao VARCHAR(500) NOT NULL,
    IdUsuarioCriacao INT NOT NULL,
    DtCriacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    IdUsuarioAtualizacao INT NULL,
    DtAtualizacao DATETIME NULL,
    PRIMARY KEY (IdCiclo),
    INDEX idx_ciclo_data (DtCiclo),
    INDEX idx_ciclo_classe (Classe)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS avaliacoes_pessoa (
    IdAvaliacao INT NOT NULL AUTO_INCREMENT,
    IdCiclo INT NOT NULL,
    IdPessoa INT NOT NULL,
    DtAvaliacao DATE NOT NULL,
    TextoAvaliacao TEXT NOT NULL,
    Resultado ENUM('NEGATIVA','NEUTRA','POSITIVA') NOT NULL,
    AcaoTexto TEXT NULL,
    AcaoResponsavel VARCHAR(200) NULL,
    AcaoStatus ENUM('PENDENTE','CONCLUIDA') NULL,
    IdUsuarioCriacao INT NOT NULL,
    DtCriacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    IdUsuarioAtualizacao INT NULL,
    DtAtualizacao DATETIME NULL,
    PRIMARY KEY (IdAvaliacao),
    UNIQUE KEY uk_avaliacao_ciclo_pessoa (IdCiclo, IdPessoa),
    INDEX idx_avaliacao_pessoa_data (IdPessoa, DtAvaliacao),
    CONSTRAINT fk_avaliacao_ciclo FOREIGN KEY (IdCiclo)
        REFERENCES ciclos_avaliacao (IdCiclo)
        ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
