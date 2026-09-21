<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="html" encoding="UTF-8"/>

  <xsl:template match="SQL">
    <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <title>Redirecionando...</title>
        <script type="text/javascript">
          <xsl:choose>
            <xsl:when test="ROWSET/ROW">
              // Redireciona para sucesso.jsp com parâmetros
              <![CDATA[
              window.location.href = "sucesso.jsp?id="]]>
              <xsl:value-of select="ROWSET/ROW/idPessoa"/>
              <![CDATA[&nome="]]>
              <xsl:value-of select="ROWSET/ROW/nome"/>
              <![CDATA[";]]>
            </xsl:when>
            <xsl:otherwise>
              // Redireciona para login.jsp com erro
              <![CDATA[
              window.location.href = "login.jsp?erro=1";]]>
            </xsl:otherwise>
          </xsl:choose>
        </script>
      </head>
      <body>
        <xsl:choose>
          <xsl:when test="ROWSET/ROW">
            Redirecionando para a página de sucesso...
          </xsl:when>
          <xsl:otherwise>
            Usuário não encontrado. Retornando para login...
          </xsl:otherwise>
        </xsl:choose>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
