<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
private final String[] CAMPOS = {
    "trabalho", "familia", "financeiro", "pessoal",
    "social", "saude", "ecologico", "formacao"
};

private final String[] ROTULOS = {
    "Trabalho", "Família", "Financeiro", "Pessoal",
    "Social", "Saúde", "Ecológico", "Formação"
};

private Connection abrirConexao() throws Exception {
    return cad.db.Database.getConnection();
}

private void garantirTabela(Connection conexao) throws SQLException {
    String sql = "CREATE TABLE IF NOT EXISTS dimensoes_vida_v2 (" +
        "id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT," +
        "trabalho TINYINT UNSIGNED NOT NULL," +
        "familia TINYINT UNSIGNED NOT NULL," +
        "financeiro TINYINT UNSIGNED NOT NULL," +
        "pessoal TINYINT UNSIGNED NOT NULL," +
        "social TINYINT UNSIGNED NOT NULL," +
        "saude TINYINT UNSIGNED NOT NULL," +
        "ecologico TINYINT UNSIGNED NOT NULL," +
        "formacao TINYINT UNSIGNED NOT NULL," +
        "data_submissao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP," +
        "PRIMARY KEY (id)," +
        "INDEX idx_dimensoes_vida_v2_data (data_submissao)" +
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";
    try (Statement comando = conexao.createStatement()) {
        comando.executeUpdate(sql);
    }
}
%>
<%
request.setCharacterEncoding("UTF-8");
int[] notas = new int[CAMPOS.length];
boolean enviado = false;
String mensagemErro = null;

if ("POST".equalsIgnoreCase(request.getMethod())) {
    try {
        for (int i = 0; i < CAMPOS.length; i++) {
            String valor = request.getParameter(CAMPOS[i]);
            if (valor == null || !valor.matches("\\d{1,2}")) {
                throw new IllegalArgumentException("Preencha uma nota válida para " + ROTULOS[i] + ".");
            }
            notas[i] = Integer.parseInt(valor);
            if (notas[i] < 0 || notas[i] > 10) {
                throw new IllegalArgumentException("As notas devem estar entre 0 e 10.");
            }
        }

        try (Connection conexao = abrirConexao()) {
            garantirTabela(conexao);
            String sql = "INSERT INTO dimensoes_vida_v2 " +
                "(trabalho,familia,financeiro,pessoal,social,saude,ecologico,formacao) " +
                "VALUES (?,?,?,?,?,?,?,?)";
            try (PreparedStatement comando = conexao.prepareStatement(sql)) {
                for (int i = 0; i < notas.length; i++) {
                    comando.setInt(i + 1, notas[i]);
                }
                comando.executeUpdate();
            }
        }
        enviado = true;
    } catch (IllegalArgumentException erro) {
        mensagemErro = erro.getMessage();
    } catch (Exception erro) {
        getServletContext().log("Erro ao salvar Dimensões da Vida", erro);
        mensagemErro = "Não foi possível salvar suas respostas neste momento. Tente novamente.";
    }
}
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Dimensões da Vida</title>
    <style>
        :root { --verde:#176b57; --verde-escuro:#0d4e3e; --fundo:#f2f6f4; --texto:#18332c; --borda:#d9e5e0; }
        * { box-sizing:border-box; }
        body { margin:0; color:var(--texto); background:linear-gradient(145deg,#eef6f2,#f8faf9); font-family:Arial,Helvetica,sans-serif; }
        .pagina { width:min(1040px,calc(100% - 32px)); margin:36px auto; }
        .cabecalho { text-align:center; margin-bottom:24px; }
        .logo { display:block; width:min(240px,65vw); height:auto; margin:0 auto 20px; }
        .cabecalho h1 { margin:0 0 10px; color:var(--verde-escuro); font-size:clamp(2rem,5vw,3.2rem); }
        .cabecalho p { max-width:850px; margin:0 auto; color:#50665f; line-height:1.65; }
        .cartao { background:#fff; border:1px solid var(--borda); border-radius:20px; padding:clamp(20px,4vw,40px); box-shadow:0 14px 40px rgba(13,78,62,.09); }
        .grade { display:grid; grid-template-columns:repeat(2,minmax(0,1fr)); gap:18px; }
        .dimensao { border:1px solid var(--borda); border-radius:14px; padding:18px; background:#fbfdfc; }
        .linha { display:flex; align-items:center; justify-content:space-between; gap:12px; margin-bottom:14px; }
        .linha label { font-weight:700; }
        output { display:grid; place-items:center; min-width:42px; height:42px; color:#fff; background:var(--verde); border-radius:50%; font-weight:700; font-size:1.1rem; }
        input[type=range] { width:100%; accent-color:var(--verde); cursor:pointer; }
        .escala { display:flex; justify-content:space-between; color:#71817c; font-size:.78rem; margin-top:5px; }
        .acoes { text-align:center; margin-top:26px; }
        button,.botao { display:inline-block; border:0; border-radius:999px; padding:14px 30px; color:#fff; background:var(--verde); font-size:1rem; font-weight:700; cursor:pointer; text-decoration:none; }
        button:hover,.botao:hover { background:var(--verde-escuro); }
        .botao-secundario { margin-right:10px; color:var(--verde-escuro); background:#e3f0eb; }
        .botao-secundario:hover { color:#fff; background:var(--verde-escuro); }
        .erro { margin:0 0 20px; padding:13px 16px; border-radius:10px; color:#842029; background:#f8d7da; border:1px solid #f5c2c7; }
        .resultado h2 { text-align:center; margin-top:0; color:var(--verde-escuro); }
        .resultado > p { text-align:center; color:#566b64; }
        .grafico-wrap { display:flex; justify-content:center; width:100%; margin-top:24px; }
        #graficoVida { display:block; width:min(100%,820px); height:auto; overflow:visible; }
        .rotulo-fatia { fill:#17352d; font-size:11px; font-weight:700; text-anchor:middle; paint-order:stroke; stroke:rgba(255,255,255,.95); stroke-width:3px; stroke-linejoin:round; }
        .nota-fatia { font-size:14px; }
        .rodape { text-align:center; margin-top:22px; color:#71817c; font-size:.85rem; }
        @media (max-width:720px) { .grade { grid-template-columns:1fr; } .pagina { width:min(100% - 12px,1040px); margin:8px auto; } .cartao { padding:12px 6px; } .rotulo-fatia { font-size:10px; } }
    </style>
</head>
<body>
<main class="pagina">
    <header class="cabecalho">
        <img class="logo" src="img/logo_andreza.png" alt="Andreza Almeida">
        <h1>Dimensões da Vida</h1>
        <% if (!enviado) { %>
        <p>Abaixo estão apresentados oito dimensões que interferem em nossa vida. Analise calmamente o envolvimento de cada dimensão e preencha, dando uma nota de 0 a 10, de acordo com a intensidade que elas lhe afetam, seja positiva ou negativamente.</p>
        <% } %>
    </header>

    <section class="cartao">
        <% if (mensagemErro != null) { %><div class="erro" role="alert"><%= mensagemErro %></div><% } %>
        <% if (!enviado) { %>
        <form method="post" action="dimensoes-vida.jsp">
            <div class="grade">
                <% for (int i = 0; i < CAMPOS.length; i++) {
                    String recebido = request.getParameter(CAMPOS[i]);
                    int valor = recebido != null && recebido.matches("\\d{1,2}") ? Math.min(10, Integer.parseInt(recebido)) : 0;
                %>
                <div class="dimensao">
                    <div class="linha">
                        <label for="<%= CAMPOS[i] %>"><%= ROTULOS[i] %></label>
                        <output id="<%= CAMPOS[i] %>-valor" for="<%= CAMPOS[i] %>"><%= valor %></output>
                    </div>
                    <input type="range" id="<%= CAMPOS[i] %>" name="<%= CAMPOS[i] %>" min="0" max="10" step="1" value="<%= valor %>" required>
                    <div class="escala"><span>0</span><span>10</span></div>
                </div>
                <% } %>
            </div>
            <div class="acoes"><button type="submit">Ver meu resultado</button></div>
        </form>
        <% } else { %>
        <div class="resultado">
            <h2>Seu resultado</h2>
            <p>Cada fatia representa uma dimensão; quanto mais próxima da borda, maior foi a nota atribuída.</p>
            <div class="grafico-wrap">
                <svg id="graficoVida" viewBox="-18 -18 436 436" role="img" aria-label="Gráfico das oito dimensões da vida"></svg>
            </div>
            <div class="acoes">
                <button type="button" id="salvarImagem" class="botao-secundario">Salvar resultado como imagem</button>
                <a class="botao" href="dimensoes-vida.jsp">Fazer nova avaliação</a>
            </div>
        </div>
        <% } %>
    </section>
    <div class="rodape">Nenhuma informação de identificação pessoal é solicitada ou armazenada.</div>
</main>
<script>
document.querySelectorAll('input[type="range"]').forEach(function(campo) {
    campo.addEventListener('input', function() {
        document.getElementById(campo.id + '-valor').value = campo.value;
    });
});

<% if (enviado) { %>
(function() {
    const nomes = [<% for (int i=0;i<ROTULOS.length;i++) { %>"<%= ROTULOS[i] %>"<%= i < ROTULOS.length-1 ? "," : "" %><% } %>];
    const notas = [<% for (int i=0;i<notas.length;i++) { %><%= notas[i] %><%= i < notas.length-1 ? "," : "" %><% } %>];
    const cores = ['#e45756','#f2a541','#f7cf5c','#66a182','#2e86ab','#6554c0','#a44a9f','#d95d8c'];
    const svg = document.getElementById('graficoVida');
    const ns = 'http://www.w3.org/2000/svg';
    const centro = 200, raioMaximo = 180;

    function ponto(raio, angulo) {
        const rad = (angulo - 90) * Math.PI / 180;
        return [centro + raio * Math.cos(rad), centro + raio * Math.sin(rad)];
    }
    function setor(raio, inicio, fim) {
        if (raio <= 0) return '';
        const a = ponto(raio, inicio), b = ponto(raio, fim);
        return 'M '+centro+' '+centro+' L '+a[0]+' '+a[1]+' A '+raio+' '+raio+' 0 0 1 '+b[0]+' '+b[1]+' Z';
    }
    for (let nivel=2; nivel<=10; nivel+=2) {
        const circulo = document.createElementNS(ns,'circle');
        circulo.setAttribute('cx',centro); circulo.setAttribute('cy',centro);
        circulo.setAttribute('r',raioMaximo*nivel/10);
        circulo.setAttribute('fill','none'); circulo.setAttribute('stroke','#d6e0dc');
        circulo.setAttribute('stroke-width','1');
        svg.appendChild(circulo);
    }
    notas.forEach(function(nota,i) {
        const inicio = i*45-22.5, fim = inicio+45;
        const fundo = document.createElementNS(ns,'path');
        fundo.setAttribute('d',setor(raioMaximo,inicio,fim));
        fundo.setAttribute('fill','#eef2f0'); fundo.setAttribute('stroke','#81958e'); fundo.setAttribute('stroke-width','1.4');
        svg.appendChild(fundo);
        if (nota > 0) {
            const fatia = document.createElementNS(ns,'path');
            fatia.setAttribute('d',setor(raioMaximo*nota/10,inicio,fim));
            fatia.setAttribute('fill',cores[i]); fatia.setAttribute('stroke','#fff'); fatia.setAttribute('stroke-width','2');
            const titulo = document.createElementNS(ns,'title');
            titulo.textContent = nomes[i]+': '+nota;
            fatia.appendChild(titulo); svg.appendChild(fatia);
        }
        const posicao = ponto(raioMaximo*.72,(inicio+fim)/2);
        const texto = document.createElementNS(ns,'text');
        texto.setAttribute('x',posicao[0]); texto.setAttribute('y',posicao[1]-7);
        texto.setAttribute('class','rotulo-fatia');
        const palavras = nomes[i].split(' '), linhas = [];
        if (nomes[i].length > 13) {
            const corte = Math.ceil(palavras.length/2);
            linhas.push(palavras.slice(0,corte).join(' '),palavras.slice(corte).join(' '));
        } else linhas.push(nomes[i]);
        linhas.forEach(function(linha,j) {
            const tspan = document.createElementNS(ns,'tspan');
            tspan.setAttribute('x',posicao[0]); tspan.setAttribute('dy',j===0 ? 0 : 12);
            tspan.textContent=linha; texto.appendChild(tspan);
        });
        const tnota = document.createElementNS(ns,'tspan');
        tnota.setAttribute('x',posicao[0]); tnota.setAttribute('dy','16');
        tnota.setAttribute('class','nota-fatia'); tnota.textContent=nota+'/10';
        texto.appendChild(tnota); svg.appendChild(texto);
    });
    const contorno = document.createElementNS(ns,'circle');
    contorno.setAttribute('cx',centro); contorno.setAttribute('cy',centro);
    contorno.setAttribute('r',raioMaximo); contorno.setAttribute('fill','none');
    contorno.setAttribute('stroke','#17352d'); contorno.setAttribute('stroke-width','3');
    svg.appendChild(contorno);

    function carregarImagem(src) {
        return new Promise(function(resolve,reject) {
            const imagem = new Image();
            imagem.onload=function(){resolve(imagem);};
            imagem.onerror=reject;
            imagem.src=src;
        });
    }

    document.getElementById('salvarImagem').addEventListener('click',async function() {
        const botao=this, textoOriginal=botao.textContent;
        botao.disabled=true; botao.textContent='Gerando imagem...';
        try {
            const canvas=document.createElement('canvas'), ctx=canvas.getContext('2d');
            canvas.width=1400; canvas.height=1680;
            ctx.fillStyle='#ffffff'; ctx.fillRect(0,0,canvas.width,canvas.height);

            const logo=await carregarImagem('img/logo_andreza.png');
            const larguraLogo=Math.min(360,logo.naturalWidth);
            const alturaLogo=logo.naturalHeight*(larguraLogo/logo.naturalWidth);
            ctx.drawImage(logo,(canvas.width-larguraLogo)/2,55,larguraLogo,alturaLogo);

            ctx.fillStyle='#0d4e3e'; ctx.textAlign='center';
            ctx.font='bold 64px Arial, sans-serif';
            ctx.fillText('Dimensões da Vida',canvas.width/2,alturaLogo+155);
            ctx.fillStyle='#566b64'; ctx.font='30px Arial, sans-serif';
            ctx.fillText('Seu resultado',canvas.width/2,alturaLogo+210);
            ctx.font='24px Arial, sans-serif';
            ctx.fillText('Quanto mais próxima da borda, maior a nota atribuída.',canvas.width/2,alturaLogo+255);

            const copia=svg.cloneNode(true);
            copia.setAttribute('xmlns',ns);
            copia.setAttribute('width','1050'); copia.setAttribute('height','1050');
            copia.querySelectorAll('.rotulo-fatia').forEach(function(el) {
                el.setAttribute('fill','#17352d'); el.setAttribute('font-family','Arial, sans-serif');
                el.setAttribute('font-size','11px'); el.setAttribute('font-weight','700');
                el.setAttribute('text-anchor','middle'); el.setAttribute('stroke','#ffffff');
                el.setAttribute('stroke-width','3px'); el.setAttribute('paint-order','stroke');
            });
            copia.querySelectorAll('.nota-fatia').forEach(function(el){el.setAttribute('font-size','14px');});
            const dadosSvg=new XMLSerializer().serializeToString(copia);
            const urlSvg=URL.createObjectURL(new Blob([dadosSvg],{type:'image/svg+xml;charset=utf-8'}));
            try {
                const imagemGrafico=await carregarImagem(urlSvg);
                ctx.drawImage(imagemGrafico,175,alturaLogo+290,1050,1050);
            } finally { URL.revokeObjectURL(urlSvg); }

            ctx.fillStyle='#71817c'; ctx.font='22px Arial, sans-serif';
            ctx.fillText('Avaliação anônima • notas de 0 a 10',canvas.width/2,canvas.height-70);
            const link=document.createElement('a');
            link.download='dimensoes-da-vida-resultado.png';
            link.href=canvas.toDataURL('image/png');
            link.click();
        } catch (erro) {
            alert('Não foi possível gerar a imagem. Tente novamente.');
            console.error(erro);
        } finally {
            botao.disabled=false; botao.textContent=textoOriginal;
        }
    });
})();
<% } %>
</script>
</body>
</html>
