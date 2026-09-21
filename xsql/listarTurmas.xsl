<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" indent="yes"/>

    <xsl:template match="/">
        <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1" />
                <link rel="stylesheet" href="../jquery/jquery.mobile-1.4.5.min.css"/>
				<script src="../jquery/jquery.min.js"></script>
				<script src="../jquery/jquery.mobile-1.4.5.min.js"></script>
            </head>
            <body>
                <div data-role="page">
                    <div data-role="header">
                        <h1>Listagem de Turmas</h1>
                        <a href="#cadastrar-turma" class="ui-btn ui-btn-right ui-icon-plus ui-btn-icon-left">Nova Turma</a>
                    </div>

                    <div data-role="main" class="ui-content">
                        <ul data-role="listview" data-inset="true">
                            <xsl:for-each select="ROWSET/ROW">
                                <li>
                                    <a href="#editar-turma" data-id="{idTurma}" class="editar-turma">
                                        <h2><xsl:value-of select="Nome"/></h2>
                                        <p><xsl:value-of select="Descricao"/></p>
                                        <p>Início: <xsl:value-of select="DtInicio"/></p>
                                    </a>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </div>
                </div>

                <!-- Página para cadastrar nova turma -->
                <div data-role="page" id="cadastrar-turma">
                    <div data-role="header">
                        <h1>Cadastrar Turma</h1>
                        <a href="#" data-rel="back" class="ui-btn ui-btn-left ui-icon-back ui-btn-icon-left">Voltar</a>
                    </div>

                    <div data-role="main" class="ui-content">
                        <form id="form-cadastrar" action="turmas.xsql" method="post">
                            <label for="nome">Nome:</label>
                            <input type="text" name="Nome" id="nome" required="true"/>

                            <label for="descricao">Descrição:</label>
                            <textarea name="Descricao" id="descricao" required="true"></textarea>

                            <label for="dtInicio">Data de Início:</label>
                            <input type="date" name="DtInicio" id="dtInicio" required="true"/>

                            <button type="submit" class="ui-btn ui-btn-b">Salvar</button>
                        </form>
                    </div>
                </div>

                <!-- Página para editar turma -->
                <div data-role="page" id="editar-turma">
                    <div data-role="header">
                        <h1>Editar Turma</h1>
                        <a href="#" data-rel="back" class="ui-btn ui-btn-left ui-icon-back ui-btn-icon-left">Voltar</a>
                    </div>

                    <div data-role="main" class="ui-content">
                        <form id="form-editar" action="turmas.xsql" method="post">
                            <input type="hidden" name="idTurma" id="idTurma-editar"/>

                            <label for="nome-editar">Nome:</label>
                            <input type="text" name="Nome" id="nome-editar" required="true"/>

                            <label for="descricao-editar">Descrição:</label>
                            <textarea name="Descricao" id="descricao-editar" required="true"></textarea>

                            <label for="dtInicio-editar">Data de Início:</label>
                            <input type="date" name="DtInicio" id="dtInicio-editar" required="true"/>

                            <button type="submit" class="ui-btn ui-btn-b">Salvar</button>
                        </form>
                    </div>
                </div>

                <!-- Script para manipulação de dados -->
                <script>
                    $(document).ready(function() {
                        // Preenche o formulário de edição ao clicar em uma turma
                        $(".editar-turma").click(function() {
                            var idTurma = $(this).data("id");
                            var nome = $(this).find("h2").text();
                            var descricao = $(this).find("p").eq(0).text();
                            var dtInicio = $(this).find("p").eq(1).text().replace("Início: ", "");

                            $("#idTurma-editar").val(idTurma);
                            $("#nome-editar").val(nome);
                            $("#descricao-editar").val(descricao);
                            $("#dtInicio-editar").val(dtInicio);
                        });
                    });
                </script>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>