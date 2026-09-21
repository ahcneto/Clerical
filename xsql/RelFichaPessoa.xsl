<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" doctype-system="about:legacy-compat" />
    <xsl:template match="SQL">
        <html>
            <head>
                <title>Cadastro de Pessoas</title>
                <meta name="viewport" content="width=device-width, initial-scale=1" />
                <link rel="stylesheet" href="../jquery/jquery.mobile-1.4.5.min.css"/>
                <script src="../jquery/jquery.min.js"></script>
                <script src="../jquery/jquery.mobile-1.4.5.min.js"></script>
            </head>
            <body>
                <div data-role="page">
                    
                    <!-- Cabeçalho -->
                    <div data-role="header">
				<a href="../relatorios.jsp" data-ajax="false" class="ui-btn-left ui-btn ui-btn-inline ui-mini ui-corner-all ui-btn-icon-left ui-icon-back">Voltar</a>
                        <h1>Dados das Pessoas</h1>
                    </div>

                    <!-- Conteúdo -->
                    <div role="main" class="ui-content">
                        
                        <!-- Caixa de seleção para filtro -->
                        <form method="get" action="RelFichaPessoa.xsql">
                            <label for="classe">Filtrar por classe:</label>
                            <select name="classe" id="classe" data-mini="true" onchange="this.form.submit()">
                                <option value="">-- Selecione --</option>
                               
								<option value="1"><xsl:if test="//request/parameters/classe = 1">	<xsl:attribute name="selected">selected</xsl:attribute> </xsl:if>Diáconos</option>
								<option value="2"><xsl:if test="//request/parameters/classe = 2">	<xsl:attribute name="selected">selected</xsl:attribute> </xsl:if>Candidatos</option>
								<option value="3"><xsl:if test="//request/parameters/classe = 3">	<xsl:attribute name="selected">selected</xsl:attribute> </xsl:if>Vocacionados</option>
                            </select>
                        </form>

                        <!-- Tabela de Pessoas -->
                        <table data-role="table" class="ui-responsive ui-shadow ui-body-a">
                            <thead>
                                <tr>
                                    <th>Foto</th>
                                    <th>Nome</th>
                                    <th>Região</th>
                                    <th>Paróquia - Bairro</th>
                                    <th>Classe</th>
                                </tr>
                            </thead>
                            <tbody>
                                <!-- Diáconos -->
                                <xsl:for-each select="ROWSET/PESSOA">
                                    <tr>
                                        <td>
                                            <a href="ExibePessoa.xsql?IdPessoa={IdPessoa}">
                                                <img src="../fotos/foto_{IdPessoa}.jpg" style="width:60px;height:60px;"/>
                                            </a>
                                        </td>
                                        <td><xsl:value-of select="Nome"/></td>
                                        <td><xsl:value-of select="Regiao"/></td>
                                        <td><xsl:value-of select="Paroquia"/> - <xsl:value-of select="Bairro"/></td>
                                        <td><strong><xsl:value-of select="Classe"/></strong></td>
                                    </tr>
                                </xsl:for-each>

                              
                            </tbody>
                        </table>
                        
                    </div>

                    <!-- Rodapé -->
                    <div data-role="footer">
                        <h4>Sistema de Cadastro - CAD</h4>
                    </div>
                </div>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
