<%@ page import="java.sql.*" %>
<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
private String jsonErro(String texto) { return texto == null ? "" : texto.replace("\\", "\\\\").replace("\"", "\\\""); }
%>
<%
String perfil = (String) session.getAttribute("usuarioPerfil");
Integer usuario = (Integer) session.getAttribute("usuarioId");
Integer grupoUsuario = (Integer) session.getAttribute("usuarioGrupoId");
if ((!"ADM".equals(perfil) && !"FIN".equals(perfil)) || usuario == null) { response.setStatus(403); out.print("{\"ok\":false,\"mensagem\":\"Acesso não autorizado.\"}"); return; }
try {
    int pessoa = Integer.parseInt(request.getParameter("idPessoa"));
    int classe = Integer.parseInt(request.getParameter("classe"));
    int mes = Integer.parseInt(request.getParameter("mes"));
    int ano = Integer.parseInt(request.getParameter("ano"));
    if (mes < 1 || mes > 12) throw new IllegalArgumentException("Competência inválida.");
    if ("FIN".equals(perfil) && (grupoUsuario == null || grupoUsuario.intValue() != classe)) throw new SecurityException("Você só pode registrar contribuições do seu grupo.");
    try (Connection conexao = cad.db.Database.getConnection()) {
        double valor=0;int dia=1;boolean editavel=false;String periodicidade="";
        try(PreparedStatement regra=conexao.prepareStatement("SELECT g.ContribuicaoValor,g.ContribuicaoDiaVencimento,g.ContribuicaoValorEditavel,g.ContribuicaoPeriodicidade,g.ContribuicaoAteMesAtual FROM grupos g JOIN pessoas p ON p.IdPessoa=? AND p.Classe=g.IdGrupo WHERE g.IdGrupo=? AND g.StatusGrupo='ATIVO' AND g.GrupoOperacional=1 AND g.ModuloContribuicoes=1 AND g.ContribuicaoAtiva=1")){regra.setInt(1,pessoa);regra.setInt(2,classe);try(ResultSet r=regra.executeQuery()){if(!r.next())throw new IllegalArgumentException("Grupo sem contribuição ativa.");valor=r.getDouble(1);dia=Math.max(1,Math.min(28,r.getInt(2)));editavel=r.getBoolean(3);periodicidade=r.getString(4);if(r.getBoolean(5)&&java.time.YearMonth.of(ano,mes).isAfter(java.time.YearMonth.now()))throw new IllegalArgumentException("Competência futura não permitida.");}}
        if("ENCONTRO".equals(periodicidade)){try(PreparedStatement p=conexao.prepareStatement("SELECT 1 FROM Encontros WHERE Classe=? AND Checklist=0 AND YEAR(DtEncontro)=? AND MONTH(DtEncontro)=? LIMIT 1")){p.setInt(1,classe);p.setInt(2,ano);p.setInt(3,mes);try(ResultSet r=p.executeQuery()){if(!r.next())throw new IllegalArgumentException("Não há encontro nesta competência.");}}}else if(!"MENSAL".equals(periodicidade)&&!"MANUAL".equals(periodicidade))throw new IllegalArgumentException("Competência não habilitada.");
        String valorInformado=request.getParameter("valor");if(editavel&&valorInformado!=null&&!valorInformado.trim().isEmpty())valor=Double.parseDouble(valorInformado.replace(',','.'));if(valor<=0)throw new IllegalArgumentException("Valor inválido.");
        String vencimento=String.format("%04d-%02d-%02d",ano,mes,dia);
        int id = 0;
        try (PreparedStatement busca = conexao.prepareStatement("SELECT idLancamento FROM lancamentos WHERE idPessoa=? AND tipoLancamento='1.1' AND YEAR(dtVencimento)=? AND MONTH(dtVencimento)=? ORDER BY idLancamento DESC LIMIT 1")) {
            busca.setInt(1, pessoa); busca.setInt(2, ano); busca.setInt(3, mes);
            try (ResultSet resultado = busca.executeQuery()) { if (resultado.next()) id = resultado.getInt(1); }
        }
        String sql = id == 0
            ? "INSERT INTO lancamentos (dtLancamento,dtVencimento,dtPagamento,valorOriginal,valorPago,tipoLancamento,descricao,idClasse,idPessoa,idUsuario,status) VALUES (CURDATE(),?,CURDATE(),?,?,'1.1','Contribuição mensal',?,?,?,1)"
            : "UPDATE lancamentos SET dtPagamento=CURDATE(),valorPago=?,idUsuario=?,status=1 WHERE idLancamento=?";
        try (PreparedStatement grava = conexao.prepareStatement(sql)) {
            if (id == 0) { grava.setDate(1, Date.valueOf(vencimento)); grava.setDouble(2, valor); grava.setDouble(3, valor); grava.setInt(4, classe); grava.setInt(5, pessoa); grava.setInt(6, usuario); }
            else { grava.setDouble(1, valor); grava.setInt(2, usuario); grava.setInt(3, id); }
            grava.executeUpdate();
        }
    }
    out.print("{\"ok\":true}");
} catch (Exception erro) {
    getServletContext().log("Erro ao registrar contribuição", erro);
    response.setStatus(400);
    out.print("{\"ok\":false,\"mensagem\":\"Não foi possível registrar o pagamento: " + jsonErro(erro.getMessage()) + "\"}");
}
%>
