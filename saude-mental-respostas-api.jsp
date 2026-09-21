<%@ page import="java.sql.*" %>
<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
private String json(String s) {
    if (s==null) return "";
    StringBuilder b=new StringBuilder();
    for (int i=0;i<s.length();i++) {
        char c=s.charAt(i);
        switch(c) {
            case '\\': b.append("\\\\"); break;
            case '"': b.append("\\\""); break;
            case '\n': b.append("\\n"); break;
            case '\r': b.append("\\r"); break;
            case '\t': b.append("\\t"); break;
            default:
                if (c<32) b.append(String.format("\\u%04x",(int)c)); else b.append(c);
        }
    }
    return b.toString();
}
private Connection abrirConexaoApi() throws Exception {
    return cad.db.Database.getConnection();
}
private void garantirTabelaApi(Connection c) throws SQLException {
    try(Statement s=c.createStatement()){
        s.executeUpdate("CREATE TABLE IF NOT EXISTS demandas_saude_mental ("+
            "id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,resposta VARCHAR(1000) NOT NULL,"+
            "data_submissao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,PRIMARY KEY(id),"+
            "INDEX idx_demandas_saude_data(data_submissao)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
        s.executeUpdate("CREATE TABLE IF NOT EXISTS demandas_saude_config ("+
            "id TINYINT NOT NULL,pergunta VARCHAR(500) NOT NULL,PRIMARY KEY(id)) "+
            "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
        s.executeUpdate("INSERT IGNORE INTO demandas_saude_config(id,pergunta) VALUES(1,"+
            "'Quais demandas você considera que impactam sua saúde mental no ambiente de trabalho?')");
    }
}
%>
<%
response.setHeader("Cache-Control","no-store, no-cache, must-revalidate");
request.setCharacterEncoding("UTF-8");
long depois=0;
try { depois=Math.max(0,Long.parseLong(request.getParameter("depois"))); } catch(Exception ignorado){}
try(Connection c=abrirConexaoApi()){
    garantirTabelaApi(c);
    if("POST".equalsIgnoreCase(request.getMethod())){
        String token=request.getParameter("token");
        String tokenSessao=(String)session.getAttribute("tokenPainelSaude");
        if(tokenSessao==null || !tokenSessao.equals(token)){
            response.setStatus(403);out.print("{\"ok\":false,\"mensagem\":\"Sessão inválida.\"}");return;
        }
        String acao=request.getParameter("acao");
        if("limpar".equals(acao)){
            try(Statement s=c.createStatement()){s.executeUpdate("DELETE FROM demandas_saude_mental");}
            out.print("{\"ok\":true}");return;
        }
        if("pergunta".equals(acao)){
            String pergunta=request.getParameter("pergunta");
            pergunta=pergunta==null?"":pergunta.trim();
            if(pergunta.length()<5 || pergunta.length()>500){
                response.setStatus(400);out.print("{\"ok\":false,\"mensagem\":\"A pergunta deve ter entre 5 e 500 caracteres.\"}");return;
            }
            try(PreparedStatement p=c.prepareStatement("UPDATE demandas_saude_config SET pergunta=? WHERE id=1")){
                p.setString(1,pergunta);p.executeUpdate();
            }
            out.print("{\"ok\":true,\"pergunta\":\""+json(pergunta)+"\"}");return;
        }
        response.setStatus(400);out.print("{\"ok\":false,\"mensagem\":\"Ação inválida.\"}");return;
    }
    long total=0;
    String pergunta="";
    try(Statement s=c.createStatement();ResultSet rs=s.executeQuery("SELECT pergunta FROM demandas_saude_config WHERE id=1")){if(rs.next())pergunta=rs.getString(1);}
    try(Statement s=c.createStatement();ResultSet rs=s.executeQuery("SELECT COUNT(*) FROM demandas_saude_mental")){if(rs.next())total=rs.getLong(1);}
    String sql=depois==0
        ? "SELECT id,resposta FROM demandas_saude_mental ORDER BY id DESC LIMIT 100"
        : "SELECT id,resposta FROM demandas_saude_mental WHERE id>? ORDER BY id ASC LIMIT 100";
    out.print("{\"ok\":true,\"total\":"+total+",\"pergunta\":\""+json(pergunta)+"\",\"respostas\":[");
    boolean primeira=true;
    try(PreparedStatement p=c.prepareStatement(sql)){
        if(depois>0)p.setLong(1,depois);
        try(ResultSet rs=p.executeQuery()){
            while(rs.next()){
                if(!primeira)out.print(",");
                out.print("{\"id\":"+rs.getLong("id")+",\"texto\":\""+json(rs.getString("resposta"))+"\"}");
                primeira=false;
            }
        }
    }
    out.print("]}");
}catch(Exception e){
    getServletContext().log("Erro na API de respostas de saúde mental",e);
    response.setStatus(500);
    out.print("{\"ok\":false,\"mensagem\":\"Não foi possível carregar as respostas.\"}");
}
%>
