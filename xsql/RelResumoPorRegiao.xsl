<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" indent="yes"/>

  <xsl:template match="SQL/ROWSET">
    <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
         <!-- Inclui jQuery e jQuery Mobile -->
                <meta name="viewport" content="width=device-width, initial-scale=1" />
                <link rel="stylesheet" href="../jquery/jquery.mobile-1.4.5.min.css"/>
				<script src="../jquery/jquery.min.js"></script>
				<script src="../jquery/jquery.mobile-1.4.5.min.js"></script>
        <style>
          .subtotal { font-weight: bold; background-color: #eef; padding: 6px; }
          .total { font-weight: bold; background-color: #cfc; padding: 6px; }
          .regiao-header { font-weight: bold; color: #333; padding-top: 1em; }
          .item { padding: 4px 0; border-bottom: 1px solid #ccc; }
		  .total-row { background-color: #eef; font-weight: bold; }
		  
		  .ui-table th { background-color: #ccc; font-weight: bold; }
		  .ui-table th,
		  .ui-table td {
		  border-top: 1px solid #ccc;
		  border-right: 1px solid #ccc; /* Linha divisória entre colunas */
		  border-left: 1px solid #ccc;
		  border-bottom: 1px solid #ccc; /* Linha divisória entre linhas */
		  padding: 8px;
		  font-size: 14px; /* Ajuste conforme necessário */
		  
		  
		}
		  
        </style>
      </head>
      <body>
        <div data-role="page" id="resumo">
          <div data-role="header">
				<a href="../relatorios.jsp" data-ajax="false" class="ui-btn-left ui-btn ui-btn-inline ui-mini ui-corner-all ui-btn-icon-left ui-icon-back">Voltar</a>
                        <h1>Resumo de 
						<xsl:if test="//request/parameters/classe = 1">Diáconos</xsl:if>
						<xsl:if test="//request/parameters/classe = 2">Candidatos</xsl:if>
			  			<xsl:if test="//request/parameters/classe = 3">Vocacionados</xsl:if>						
						
						por Região</h1>
						
					<a href="#" onclick="window.print(); return false;" class="ui-btn-right ui-btn ui-btn-inline ui-mini ui-corner-all ui-btn-icon-left ui-icon-printer">Imprimir</a>
					
                    </div>

          <div role="main" class="ui-content">
		  
		  <form method="get">		
			 <label for="classe">Classe : </label>
              <select name="classe" id="classe" onchange="this.form.submit()">
			    <option value="">Selecione</option>
                <option value="1">
				<xsl:if test="//request/parameters/classe = 1">
				<xsl:attribute name="selected">selected</xsl:attribute>
                    </xsl:if>Diaconos
                    
				</option>
				<option value="2">
				<xsl:if test="//request/parameters/classe = 2">
                      <xsl:attribute name="selected">selected</xsl:attribute>
                    </xsl:if>Candidatos
			   </option>
				<option value="3">
				<xsl:if test="//request/parameters/classe = 3">
                      <xsl:attribute name="selected">selected</xsl:attribute>
                    </xsl:if>Vocacionados
				</option>
               
              </select>
                        <!-- Filtro de Região -->
                        <label for="regiao">Filtrar por Região:</label>
                        <select id="regiao" name="regiao" data-role="listbox" onchange="this.form.submit()">
                            <option value="0">
							<xsl:if test="//request/parameters/regiao = 0">
									<xsl:attribute name="selected">selected</xsl:attribute>
									</xsl:if>
							Todas as Regiões</option>
                            <xsl:for-each select="//REGIOES/REGIAO">
							<xsl:variable name="varRegiao" select="idRegiao"/>
                                <option>
                                    <xsl:attribute name="value">
                                        <xsl:value-of select="idRegiao"/>
                                    </xsl:attribute>
									<xsl:if test="//request/parameters/regiao = $varRegiao">
									<xsl:attribute name="selected">selected</xsl:attribute>
									</xsl:if>
                                    <xsl:value-of select="Regiao"/>
                                </option>
                            </xsl:for-each>
                        </select>
			</form>		
		  
		  
		 <table data-role="table" class="ui-responsive" id="tabela-resumo">
              <thead>
                <tr>
                  <th>Região</th>
                  <th>Paróquia</th>
                  <th>Quantidade</th>
                </tr>
              </thead>
              <tbody>
                <xsl:for-each select="ROW">
				<xsl:variable name="regiao" select="Regiao"/>
				 <xsl:variable name="pos" select="position()" />
                  <tr >
				  <xsl:if test="Paroquia = '-'">
				   <xsl:attribute name="class">total-row</xsl:attribute>
				   </xsl:if>
                   
				   <!-- Região -->
                  
				   <xsl:if test="Regiao != 'Total' and Paroquia = '-'">
                     <td>Total da <xsl:value-of select="Regiao"/></td>
				   </xsl:if>
				   			   
				   	
					<xsl:if test="$pos = 1">
					 <td style="vertical-align: middle;"> 
					 
					   <xsl:attribute name="rowspan"><xsl:value-of select="count(../ROW[Regiao=$regiao])-1"/></xsl:attribute>
					     <xsl:if test="Regiao != 'Total' and Paroquia != '-'">	
					       <xsl:value-of select="Regiao"/>
						 </xsl:if>   
					</td> 
					</xsl:if>
					
					<xsl:if test="$pos > 1">
					<xsl:if test="not($pos > 1 and (../ROW[$pos - 1]/Regiao = $regiao))">
						<td style="vertical-align: middle;">
						 <xsl:attribute name="rowspan"><xsl:value-of select="count(../ROW[Regiao=$regiao])-1"/></xsl:attribute>
						<xsl:value-of select="Regiao"/></td>
					</xsl:if>
				   </xsl:if>
				  
				  				   
                    <td><xsl:value-of select="Paroquia"/></td>
                   
                   <!-- Quantidade -->
                    <td>
                      <xsl:value-of select="Qtd"/>
                    </td>
                  </tr>
                </xsl:for-each>
              </tbody>
            </table>
		  
          
          </div>

        </div>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
		   
