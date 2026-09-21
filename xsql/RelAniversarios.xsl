<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="html" encoding="UTF-8"/>

<xsl:template match="SQL">

<html>
<head>
    <title>Lista de Encontros</title>
    <link rel="stylesheet" href="../jquery/jquery.mobile-1.4.5.min.css"/>
				<script src="../jquery/jquery.min.js"></script>
				<script src="../jquery/jquery.mobile-1.4.5.min.js"></script>
				
				
	<style>
        /* Adiciona bordas à tabela */
        .ui-responsive table, 
        .ui-responsive th, 
        .ui-responsive td {
            border: 1px solid #000;
            border-collapse: collapse; /* Para evitar bordas duplas */
        }

        .ui-responsive th, 
        .ui-responsive td {
            padding: 8px;
            text-align: center;
        }
    </style>
	
</head>
<body>
	
<div data-role="page" id="encontros">
    <div data-role="header">
				<a href="../relatorios.jsp" data-ajax="false" class="ui-btn-left ui-btn ui-btn-inline ui-mini ui-corner-all ui-btn-icon-left ui-icon-back">Voltar</a>
        <h1>Aniversários</h1>
		
    </div>

    <div data-role="content">

        <form method="get" action="RelAniversarios.xsql">
		     <div class="ui-grid-a">
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
				<label for="Ano">Mês: </label>
            <select name="Mes" id="Mes">
			
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
          
            </select>
				</div>
			 </div><!-- /grid-b --> 
		
            <input type="submit" value="Filtrar" data-inline="true"/>
        </form>
		<br/>
        <table data-role="table" id="movie-table-custom"  class="table-stripe movie-list ui-responsive">
					<thead>
					<tr>
						<th data-priority="1">Classe</th>
						<th data-priority="2">Nome</th>
						<th data-priority="3">Esposa</th>
						<th data-priority="4">Dia</th>
						<th data-priority="5">Idade</th>
						<th data-priority="6">Tipo</th>
						
					</tr>
					</thead>
					<tbody>
					<xsl:for-each select="ROWSET/ROW">
						<tr>
							<th><xsl:value-of select="DescClasse" /></th>
							<td><xsl:value-of select="Nome" /></td>
							<td><xsl:value-of select="Esposa" /></td>
							<td><xsl:value-of select="Dia" /></td>
							<td><xsl:value-of select="Idade" /></td>
							<td><xsl:value-of select="Tipo" /></td>
							
						</tr>
					</xsl:for-each>	
					</tbody>
					</table>	
									
					<br/>
					Relatório gerado em: <xsl:value-of select="format-dateTime(current-dateTime(), '[D]/[M]/[Y] [H]:[m]')" />

    </div>
</div>





</body>
</html>

</xsl:template>
</xsl:stylesheet>
