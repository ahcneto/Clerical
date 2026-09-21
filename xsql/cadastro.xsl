<?xml version="1.0" encoding="UTF-8"?>
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
					<a href="ExibePessoa.xsql?IdPessoa={Pessoas/Pessoa/IdPessoa}" class="ui-btn-left ui-btn ui-btn-inline ui-mini ui-corner-all ui-btn-icon-left ui-icon-back">Voltar</a>
                        <h1>Cadastro de Pessoas</h1>
					<a href="../jsp/upload.jsp?IdPessoa={Pessoas/Pessoa/IdPessoa}" class="ui-btn-right ui-btn ui-btn-inline ui-mini ui-corner-all ui-btn-icon-left ui-icon-user">Foto</a>
                    </div>

                    <!-- Conteúdo -->
                    <div data-role="content">
                        <!-- Formulário de Cadastro -->
                        <form id="formCadastro" action="salvarPessoa.jsp" method="post">
                            <input type="text" name="IdPessoa" value="{Pessoas/Pessoa/IdPessoa}" />

                            <label for="Nome">Nome:</label>
                            <input type="text" name="Nome" id="Nome" value="{Pessoas/Pessoa/Nome}" />

                            <label for="DtNascimento">Data de Nascimento:</label>
                            <input type="date" name="DtNascimento" id="DtNascimento" value="{Pessoas/Pessoa/DtNascimento}" />

                            <label for="Fone1">Telefone:</label>
                            <input type="tel" name="Fone1" id="Fone1" value="{Pessoas/Pessoa/Fone1}" />

                            <label for="Email">Email:</label>
                            <input type="email" name="Email" id="Email" value="{Pessoas/Pessoa/Email}" />

                            <label for="Endereco">Endereço:</label>
                            <input type="text" name="Endereco" id="Endereco" value="{Pessoas/Pessoa/Endereco}" />

                            <label for="Profissao">Profissão:</label>
                            <input type="text" name="Profissao" id="Profissao" value="{Pessoas/Pessoa/Profissao}" />

                            <label for="NomeEsposa">Nome da Esposa:</label>
                            <input type="text" name="NomeEsposa" id="NomeEsposa" value="{Pessoas/Pessoa/NomeEsposa}" />
							
							 <label for="DtNascEsposa">Data de Nascimento da Esposa:</label>
                            <input type="date" name="DtNascEsposa" id="DtNascEsposa" value="{Pessoas/Pessoa/DtNascEsposa}" />
							<label for="ProfissaoEsposa">Profissão da Esposa:</label>
                            <input type="text" name="ProfissaoEsposa" id="ProfissaoEsposa" value="{Pessoas/Pessoa/ProfissaoEsposa}" />

                            <label for="DtCasamento">Data de Casamento:</label>
                            <input type="date" name="DtCasamento" id="DtCasamento" value="{Pessoas/Pessoa/DtCasamento}" />
						<div class="ui-field-contain">

                            <label for="IdParoquia">Paróquia:</label>
                            <select name="IdParoquia" id="IdParoquia" data-native-menu="false" class="filterable-select" >
								<xsl:for-each select="Paroquias/Paroquia">
									<option value="{IdParoquia}">
									 <xsl:if test="IdParoquia = ../../Pessoas/Pessoa/IdParoquia">
									<xsl:attribute name="selected">selected</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="Descricao" /> - <xsl:value-of select="Bairro" /> - <xsl:value-of select="Cidade" />
							    </option>
								</xsl:for-each>
					
							</select>
							</div>

                            <label for="Pastoral">Pastoral:</label>
                            <input type="text" name="Pastoral" id="Pastoral" value="{Pessoas/Pessoa/Pastoral}" />

                            <button type="submit" data-theme="b">Salvar</button>
                        </form>

                     
                    </div>

                    <!-- Rodapé -->
                    <div data-role="footer" data-position="fixed">
                        <h4>Sistema de Cadastro</h4>
                    </div>
                </div>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>