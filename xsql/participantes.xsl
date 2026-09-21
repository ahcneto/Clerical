<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="html" encoding="UTF-8"/>

<xsl:template match="SQL">

<html>
<head>
    <title>Participantes do Encontro</title>
    <link rel="stylesheet" href="../jquery/jquery.mobile-1.4.5.min.css"/>
				<script src="../jquery/jquery.min.js"></script>
				<script src="../jquery/jquery.mobile-1.4.5.min.js"></script>
</head>
<body>

<div data-role="page" id="participantes">
    <div data-role="header"  data-position="fixed">
	<a href="encontros.xsql?cmd=listEncontros" class="ui-btn-left ui-btn ui-btn-inline ui-mini ui-corner-all ui-btn-icon-left ui-icon-back">Voltar</a>
        <h1>Participantes do Encontro</h1>
	<a href="RelParticipantesEncontro.xsql?IdEncontro={request/parameters/IdEncontro}" class="ui-btn-right ui-btn ui-btn-inline ui-mini ui-corner-all ui-btn-icon-left ui-icon-bullets">Relatório</a>
	
	
    </div>

    <div data-role="content">
	 <h3>Dados do Encontro</h3>
	  <xsl:for-each select="Encontros/Encontro">
	   <p><strong>Classe: </strong><xsl:choose>
                            <xsl:when test="Classe=1">Diáconos</xsl:when>
                            <xsl:when test="Classe=2">Candidatos</xsl:when>
                            <xsl:otherwise>Vocacionados</xsl:otherwise>
                        </xsl:choose></p>
	  <div class="ui-grid-a">
		<div class="ui-block-a"><p><strong>Data : </strong> <xsl:value-of select="DtEncontro"/></p></div>
		<div class="ui-block-b"><p><strong>Local : </strong> <xsl:value-of select="Local"/></p></div>
	   </div>
	  <p><strong>Descricao : </strong> <xsl:value-of select="Descricao"/></p>
	  <p><strong>Detalhe : </strong> <br/><xsl:value-of select="Detalhe"/></p>
	  
	  </xsl:for-each>
	 <br/>
        <ul data-role="listview" data-filter="true" data-filter-theme="a">
            <xsl:for-each select="ROWSET/ROW">
                <li>
                    
                    <form method="get" action="participantes.xsql">
                        <input type="hidden" name="IdPessoa" value="{IdPessoa}"/>
                        <input type="hidden" name="IdEncontro" value="{IdEncontro}"/>
						<fieldset class="ui-grid-d">
							<div class="ui-block-a">
							<div class="ui-field-contain" >
							<strong><xsl:value-of select="Nome"/></strong></div>
							</div>
							<div class="ui-block-b">
							
							<div class="ui-field-contain">
									<label for="Justificativa"><strong>Justificativa: </strong></label>
									
									<textarea cols="40" rows="8" name="Justificativa" id="Justificativa"><xsl:value-of select="Justificativa"/></textarea>
									
								</div>
								
							</div>
							<div class="ui-block-c">
								<input type="submit" data-inline="true" value="Justificar"/>
							</div>
							<div class="ui-block-d">
							<div class="ui-field-contain" align="center">
								<label for="flgEsposaPres"><strong>Esposa: </strong></label>
								<select name="flgEsposaPres" data-role="slider" onchange="this.form.submit()">
									<option value="0"> <xsl:if test="flgEsposaPres=0">	<xsl:attribute name="selected">selected</xsl:attribute> </xsl:if>Faltou</option>
									<option value="1"> <xsl:if test="flgEsposaPres=1">	<xsl:attribute name="selected">selected</xsl:attribute></xsl:if>Presente</option>
								 </select>
							</div>	 
								 
							</div>
							<div class="ui-block-e">
							
							<div class="ui-field-contain" align="center">
							<label for="flgPresenca"><strong>Presença: </strong></label>
								<select name="flgPresenca" data-role="slider" onchange="this.form.submit()">
									<option value="0"> <xsl:if test="flgPresenca=0">	<xsl:attribute name="selected">selected</xsl:attribute> </xsl:if>Faltou</option>
									<option value="1"> <xsl:if test="flgPresenca=1">	<xsl:attribute name="selected">selected</xsl:attribute></xsl:if>Presente</option>
								 </select>
							</div>	 
								 
							</div>
						</fieldset>	
                    </form>
                </li>
            </xsl:for-each>
        </ul>
    </div>
	
	<div data-role="footer" data-position="fixed">
		<h4>Informações de Encontros</h4>
	</div>	
</div>

</body>
</html>

</xsl:template>
</xsl:stylesheet>
