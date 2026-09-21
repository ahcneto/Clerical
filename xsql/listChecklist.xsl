<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="html" encoding="UTF-8"/>

<xsl:template match="SQL">

<html>
<head>
    <title>Lista de CheckList</title>
    <link rel="stylesheet" href="../jquery/jquery.mobile-1.4.5.min.css"/>
				<script src="../jquery/jquery.min.js"></script>
				<script src="../jquery/jquery.mobile-1.4.5.min.js"></script>
</head>
<body>
	
<div data-role="page" id="encontros">
    <div data-role="header">
	   <a href="../index.html" class="ui-btn-left ui-btn ui-btn-inline ui-mini ui-corner-all ui-btn-icon-left ui-icon-back">Voltar</a>
        <h1>Encontros</h1>
		<a href="checklist.xsql?cmd=novoChecklist" class="ui-btn-right ui-btn ui-btn-inline ui-mini ui-corner-all ui-btn-icon-left ui-icon-plus">Novo</a>
    </div>

    <div data-role="content">

        <form method="get" action="encontros.xsql">
		<input name="cmd" id="cmd" type="hidden" value="listEncontros"/>
		     <div class="ui-grid-b">
				<div class="ui-block-a">
				<label for="classe">Classe:</label>
				<select name="classe" id="classe">
					<option value="0"><xsl:if test="request/parameters/classe = 0">	<xsl:attribute name="selected">selected</xsl:attribute> </xsl:if>Todas</option>
					<option value="1"><xsl:if test="request/parameters/classe = 1">	<xsl:attribute name="selected">selected</xsl:attribute> </xsl:if>Diáconos</option>
					<option value="2"><xsl:if test="request/parameters/classe = 2">	<xsl:attribute name="selected">selected</xsl:attribute> </xsl:if>Candidatos</option>
					<option value="3"><xsl:if test="request/parameters/classe = 3">	<xsl:attribute name="selected">selected</xsl:attribute> </xsl:if>Vocacionados</option>
				</select>
				</div>
				<div class="ui-block-b">
				<label for="Ano">Ano: </label>
            <select name="Ano" id="Ano">
			   <xsl:for-each select="Anos/Ano">
                <option value="0"><xsl:if test="//request/parameters/Ano =0">	<xsl:attribute name="selected">selected</xsl:attribute> </xsl:if>Todos</option>
                <option value="{Ano}"> <xsl:if test="//request/parameters/Ano =  Ano">	<xsl:attribute name="selected">selected</xsl:attribute> </xsl:if> <xsl:value-of select="Ano"/></option>
               </xsl:for-each>  
            </select>
				
				</div>
				<div class="ui-block-c">
				<label for="Ano">Mês: </label>
            <select name="Mes" id="Mes">
			   <xsl:for-each select="Meses/Mes">
                <option value="0"><xsl:if test="//request/parameters/Mes=0">	<xsl:attribute name="selected">selected</xsl:attribute> </xsl:if>Todos</option>
                <option value="1"><xsl:if test="//request/parameters/Mes=1">	<xsl:attribute name="selected">selected</xsl:attribute> </xsl:if>Janeiro</option>
				<option value="2"><xsl:if test="//request/parameters/Mes=2">	<xsl:attribute name="selected">selected</xsl:attribute> </xsl:if>Fevereiro</option>
				<option value="3"><xsl:if test="//request/parameters/Mes=3">	<xsl:attribute name="selected">selected</xsl:attribute> </xsl:if>Março</option>
				<option value="4"><xsl:if test="//request/parameters/Mes=4">	<xsl:attribute name="selected">selected</xsl:attribute> </xsl:if>Abril</option>
				<option value="5"><xsl:if test="//request/parameters/Mes=5">	<xsl:attribute name="selected">selected</xsl:attribute> </xsl:if>Maio</option>
				<option value="6"><xsl:if test="//request/parameters/Mes=6">	<xsl:attribute name="selected">selected</xsl:attribute> </xsl:if>Junho</option>
				<option value="7"><xsl:if test="//request/parameters/Mes=7">	<xsl:attribute name="selected">selected</xsl:attribute> </xsl:if>Julho</option>
				<option value="8"><xsl:if test="//request/parameters/Mes=8">	<xsl:attribute name="selected">selected</xsl:attribute> </xsl:if>Agosto</option>
				<option value="9"><xsl:if test="//request/parameters/Mes=9">	<xsl:attribute name="selected">selected</xsl:attribute> </xsl:if>Setembro</option>
				<option value="10"><xsl:if test="//request/parameters/Mes=10">	<xsl:attribute name="selected">selected</xsl:attribute> </xsl:if>Outubro</option>
				<option value="11"><xsl:if test="//request/parameters/Mes=11">	<xsl:attribute name="selected">selected</xsl:attribute> </xsl:if>Novembro</option>
				<option value="12"><xsl:if test="//request/parameters/Mes=12">	<xsl:attribute name="selected">selected</xsl:attribute> </xsl:if>Dezembro</option>
               </xsl:for-each>  
            </select>
				</div>
			 </div><!-- /grid-b --> 
		
            <input type="submit" value="Filtrar" data-inline="true"/>
        </form>

        <ul data-role="listview">
            <xsl:for-each select="ROWSET/ROW">
                <li>
                    <a href="RelParticipantesEncontro.xsql?IdEncontro={IdEncontro}">
                        <strong><xsl:value-of select="Descricao"/></strong>
                        <p><strong>Data: <xsl:value-of select="DtEncontro"/></strong></p>
                        <p><strong>Classe: </strong><xsl:choose>
                            <xsl:when test="Classe=1">Diáconos</xsl:when>
                            <xsl:when test="Classe=2">Candidatos</xsl:when>
                            <xsl:otherwise>Vocacionados</xsl:otherwise>
                        </xsl:choose></p>
						<p><strong>Local: <xsl:value-of select="Local"/></strong></p>
												
                    </a>
                </li>
            </xsl:for-each>
        </ul>

    </div>
</div>





</body>
</html>

</xsl:template>
</xsl:stylesheet>
