<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>

<%
Connection conn=null;
Statement st=null;
ResultSet rs=null;

int vocacionados=0;
int candidatos=0;
int diaconos=0;
conn = cad.db.Database.getConnection();

st = conn.createStatement();

/* contadores por classe */
rs = st.executeQuery(
"SELECT classe, COUNT(*) total FROM pessoas WHERE status=1 GROUP BY classe"
);

while(rs.next()){
 String classe = rs.getString("classe");
 if("3".equals(classe)) vocacionados = rs.getInt("total");
 if("2".equals(classe)) candidatos  = rs.getInt("total");
 if("1".equals(classe)) diaconos    = rs.getInt("total");
}
%>

<!DOCTYPE html>
<html>
<head>

<title>Dashboard Escola Diaconal</title>

<link rel="stylesheet"
href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">

<link rel="stylesheet"
href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css">

<link rel="stylesheet"
href="https://unpkg.com/leaflet/dist/leaflet.css"/>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://unpkg.com/leaflet/dist/leaflet.js"></script>

<style>

body{
background:#f4f6f9;
font-family:Arial;
}

.card.filtro{
cursor:pointer;
transition:0.3s;
}

.card.filtro:hover{
transform:scale(1.03);
}

.card.ativo{
border:3px solid #0d6efd;
}

#mapa{
height:400px;
}

</style>

</head>

<body>

<div class="container-fluid p-4">

<h3 class="mb-4">Dashboard Vocacional - Escola Diaconal</h3>

<!-- CARDS -->

<div class="row mb-4">

<div class="col-md-3">
<div class="card text-white bg-primary shadow filtro" data-tipo="Vocacionado">
<div class="card-body text-center">
<h6>Vocacionados</h6>
<h2><%=vocacionados%></h2>
</div>
</div>
</div>

<div class="col-md-3">
<div class="card text-white bg-warning shadow filtro" data-tipo="Candidato">
<div class="card-body text-center">
<h6>Candidatos</h6>
<h2><%=candidatos%></h2>
</div>
</div>
</div>

<div class="col-md-3">
<div class="card text-white bg-success shadow filtro" data-tipo="Diácono">
<div class="card-body text-center">
<h6>Diáconos</h6>
<h2><%=diaconos%></h2>
</div>
</div>
</div>

<div class="col-md-3">
<div class="card text-white bg-dark shadow">
<div class="card-body text-center">
<h6>Total</h6>
<h2><%=vocacionados + candidatos + diaconos%></h2>
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
<option value="">Turma/Ano</option>
</select>
</div>

<div class="col-md-3">
<select id="filtroIdade" class="form-select">
<option value="">Faixa Etária</option>
<option value="1">Até 30</option>
<option value="2">31-40</option>
<option value="3">41-50</option>
<option value="4">51+</option>
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
<h6>Pessoas por Região</h6>
<canvas id="graficoRegiao"></canvas>
</div>
</div>
</div>

<div class="col-md-6">
<div class="card shadow">
<div class="card-body">
<h6>Pessoas por Paróquia</h6>
<canvas id="graficoParoquia"></canvas>
</div>
</div>
</div>

</div>

<div class="row mb-4">

<div class="col-md-6">
<div class="card shadow">
<div class="card-body">
<h6>Evolução por Turma</h6>
<canvas id="graficoTurma"></canvas>
</div>
</div>
</div>

<div class="col-md-6">
<div class="card shadow">
<div class="card-body">
<h6>Distribuição por Idade</h6>
<canvas id="graficoIdade"></canvas>
</div>
</div>
</div>

</div>

<!-- MAPA -->

<div class="card shadow mb-4">
<div class="card-body">
<h6>Mapa das Regiões Episcopais</h6>
<div id="mapa"></div>
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
<th>Turma</th>
<th>Idade</th>
</tr>

</thead>

<tbody>

<%

rs = st.executeQuery("SELECT * FROM sqlPessoas WHERE status=1");

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
var graficoParoquia;
var graficoTurma;
var graficoIdade;
var tipoSelecionado="";

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

/* filtros */

$('#filtroRegiao').change(function(){
tabela.column(3).search(this.value).draw();
});

$('#filtroParoquia').change(function(){
tabela.column(4).search(this.value).draw();
});

$('#filtroAno').change(function(){
tabela.column(5).search(this.value).draw();
});

/* cards */

$(".filtro").click(function(){

var tipo=$(this).data("tipo");

if(tipoSelecionado===tipo){

tipoSelecionado="";
$(".filtro").removeClass("ativo");
tabela.column(2).search("").draw();

}else{

tipoSelecionado=tipo;

$(".filtro").removeClass("ativo");
$(this).addClass("ativo");

tabela.column(2).search(tipo).draw();
}

});

/* gráficos */

graficoRegiao = new Chart(document.getElementById("graficoRegiao"),{
type:'bar',
data:{labels:[],datasets:[{label:'Região',data:[]}]}
});

graficoParoquia = new Chart(document.getElementById("graficoParoquia"),{
type:'bar',
data:{labels:[],datasets:[{label:'Paróquia',data:[]}]}
});

graficoTurma = new Chart(document.getElementById("graficoTurma"),{
type:'line',
data:{labels:[],datasets:[{label:'Turma',data:[]}]}
});

graficoIdade = new Chart(document.getElementById("graficoIdade"),{
type:'pie',
data:{labels:['Até 30','31-40','41-50','51+'],datasets:[{data:[0,0,0,0]}]}
});

/* atualizar gráficos */

tabela.on('draw',function(){
atualizarGraficos();
});

atualizarGraficos();

/* mapa */

var map = L.map('mapa').setView([-3.73,-38.52],11);

L.tileLayer(
'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
{attribution:'OpenStreetMap'}
).addTo(map);

});

function atualizarGraficos(){

var dados = tabela.rows({search:'applied'}).data();

var regioes={};
var paroquias={};
var turmas={};
var idade=[0,0,0,0];

for(var i=0;i<dados.length;i++){

var regiao=dados[i][3];
var paroquia=dados[i][4];
var turma=dados[i][5];
var idadePessoa=parseInt(dados[i][6]);

if(!regioes[regiao])regioes[regiao]=0;
regioes[regiao]++;

if(!paroquias[paroquia])paroquias[paroquia]=0;
paroquias[paroquia]++;

if(!turmas[turma])turmas[turma]=0;
turmas[turma]++;

if(idadePessoa<=30)idade[0]++;
else if(idadePessoa<=40)idade[1]++;
else if(idadePessoa<=50)idade[2]++;
else idade[3]++;

}

/* atualizar gráficos */

graficoRegiao.data.labels=Object.keys(regioes);
graficoRegiao.data.datasets[0].data=Object.values(regioes);
graficoRegiao.update();

graficoParoquia.data.labels=Object.keys(paroquias);
graficoParoquia.data.datasets[0].data=Object.values(paroquias);
graficoParoquia.update();

graficoTurma.data.labels=Object.keys(turmas);
graficoTurma.data.datasets[0].data=Object.values(turmas);
graficoTurma.update();

graficoIdade.data.datasets[0].data=idade;
graficoIdade.update();

}

</script>

</body>
</html>