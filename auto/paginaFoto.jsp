<%@ page import="java.sql.*, java.net.URLEncoder" %>
<%@ page contentType="text/html;charset=UTF-8" %>

<%! 
// =======================================================
// FUNÇÃO HAVERSINE
// =======================================================
public static double distanciaEmMetros(
    double lat1, double lon1,
    double lat2, double lon2) {

    final int R = 6371000;

    double dLat = Math.toRadians(lat2 - lat1);
    double dLon = Math.toRadians(lon2 - lon1);

    double a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(Math.toRadians(lat1)) *
        Math.cos(Math.toRadians(lat2)) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);

    double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
}
%>

<%
/* =======================================================
   1️⃣ VALIDAÇÃO DE SESSÃO
======================================================= */
HttpSession sessao = request.getSession(false);

if (sessao == null || sessao.getAttribute("idLogin") == null) {
    response.sendRedirect("login.jsp?erro=GetSession");
    return;
}

Integer idLogin = (Integer) sessao.getAttribute("idLogin");
String profile = (String) sessao.getAttribute("Profile");

Double latUsuarioObj = (Double) sessao.getAttribute("latUsuario");
Double lonUsuarioObj = (Double) sessao.getAttribute("lonUsuario");

double latUsuario = latUsuarioObj != null ? latUsuarioObj : 0.0;
double lonUsuario = lonUsuarioObj != null ? lonUsuarioObj : 0.0;

/* =======================================================
   2️⃣ VARIÁVEIS
======================================================= */

String nome = "";
String classe = "";
String idClasse = "";
String dtNascimento = "";
String dtOrdenacao = "";
String paroquia = "";
String bairro = "";
String regiao = "";
String presenca = "0 %";
String dataUltimoEncontro = "";

int encontroAtual = 0;
String descricaoEncontro = "";
double latEncontro = 0.0;
double lonEncontro = 0.0;
double distancia = 0.0;

/* =======================================================
   3️⃣ CONEXÃO PRINCIPAL
======================================================= */
Connection con = null;

try {
    con = cad.db.Database.getConnection();

    /* ================= UPDATE PRESENÇA ================= */

    String idEncontroParam = request.getParameter("idEncontroUpd");
	String justificativa = request.getParameter("justificativa");
	String flgPresenca = request.getParameter("flgPresenca");

    if (idEncontroParam != null && !idEncontroParam.isEmpty()) {

        try {
            int idEncontroUpdate = Integer.parseInt(idEncontroParam);
			int flgPresencaUpd = Integer.parseInt(flgPresenca);

            latEncontro = Double.parseDouble(
                request.getParameter("latEncontro") != null ?
                request.getParameter("latEncontro") : "0"
            );

            lonEncontro = Double.parseDouble(
                request.getParameter("lonEncontro") != null ?
                request.getParameter("lonEncontro") : "0"
            );

            if(latUsuario != 0 && latEncontro != 0){
                distancia = distanciaEmMetros(
                    latUsuario, lonUsuario,
                    latEncontro, lonEncontro
                );
            }

            //if(distancia <= 100){
                String cmd = "UPDATE participanteEncontro " +
                        "SET flgPresenca=?, justificativa=? , data_atualizacao=NOW(), " +
                        "latPessoa=?, lonPessoa=?, distancia=? " +
                        "WHERE IdEncontro=? AND IdPessoa=?";

                PreparedStatement stmtUpd = con.prepareStatement(cmd);
				stmtUpd.setInt(1, flgPresencaUpd);
				stmtUpd.setString(2,justificativa);
                stmtUpd.setDouble(3, latUsuario);
                stmtUpd.setDouble(4, lonUsuario);
                stmtUpd.setDouble(5, distancia);
                stmtUpd.setInt(6, idEncontroUpdate);
                stmtUpd.setInt(7, idLogin);
                stmtUpd.executeUpdate();
                stmtUpd.close();
            //}

        } catch (Exception e) {
            out.println("Erro ao atualizar presença: " + e.getMessage());
        }
    }

    /* ================= SELECT DADOS PESSOA ================= */

    String sqlPessoa = "SELECT p.Nome, p.Classe AS idClasse, " +
            "CASE p.Classe WHEN 1 THEN 'Diácono' WHEN 2 THEN 'Candidato' WHEN 3 THEN 'Vocacionado' END AS Classe, " +
            "DATE_FORMAT(p.DtNascimento,'%d/%m/%Y') AS DtNascimento, " +
            "DATE_FORMAT(p.DtOrdenacao,'%d/%m/%Y') AS DtOrdenacao, " +
            "p2.Descricao as Paroquia, p2.Bairro, p2.Regiao, " +
            "ROUND(100.0 * SUM(CASE WHEN pe.flgPresenca=1 THEN 1 ELSE 0 END)/COUNT(pe.IdEncontro),2) AS PercentualParticipacao, " +
            "DATE_FORMAT(MAX(CASE WHEN pe.flgPresenca=1 THEN e.DtEncontro END),'%d/%m/%Y') AS UltimaPresenca " +
            "FROM pessoas p " +
            "LEFT JOIN participanteEncontro pe ON p.IdPessoa=pe.IdPessoa " +
            "LEFT JOIN Encontros e ON pe.IdEncontro=e.IdEncontro " +
            "LEFT JOIN paroquia p2 ON p.IdParoquia=p2.IdParoquia " +
            "WHERE p.IdPessoa=? GROUP BY p.IdPessoa";

    PreparedStatement stmtPessoa = con.prepareStatement(sqlPessoa);
    stmtPessoa.setInt(1, idLogin);
    ResultSet rsPessoa = stmtPessoa.executeQuery();

    if(rsPessoa.next()){
        nome = rsPessoa.getString("Nome");
        classe = rsPessoa.getString("Classe");
        idClasse = rsPessoa.getString("idClasse");
        dtNascimento = rsPessoa.getString("DtNascimento");
        dtOrdenacao = rsPessoa.getString("DtOrdenacao");
        paroquia = rsPessoa.getString("Paroquia");
        bairro = rsPessoa.getString("Bairro");
        regiao = rsPessoa.getString("Regiao");
        presenca = rsPessoa.getString("PercentualParticipacao") + " %";
        dataUltimoEncontro = rsPessoa.getString("UltimaPresenca");
    }

    rsPessoa.close();
    stmtPessoa.close();

} catch(Exception e){
    out.println("Erro: " + e.getMessage());
} finally {
    if(con != null) try { con.close(); } catch(Exception e){}
}

String nomeSafe = nome != null ? URLEncoder.encode(nome,"UTF-8") : "";
%>

<%
/* =======================================================
   3️⃣ VERIFICAR ENCONTRO DISPONÍVEL PARA PRESENÇA
======================================================= */

Integer idEncontro = null;
String descricao = null;
String dataEncontro = null;


Connection conEncontro = null;
PreparedStatement stmtEncontro = null;
ResultSet rsEncontro = null;

try {
    conEncontro = cad.db.Database.getConnection();

    String sql2 = "SELECT e.IdEncontro, " +
                  "DATE_FORMAT(e.DtEncontro,'%d/%m/%Y') as DtEncontro, " +
                  "e.Descricao, pe.IdPessoa, pe.flgPresenca, pe.Justificativa, " +
                  "e.latitude, e.longitude " +
                  "FROM Encontros e " +
                  "INNER JOIN participanteEncontro pe ON e.IdEncontro = pe.IdEncontro " +
                  "WHERE e.flgEnviado = 1 AND pe.data_atualizacao is null " +
                  "AND e.Classe = ? " +
                  "AND pe.IdPessoa = ?";

    stmtEncontro = conEncontro.prepareStatement(sql2);
    stmtEncontro.setString(1, idClasse);
    stmtEncontro.setInt(2, idLogin);

    rsEncontro = stmtEncontro.executeQuery();

    if(rsEncontro.next()){

        idEncontro = rsEncontro.getInt("IdEncontro");
        descricao = rsEncontro.getString("Descricao");
        dataEncontro = rsEncontro.getString("DtEncontro");

        latEncontro = rsEncontro.getDouble("latitude");
        lonEncontro = rsEncontro.getDouble("longitude");

        // 🔹 Calcula distância apenas se coordenadas válidas
        if(latUsuario != 0.0 && lonUsuario != 0.0 &&
           latEncontro != 0.0 && lonEncontro != 0.0){

            distancia = distanciaEmMetros(
                    latUsuario, lonUsuario,
                    latEncontro, lonEncontro
            );
        }
    }

} catch(Exception e){
    out.println("Erro ao buscar encontro: " + e.getMessage());
} finally {

    if(rsEncontro != null) try{ rsEncontro.close(); } catch(Exception e){}
    if(stmtEncontro != null) try{ stmtEncontro.close(); } catch(Exception e){}
    if(conEncontro != null) try{ conEncontro.close(); } catch(Exception e){}
}
%>



<!DOCTYPE html>
<html>
<head>
<title>Clerical</title>

<link rel="stylesheet"
href="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.css"/>

<script src="https://code.jquery.com/jquery-1.11.3.min.js"></script>
<script src="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.js"></script>

<style>
.percentual-destaque{font-weight:bold;color:#d9534f;}
.presente{color:green;font-weight:bold;}
.faltou{color:red;font-weight:bold;}
table{width:100%;border-collapse:collapse;}
th,td{padding:6px;border:1px solid #ddd;}
</style>
</head>

<body>

<div data-role="page" class="ui-responsive-panel">

<% if("ADM".equals(profile)){ %>
<div data-role="panel" data-display="overlay" data-theme="b" id="nav-panel">
<ul data-role="listview">
<li data-icon="delete"><a href="#" data-rel="close">Fechar menu</a></li>
<li><a href="../xsql/PesquisaPessoa.xsql">Pessoas</a></li>
<li><a href="../xsql/encontros.xsql?cmd=listEncontros">Encontros</a></li>
<li><a href="../relatorios.html">Relatórios</a></li>
<li><a href="../xsql/paroquias.xsql">Paróquias e Regiões</a></li>
<li><a href="../jsp/dashboard4.jsp">Painel Geral</a></li>
</ul>
</div><!-- /panel -->
<% } %>

<div data-role="header"><h1>Clerical</h1>
<% if("ADM".equals(profile)){ %>
<a href="#nav-panel" data-icon="bars" data-iconpos="notext">Menu</a>
<% } %>

<a href="login.jsp" class="ui-btn-right ui-btn ui-btn-inline ui-mini ui-corner-all ui-btn-icon-left ui-icon-power">Encerrar</a>
</div>

<div role="main" class="ui-content jqm-fullwidth">

 <div class="ui-grid-a">
		<div class="ui-block-a">

<h3><%= nome %></h3>

<p><strong>Nascimento:</strong> <%= dtNascimento %></p>
<p><strong>Classe:</strong> <%= classe %></p>

<% if("1".equals(idClasse)){ %>
<p><strong>Ordenação:</strong> <%= dtOrdenacao %></p>
<% } %>

<p><strong>Paróquia:</strong> <%= paroquia %> - <%= bairro %></p>
<p><strong>Região:</strong> <%= regiao %></p>

<p><strong>Participação:</strong>
<span class="percentual-destaque"><%= presenca %></span></p>

<p><strong>Última Presença:</strong> <%= dataUltimoEncontro %></p>

<br>

</div>
<div class="ui-block-b" style="display:flex;
            flex-direction:column;
            align-items:center;">
	   
<img src="../fotos/foto_<%= idLogin %>.jpg"
style="max-width:250px;max-height:250px;"/>

<br><br>

<form action="uploadArquivo.jsp" method="post">
<input type="hidden" name="idPessoa" value="<%= idLogin %>">
<input type="hidden" name="nome" value="<%= nomeSafe %>">
<input type="submit" value="Alterar Foto">
</form>

</div>
	   
 </div>
<br>

<% if(idEncontro != null){ %>

<div class="ui-body ui-body-a ui-corner-all ui-shadow">

    <h3>Registro de Presença Disponível</h3>

    <p><strong>Data:</strong> <%= dataEncontro %></p>
    <p><strong>Descrição:</strong> <%= descricao %></p>

	<a href="#presencaDialog" data-rel="popup" data-position-to="window" data-transition="pop" class="ui-btn ui-btn-inline ui-corner-all ui-shadow ui-icon-check ui-btn-icon-left ui-btn-b">Registrar Presença</a>
	<a href="#justificarDialog" data-rel="popup" data-position-to="window" data-transition="pop" class="ui-btn ui-btn-inline ui-corner-all ui-shadow ui-icon-comment ui-btn-icon-left ui-btn-a">Justificar Ausência</a>
	
<div data-role="popup" id="presencaDialog" data-overlay-theme="a" data-theme="a" data-dismissible="false" style="max-width:400px;">
<div data-role="header" data-theme="a">
<h1>Registrar Pesença</h1>
</div>


<div role="main" class="ui-content" >
<h3 class="ui-title">Confirma sua participação no evento ?</h3>
<p><%= descricao %></p>
<% if ( Math.round(distancia) <= 100 ) { %>
<p> Você está a <span class="presente"> <%= Math.round(distancia) %> </span> metros do local do evento. </p>
<% } else {%>
<p> Você está a <span class="faltou"> <%= Math.round(distancia) %> </span> metros do local do evento. </p>
<% } %>



<form method="post" action="paginaFoto.jsp" id="formPresenca">

      <!-- Campos ocultos -->
      <input type="hidden" name="idPessoa" id="idPessoa" value="<%=idLogin %>">
	  <input type="hidden" name="idEncontroUpd" id="idEncontroUpd" value="<%=idEncontro %>">
      <input type="hidden" name="latitude" id="latitude" value="<%= latUsuario %>">
      <input type="hidden" name="longitude" id="longitude" value="<%= lonUsuario %>">
	  <input type="hidden" name="latEncontro" id="latEncontro" value="<%= latEncontro %>">
      <input type="hidden" name="lonEncontro" id="lonEncontro" value="<%= lonEncontro %>">
	  <input type="hidden" name="flgPresenca" id="flgPresenca" value="1">
	  <input type="hidden" name="justificativa" id="justificativa" value=".">
	  
       <a href="#" class="ui-btn ui-corner-all ui-shadow ui-btn-inline ui-btn-a" data-rel="back">Cancela</a>
        <button type="submit" class="ui-btn ui-btn-b ui-btn-inline ui-corner-all">
        Confirma
		</button>
		
    </form>
</div>

	

</div>


<div data-role="popup" id="justificarDialog" data-overlay-theme="a" data-theme="a" data-dismissible="false" style="max-width:400px;">
<div data-role="header" data-theme="a">
<h1>Justificar Ausência</h1>
</div>


<div role="main" class="ui-content" >
<h3 class="ui-title">Porque você faltou o encontro ?</h3>
<p><%= descricao %></p>

<form method="post" action="paginaFoto.jsp" id="formJustificativa">

      <!-- Campos ocultos -->
      <input type="hidden" name="idPessoa" id="idPessoa" value="<%=idLogin %>">
	  <input type="hidden" name="idEncontroUpd" id="idEncontroUpd" value="<%=idEncontro %>">
       <input type="hidden" name="flgPresenca" id="flgPresenca" value="0">
	 <textarea cols="40" rows="8" name="justificativa" id="justificativa"></textarea>
	   
       <a href="#" class="ui-btn ui-corner-all ui-shadow ui-btn-inline ui-btn-a" data-rel="back">Cancela</a>
        <button type="submit" class="ui-btn ui-btn-b ui-btn-inline ui-corner-all">
        Confirma
		</button>
		
    </form>
</div>

	

</div>



<% } else { %>

<div class="ui-body ui-body-a ui-corner-all ui-shadow">
    <p>Nenhum encontro disponível para registro no momento.</p>
</div>

<% } %>

<br>


<hr>

<!-- ================= HISTÓRICO ================= -->

<div data-role="collapsible" data-collapsed="true">
<h4>Histórico de Frequência</h4>

<%
Connection conHist = null;
PreparedStatement stmtHist = null;
ResultSet rsHist = null;

try{
    conHist = cad.db.Database.getConnection();

    String sqlHist = "SELECT DATE_FORMAT(e.DtEncontro,'%d/%m/%Y') as DtEncontro, " +
            "e.Descricao, e.Local, pe.flgPresenca, pe.Justificativa " +
            "FROM participanteEncontro pe " +
            "JOIN Encontros e ON pe.IdEncontro=e.IdEncontro " +
            "WHERE pe.IdPessoa=? ORDER BY e.DtEncontro DESC";

    stmtHist = conHist.prepareStatement(sqlHist);
    stmtHist.setInt(1, idLogin);
    rsHist = stmtHist.executeQuery();
%>

<table>
<thead>
<tr>
<th>Data</th>
<th>Descrição</th>
<th>Local</th>
<th>Presença</th>
<th>Justificativa</th>
</tr>
</thead>
<tbody>

<%
while(rsHist.next()){
    boolean pres = rsHist.getInt("flgPresenca")==1;
%>

<tr>
<td><%= rsHist.getString("DtEncontro") %></td>
<td><%= rsHist.getString("Descricao") %></td>
<td><%= rsHist.getString("Local") %></td>
<td class="<%= pres ? "presente":"faltou" %>">
<%= pres ? "Presente":"Faltou" %>
</td>
<td><%= rsHist.getString("Justificativa")!=null?
rsHist.getString("Justificativa"):"" %></td>
</tr>

<% } %>

</tbody>
</table>

<%
} catch(Exception e){
    out.println("Erro ao carregar histórico: " + e.getMessage());
} finally{
    if(rsHist!=null) try{rsHist.close();}catch(Exception e){}
    if(stmtHist!=null) try{stmtHist.close();}catch(Exception e){}
    if(conHist!=null) try{conHist.close();}catch(Exception e){}
}
%>

</div>

</div>
</div>




</body>
</html>
