<%@ page import="java.sql.*,java.util.UUID" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
private final String[] ROTULOS_MEDIA = {
    "Trabalho", "Família", "Financeiro", "Pessoal",
    "Social", "Saúde", "Ecológico", "Formação"
};
private Connection abrirConexaoMedia() throws Exception {
    return cad.db.Database.getConnection();
}
private void garantirTabelaMedia(Connection c) throws SQLException {
    try (Statement s = c.createStatement()) {
        s.executeUpdate("CREATE TABLE IF NOT EXISTS dimensoes_vida_v2 (" +
            "id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,trabalho TINYINT UNSIGNED NOT NULL," +
            "familia TINYINT UNSIGNED NOT NULL,financeiro TINYINT UNSIGNED NOT NULL,pessoal TINYINT UNSIGNED NOT NULL," +
            "social TINYINT UNSIGNED NOT NULL,saude TINYINT UNSIGNED NOT NULL," +
            "ecologico TINYINT UNSIGNED NOT NULL,formacao TINYINT UNSIGNED NOT NULL," +
            "data_submissao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,PRIMARY KEY(id)," +
            "INDEX idx_dimensoes_vida_v2_data(data_submissao)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    }
}
%>
<%
request.setCharacterEncoding("UTF-8");
if ("POST".equalsIgnoreCase(request.getMethod()) && "limpar".equals(request.getParameter("acao"))) {
    String tokenRecebido=request.getParameter("token");
    String tokenSessao=(String)session.getAttribute("tokenDimensoesMedias");
    if (tokenSessao == null || !tokenSessao.equals(tokenRecebido)) {
        response.sendError(403,"Sessão inválida.");
        return;
    }
    try (Connection conexao=abrirConexaoMedia()) {
        garantirTabelaMedia(conexao);
        try (Statement comando=conexao.createStatement()) {
            comando.executeUpdate("DELETE FROM dimensoes_vida_v2");
        }
        session.removeAttribute("tokenDimensoesMedias");
        response.sendRedirect("dimensoes-vida-medias.jsp?limpo=1");
        return;
    } catch (Exception e) {
        getServletContext().log("Erro ao limpar respostas de Dimensões da Vida",e);
        response.sendRedirect("dimensoes-vida-medias.jsp?erroLimpeza=1");
        return;
    }
}
String tokenLimpeza=UUID.randomUUID().toString();
session.setAttribute("tokenDimensoesMedias",tokenLimpeza);
double[] medias = new double[8];
long total = 0;
String erro = null;
try (Connection conexao = abrirConexaoMedia()) {
    garantirTabelaMedia(conexao);
    String sql = "SELECT COUNT(*) total,AVG(trabalho),AVG(familia),AVG(financeiro),AVG(pessoal)," +
        "AVG(social),AVG(saude),AVG(ecologico),AVG(formacao) FROM dimensoes_vida_v2";
    try (Statement comando = conexao.createStatement(); ResultSet rs = comando.executeQuery(sql)) {
        if (rs.next()) {
            total = rs.getLong(1);
            for (int i=0; i<medias.length; i++) medias[i] = rs.getDouble(i+2);
        }
    }
} catch (Exception e) {
    getServletContext().log("Erro ao calcular médias de Dimensões da Vida", e);
    erro = "Não foi possível carregar as médias neste momento.";
}
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Médias — Dimensões da Vida</title>
    <style>
        *{box-sizing:border-box} body{margin:0;background:#f2f6f4;color:#18332c;font-family:Arial,Helvetica,sans-serif}
        main{width:min(1060px,calc(100% - 32px));margin:36px auto} header{text-align:center;margin-bottom:24px}
        .logo{display:block;width:min(240px,65vw);height:auto;margin:0 auto 20px}
        h1{margin:0 0 8px;color:#0d4e3e;font-size:clamp(1.8rem,5vw,3rem)} header p{color:#60736d;margin:0}
        .cartao{background:#fff;border:1px solid #d9e5e0;border-radius:20px;padding:clamp(20px,4vw,40px);box-shadow:0 14px 40px rgba(13,78,62,.09)}
        .resumo{text-align:center;margin-bottom:20px}.numero{font-size:2.5rem;font-weight:700;color:#176b57}.grafico-wrap{display:flex;justify-content:center;width:100%}
        svg{display:block;width:min(100%,820px);height:auto;overflow:visible}.rotulo-fatia{fill:#17352d;font-size:11px;font-weight:700;text-anchor:middle;paint-order:stroke;stroke:rgba(255,255,255,.95);stroke-width:3px;stroke-linejoin:round}.nota-fatia{font-size:14px}.vazio,.erro{text-align:center;padding:35px;color:#60736d}.erro{color:#842029}
        .atualizar{text-align:center;margin-top:24px}.atualizar a{display:inline-block;padding:12px 24px;border-radius:999px;background:#176b57;color:#fff;text-decoration:none;font-weight:700}
        .acoes{display:flex;justify-content:center;flex-wrap:wrap;gap:10px;margin-top:24px}.acoes a,.acoes button{display:inline-block;border:0;border-radius:999px;padding:12px 24px;font-weight:700;cursor:pointer;text-decoration:none}.acoes a{background:#176b57;color:#fff}.limpar{background:#fbe3e3;color:#982f2f}.limpar:hover{background:#982f2f;color:#fff}.aviso{margin-bottom:20px;padding:13px 16px;border-radius:10px;text-align:center}.aviso.sucesso{color:#0f5132;background:#d1e7dd;border:1px solid #badbcc}.aviso.erro-limpeza{color:#842029;background:#f8d7da;border:1px solid #f5c2c7}
        @media(max-width:720px){main{width:min(100% - 12px,1060px);margin:8px auto}.cartao{padding:12px 6px}.rotulo-fatia{font-size:10px}}
    </style>
</head>
<body>
<main>
    <header><img class="logo" src="img/logo_andreza.png" alt="Andreza Almeida"><h1>Médias — Dimensões da Vida</h1><p>Visão geral de todas as avaliações anônimas recebidas.</p></header>
    <section class="cartao">
        <% if ("1".equals(request.getParameter("limpo"))) { %><div class="aviso sucesso">Todas as respostas foram apagadas.</div><% } %>
        <% if ("1".equals(request.getParameter("erroLimpeza"))) { %><div class="aviso erro-limpeza">Não foi possível apagar as respostas. Tente novamente.</div><% } %>
        <% if (erro != null) { %><div class="erro"><%= erro %></div>
        <% } else if (total == 0) { %><div class="vazio">Ainda não há avaliações enviadas.</div>
        <% } else { %>
        <div class="resumo"><div class="numero"><%= total %></div><div>avaliaç<%= total == 1 ? "ão recebida" : "ões recebidas" %></div></div>
        <div class="grafico-wrap"><svg id="graficoMedia" viewBox="-18 -18 436 436" role="img" aria-label="Médias das oito dimensões da vida"></svg></div>
        <% } %>
        <div class="acoes">
            <a href="dimensoes-vida-medias.jsp">Atualizar dados</a>
            <form method="post" action="dimensoes-vida-medias.jsp" onsubmit="return confirm('Deseja realmente apagar todas as respostas das Dimensões da Vida? Esta ação não pode ser desfeita.');">
                <input type="hidden" name="acao" value="limpar">
                <input type="hidden" name="token" value="<%= tokenLimpeza %>">
                <button type="submit" class="limpar">Limpar respostas</button>
            </form>
        </div>
    </section>
</main>
<% if (erro == null && total > 0) { %>
<script>
(function(){
 const nomes=[<% for(int i=0;i<ROTULOS_MEDIA.length;i++){ %>"<%= ROTULOS_MEDIA[i] %>"<%= i<ROTULOS_MEDIA.length-1?",":"" %><% } %>];
 const notas=[<% for(int i=0;i<medias.length;i++){ %><%= String.format(java.util.Locale.US,"%.2f",medias[i]) %><%= i<medias.length-1?",":"" %><% } %>];
 const cores=['#e45756','#f2a541','#f7cf5c','#66a182','#2e86ab','#6554c0','#a44a9f','#d95d8c'],ns='http://www.w3.org/2000/svg',svg=document.getElementById('graficoMedia'),c=200,r=180;
 function p(raio,a){const x=(a-90)*Math.PI/180;return[c+raio*Math.cos(x),c+raio*Math.sin(x)]}
 function d(raio,a,b){if(raio<=0)return'';const x=p(raio,a),y=p(raio,b);return'M '+c+' '+c+' L '+x[0]+' '+x[1]+' A '+raio+' '+raio+' 0 0 1 '+y[0]+' '+y[1]+' Z'}
 for(let n=2;n<=10;n+=2){const el=document.createElementNS(ns,'circle');el.setAttribute('cx',c);el.setAttribute('cy',c);el.setAttribute('r',r*n/10);el.setAttribute('fill','none');el.setAttribute('stroke','#d6e0dc');svg.appendChild(el)}
 notas.forEach((nota,i)=>{const a=i*45-22.5,b=a+45,bg=document.createElementNS(ns,'path');bg.setAttribute('d',d(r,a,b));bg.setAttribute('fill','#eef2f0');bg.setAttribute('stroke','#81958e');bg.setAttribute('stroke-width','1.4');svg.appendChild(bg);if(nota>0){const f=document.createElementNS(ns,'path');f.setAttribute('d',d(r*nota/10,a,b));f.setAttribute('fill',cores[i]);f.setAttribute('stroke','#fff');f.setAttribute('stroke-width','2');svg.appendChild(f)}const pos=p(r*.72,(a+b)/2),texto=document.createElementNS(ns,'text');texto.setAttribute('x',pos[0]);texto.setAttribute('y',pos[1]-7);texto.setAttribute('class','rotulo-fatia');const palavras=nomes[i].split(' '),linhas=[];if(nomes[i].length>13){const corte=Math.ceil(palavras.length/2);linhas.push(palavras.slice(0,corte).join(' '),palavras.slice(corte).join(' '))}else linhas.push(nomes[i]);linhas.forEach((linha,j)=>{const t=document.createElementNS(ns,'tspan');t.setAttribute('x',pos[0]);t.setAttribute('dy',j===0?0:12);t.textContent=linha;texto.appendChild(t)});const tn=document.createElementNS(ns,'tspan');tn.setAttribute('x',pos[0]);tn.setAttribute('dy','16');tn.setAttribute('class','nota-fatia');tn.textContent=nota.toFixed(2).replace('.',',');texto.appendChild(tn);svg.appendChild(texto)});
 const contorno=document.createElementNS(ns,'circle');contorno.setAttribute('cx',c);contorno.setAttribute('cy',c);contorno.setAttribute('r',r);contorno.setAttribute('fill','none');contorno.setAttribute('stroke','#17352d');contorno.setAttribute('stroke-width','3');svg.appendChild(contorno);
})();
</script>
<% } %>
</body>
</html>
