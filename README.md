# Clerical

Sistema de gestão desenvolvido em JSP/Java, executado no Apache Tomcat 9, com banco MySQL e relatórios legados XSQL.

## Estrutura

- Arquivos JSP, `css/`, `js/` e `includes/`: aplicação web.
- `src/` e `conexao.java`: fontes Java.
- `sql/`: scripts de estrutura e atualização do banco; revisar antes de executar.
- `xsql/`: consultas e relatórios legados.
- `php/`: espaço reservado para desenvolvimento futuro.

## Configuração local

Este repositório contém código, não um backup dos dados de produção.

1. Prepare o Tomcat 9 e um banco MySQL com a estrutura necessária. Os scripts existentes não constituem necessariamente uma instalação completa do banco.
2. Configure localmente o recurso JNDI `jdbc/CadDB` em `META-INF/context.xml`, usando as credenciais do ambiente. Esse arquivo não é versionado.
3. Disponibilize as dependências em `WEB-INF/lib/`: MySQL Connector/J, Commons FileUpload/IO e as bibliotecas Oracle XSQL/XML exigidas pelos relatórios legados. Os JARs não são versionados. A API Servlet é fornecida pelo Tomcat.
4. Compile os fontes Java para `WEB-INF/classes/` com as dependências e a API Servlet do Tomcat no classpath. Configure localmente `WEB-INF/classes/XSQLConfig.xml` caso utilize XSQL.
5. Restaure fotos e documentos somente por meios privados e configure as permissões de acesso necessárias.

Fotos, uploads, documentos de membros, planilhas de presença, configurações com credenciais e utilitários locais com conexões embutidas estão excluídos pelo `.gitignore`. Eles permanecem no ambiente original. Não adicionar esses arquivos com `git add -f`.

## Versionamento

Revise `git status` e `git diff` antes de cada commit. Não inclua senhas, tokens ou dados pessoais. As configurações e os dados de produção precisam de backup separado e protegido.