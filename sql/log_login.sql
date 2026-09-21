-- Auditoria de acessos ao sistema.
CREATE TABLE IF NOT EXISTS LogLogin (
    IdLogLogin BIGINT NOT NULL AUTO_INCREMENT,
    IdPessoa INT NOT NULL,
    DataLogin DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    EnderecoIp VARCHAR(45) NULL,
    UserAgent VARCHAR(500) NULL,
    IdSessao VARCHAR(128) NULL,
    PRIMARY KEY (IdLogLogin),
    KEY IX_LogLogin_Pessoa_Data (IdPessoa, DataLogin),
    KEY IX_LogLogin_Data (DataLogin)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
