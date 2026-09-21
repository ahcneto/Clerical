CREATE TABLE IF NOT EXISTS financeiro_contas (
 IdConta INT AUTO_INCREMENT PRIMARY KEY, Codigo VARCHAR(20) NOT NULL UNIQUE, Nome VARCHAR(120) NOT NULL,
 Tipo ENUM('ENTRADA','SAIDA') NOT NULL, StatusConta ENUM('ATIVA','INATIVA') NOT NULL DEFAULT 'ATIVA'
);
CREATE TABLE IF NOT EXISTS financeiro_lancamentos (
 IdLancamento INT AUTO_INCREMENT PRIMARY KEY, IdGrupo INT NOT NULL, IdConta INT NOT NULL, Tipo ENUM('ENTRADA','SAIDA') NOT NULL,
 Descricao VARCHAR(255) NOT NULL, Competencia DATE NOT NULL, DtPrevista DATE NULL, DtRealizada DATE NULL,
 Valor DECIMAL(12,2) NOT NULL, Situacao ENUM('PREVISTO','REALIZADO','CANCELADO') NOT NULL DEFAULT 'PREVISTO',
 Origem ENUM('MANUAL','CONTRIBUICOES') NOT NULL DEFAULT 'MANUAL', Referencia VARCHAR(80) NULL,
 IdUsuarioCriacao INT NOT NULL, DtCriacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 IdUsuarioAtualizacao INT NULL, DtAtualizacao TIMESTAMP NULL,
 UNIQUE KEY uk_fin_origem_referencia (Origem,Referencia), KEY ix_fin_competencia (Competencia), KEY ix_fin_grupo (IdGrupo)
);
CREATE TABLE IF NOT EXISTS financeiro_lancamentos_log (
 IdLog BIGINT AUTO_INCREMENT PRIMARY KEY, IdLancamento INT NULL, Acao VARCHAR(20) NOT NULL, IdUsuario INT NOT NULL,
 DtLog TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, DadosAnteriores TEXT NULL, DadosNovos TEXT NULL, Motivo VARCHAR(500) NULL
);
INSERT IGNORE INTO financeiro_contas(Codigo,Nome,Tipo) VALUES
 ('1.01','Contribuições','ENTRADA'),('1.02','Doações','ENTRADA'),('1.03','Eventos','ENTRADA'),
 ('2.01','Alimentação','SAIDA'),('2.02','Transporte','SAIDA'),('2.03','Material','SAIDA'),('2.04','Outras despesas','SAIDA');
