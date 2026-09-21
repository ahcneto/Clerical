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
    <title>Resumo da Presença</title>
    
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
	
	.quebra {
    white-space: normal !important;
    word-wrap: break-word;
    word-break: break-word;
	}
	
	#movie-table-custom {
    table-layout: fixed;
	}
	</style>	
 </head>
 
<body>
	<div data-role="page" id="presencas">
		
	 <div data-role="header"  data-position="fixed">
				<a href="../relatorios.jsp" data-ajax="false" class="ui-btn-left ui-btn ui-btn-inline ui-mini ui-corner-all ui-btn-icon-left ui-icon-back">Voltar</a>
		<h1>Resumo da Presença</h1>
			
	</div>

    <div data-role="content">
            <form method="get">
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

             <table data-role="table" id="movie-table-custom"  class="table-stripe movie-list ui-responsive">
			  <colgroup>
				<col style="width: 25%;"/>
				<col style="width: 25%;"/>
				<col style="width: 35%;"/>
				<col style="width: 15%;"/>
				</colgroup>
			 <thead>
              <tr>
			    <th>Região</th>
				<th>Paroquia</th>
                <th>Nome</th>
				<th>Participação</th>
              </tr>
			  </thead> 

              <!-- Linhas por pessoa -->
              <xsl:for-each select="ROWSET/ROW[generate-id() = generate-id(key('pessoas', IdPessoa)[1])]">
                <xsl:variable name="idPessoa" select="IdPessoa"/>
                <xsl:variable name="nome" select="Nome"/>
				<xsl:variable name="regiao" select="Regiao"/>
				<xsl:variable name="paroquia" select="Paroquia"/>
				
                <tr>
                 <td class="quebra"><xsl:value-of select="$regiao"/></td>
				 <td class="quebra"><xsl:value-of select="$paroquia"/></td>
				 <td><xsl:value-of select="$nome"/></td>
				 
				 <td>
				 <xsl:variable name="total" select="count(//DATAS/DATA)"/>
                 <xsl:variable name="presenca" select="count(//ROWSET/ROW[IdPessoa = $idPessoa and flgPresenca = '1'])"/>
                 <xsl:variable name="percentual" select="($presenca div $total) * 100"/>
				 
				 <p><xsl:value-of select="format-number($percentual, '0.00')"/>% - (<xsl:value-of select="$presenca"/> / <xsl:value-of select="$total"/>) </p>
				   
				 </td>
             
                </tr>
              </xsl:for-each>
            </table>
				 
          </div>

        </div>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
