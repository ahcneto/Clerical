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
        
		  
				<div data-role="page" id="relatorio">
				
				   <div data-role="header" data-position="fixed">
				<a href="../relatorios.jsp" data-ajax="false" class="ui-btn-left ui-btn ui-btn-inline ui-mini ui-corner-all ui-btn-icon-left ui-icon-back">Voltar</a>
                        <h1>Relatorio de Candidatos</h1>
                    </div>

				<div data-role="content">		
	
					<center>
					
					<p><img src="../img/logo_escola.jpg" alt="Logo" style="width: 200px; height: auto;"/> </p>
					
					<h2>Situação dos Candidatos</h2>
					</center>
					<br/>
					
					
					<table data-role="table" id="movie-table-custom"  class="table-stripe movie-list ui-responsive">
					<thead>
					<tr>
						<th data-priority="1">Nome</th>
						<th data-priority="2">Curso Teológico</th>
						<th data-priority="3">Ordem Sacra</th>
						<th data-priority="4">Min. Leitor</th>
						<th data-priority="5">Min. Acolito</th>
						
					</tr>
					</thead>
					<tbody>
					<xsl:for-each select="ROWSET/ROW">
						<tr>
							<th><xsl:value-of select="Nome" /></th>
							<td><xsl:value-of select="Teologia" /></td>
							<td><xsl:value-of select="OrdemSacra" /></td>
							<td><xsl:value-of select="Leitor" /></td>
							<td><xsl:value-of select="Acolito" /></td>
							
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
