<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="html" indent="yes" encoding="UTF-8"/>

<xsl:template match="/">

<html>
<head>

<title>Paróquias</title>

<meta name="viewport" content="width=device-width, initial-scale=1"/>

<link rel="stylesheet" href="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.css"/>
<script src="https://code.jquery.com/jquery-1.11.3.min.js"></script>
<script src="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.js"></script>

<script>

$(document).on("pagecreate", "#pageParoquias", function(){

    $("#busca").on("keyup", function(){

        var valor = $(this).val().toLowerCase();

        $("#tabelaParoquias tbody tr").filter(function(){

            $(this).toggle($(this).text().toLowerCase().indexOf(valor) > -1);

        });

    });

});

</script>

</head>

<body>

<div data-role="page" id="pageParoquias">

<div data-role="header" data-position="fixed">
   <a href="../auto/paginaFoto.jsp" class="ui-btn-left ui-btn ui-btn-inline ui-mini ui-corner-all ui-btn-icon-left ui-icon-back">Voltar</a>
   <h1>Paróquias e Regiões</h1>
</div>

<div role="main" class="ui-content">

<label for="busca">Buscar:</label>
<input type="text" id="busca" placeholder="Digite para pesquisar..."/>

<table data-role="table" 
       id="tabelaParoquias" 
       data-mode="reflow" 
       class="ui-responsive table-stroke">

<thead>
<tr>
<th>ID</th>
<th>Paróquia</th>
<th>Cidade</th>
<th>Bairro</th>
<th>Estado</th>
<th>Região</th>
</tr>
</thead>

<tbody>

<xsl:for-each select="ROWSET/ROW">

<tr>

<td>
<xsl:value-of select="IdParoquia"/>
</td>

<td>
<xsl:value-of select="Descricao"/>
</td>

<td>
<xsl:value-of select="Cidade"/>
</td>

<td>
<xsl:value-of select="Bairro"/>
</td>

<td>
<xsl:value-of select="Estado"/>
</td>

<td>
<xsl:value-of select="Regiao"/>
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