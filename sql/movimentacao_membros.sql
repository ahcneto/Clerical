CREATE TABLE IF NOT EXISTS HistoricoMovimentacaoMembro (
    IdMovimentacao INT NOT NULL AUTO_INCREMENT,
    IdPessoa INT NOT NULL,
    TipoMovimentacao VARCHAR(30) NOT NULL,
    DataMovimentacao DATE NOT NULL,
    ClasseAnterior INT NULL,
    ClasseNova INT NULL,
    StatusAnterior TINYINT NULL,
    StatusNovo TINYINT NULL,
    ObservacaoAnterior TEXT NULL,
    Motivo TEXT NULL,
    IdUsuarioRegistro INT NOT NULL,
    DataRegistro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (IdMovimentacao),
    KEY IX_Movimentacao_Pessoa_Data (IdPessoa, DataMovimentacao),
    KEY IX_Movimentacao_Usuario (IdUsuarioRegistro),
    CONSTRAINT FK_Movimentacao_Pessoa
        FOREIGN KEY (IdPessoa) REFERENCES pessoas (IdPessoa),
    CONSTRAINT FK_Movimentacao_Usuario
        FOREIGN KEY (IdUsuarioRegistro) REFERENCES pessoas (IdPessoa)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Mantém o script reaplicável caso a tabela tenha sido criada pela versão anterior.
SET @coluna_observacao_anterior = (
    SELECT COUNT(*)
      FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE()
       AND TABLE_NAME = 'HistoricoMovimentacaoMembro'
       AND COLUMN_NAME = 'ObservacaoAnterior'
);
SET @sql_observacao_anterior = IF(
    @coluna_observacao_anterior = 0,
    'ALTER TABLE HistoricoMovimentacaoMembro ADD COLUMN ObservacaoAnterior TEXT NULL AFTER StatusNovo',
    'SELECT 1'
);
PREPARE stmt_observacao_anterior FROM @sql_observacao_anterior;
EXECUTE stmt_observacao_anterior;
DEALLOCATE PREPARE stmt_observacao_anterior;
