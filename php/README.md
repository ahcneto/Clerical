# Clerical PHP

Esta pasta é reservada para a nova versão comercial da aplicação em PHP.

## Separação das aplicações

- A aplicação JSP existente continua sendo a versão principal em produção.
- A versão PHP será desenvolvida em paralelo dentro desta pasta.
- A aplicação PHP não deve depender de sessões, classes compiladas ou configurações internas da versão JSP.
- Nenhuma mudança nesta pasta deve alterar as rotas ou o funcionamento atual do Tomcat.

## Direção arquitetural prevista

- Uma única base de código PHP.
- Identificação da instituição pelo domínio ou subdomínio.
- Banco central para o catálogo de instituições.
- Banco de dados separado e credencial exclusiva para cada instituição.
- Configurações, arquivos, cache, sessões e filas isolados por instituição.
- Migrações de banco versionadas e aplicadas de forma controlada por tenant.

## Estado atual

A pasta foi criada apenas como espaço inicial de trabalho. Nenhuma aplicação PHP foi instalada ou configurada e nenhum banco de dados foi alterado.
