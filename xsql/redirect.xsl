<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" indent="yes"/>

    <xsl:template match="salvar">
        <html>
            <head>
                <script type="text/javascript">
                    // Constrói a URL de redirecionamento
                    var IdPessoa = "<xsl:value-of select="ROWSET/ROW/IdPessoa"/>";
                    var redirectUrl = "ExibePessoa.xsql?IdPessoa=" + IdPessoa;

                    // Redireciona para a URL construída
                    window.location.href = redirectUrl;
                </script>
                <title>Redirecionando...</title>
            </head>
            <body>
                <p>Redirecionando para a página de cadastro...Id: <xsl:value-of select="ROWSET/ROW/IdPessoa"/></p>
				
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>