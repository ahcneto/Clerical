CREATE TABLE IF NOT EXISTS dimensoes_vida_v2 (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    trabalho TINYINT UNSIGNED NOT NULL,
    familia TINYINT UNSIGNED NOT NULL,
    financeiro TINYINT UNSIGNED NOT NULL,
    pessoal TINYINT UNSIGNED NOT NULL,
    social TINYINT UNSIGNED NOT NULL,
    saude TINYINT UNSIGNED NOT NULL,
    ecologico TINYINT UNSIGNED NOT NULL,
    formacao TINYINT UNSIGNED NOT NULL,
    data_submissao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_dimensoes_vida_v2_data (data_submissao),
    CONSTRAINT chk_dimensoes_v2_trabalho CHECK (trabalho BETWEEN 0 AND 10),
    CONSTRAINT chk_dimensoes_v2_familia CHECK (familia BETWEEN 0 AND 10),
    CONSTRAINT chk_dimensoes_v2_financeiro CHECK (financeiro BETWEEN 0 AND 10),
    CONSTRAINT chk_dimensoes_v2_pessoal CHECK (pessoal BETWEEN 0 AND 10),
    CONSTRAINT chk_dimensoes_v2_social CHECK (social BETWEEN 0 AND 10),
    CONSTRAINT chk_dimensoes_v2_saude CHECK (saude BETWEEN 0 AND 10),
    CONSTRAINT chk_dimensoes_v2_ecologico CHECK (ecologico BETWEEN 0 AND 10),
    CONSTRAINT chk_dimensoes_v2_formacao CHECK (formacao BETWEEN 0 AND 10)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;
