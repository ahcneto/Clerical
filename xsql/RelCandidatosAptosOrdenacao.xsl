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
          
				<div data-role="page" id="relatorio">
					<div data-role="header" data-position="fixed">
				<a href="../relatorios.jsp" data-ajax="false" class="ui-btn-left ui-btn ui-btn-inline ui-mini ui-corner-all ui-btn-icon-left ui-icon-back">Voltar</a>
                        <h1>Relatorio de Candidatos</h1>
                    </div>
				<div data-role="content">		
	
					<center>
					
					<p><img src="../img/logo_escola.jpg" alt="Logo" style="width: 200px; height: auto;"/> </p>
					
					<h2>Candidatos Aptos à Ordenação Diaconal</h2>
					</center>
					<br/>
					<xsl:for-each select="ROWSET/ROW">
					
				
					<p><xsl:value-of select="@num" />. <xsl:value-of select="Nome" /></p>
					
					
					</xsl:for-each>
					<br/>
					Relatório gerado em: <xsl:value-of select="format-dateTime(current-dateTime(), '[D]/[M]/[Y] [H]:[m]')" />

					<br/>	
					<h5>* Consideram-se aptos, os candidatos que já <b>concluíram o curso de Teologia, foram admitidos às Ordens Sacras e receberam os ministérios de Leitor e Acólito</b>. </h5>
					
					
			</div>
			</div>
			
			</body>
		</html>
    </xsl:template>
</xsl:stylesheet>	
