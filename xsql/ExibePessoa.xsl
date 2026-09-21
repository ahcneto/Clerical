<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="html" encoding="UTF-8"/>
    
    <xsl:template match="SQL/ROWSET/ROW">
        <html>
            <head>
			
			  <link rel="stylesheet" href="../jquery/jquery.mobile-1.4.5.min.css"/>
				<script src="../jquery/jquery.min.js"></script>
				<script src="../jquery/jquery.mobile-1.4.5.min.js"></script>
				
				<style>
				
				table {
            width: 100%;
            border-collapse: collapse;
        }
        table th, table td {
            border: 1px solid #ccc;
            padding: 6px;
            text-align: left;
        }
        table th {
            background-color: #f6f6f6;
        }
		
	.presente {
        color: green;
        font-weight: bold;
    }
    .faltou {
        color: red;
        font-weight: bold;
    }
				
				</style>
				
                <title>Ficha Cadastral</title>
               
            </head>	
			
            <body>
			
			 <div data-role="page">
                    <div data-role="header" data-position="fixed">
					<a href="PesquisaPessoa.xsql" class="ui-btn-left ui-btn ui-btn-inline ui-mini ui-corner-all ui-btn-icon-left ui-icon-back">Voltar</a>
						<h1>Ficha Cadastral</h1>
					
					<xsl:if test="//request/session/Profile = 'ADM' ">					
						<a href="cadastro.xsql?IdPessoa={IdPessoa}" class="ui-btn-right ui-btn ui-btn-inline ui-mini ui-corner-all ui-btn-icon-left ui-icon-edit">Editar</a>
				    </xsl:if>
					</div>
                    <div data-role="content">
                        <xsl:for-each select=".">
                            
							<!-- Dados Pessoais com foto ao lado -->
							 <h3>Dados Pessoais</h3>
                            <div class="ui-grid-a">
                                <div class="ui-block-a">
                                    <!-- Informações Pessoais -->
                                    <p><strong>ID:</strong> <xsl:value-of select="IdPessoa"/>   
									<xsl:if test="Status=0">- AFASTADO</xsl:if>
									</p>
                                    <p><strong>Nome:</strong> <xsl:value-of select="Nome"/></p>
                                    <p><strong>Data de Nascimento:</strong> <xsl:value-of select="DtNascimento"/> - Idade: <strong><xsl:value-of select="Idade"/>  anos</strong> </p>
                                    <p><strong>Telefone:</strong> <xsl:value-of select="Fone1"/> / <xsl:value-of select="Fone2"/></p>
                                    <p><strong>Email:</strong> <xsl:value-of select="Email"/></p>
                                    <p><strong>Endereço:</strong> <xsl:value-of select="Endereco"/></p>
                                    <p><strong>Profissão:</strong> <xsl:value-of select="Profissao"/></p>
									<xsl:if test="Classe=1">
									<p><strong>Data Ordenação :</strong> <xsl:value-of select="DtOrdenacao"/></p>
									</xsl:if>
									<p><strong>Observação :</strong> <xsl:value-of select="Obs"/></p>
									
                                </div>
								<div class="ui-block-b">
                                    <!-- Imagem (Foto) -->
                                    <img src="../fotos/foto_{IdPessoa}.jpg" alt="Foto" style="max-width: 250px; max-height: 250px;" />
                                </div>
                            </div>
							<!--
							<div data-role="collapsible" data-collapsed="false">
                                <h3>Dados Pessoais</h3>
                                <p><strong>ID:</strong> <xsl:value-of select="IdPessoa"/></p>
                                <p><strong>Nome:</strong> <xsl:value-of select="Nome"/></p>
                                <p><strong>Data de Nascimento:</strong> <xsl:value-of select="DtNascimento"/></p>
                                <p><strong>Telefone:</strong> <xsl:value-of select="Telefone"/></p>
                                <p><strong>Email:</strong> <xsl:value-of select="Email"/></p>
                                <p><strong>Endereço:</strong> <xsl:value-of select="Endereco"/></p>
                                <p><strong>Profissão:</strong> <xsl:value-of select="Profissao"/></p>
                            </div>
							-->
                            <div data-role="collapsible">
                                <h3>Informações Familiares</h3>
                                <p><strong>Nome da Esposa:</strong> <xsl:value-of select="NomeEsposa"/></p>
								<p><strong>Profissão da Esposa:</strong> <xsl:value-of select="ProfissaoEsposa"/></p>
								<p><strong>Data de Nascimento Esposa:</strong> <xsl:value-of select="DtNascEsposa"/></p>
                                <p><strong>Data de Casamento:</strong> <xsl:value-of select="DtCasamento"/></p>
                            </div>

                            <div data-role="collapsible">
                                <h3>Informações do Candidato</h3>
                                <p><strong>Etapa:</strong> <xsl:value-of select="Etapa"/></p>
								<div class="ui-grid-c">
									<div class="ui-block-a">
										<p><strong>Concluiu Teologia:</strong> <xsl:if test="flgTeologia=1">Sim</xsl:if><xsl:if test="flgTeologia=0">Não</xsl:if></p>
									</div>
									<div class="ui-block-b">
										<p><strong>Adm. Ordens Sacras:</strong> <xsl:if test="flgOrdemSacra=1">Sim</xsl:if><xsl:if test="flgOrdemSacra=0">Não</xsl:if></p>	
									</div>
									<div class="ui-block-c">
										 <p><strong>Ministério de Leitor:</strong> <xsl:if test="flgLeitor=1">Sim</xsl:if><xsl:if test="flgLeitor=0">Não</xsl:if></p>	
									</div>
									<div class="ui-block-d">
										 <p><strong>Ministério de Acólito:</strong> <xsl:if test="flgAcolito=1">Sim</xsl:if><xsl:if test="flgAcolito=0">Não</xsl:if></p>	
									</div>
																		
								</div>
																
								<div class="ui-grid-a">
									<div class="ui-block-a">								
										<p><strong>Paróquia: </strong> <xsl:value-of select="Paroquia"/> - <xsl:value-of select="Bairro"/></p>
									</div>
									<div class="ui-block-b">
										<p><strong>Região: </strong> <xsl:value-of select="Regiao"/></p>	
									</div>
								
								</div>
                                <p><strong>Pastoral: </strong> <xsl:value-of select="Pastoral"/></p>
                          
                            </div>
                        </xsl:for-each>
						 <div data-role="collapsible">
                            <h3>Registro de Presença</h3>

							 
							 
							 <table data-role="table" class="ui-responsive">
								<thead>
									<tr>
										<th>Data</th>
										<th>Descrição</th>
										<th>Local</th>
										<th>Presença</th>
										<th>Distancia</th>
										<th>Justificativa</th>
									</tr>
								</thead>
								<tbody>
								<xsl:for-each select="../../ENCONTROS/ENCONTRO">
									
									<tr>
										<td><xsl:value-of select="DtEncontro"/></td>
										<td><xsl:value-of select="Descricao"/></td>
										<td><xsl:value-of select="Local"/></td>
										<td>
										<xsl:attribute name="class"><xsl:value-of select="Presenca"/></xsl:attribute>
										<xsl:value-of select="Presenca"/></td>
										<td><xsl:value-of select="distancia"/> m </td>
										<td><xsl:value-of select="Justificativa"/> 
										
										<xsl:if test="//request/session/Profile = 'ADM' and Presenca != 'Presente' and normalize-space(Justificativa) = ''">	
											<a href="#PresencaDialog_{IdEncontro}" data-rel="popup" data-position-to="window" data-transition="pop" class="ui-btn ui-mini ui-btn-inline ui-corner-all ui-shadow ui-icon-check ui-btn-icon-left ui-btn-a">Confirmar Presença</a>
											<a href="#justificarDialog_{IdEncontro}" data-rel="popup" data-position-to="window" data-transition="pop" class="ui-btn ui-mini ui-btn-inline ui-corner-all ui-shadow ui-icon-comment ui-btn-icon-left ui-btn-a">Justificar Ausência</a>
										</xsl:if>
										
										</td>
									</tr>
								
								<div data-role="popup" id="justificarDialog_{IdEncontro}" data-overlay-theme="a" data-theme="a" data-dismissible="false" style="max-width:400px;">
									<div data-role="header" data-theme="a">
									<h1>Justificar Ausência</h1>
									</div>


									<div role="main" class="ui-content" >
									<h3 class="ui-title">Justificativa da ausência</h3>
									<p><xsl:value-of select="Descricao"/></p>

									<form method="get" action="salvarJustificativa.jsp" id="formJustificativa_{IdEncontro}">

										  <!-- Campos ocultos -->
										  <input type="hidden" name="IdPessoa" id="IdPessoa" value="{IdPessoa}"/>
										  <input type="hidden" name="IdEncontro" id="IdEncontro" value="{IdEncontro}"/>
										   <input type="hidden" name="flgPresenca" id="flgPresenca" value="0"/>
										 <textarea cols="40" rows="8" name="Justificativa" id="Justificativa"></textarea>
										 <input type="hidden" name="IdUsuario" id="IdUsuario" value="{//request/session/idLogin}"/>
										   
										   <a href="#" class="ui-btn ui-corner-all ui-shadow ui-btn-inline ui-btn-a" data-rel="back">Cancela</a>
											<button type="submit" class="ui-btn ui-btn-b ui-btn-inline ui-corner-all">
											Confirma
											</button>
											
										</form>
									</div>
									

									</div>
									
									<div data-role="popup" id="PresencaDialog_{IdEncontro}" data-overlay-theme="a" data-theme="a" data-dismissible="false" style="max-width:400px;">
									<div data-role="header" data-theme="a">
									<h1>Registrar Presença</h1>
									</div>


									<div role="main" class="ui-content" >
									<h3 class="ui-title">Registrar Presença</h3>
									<p><xsl:value-of select="Descricao"/></p>

									<form method="get" action="salvarJustificativa.jsp" id="formPresenca_{IdEncontro}">

										  <!-- Campos ocultos -->
										  <input type="hidden" name="IdPessoa" id="IdPessoa" value="{IdPessoa}"/>
										  <input type="hidden" name="IdEncontro" id="IdEncontro" value="{IdEncontro}"/>
										  <input type="hidden" name="flgPresenca" id="flgPresenca" value="1"/>
										  <input type="hidden" name="IdUsuario" id="IdUsuario" value="{//request/session/idLogin}"/>
										   
										   <a href="#" class="ui-btn ui-corner-all ui-shadow ui-btn-inline ui-btn-a" data-rel="back">Cancela</a>
											<button type="submit" class="ui-btn ui-btn-b ui-btn-inline ui-corner-all">
											Confirma
											</button>
											
										</form>
									</div>
									

									</div>
								
								
									</xsl:for-each>
								</tbody>
							</table>
							 
							 
							 
								
						</div>
						
						
                    </div>
                    <div data-role="footer" data-position="fixed">
                        <h4>Informações de Cadastro</h4>
                    </div>
                </div>
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>