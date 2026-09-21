<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="html" encoding="UTF-8"/>

<xsl:template match="SQL">

<html>
<head>
    <title>Lista de Encontros</title>
    <link rel="stylesheet" href="../jquery/jquery.mobile-1.4.5.min.css"/>
				<script src="../jquery/jquery.min.js"></script>
				<script src="../jquery/jquery.mobile-1.4.5.min.js"></script>
</head>
<body>

<div data-role="page" id="editar">
	<div data-role="header" data-position="fixed">
		<a href="encontros.xsql?cmd=listEncontros" class="ui-btn-left ui-btn ui-btn-inline ui-mini ui-corner-all ui-btn-icon-left ui-icon-back">Voltar</a>
		<h1>Novo Evento</h1>
		<a href="#" onclick="$('#formencontros').submit();" class="ui-btn-right ui-btn ui-btn-inline ui-mini ui-corner-all ui-btn-icon-left ui-icon-check">Salvar</a>
	</div>
	<div role="main" class="ui-content">
	 <form action="encontros.xsql" id="formencontros"  method="get">
                    <input type="hidden" name="IdEncontro" value="0"/>
					<input type="hidden" name="classe" value="{request/parameters/classe}"/>
					<input type="hidden" name="Ano" value="{request/parameters/Ano}"/>
					<input type="hidden" name="Mes" value="{request/parameters/Mes}"/>
					<input type="hidden" name="cmd" value="listEncontros"/>

                    <label for="Classe">Classe:</label>
						<select name="Classe" id="Classe">
							<option value="1">Diáconos</option>
							<option value="2">Candidatos</option>
							<option value="3">Vocacionados</option>
						</select> <br/>

                    <label>Descrição:</label>
                    <input type="text" name="Descricao" value="" /><br/>

                    <label>Data do Encontro:</label>
                    <input type="date" name="DtEncontro" value="" /><br/>

                    <label>Detalhe:</label>
                    <textarea name="Detalhe"></textarea><br/>

                    <label>Esposa Participa:</label>
                    <select name="flgEsposa">
                        <option value="0">Não</option>
                        <option value="1">Sim</option>
                    </select><br/>

                    <label>Local:</label>
                    <input type="text" name="Local" value="" /><br/>
					
					<div class="ui-grid-a">
						<div class="ui-block-a">
							<label for="Latitude">Latidude</label>
							<input type="text" id="Latitude"/>
						</div>
						<div class="ui-block-b">
							<label for="Longitude">Longitude</label>
							<input type="text" id="Longitude"/>
						</div>
					</div>

                    <button type="submit">Salvar</button>
                </form>
	
	</div>
	
	<div data-role="footer" data-position="fixed">
		<h4>Informações de Encontros</h4>
	</div>	

</div>



</body>
</html>

</xsl:template>
</xsl:stylesheet>
