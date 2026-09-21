<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <xsl:template match="/">
        <html>
            <head>
			
			  <link rel="stylesheet" href="../jquery/jquery.mobile-1.4.5.min.css"/>
				<script src="../jquery/jquery.min.js"></script>
				<script src="../jquery/jquery.mobile-1.4.5.min.js"></script>
				
                <title>Ficha Cadastral</title>
                <style>
                    * {
                        margin: 0;
                        padding: 0;
                        box-sizing: border-box;
                    }
                    body {
                        font-family: Arial, sans-serif;
                        background-color: #f4f4f4;
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        height: 100vh;
                        padding: 20px;
                    }
                    .container {
                        width: 90%;
                        max-width: 1200px;
                        background: white;
                        padding: 20px;
                        border-radius: 8px;
                        box-shadow: 2px 2px 8px rgba(0,0,0,0.2);
                    }
                    .titulo {
                        font-size: 28px;
                        font-weight: bold;
                        text-align: center;
                        margin-bottom: 20px;
                        color: #333;
                    }
                    .grid {
                        display: grid;
                        grid-template-columns: repeat(2, 1fr);
                        gap: 15px;
                    }
                    .campo {
                        font-size: 16px;
                        padding: 10px;
                        background: #f9f9f9;
                        border-radius: 5px;
                    }
                    .campo span {
                        font-weight: bold;
                        color: #444;
                    }
                    .secao {
                        grid-column: span 2;
                        font-size: 18px;
                        font-weight: bold;
                        color: #222;
                        margin-top: 20px;
                        padding-top: 10px;
                        border-top: 2px solid #ccc;
                    }
                </style>
            </head>
            <body>
			
			 <div data-role="page">
                    <!-- Cabeçalho -->
                    <div data-role="header">
                        <h1>Cadastro de Pessoas</h1>
                    </div>
					
                <div class="container">
                    <div class="titulo">Dados Cadastrais</div>
                    
                    <xsl:for-each select="SQL/ROWSET/ROW">
                        <div class="grid">
                            <div class="campo"><span>ID:</span> <xsl:value-of select="IdPessoa"/></div>
                            <div class="campo"><span>Nome:</span> <xsl:value-of select="Nome"/></div>
                            <div class="campo"><span>Data de Nascimento:</span> <xsl:value-of select="DtNascimento"/></div>
                            <div class="campo"><span>Telefone:</span> <xsl:value-of select="Telefone"/></div>
                            <div class="campo"><span>Email:</span> <xsl:value-of select="Email"/></div>
                            <div class="campo"><span>Endereço:</span> <xsl:value-of select="Endereco"/></div>
                            <div class="campo"><span>Profissão:</span> <xsl:value-of select="Profissao"/></div>

                            <div class="secao">Informações Familiares</div>
                            <div class="campo"><span>Nome da Esposa:</span> <xsl:value-of select="NomeEsposa"/></div>
                            <div class="campo"><span>Data de Casamento:</span> <xsl:value-of select="DtCasamento"/></div>

                            <div class="secao">Informações Religiosas</div>
                            <div class="campo"><span>ID Paróquia de Origem:</span> <xsl:value-of select="IdParoquiaOrigem"/></div>
                            <div class="campo"><span>Pastoral:</span> <xsl:value-of select="Pastoral"/></div>
                            <div class="campo"><span>Classe:</span> <xsl:value-of select="Classe"/></div>
                            <div class="campo"><span>Teologia:</span> <xsl:if test="flgTeologia=1">Sim</xsl:if><xsl:if test="flgTeologia=0">Não</xsl:if></div>
                            <div class="campo"><span>Ordem Sacra:</span> <xsl:if test="flgOrdemSacra=1">Sim</xsl:if><xsl:if test="flgOrdemSacra=0">Não</xsl:if></div>
                            <div class="campo"><span>Leitor:</span> <xsl:if test="flgLeitor=1">Sim</xsl:if><xsl:if test="flgLeitor=0">Não</xsl:if></div>
                            <div class="campo"><span>Acólito:</span> <xsl:if test="flgAcolito=1">Sim</xsl:if><xsl:if test="flgAcolito=0">Não</xsl:if></div>
                        </div>
                    </xsl:for-each>
                </div>
			</div>	
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>
