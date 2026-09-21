<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" indent="yes"/>

    <!-- Template principal -->
    <xsl:template match="SQL/ROWSET">
        <html>
            <head>
                <!-- Inclui jQuery e jQuery Mobile -->
                <meta name="viewport" content="width=device-width, initial-scale=1" />
                <link rel="stylesheet" href="../jquery/jquery.mobile-1.4.5.min.css"/>
				<script src="../jquery/jquery.min.js"></script>
				<script src="../jquery/jquery.mobile-1.4.5.min.js"></script>
            </head>
            <body>
                <div data-role="page">
                    <div data-role="header" data-position="fixed">
				<a href="../relatorios.jsp" data-ajax="false" class="ui-btn-left ui-btn ui-btn-inline ui-mini ui-corner-all ui-btn-icon-left ui-icon-back">Voltar</a>
                        <h1>Relatório de 
						<xsl:if test="//request/parameters/classe = 1">Diáconos</xsl:if>
						<xsl:if test="//request/parameters/classe = 2">Candidatos</xsl:if>
			  			<xsl:if test="//request/parameters/classe = 3">Vocacionados</xsl:if>						
						
						por Região</h1>
						
					<a href="#" onclick="window.print(); return false;" class="ui-btn-right ui-btn ui-btn-inline ui-mini ui-corner-all ui-btn-icon-left ui-icon-printer">Imprimir</a>	
                    </div>

            <div data-role="main" class="ui-content">
					
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
						
						
						
                        <!-- Resumo de Diáconos por Região -->
                        <h2>Resumo por Região</h2>
                        <ul>
                            <xsl:for-each select="ROW[not(Regiao=preceding-sibling::ROW/Regiao)]">
                                <xsl:variable name="regiao" select="Regiao"/>
                                <li>
                                    <strong><xsl:value-of select="$regiao"/>: </strong>
                                    <xsl:value-of select="count(../ROW[Regiao=$regiao])"/>
                                </li>
                            </xsl:for-each>
                        </ul>
						
						<!-- Total Geral de Diáconos -->
                        
                        <p>
                            <strong>Total de 
							<xsl:if test="//request/parameters/classe = 1">Diáconos</xsl:if>
						<xsl:if test="//request/parameters/classe = 2">Candidatos</xsl:if>
			  			<xsl:if test="//request/parameters/classe = 3">Vocacionados</xsl:if>
							: </strong>
                            <xsl:value-of select="count(//ROW)"/>
                        </p>
						
                        <!-- Listagem de Diáconos -->
                        <h2>Listagem por Região / Paróquia</h2>
                        <xsl:for-each select="ROW[not(Regiao=preceding-sibling::ROW/Regiao)]">
                            <xsl:variable name="regiao" select="Regiao"/>
                            <div class="regiao" data-regiao="{$regiao}">
                                <h3><xsl:value-of select="$regiao"/></h3>
                                <xsl:for-each select="../ROW[Regiao=$regiao][not(Paroquia=preceding-sibling::ROW[Regiao=$regiao]/Paroquia)]">
                                    <xsl:variable name="paroquia" select="Paroquia"/>
                                    
                                    <h4>
                                        Paróquia: <xsl:value-of select="$paroquia"/>
                                    </h4>
                                    <ul>
                                        <xsl:for-each select="../ROW[Regiao=$regiao][Paroquia=$paroquia]">
                                            <li>
                                                <xsl:value-of select="Nome"/> - <xsl:value-of select="idade"/> anos
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </xsl:for-each>
								<br/>
                            </div>
                        </xsl:for-each>
					<hr/>	
                    <br/>
					Relatório gerado em: <xsl:value-of select="format-dateTime(current-dateTime(), '[D]/[M]/[Y] [H]:[m]')" />
					
					</div>
					
                </div>

                <!-- Script para Filtro -->
                <script>
                    $(document).ready(function() {
                        // Filtra as regiões ao selecionar uma opção no listbox
                        $('#regiao-filter').change(function() {
                            var regiaoSelecionada = $(this).val();
                            if (regiaoSelecionada === "all") {
                                $('.regiao').show(); // Mostra todas as regiões
                            } else {
                                $('.regiao').hide(); // Esconde todas as regiões
                                $('.regiao[data-regiao="' + regiaoSelecionada + '"]').show(); // Mostra apenas a região selecionada
                            }
                        });
                    });
                </script>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
