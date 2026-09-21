<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="html" encoding="UTF-8"/>

<xsl:template match="SQL">

<html>
<head>
    <title>CheckList</title>
    <link rel="stylesheet" href="../jquery/jquery.mobile-1.4.5.min.css"/>
	<script src="../jquery/jquery.min.js"></script>
	<script src="../jquery/jquery.mobile-1.4.5.min.js"></script>
	<style>
	
	 /* Centraliza a segunda coluna */
        .ui-table td:nth-child(2),
        .ui-table th:nth-child(2) {
            text-align: left;
        }
		
		 /* Centraliza a terceira coluna */
        .ui-table td:nth-child(3),
        .ui-table th:nth-child(3) {
            text-align: left;
        }
		
		 /* Centraliza a quarta coluna */
        .ui-table td:nth-child(4),
        .ui-table th:nth-child(4) {
            text-align: left;
        }
		
		/* Centraliza a quarta coluna */
        .ui-table td:nth-child(5),
        .ui-table th:nth-child(5) {
            text-align: left;
        }
		
	.ui-table th,
	.ui-table td {
		border-right: 1px solid #ccc; /* Linha divisória entre colunas */
		border-bottom: 1px solid #ccc; /* Linha divisória entre linhas */
		padding: 8px;
		font-size: 20px; /* Ajuste conforme necessário */
		}

	.ui-table th:last-child,
	.ui-table td:last-child {
    border-right: none; /* Remove a borda da última coluna */
	}
	</style>	
</head>
<body>

<div data-role="page" id="participantes">
    <div data-role="header" >
				<a href="../relatorios.jsp" data-ajax="false" class="ui-btn-left ui-btn ui-btn-inline ui-mini ui-corner-all ui-btn-icon-left ui-icon-back">Voltar</a>
        <h1>Participantes do Encontro</h1>
	<a href="participantes.xsql?IdEncontro={request/parameters/IdEncontro}" class="ui-btn-right ui-btn ui-btn-inline ui-mini ui-corner-all ui-btn-icon-left ui-icon-edit">Editar</a>	
    </div>

    <div data-role="content"> 
	<xsl:for-each select="Encontros/Encontro">
	 <h3><xsl:value-of select="Descricao"/> - <xsl:value-of select="concat(substring(DtEncontro, 9, 2), '/', substring(DtEncontro, 6, 2), '/', substring(DtEncontro, 1, 4))"/></h3>
	
	   <p><strong>Público : </strong><xsl:choose>
                            <xsl:when test="Classe=1">Diáconos</xsl:when>
                            <xsl:when test="Classe=2">Candidatos</xsl:when>
                            <xsl:otherwise>Vocacionados</xsl:otherwise>
                        </xsl:choose></p>
	 
	   <p><strong>Detalhe : </strong> <br/><xsl:value-of select="Detalhe"/></p>
	  
	  <xsl:if test="not(//request/parameters/lista)">	
	  
		<fieldset class="ui-grid-c">
			<div class="ui-block-a">
			<xsl:variable name="total" select="count(//ROWSET/ROW)"/>
            <xsl:variable name="presenca" select="count(//ROWSET/ROW[flgPresenca = '1'])"/>
            <xsl:variable name="percentual" select="($presenca div $total) * 100"/>
         		
				<p><strong>Presentes : </strong> <xsl:value-of select="count(//ROWSET/ROW[flgPresenca=1])"/> / <xsl:value-of select="count(//ROWSET/ROW)"/> ( <xsl:value-of select="format-number($percentual, '0.00')"/>% )</p>
			</div>
			<div class="ui-block-b">
				<p><strong>Ausentes  : </strong> <xsl:value-of select="count(//ROWSET/ROW[flgPresenca=0])"/></p>
			</div>
			<div class="ui-block-c">
				<p><strong>justificados  : </strong> <xsl:value-of select="count(//ROWSET/ROW[Justificativa and string-length(Justificativa) &gt; 0])"/></p>
			</div>
			<xsl:if test="//Encontros/Encontro/flgEsposa = 1">
				<div class="ui-block-d">
					<p><strong>Esposas   : </strong> <xsl:value-of select="count(//ROWSET/ROW[flgEsposaPres=1])"/></p>
				</div>
			</xsl:if> 
		</fieldset>
	  </xsl:if> 
	 
	  
	  </xsl:for-each>
	 <br/>
	 <hr/>
	  <strong>Checklist</strong>   
	  <xsl:if test="(//request/parameters/Presentes = 1)">	
			 - (Apenas Presentes)
		</xsl:if> 		
		<xsl:if test="(//request/parameters/Ausentes = 1)">	
			- (Apenas Presentes)
		</xsl:if> 	
		
	  
	  <br/>
	
	 <table data-role="table" id="movie-table-custom"   class="table-stripe movie-list ui-responsive" data-column-btn-text="Exibir Colunas..." data-column-popup-theme="a">
					<thead>
					<tr>
						
						<th data-priority="1"></th>
						
						<th data-priority="1">Região</th>
						<th data-priority="1">Cidade</th>
						<th data-priority="1">Bairro</th>
						
						<th data-priority="1">Paroquia</th>
						<th data-priority="3">Nome</th>
						<xsl:if test="//Encontros/Encontro/flgCustom1 = 1">
						  <th data-priority="1"><xsl:value-of select="//Encontros/Encontro/NmCustom1" /></th>
						</xsl:if> 
						
											
					</tr>
					</thead>
					<tbody>
					<xsl:for-each select="ROWSET/ROW">
						<tr>
							<td><xsl:value-of select="IdPessoa" /></td>
							<td><xsl:value-of select="Regiao" /></td>
							<td><xsl:value-of select="Cidade" /></td>
							<td><xsl:value-of select="Bairro" /></td>
							
							<td><xsl:value-of select="Paroquia" /> </td>
							<td> <xsl:value-of select="Nome" /> <xsl:if test="idade &gt; 74"> (*)</xsl:if></td>
							<td><xsl:if test="not(//request/parameters/lista)"> 
								 
								</xsl:if>  
							</td>
						</tr>
					</xsl:for-each>	
					</tbody>
					</table>
<h5>* Pessoas com mais de 75 anos.</h5>		
<xsl:if test="not(//request/parameters/lista)">	
<br/>
Relatório gerado em: <xsl:value-of select="format-dateTime(current-dateTime(), '[D]/[M]/[Y] [H]:[m]')" />
</xsl:if> 		
	
    </div>
	
	<div data-role="footer" >
		<h4>CheckList</h4>
		<div data-role="navbar">
		<ul>
		
	
		<li>
			<a href="#" onclick="window.print(); return false;">Imprimir esta página</a>
		</li>		
		</ul>
		</div><!-- /navbar -->
	</div>	
</div>

</body>
</html>

</xsl:template>
</xsl:stylesheet>
