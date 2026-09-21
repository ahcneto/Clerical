<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
	
<%

Connection conn=null;
Statement st=null;
ResultSet rs=null;

int vocacionados=0;
int candidatos=0;
int diaconos=0;

String labels="";
String valores="";
conn = cad.db.Database.getConnection();

st = conn.createStatement();

/* contadores */

rs = st.executeQuery(
"SELECT classe, COUNT(*) total FROM pessoas where status = 1 GROUP BY classe"
);

while(rs.next()){

String tipo = rs.getString("classe");

if(tipo.equals("3"))
vocacionados = rs.getInt("total");

if(tipo.equals("2"))
candidatos = rs.getInt("total");

if(tipo.equals("1"))
diaconos = rs.getInt("total");

}

/* gráfico regiões */

rs = st.executeQuery(
"SELECT Regiao, COUNT(*) total FROM sqlPessoas where status =1 GROUP BY Regiao"
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

<style>

.card.filtro{
cursor:pointer;
transition:0.3s;
}

.card.filtro:hover{
transform:scale(1.03);
}

.card.ativo{
border:3px solid #0d6efd;
background:#e7f1ff;
}

</style>

</head>

<body class="bg-light">

<div class="container mt-4">

<h2>Dashboard Vocacional</h2>

<!-- CARDS -->

<div class="row mb-4">

<div class="col-md-4">
<div class="card shadow text-center filtro" data-tipo="Vocacionado">
<div class="card-body">
<h5>Vocacionados</h5>
<h2><%=vocacionados%></h2>
</div>
</div>
</div>

<div class="col-md-4">
<div class="card shadow text-center filtro" data-tipo="Candidato">
<div class="card-body">
<h5>Candidatos</h5>
<h2><%=candidatos%></h2>
</div>
</div>
</div>

<div class="col-md-4">
<div class="card shadow text-center filtro" data-tipo="Diácono">
<div class="card-body">
<h5>Diáconos</h5>
<h2><%=diaconos%></h2>
</div>
</div>
</div>

</div>

<!-- FILTROS -->

<div class="card shadow mb-4">

<div class="card-body">

<div class="row">

<div class="col-md-3">
<select id="filtroRegiao" class="form-select">
<option value="">Região Episcopal</option>
</select>
</div>

<div class="col-md-3">
<select id="filtroParoquia" class="form-select">
<option value="">Paróquia</option>
</select>
</div>

<div class="col-md-3">
<select id="filtroAno" class="form-select">
<option value="">Ano de ingresso</option>
</select>
</div>

<div class="col-md-3">
<select id="filtroIdade" class="form-select">
<option value="">Idade</option>
<option value="30">Até 30</option>
<option value="40">31-40</option>
<option value="50">41-50</option>
<option value="60">51+</option>
</select>
</div>

</div>

</div>

</div>

<!-- GRAFICOS -->

<div class="row mb-4">

<div class="col-md-6">

<div class="card shadow">

<div class="card-body">

<canvas id="graficoRegiao"></canvas>

</div>

</div>

</div>

<div class="col-md-6">

<div class="card shadow">

<div class="card-body">

<canvas id="graficoTipo"></canvas>

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
<th>Região</th>
<th>Paróquia</th>
<th>Ano</th>
<th>Idade</th>
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
<td><%=rs.getString("Paroquia")%></td>
<td><%=rs.getInt("Turma")%></td>
<td><%=rs.getInt("Idade")%></td>

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

var tabela;
var graficoRegiao;
var graficoTipo;
var tipoSelecionado = "";

$(document).ready(function(){

tabela = $('#tabela').DataTable();

/* preencher filtros */

tabela.column(3).data().unique().each(function(d){
$('#filtroRegiao').append('<option>'+d+'</option>');
});

tabela.column(4).data().unique().each(function(d){
$('#filtroParoquia').append('<option>'+d+'</option>');
});

tabela.column(5).data().unique().each(function(d){
$('#filtroAno').append('<option>'+d+'</option>');
});

/* eventos filtros */

$('#filtroRegiao').on('change',function(){
tabela.column(3).search(this.value).draw();
});

$('#filtroParoquia').on('change',function(){
tabela.column(4).search(this.value).draw();
});

$('#filtroAno').on('change',function(){
tabela.column(5).search(this.value).draw();
});

/* CARDS */

$(".filtro").click(function(){

var tipo = $(this).data("tipo");

if(tipoSelecionado === tipo){

tipoSelecionado="";
$(".filtro").removeClass("ativo");

tabela.column(2).search("").draw();

}else{

tipoSelecionado = tipo;

$(".filtro").removeClass("ativo");
$(this).addClass("ativo");

tabela.column(2).search(tipo).draw();

}

});

/* criar gráficos */

graficoRegiao = new Chart(document.getElementById("graficoRegiao"),{

type:'bar',

data:{
labels:[],
datasets:[{
label:'Pessoas por Região',
data:[]
}]
}

});

graficoTipo = new Chart(document.getElementById("graficoTipo"),{

type:'doughnut',

data:{
labels:['Vocacionado','Candidato','Diácono'],
datasets:[{
data:[0,0,0]
}]
}

});

/* atualizar quando tabela mudar */

tabela.on('draw',function(){
atualizarGraficos();
});

atualizarGraficos();

});


function atualizarGraficos(){

var dados = tabela.rows({search:'applied'}).data();

var regioes = {};
var tipos = {
"Vocacionado":0,
"Candidato":0,
"Diácono":0
};

for(var i=0;i<dados.length;i++){

var regiao = dados[i][3];
var tipo = dados[i][2];

if(!regioes[regiao])
regioes[regiao]=0;

regioes[regiao]++;

if(tipos[tipo] != undefined)
tipos[tipo]++;

}

/* atualizar gráfico região */

graficoRegiao.data.labels = Object.keys(regioes);
graficoRegiao.data.datasets[0].data = Object.values(regioes);
graficoRegiao.update();

/* atualizar gráfico tipo */

graficoTipo.data.datasets[0].data = [
tipos["Vocacionado"],
tipos["Candidato"],
tipos["Diácono"]
];

graficoTipo.update();

}
</script>

</body>
</html>