<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="html" encoding="UTF-8"/>

  <xsl:key name="datas" match="ROW" use="DataCompleta"/>
  <xsl:key name="pessoas" match="ROW" use="IdPessoa"/>
  <xsl:key name="anos" match="ROW" use="Ano"/>
  <xsl:param name="anoSelecionado"/>

<xsl:template match="SQL">



<html>
  <head>
    <title>Presenças por Encontro</title>
    
	<link rel="stylesheet" href="../jquery/jquery.mobile-1.4.5.min.css"/>
	<script src="../jquery/jquery.min.js"></script>
	<script src="../jquery/jquery.mobile-1.4.5.min.js"></script>
    <style>
	
	/* Centraliza a segunda coluna */
        .ui-table td,
        .ui-table th {
            text-align: center;
        }
		
		 /* Primeira coluna */
        .ui-table td:nth-child(1),
        .ui-table th:nth-child(1) {
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
	<div data-role="page" id="presencas">
		
	 <div data-role="header"  data-position="fixed">
				<a href="../relatorios.jsp" data-ajax="false" class="ui-btn-left ui-btn ui-btn-inline ui-mini ui-corner-all ui-btn-icon-left ui-icon-back">Voltar</a>
		<h1>Mapa de Presença</h1>
			
	</div>

    <div data-role="content">
            <form method="get">
			
				<div class="ui-grid-b">
					<div class="ui-block-a">
					<label for="Ano">Ano: </label>
						<select name="Ano" id="Ano">
							<xsl:for-each select="Anos/Ano">
							<option value="0"><xsl:if test="//request/parameters/Ano =0">	<xsl:attribute name="selected">selected</xsl:attribute> </xsl:if>Todos</option>
							<option value="{Ano}"> <xsl:if test="//request/parameters/Ano =  Ano">	<xsl:attribute name="selected">selected</xsl:attribute> </xsl:if> <xsl:value-of select="Ano"/></option>
							</xsl:for-each>  
						</select>
				
					</div>
					<div class="ui-block-b">
			
						<xsl:variable name="classe" select="request/parameters/classe"/>
						  <label for="classe">Classe : </label>
						  <select name="classe" id="classe" onchange="this.form.submit()">
							<option value="">Selecione</option>
							<option value="1">
							<xsl:if test="request/parameters/classe = 1">
							<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>Diaconos
								
							</option>
							<option value="2">
							<xsl:if test="request/parameters/classe = 2">
								  <xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>Candidatos
						   </option>
							<option value="3">
							<xsl:if test="request/parameters/classe = 3">
								  <xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>Vocacionados
							</option>
						   
						  </select>
						  </div>
			  </div>
            </form>

             <table data-role="table" id="movie-table-custom"  class="table-stripe movie-list ui-responsive">
			 <thead>
              <tr>
                <th>Nome</th>
				<th>Participação</th>
                <!-- Cabeçalhos das datas -->
                <xsl:for-each select="ROWSET/ROW[generate-id() = generate-id(key('datas', DataCompleta)[1])]">
                  <xsl:sort select="DataCompleta"/>
                  <th><xsl:value-of select="DataFormatada"/></th>
                </xsl:for-each>
              </tr>
			  </thead> 

              <!-- Linhas por pessoa -->
              <xsl:for-each select="ROWSET/ROW[generate-id() = generate-id(key('pessoas', IdPessoa)[1])]">
                <xsl:variable name="idPessoa" select="IdPessoa"/>
                <xsl:variable name="nome" select="Nome"/>
				
                <tr>
                 <td><xsl:value-of select="$nome"/></td>
				 
				 <td>
				 <xsl:variable name="total" select="count(//DATAS/DATA)"/>
                 <xsl:variable name="presenca" select="count(//ROWSET/ROW[IdPessoa = $idPessoa and flgPresenca = '1'])"/>
                 <xsl:variable name="percentual" select="($presenca div $total) * 100"/>
				 
				 <p><xsl:value-of select="format-number($percentual, '0.00')"/>% - (<xsl:value-of select="$presenca"/> / <xsl:value-of select="$total"/>) </p>
				   
				 </td>
               <xsl:for-each select="//DATAS/DATA">
                <xsl:sort select="DataCompleta"/>
                <xsl:variable name="data" select="DataFormatada"/>
                
                <td>
                  
                  <xsl:value-of select="//ROWSET/ROW[IdPessoa = $idPessoa and DataFormatada = $data]/flgPresenca"/>
                    
                </td>
              </xsl:for-each>
                </tr>
              </xsl:for-each>
            </table>
				 
          </div>

        </div>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
