-- Grade fornecida em grade_teologia_2023.csv.
-- 61 disciplinas: 47 obrigatórias e 14 opcionais.
-- Executar depois de formacao.sql.

SET @programa_teologia = (
    SELECT IdPrograma FROM formacao_programa
     WHERE Nome = 'Curso de Teologia'
     ORDER BY IdPrograma LIMIT 1
);

INSERT INTO formacao_disciplina
    (IdPrograma, Descricao, CargaHoraria, TipoDisciplina, Bloco, Ordem)
VALUES
(@programa_teologia,'Introdução à Sagrada Escritura',NULL,'OBRIGATORIA','1º semestre',101),
(@programa_teologia,'Introdução à Teol. e Metodologia Teológica',NULL,'OBRIGATORIA','1º semestre',102),
(@programa_teologia,'Pentateuco',NULL,'OBRIGATORIA','1º semestre',103),
(@programa_teologia,'Metodologia do Trabalho Científico',NULL,'OBRIGATORIA','1º semestre',104),
(@programa_teologia,'Letramento Acadêmico e Produção Textual',NULL,'OBRIGATORIA','1º semestre',105),
(@programa_teologia,'Grego Bíblico I',NULL,'OPCIONAL','1º semestre',106),
(@programa_teologia,'Língua Brasileira de Sinais I',NULL,'OPCIONAL','1º semestre',107),
(@programa_teologia,'Introdução às Ciências da Religião',NULL,'OPCIONAL','1º semestre',108),
(@programa_teologia,'Teologia Fundamental',NULL,'OBRIGATORIA','2º semestre',201),
(@programa_teologia,'Marcos e a Questão Sinótica',NULL,'OBRIGATORIA','2º semestre',202),
(@programa_teologia,'Livros Históricos',NULL,'OBRIGATORIA','2º semestre',203),
(@programa_teologia,'Teologia Patrística',NULL,'OBRIGATORIA','2º semestre',204),
(@programa_teologia,'Profetas',NULL,'OBRIGATORIA','2º semestre',205),
(@programa_teologia,'Teologia Pastoral I',NULL,'OBRIGATORIA','2º semestre',206),
(@programa_teologia,'Catequética',NULL,'OBRIGATORIA','3º semestre',301),
(@programa_teologia,'Cartas Paulinas',NULL,'OBRIGATORIA','3º semestre',302),
(@programa_teologia,'Cristologia',NULL,'OBRIGATORIA','3º semestre',303),
(@programa_teologia,'História da Igreja Antiga e Medieval',NULL,'OBRIGATORIA','3º semestre',304),
(@programa_teologia,'Psicologia da Religião',NULL,'OPCIONAL','3º semestre',305),
(@programa_teologia,'Teologia Pastoral II – Plan. Pastoral',NULL,'OPCIONAL','3º semestre',306),
(@programa_teologia,'Ecologia e Teologia',NULL,'OPCIONAL','3º semestre',307),
(@programa_teologia,'Evangelho de Mateus',NULL,'OBRIGATORIA','4º semestre',401),
(@programa_teologia,'Antropologia Teológica',NULL,'OBRIGATORIA','4º semestre',402),
(@programa_teologia,'Cartas Católicas e Hebreus',NULL,'OBRIGATORIA','4º semestre',403),
(@programa_teologia,'Hist. da Igreja Moderna e Contemporânea',NULL,'OBRIGATORIA','4º semestre',404),
(@programa_teologia,'Teologia Moral Fundamental',NULL,'OBRIGATORIA','4º semestre',405),
(@programa_teologia,'Sacramentos I – Sacramentos da Iniciação',NULL,'OBRIGATORIA','4º semestre',406),
(@programa_teologia,'Teologia da Missão',NULL,'OPCIONAL','4º semestre',407),
(@programa_teologia,'Eclesiologia',NULL,'OBRIGATORIA','5º semestre',501),
(@programa_teologia,'Direito Canônico I',NULL,'OBRIGATORIA','5º semestre',502),
(@programa_teologia,'Pneumatologia',NULL,'OBRIGATORIA','5º semestre',503),
(@programa_teologia,'Sacramentos II – Ordem e Ministérios',NULL,'OBRIGATORIA','5º semestre',504),
(@programa_teologia,'Evangelho de Lucas e Atos dos Apóstolos',NULL,'OBRIGATORIA','5º semestre',505),
(@programa_teologia,'Liturgia',NULL,'OBRIGATORIA','5º semestre',506),
(@programa_teologia,'Socioantropologia',NULL,'OBRIGATORIA','5º semestre',507),
(@programa_teologia,'Estágio Supervisionado I',NULL,'OBRIGATORIA','5º semestre',508),
(@programa_teologia,'Bioética',NULL,'OBRIGATORIA','6º semestre',601),
(@programa_teologia,'Escritos Joaninos',NULL,'OBRIGATORIA','6º semestre',602),
(@programa_teologia,'Sacramentos III - Pen. e Unção dos Enfermos',NULL,'OBRIGATORIA','6º semestre',603),
(@programa_teologia,'Deus Uno e Trino',NULL,'OBRIGATORIA','6º semestre',604),
(@programa_teologia,'Teologia Moral Sexual',NULL,'OBRIGATORIA','6º semestre',605),
(@programa_teologia,'Direito Canônico II - Sacramental',NULL,'OPCIONAL','6º semestre',606),
(@programa_teologia,'Estágio Supervisionado II',NULL,'OBRIGATORIA','6º semestre',607),
(@programa_teologia,'Sacramentos IV - Matrimônio',NULL,'OBRIGATORIA','7º semestre',701),
(@programa_teologia,'Literatura Sapiencial e Salmos',NULL,'OBRIGATORIA','7º semestre',702),
(@programa_teologia,'Literatura Apocalíptica',NULL,'OBRIGATORIA','7º semestre',703),
(@programa_teologia,'Teologia Moral Social',NULL,'OBRIGATORIA','7º semestre',704),
(@programa_teologia,'Teologia da Espiritualidade',NULL,'OBRIGATORIA','7º semestre',705),
(@programa_teologia,'Mariologia',NULL,'OBRIGATORIA','7º semestre',706),
(@programa_teologia,'Trabalho de Conclusão de Curso I',NULL,'OBRIGATORIA','7º semestre',707),
(@programa_teologia,'Direito Canônico III - Matrimonial',NULL,'OPCIONAL','7º semestre',708),
(@programa_teologia,'Estágio Supervisionado III',NULL,'OBRIGATORIA','7º semestre',709),
(@programa_teologia,'Escatologia',NULL,'OBRIGATORIA','8º semestre',801),
(@programa_teologia,'História da Igreja na América Latina e Brasil',NULL,'OBRIGATORIA','8º semestre',802),
(@programa_teologia,'Ecumenismo e Diálogo Interreligioso',NULL,'OBRIGATORIA','8º semestre',803),
(@programa_teologia,'Trabalho de Conclusão de Curso II',NULL,'OBRIGATORIA','8º semestre',804),
(@programa_teologia,'Introdução à Filosofia',NULL,'OPCIONAL','1º semestre',109),
(@programa_teologia,'Ética I',NULL,'OPCIONAL','1º semestre',110),
(@programa_teologia,'Metafísica I',NULL,'OPCIONAL','3º semestre',308),
(@programa_teologia,'Antropologia Filosófica',NULL,'OPCIONAL','5º semestre',509),
(@programa_teologia,'Filosofia da Religião',NULL,'OPCIONAL','6º semestre',608);
