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
                <div data-role="page">
                    <!-- Cabeçalho -->
                    <div data-role="header" data-position="fixed">
					    <a href="../auto/paginaFoto.jsp" class="ui-btn-left ui-btn ui-btn-inline ui-mini ui-corner-all ui-btn-icon-left ui-icon-back">Voltar</a>
                        <h1>Cadastro de Pessoas</h1>
                    </div>

                    <!-- Conteúdo -->
                    <div data-role="content">
                       
					   
					<div data-role="collapsibleset" data-theme="a" data-content-theme="b">
					 <div data-role="collapsible">
						<h2>Diáconos (<xsl:value-of select="count(//ROWSET/DIACONO)"/>)</h2>
							<ul data-role="listview" data-filter="true" data-filter-theme="a" data-divider-theme="b">
								<xsl:for-each select="ROWSET/DIACONO">
									<li>
										<a href="ExibePessoa.xsql?IdPessoa={IdPessoa}">
                                        <h2><xsl:value-of select="Nome" /></h2>
                                        <p><strong><xsl:value-of select="Regiao" /></strong></p>
										<p><xsl:value-of select="Paroquia" /> - <xsl:value-of select="Bairro" /></p>
										<p class="ui-li-aside"><strong><xsl:value-of select="Classe" /></strong></p>
										</a>
									</li>
								</xsl:for-each>
							</ul>
					 </div>
					 
					 <div data-role="collapsible">
						<h2>Candidatos (<xsl:value-of select="count(//ROWSET/CANDIDATO)"/>)</h2>
							<ul data-role="listview" data-filter="true" data-filter-theme="a" data-divider-theme="b">
								<xsl:for-each select="ROWSET/CANDIDATO">
									<li>
										<a href="ExibePessoa.xsql?IdPessoa={IdPessoa}">
                                        <h2><xsl:value-of select="Nome" /></h2>
                                        <p><strong><xsl:value-of select="Regiao" /></strong></p>
										<p><xsl:value-of select="Paroquia" /> - <xsl:value-of select="Bairro" /></p>
										<p class="ui-li-aside"><strong><xsl:value-of select="Classe" /></strong></p>
										</a>
									</li>
								</xsl:for-each>
							</ul>
					 </div>
					 
					 <div data-role="collapsible">
						<h2>Vocacionados (<xsl:value-of select="count(//ROWSET/VOCACIONADO)"/>)</h2>
							<ul data-role="listview" data-filter="true" data-filter-theme="a" data-divider-theme="b">
								<xsl:for-each select="ROWSET/VOCACIONADO">
									<li>
										<a href="ExibePessoa.xsql?IdPessoa={IdPessoa}">
                                        <h2><xsl:value-of select="Nome" /></h2>
                                        <p><strong><xsl:value-of select="Regiao" /></strong></p>
										<p><xsl:value-of select="Paroquia" /> - <xsl:value-of select="Bairro" /></p>
										<p class="ui-li-aside"><strong><xsl:value-of select="Classe" /></strong></p>
										</a>
									</li>
								</xsl:for-each>
							</ul>
					 </div>
					 
					 <div data-role="collapsible">
						<h2>Inativos (<xsl:value-of select="count(//ROWSET/INATIVO)"/>)</h2>
							<ul data-role="listview" data-filter="true" data-filter-theme="a" data-divider-theme="b">
								<xsl:for-each select="ROWSET/INATIVO">
									<li>
										<a href="ExibePessoa.xsql?IdPessoa={IdPessoa}">
                                        <h2><xsl:value-of select="Nome" /></h2>
                                        <p><strong><xsl:value-of select="Regiao" /></strong></p>
										<p><xsl:value-of select="Paroquia" /> - <xsl:value-of select="Bairro" /></p>
										<p class="ui-li-aside"><strong><xsl:value-of select="Classe" /></strong></p>
										</a>
									</li>
								</xsl:for-each>
							</ul>
					 </div>
					</div> 
					   
                       
                    </div>

                    <!-- Rodapé -->
                    <div data-role="footer" data-position="fixed">
                        <h4>Sistema de Cadastro - CAD</h4>
                    </div>
                </div>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>