<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
private Connection abrirConexaoSaude() throws Exception {
    return cad.db.Database.getConnection();
}
private void garantirTabelaSaude(Connection c) throws SQLException {
    try (Statement s=c.createStatement()) {
        s.executeUpdate("CREATE TABLE IF NOT EXISTS demandas_saude_mental (" +
            "id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,resposta VARCHAR(1000) NOT NULL," +
            "data_submissao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP," +
            "PRIMARY KEY(id),INDEX idx_demandas_saude_data(data_submissao)) " +
            "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
        s.executeUpdate("CREATE TABLE IF NOT EXISTS demandas_saude_config ("+
            "id TINYINT NOT NULL,pergunta VARCHAR(500) NOT NULL,PRIMARY KEY(id)) "+
            "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
        s.executeUpdate("INSERT IGNORE INTO demandas_saude_config(id,pergunta) VALUES(1,"+
            "'Quais demandas você considera que impactam sua saúde mental no ambiente de trabalho?')");
    }
}
%>
<%
request.setCharacterEncoding("UTF-8");
boolean enviado=false;
String erro=null;
String perguntaAtual="Quais demandas você considera que impactam sua saúde mental no ambiente de trabalho?";
String resposta=request.getParameter("resposta");
try (Connection c=abrirConexaoSaude()) {
    garantirTabelaSaude(c);
    try(Statement s=c.createStatement();ResultSet rs=s.executeQuery("SELECT pergunta FROM demandas_saude_config WHERE id=1")){
        if(rs.next())perguntaAtual=rs.getString(1);
    }
} catch(Exception e) {
    getServletContext().log("Erro ao carregar pergunta de saúde mental",e);
}
if ("POST".equalsIgnoreCase(request.getMethod())) {
    resposta=resposta == null ? "" : resposta.trim();
    if (resposta.length() < 3) erro="Escreva uma resposta com pelo menos 3 caracteres.";
    else if (resposta.length() > 1000) erro="Sua resposta deve ter no máximo 1.000 caracteres.";
    else {
        try (Connection c=abrirConexaoSaude()) {
            try (PreparedStatement p=c.prepareStatement("INSERT INTO demandas_saude_mental(resposta) VALUES(?)")) {
                p.setString(1,resposta);
                p.executeUpdate();
                enviado=true;
            }
        } catch (Exception e) {
            getServletContext().log("Erro ao registrar demanda de saúde mental",e);
            erro="Não foi possível enviar sua resposta neste momento. Tente novamente.";
        }
    }
}
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Saúde mental no ambiente de trabalho</title>
<style>
*{box-sizing:border-box}body{margin:0;min-height:100vh;display:grid;place-items:center;padding:24px;background:radial-gradient(circle at 15% 10%,#dff6ee,transparent 35%),linear-gradient(145deg,#f5faf8,#edf4f1);font-family:Arial,Helvetica,sans-serif;color:#17352d}
.pagina{width:min(760px,100%)}.logo{display:block;width:min(240px,65vw);height:auto;margin:0 auto 24px}.cartao{background:#fff;border:1px solid #d8e6e0;border-radius:26px;padding:clamp(24px,6vw,52px);box-shadow:0 20px 55px rgba(13,78,62,.12)}
h1{margin:0 0 30px;color:#0d4e3e;text-align:center;font-size:clamp(1.65rem,4.5vw,2.6rem);line-height:1.25}label{display:block;font-weight:700;margin-bottom:10px}
textarea{display:block;width:100%;min-height:190px;padding:18px;border:2px solid #cfdfd8;border-radius:16px;resize:vertical;font:1.05rem/1.55 Arial,Helvetica,sans-serif;color:#17352d;outline:0}textarea:focus{border-color:#238269;box-shadow:0 0 0 4px rgba(35,130,105,.12)}
.contador{text-align:right;margin-top:7px;color:#71817c;font-size:.85rem}.acoes{text-align:center;margin-top:24px}button,.botao{display:inline-block;border:0;border-radius:999px;padding:14px 32px;background:#176b57;color:#fff;font-size:1rem;font-weight:700;text-decoration:none;cursor:pointer}button:hover,.botao:hover{background:#0d4e3e}
.erro{margin-bottom:18px;padding:13px 16px;border:1px solid #f5c2c7;border-radius:10px;background:#f8d7da;color:#842029}.sucesso{text-align:center}.icone{display:grid;place-items:center;width:86px;height:86px;margin:0 auto 22px;border-radius:50%;background:#dff3ea;color:#176b57;font-size:2.6rem}.sucesso h2{color:#0d4e3e;font-size:2rem;margin:0 0 12px}.sucesso p{color:#60736d;margin:0 0 28px;line-height:1.6}.anonimo{text-align:center;color:#71817c;font-size:.84rem;margin-top:18px}
</style>
</head>
<body>
<main class="pagina">
<img class="logo" src="img/logo_andreza.png" alt="Andreza Almeida">
<section class="cartao">
<% if (enviado) { %>
    <div class="sucesso"><div class="icone">✓</div><h2>Resposta enviada!</h2><p>Obrigado por compartilhar sua percepção. Sua participação é anônima.</p><a class="botao" href="saude-mental-trabalho.jsp">Enviar outra resposta</a></div>
<% } else { %>
    <h1><%= perguntaAtual.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;") %></h1>
    <% if (erro != null) { %><div class="erro" role="alert"><%= erro %></div><% } %>
    <form method="post" action="saude-mental-trabalho.jsp">
        <label for="resposta">Escreva sua resposta:</label>
        <textarea id="resposta" name="resposta" maxlength="1000" required placeholder="Compartilhe sua percepção de forma breve..."><%= resposta == null ? "" : resposta.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;") %></textarea>
        <div id="contador" class="contador">0 / 1000</div>
        <div class="acoes"><button type="submit">Enviar anonimamente</button></div>
    </form>
    <div class="anonimo">Nenhuma informação de identificação pessoal é solicitada ou armazenada.</div>
<% } %>
</section>
</main>
<script>
const campo=document.getElementById('resposta'),contador=document.getElementById('contador');
if(campo&&contador){function atualizar(){contador.textContent=campo.value.length+' / 1000'}campo.addEventListener('input',atualizar);atualizar()}
</script>
</body>
</html>
