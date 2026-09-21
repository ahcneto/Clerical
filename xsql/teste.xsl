<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" indent="yes"/>

    <!-- Template principal -->
    <xsl:template match="SQL/ROWSET">
        <html>
            <body>
                <h1>Relatório de Diáconos por Região e Paróquia</h1>
                <!-- Agrupa por Região -->
                <xsl:for-each select="ROW[not(Regiao=preceding-sibling::ROW/Regiao)]">
                    <xsl:variable name="regiao" select="Regiao"/>
                    <h2>Região: <xsl:value-of select="$regiao"/></h2>
                    <!-- Agrupa por Paróquia dentro da Região -->
                    <xsl:for-each select="../ROW[Regiao=$regiao][not(Paroquia=preceding-sibling::ROW[Regiao=$regiao]/Paroquia)]">
                        <xsl:variable name="paroquia" select="Paroquia"/>
                        <h3>Paróquia: <xsl:value-of select="$paroquia"/></h3>
                        <ul>
                            <!-- Lista os diáconos da paróquia -->
                            <xsl:for-each select="../ROW[Regiao=$regiao][Paroquia=$paroquia]">
                                <li>
                                    <xsl:value-of select="Nome"/> - <xsl:value-of select="idade"/> anos
                                </li>
                            </xsl:for-each>
                        </ul>
                    </xsl:for-each>
                    <!-- Total de diáconos por região -->
                    <p><strong>Total de diáconos na região: <xsl:value-of select="count(../ROW[Regiao=$regiao])"/></strong></p>
                </xsl:for-each>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>