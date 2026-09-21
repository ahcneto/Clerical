<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
  <title>Login</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.css" />
  <script src="https://code.jquery.com/jquery-1.11.3.min.js"></script>
  <script src="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.js"></script>
  <style>
    .ui-alert {
        background-color: #fff3cd !important;  /* amarelo claro */
        color: #b71c1c !important;             /* vermelho */
        border: 1px solid #f5c2c7 !important; 
        border-radius: 8px !important;
        padding: 12px !important;
    }
    .ui-alert h3 {
        margin: 0 0 6px 0;
        font-size: 18px;
        font-weight: bold;
    }
    .ui-alert p {
        margin: 0;
        font-size: 14px;
    }
</style>
  
</head>
<body>
  <div data-role="page" id="pageLogin">
    <div data-role="header"><h1>Login</h1></div>
    <div data-role="content">
	
	 <center><img src="../img/clerical.jpg" alt="Logo" style="width: 200px; height: auto;"> </center>
	 
      <form action="validaLogin.jsp" method="post">
<%   

    if (session != null) {
        session.invalidate();
    }
	
HttpSession sessao = request.getSession();
	
String erro = request.getParameter("erro") != null ? request.getParameter("erro") : "0";
String hash = request.getParameter("hash") != null ? request.getParameter("hash") : "0";
sessao.setAttribute("hash",hash);

if (erro.equals("2")){
%>	  
	<div class="ui-body ui-body-a ui-corner-all ui-alert">
		<h3>Erro:</h3>
			<p> Usuário ou Senha incorretos. Verifique se o formato informado está correto.</p>
	</div>
<br>	  
<%
} else if (erro.equals("GetSession")){
%>	
	
	<div class="ui-body ui-body-a ui-corner-all ui-alert">
		<h3>Erro:</h3>
			<p>Sua sessão expirou. Realize login novamente</p>
	</div>
<br>	  
<%
} 
%>	  
		
        <label>Telefone (apenas números):</label>
        <input type="text" name="fone1" required>
                
	<div class="ui-field-contain">
  <legend>Data de Nascimento (DD/MM/AAAA):</legend>
	<fieldset data-role="controlgroup" data-type="horizontal">
		
		<label for="dia">Dia</label>
            <select name="dia" id="dia">
                <option value="">Dia</option>
            </select>
		<label for="Mês">Mes</label>
            <select name="mes" id="mes">
                <option value="">Mês</option>
                <option value="01">Jan</option>
                <option value="02">Fev</option>
                <option value="03">Mar</option>
                <option value="04">Abr</option>
                <option value="05">Mai</option>
                <option value="06">Jun</option>
                <option value="07">Jul</option>
                <option value="08">Ago</option>
                <option value="09">Set</option>
                <option value="10">Out</option>
                <option value="11">Nov</option>
                <option value="12">Dez</option>
            </select>
		<label for="Ano">Ano</label>
            <select name="ano" id="ano">
                <option value="">Ano</option>
            </select>
</fieldset>


	
	</div>
	 
  	    <input type="hidden" name="latitude" id="latitude">
        <input type="hidden" name="longitude" id="longitude">
	  
        <input type="submit" value="Entrar" class="ui-btn ui-btn-b">
      </form>
    </div>
  </div>
  
  
<script>
function getParametro(nome) {
  const urlParams = new URLSearchParams(window.location.search);
  return urlParams.get(nome);
}

$(document).on("pageinit", "#pageLogin", function () {

  $("#idUsuario").val(getParametro("idUsuario"));
  $("#nome").text(getParametro("nome"));
  $("#dataEvento").text(getParametro("dataEvento"));
  $("#localEvento").text(getParametro("localEvento"));
  $("#descricaoEvento").text(getParametro("descricaoEvento"));

  // Captura localização
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(
      function (pos) {
        $("#latitude").val(pos.coords.latitude);
        $("#longitude").val(pos.coords.longitude);
      },
      function () {
        alert("Não foi possível obter sua localização.");
      }
    );
  } else {
    alert("Geolocalização não suportada.");
  }

});


$(document).on("pagecreate", function () {

    // Preencher dias
    for (var d = 1; d <= 31; d++) {
        var dia = (d < 10 ? "0" + d : d);
        $("#dia").append('<option value="' + dia + '">' + dia + '</option>');
    }

    // Preencher anos
    var anoAtual = new Date().getFullYear();
    for (var a = anoAtual; a >= 1950; a--) {
        $("#ano").append('<option value="' + a + '">' + a + '</option>');
    }

    // Atualizar selects do jQuery Mobile
    $("#dia").selectmenu("refresh");
    $("#ano").selectmenu("refresh");

});
</script>

</body>
</html>
