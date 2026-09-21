<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <xsl:template match="/">
    <html>
    <head>
      <title>Consulta Dinâmica</title>
      <meta name="viewport" content="width=device-width, initial-scale=1"/>
      <link rel="stylesheet"
        href="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.css" />
      <script src="https://code.jquery.com/jquery-1.11.1.min.js"></script>
      <script src="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.js"></script>
	  
	    <style>
    .linha-campo {
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .linha-campo .ui-checkbox {
      margin: 0;
    }

    .linha-campo input[type="text"] {
      flex: 1;
    }
  </style>
  
    </head>
    <body>
      <div data-role="page" id="pageConsulta">
        <div data-role="header">
          <h1>Consulta Dinâmica</h1>
        </div>
        <div role="main" class="ui-content">
          <form method="get" action="executaConsulta.jsp">
            
			 <!-- Cabeçalho -->
            <fieldset>
              <legend>Dados do Relatorio</legend>
			  <label>Titulo do Relatorio:</label>
                <input type="text" name="titulo" />
				
			<label>
			<input type="checkbox" name="exibe_linha"/>Exibe número da linha
			</label>
			
			<label>
			<input type="checkbox" name="exibe_total"/>Exibe Total de Registros
			</label>	
			
			<label>
			<input type="checkbox" name="exibe_data"/>Exibe Data do Relatorio
			</label>	
			
			<label>
			<input type="checkbox" name="exibe_grade"/>Exibe linhas de grade da tabela
			</label>	
			
			<label>
			<input type="checkbox" name="lista_zebrada"/>Exibe linhas da tabela zebradas
			</label>	
			
			  
            </fieldset>
			
			
			
			
            <!-- Seleção de Campos -->
            <fieldset data-role="controlgroup">
              <legend>Selecione os Campos:</legend>
              <xsl:for-each select="/colunas/coluna">
                <label>
                  <input type="checkbox" name="campos" value="{column_name}" />
                  <xsl:value-of select="column_name"/>
                </label>
              </xsl:for-each>
            </fieldset>

            <!-- Filtros Dinâmicos -->
            <fieldset>
              <legend>Filtros (opcionais)</legend>
              <xsl:for-each select="/colunas/coluna">
               		  
			  
			  <div class="linha-campo">
				<input type="checkbox" name="grp_{column_name}" id="grp_{column_name}"/>
				<label for="grp_{column_name}"> <xsl:value-of select="column_name"/> : </label>

				<input type="text"
               name="filtro_{column_name}"
               id="filtro_{column_name}"
               placeholder="Digite o filtro"/>
			</div>
	  
			  
			  </xsl:for-each>
            </fieldset>
 


            <input type="submit" value="Executar Consulta"/>
          </form>
        </div>
      </div>
    </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
