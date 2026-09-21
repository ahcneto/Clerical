<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%

int vocacionados=0;
int candidatos=0;
int diaconos=0;

String labels="";
String valores="";

Connection conn=null;
Statement st=null;
ResultSet rs=null;
conn = cad.db.Database.getConnection();

st = conn.createStatement();

/* contadores */

rs = st.executeQuery("SELECT classe, COUNT(*) total FROM pessoas where status = 1 GROUP BY classe");

while(rs.next()){

 String tipo = rs.getString("classe");

 if(tipo.equals("3"))
  vocacionados = rs.getInt("total");

 if(tipo.equals("2"))
  candidatos = rs.getInt("total");

 if(tipo.equals("1"))
  diaconos = rs.getInt("total");
}

/* regiões */

rs = st.executeQuery(
"SELECT Regiao, COUNT(*) total FROM sqlPessoas WHERE classe = 2 GROUP BY Regiao"
);

while(rs.next()){

 labels += "'" + rs.getString("Regiao") + "',";
 valores += rs.getInt("total") + ",";
}

%>

<!DOCTYPE html>
<html>

<head>

<title>Dashboard Diaconato</title>

<link rel="stylesheet"
href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">

<link rel="stylesheet"
href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css">

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>

<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>

</head>

<body class="bg-light">

<div class="container mt-4">

<h2 class="mb-4">Dashboard Vocacional</h2>

<!-- CARDS -->

<div class="row mb-4">

<div class="col-md-4">
<div class="card text-center shadow">
<div class="card-body">
<h5>Vocacionados</h5>
<h2><%=vocacionados%></h2>
</div>
</div>
</div>

<div class="col-md-4">
<div class="card text-center shadow">
<div class="card-body">
<h5>Candidatos</h5>
<h2><%=candidatos%></h2>
</div>
</div>
</div>

<div class="col-md-4">
<div class="card text-center shadow">
<div class="card-body">
<h5>Diáconos</h5>
<h2><%=diaconos%></h2>
</div>
</div>
</div>

</div>

<!-- GRAFICOS -->

<div class="row mb-4">

<div class="col-md-6">
<div class="card shadow">
<div class="card-body">
<canvas id="graficoBarra"></canvas>
</div>
</div>
</div>

<div class="col-md-6">
<div class="card shadow">
<div class="card-body">
<canvas id="graficoPizza"></canvas>
</div>
</div>
</div>

</div>

<!-- TABELA -->

<div class="card shadow">

<div class="card-body">

<table id="tabela" class="display">

<thead>
<tr>
<th>ID</th>
<th>Nome</th>
<th>Tipo</th>
<th>Região Episcopal</th>
</tr>
</thead>

<tbody>

<%

rs = st.executeQuery("SELECT * FROM sqlPessoas");

while(rs.next()){

%>

<tr>
<td><%=rs.getInt("idPessoa")%></td>
<td><%=rs.getString("nome")%></td>
<td><%=rs.getString("DescClasse")%></td>
<td><%=rs.getString("Regiao")%></td>
</tr>

<%
}
%>

</tbody>

</table>

</div>

</div>

</div>

<script>

/* gráfico barras */

new Chart(document.getElementById("graficoBarra"), {

type:'bar',

data:{
labels:[<%=labels%>],
datasets:[{
label:'Candidatos por Região',
data:[<%=valores%>]
}]
}

});

/* gráfico pizza */

new Chart(document.getElementById("graficoPizza"), {

type:'doughnut',

data:{
labels:[<%=labels%>],
datasets:[{
label:'Distribuição',
data:[<%=valores%>]
}]
}

});

/* tabela */

$(document).ready(function(){

$('#tabela').DataTable();

});

</script>

</body>
</html>