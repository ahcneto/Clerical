CREATE TABLE IF NOT EXISTS demandas_saude_mental (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    resposta VARCHAR(1000) NOT NULL,
    data_submissao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_demandas_saude_data (data_submissao)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS demandas_saude_config (
    id TINYINT NOT NULL,
    pergunta VARCHAR(500) NOT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO demandas_saude_config (id, pergunta)
VALUES (1, 'Quais demandas você considera que impactam sua saúde mental no ambiente de trabalho?');
