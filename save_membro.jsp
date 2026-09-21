<%@page import="java.sql.*"%>
<%@page contentType="text/plain;charset=UTF-8"%>


<%!

public java.sql.Date toDate(String valor){

    if(valor == null)
        return null;

    valor = valor.trim();

    if(valor.isEmpty())
        return null;

    return java.sql.Date.valueOf(valor);

}

public Integer toInteger(String valor, Integer padrao){

    if(valor == null || valor.trim().isEmpty())
        return padrao;

    return Integer.valueOf(valor.trim());

}

%>


<%
try{
Connection conn = cad.db.Database.getConnection();

String perfil = (String)session.getAttribute("usuarioPerfil");
if(perfil==null){response.setStatus(401);out.print("Sessão inválida.");conn.close();return;}
if ("EXT".equals(perfil)) {
    response.setStatus(403);
    out.print("Perfil autorizado apenas para consulta.");
    return;
}

Integer id = toInteger(request.getParameter("id"), null);

if (id == null)
    id = toInteger(request.getParameter("idPessoa"), null);

if (id == null)
    id = (Integer)session.getAttribute("usuarioId");

if (id == null)
    throw new IllegalArgumentException("Identificador do membro não informado.");

Integer usuarioId = (Integer)session.getAttribute("usuarioId");
if (!"ADM".equals(perfil) && !"REP".equals(perfil)) {
    if (usuarioId == null)
        throw new SecurityException("Sessão inválida.");
    id = usuarioId;
}
if ("REP".equals(perfil) && !id.equals(usuarioId)) {
    Integer grupoSessao=(Integer)session.getAttribute("usuarioGrupoId"),regiaoSessao=(Integer)session.getAttribute("usuarioRegiaoId");boolean autorizado=false;
    try(PreparedStatement pa=conn.prepareStatement("SELECT p.Classe,IFNULL(pr.IdRegiao,0),(SELECT EscopoRepMembros FROM grupos WHERE IdGrupo=?) Escopo FROM pessoas p LEFT JOIN paroquia pr ON pr.IdParoquia=p.IdParoquia WHERE p.IdPessoa=?")){pa.setInt(1,grupoSessao==null?-1:grupoSessao);pa.setInt(2,id);try(ResultSet ra=pa.executeQuery()){if(ra.next()){String ea=ra.getString("Escopo");autorizado="TODOS".equals(ea)||("PROPRIO".equals(ea)&&grupoSessao!=null&&ra.getInt(1)==grupoSessao)||("REGIAO_TODOS".equals(ea)&&regiaoSessao!=null&&ra.getInt(2)==regiaoSessao);}}}
    if(!autorizado){response.setStatus(403);out.print("Membro fora do escopo de acesso do representante.");conn.close();return;}
}

String nome = request.getParameter("nome");
if (nome == null || nome.trim().isEmpty())
    throw new IllegalArgumentException("Dados do perfil não recebidos. Atualização cancelada.");

String telefone = request.getParameter("telefone");
String telefone2 = request.getParameter("telefone2");
String email = request.getParameter("email");

String nascimento = request.getParameter("nascimento");

String profissao = request.getParameter("profissao");
String pastoral = request.getParameter("pastoral");

String esposa = request.getParameter("esposa");
String foneEsposa = request.getParameter("foneEsposa");
String profissaoEsposa = request.getParameter("profissaoEsposa");

String nascEsposa = request.getParameter("nascEsposa");
String casamento = request.getParameter("casamento");

String paroquiaId = request.getParameter("paroquiaId");

String turma = request.getParameter("turma");

String ordenacao = request.getParameter("ordenacao");

String provisao = request.getParameter("provisao");

String bispo = request.getParameter("bispo");

String obs = request.getParameter("obs");
String flgTeologia = request.getParameter("flgTeologia");
String flgSeminarioLeitor = request.getParameter("flgSeminarioLeitor");
String flgSeminarioAcolito = request.getParameter("flgSeminarioAcolito");
String flgOrdemSacra = request.getParameter("flgOrdemSacra");
String flgLeitor = request.getParameter("flgLeitor");
String flgAcolito = request.getParameter("flgAcolito");


StringBuilder sql = new StringBuilder();

sql.append("UPDATE pessoas SET ");

sql.append("Nome=?,");
sql.append("Fone1=?,");
sql.append("Fone2=?,");
sql.append("Email=?,");
sql.append("DtNascimento=?,");
sql.append("Profissao=?,");
sql.append("Pastoral=?,");

sql.append("NomeEsposa=?,");
sql.append("FoneEsposa=?,");
sql.append("ProfissaoEsposa=?,");
sql.append("DtNascEsposa=?,");
sql.append("DtCasamento=?,");

sql.append("IdParoquia=?");

if ("ADM".equals(perfil)) {

    sql.append(",Turma=?");
    sql.append(",DtProvisao=?");
    sql.append(",BispoOrdenante=?");

}

if ("ADM".equals(perfil)) {

    sql.append(",DtOrdenacao=?");
    sql.append(",Obs=?");
    sql.append(",flgTeologia=?");
    sql.append(",flgSeminarioLeitor=?");
    sql.append(",flgSeminarioAcolito=?");
    sql.append(",flgOrdemSacra=?");
    sql.append(",flgLeitor=?");
    sql.append(",flgAcolito=?");

}

sql.append(" WHERE IdPessoa=?");

PreparedStatement ps = conn.prepareStatement(sql.toString());

int i = 1;

ps.setString(i++, nome);
ps.setString(i++, telefone);
ps.setString(i++, telefone2);
ps.setString(i++, email);

ps.setDate(i++, toDate(nascimento));

ps.setString(i++, profissao);
ps.setString(i++, pastoral);

ps.setString(i++, esposa);
ps.setString(i++, foneEsposa);
ps.setString(i++, profissaoEsposa);

ps.setDate(i++, toDate(nascEsposa));

ps.setDate(i++, toDate(casamento));

Integer idParoquia = toInteger(paroquiaId, null);
if (idParoquia == null)
    ps.setNull(i++, java.sql.Types.INTEGER);
else
    ps.setInt(i++, idParoquia);

if ("ADM".equals(perfil)) {

    ps.setString(i++, turma);

    ps.setDate(i++, toDate(provisao));

    ps.setString(i++, bispo);

}

if ("ADM".equals(perfil)) {

    ps.setDate(i++, toDate(ordenacao));

    ps.setString(i++, obs);
    ps.setInt(i++, toInteger(flgTeologia, 0));
    ps.setInt(i++, toInteger(flgSeminarioLeitor, 0));
    ps.setInt(i++, toInteger(flgSeminarioAcolito, 0));
    ps.setInt(i++, toInteger(flgOrdemSacra, 0));
    ps.setInt(i++, toInteger(flgLeitor, 0));
    ps.setInt(i++, toInteger(flgAcolito, 0));

}

ps.setInt(i++, id);

int linhas = ps.executeUpdate();

if (linhas > 0)
    out.print("OK");
else
    out.print("Nenhum registro atualizado.");

ps.close();
conn.close();

}catch(Exception e){

    e.printStackTrace();

    out.print(e.getMessage());

}

%>
