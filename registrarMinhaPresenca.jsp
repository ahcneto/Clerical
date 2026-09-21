<%@ page import="java.sql.*" %>
<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
private double distanciaEmMetros(double lat1, double lon1, double lat2, double lon2) {
    final double raioTerra = 6371000.0;
    double dLat = Math.toRadians(lat2 - lat1);
    double dLon = Math.toRadians(lon2 - lon1);
    double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
        + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
        * Math.sin(dLon / 2) * Math.sin(dLon / 2);
    return raioTerra * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}
%>
<%
if ("EXT".equals((String)session.getAttribute("usuarioPerfil"))) {
    response.setStatus(403);
    out.print("{\"ok\":false,\"mensagem\":\"Perfil autorizado apenas para consulta.\"}");
    return;
}
Integer usuarioId = (Integer) session.getAttribute("usuarioId");
Integer grupoId = (Integer) session.getAttribute("usuarioGrupoId");
String idEncontroParam = request.getParameter("idEncontro");
String flgPresencaParam = request.getParameter("flgPresenca");
String justificativa = request.getParameter("justificativa");
String latitudeParam = request.getParameter("latitude");
String longitudeParam = request.getParameter("longitude");

if (usuarioId == null || grupoId == null) {
    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
    out.print("{\"ok\":false,\"mensagem\":\"Sessão inválida.\"}");
    return;
}

try {
    int idEncontro = Integer.parseInt(idEncontroParam);
    int flgPresenca = Integer.parseInt(flgPresencaParam);
    if (flgPresenca != 1 && flgPresenca != 2) throw new IllegalArgumentException();
    if (flgPresenca == 2 && (justificativa == null || justificativa.trim().isEmpty())) throw new IllegalArgumentException();
    Double latitude = null;
    Double longitude = null;
    Double distancia = null;
    if (flgPresenca == 1) {
        latitude = 0.0;
        longitude = 0.0;
        try {
            double latitudeInformada = Double.parseDouble(latitudeParam);
            double longitudeInformada = Double.parseDouble(longitudeParam);
            if (Double.isFinite(latitudeInformada) && Double.isFinite(longitudeInformada)
                    && latitudeInformada >= -90 && latitudeInformada <= 90
                    && longitudeInformada >= -180 && longitudeInformada <= 180) {
                latitude = latitudeInformada;
                longitude = longitudeInformada;
            }
        } catch (Exception localizacaoIndisponivel) {
            latitude = 0.0;
            longitude = 0.0;
        }
    }
    try (Connection conexao = cad.db.Database.getConnection();
         PreparedStatement verifica = conexao.prepareStatement(
            "SELECT latitude, longitude FROM Encontros WHERE IdEncontro = ? AND Classe = ? AND Checklist = 0")) {

        verifica.setInt(1, idEncontro);
        verifica.setInt(2, grupoId);
        try (ResultSet encontro = verifica.executeQuery()) {
            if (!encontro.next()) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                out.print("{\"ok\":false,\"mensagem\":\"Este encontro não pertence ao seu grupo.\"}");
                return;
            }
            if (flgPresenca == 1) {
                double latitudeEncontro = encontro.getDouble("latitude");
                boolean latitudeEncontroNula = encontro.wasNull();
                double longitudeEncontro = encontro.getDouble("longitude");
                boolean longitudeEncontroNula = encontro.wasNull();
                distancia = 0.0;
                if (latitude != null && longitude != null
                        && latitude != 0.0 && longitude != 0.0
                        && !latitudeEncontroNula && !longitudeEncontroNula
                        && latitudeEncontro != 0.0 && longitudeEncontro != 0.0) {
                    distancia = distanciaEmMetros(latitude, longitude, latitudeEncontro, longitudeEncontro);
                }
            }
        }

        try (PreparedStatement grava = conexao.prepareStatement(
    "UPDATE participanteEncontro " +
    "SET flgPresenca = ?, " +
    "    Justificativa = ?, " +
    "    IdUsuario = ?, " +
    "    latPessoa = ?, " +
    "    lonPessoa = ?, " +
    "    distancia = ?, " +
    "    flgRegistroManual = 0, " +
    "    data_atualizacao = NOW() " +
    "WHERE IdEncontro = ? " +
    "  AND IdPessoa = ?")) {

    grava.setInt(1, flgPresenca);
    grava.setString(2, flgPresenca == 2 ? justificativa.trim() : "");
    grava.setInt(3, usuarioId);
    if (latitude == null) grava.setNull(4, Types.DOUBLE); else grava.setDouble(4, latitude);
    if (longitude == null) grava.setNull(5, Types.DOUBLE); else grava.setDouble(5, longitude);
    if (distancia == null) grava.setNull(6, Types.DOUBLE); else grava.setDouble(6, distancia);
    grava.setInt(7, idEncontro);
    grava.setInt(8, usuarioId);

    grava.executeUpdate();
}
    }

    out.print("{\"ok\":true}");
} catch (IllegalArgumentException erro) {
    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
    out.print("{\"ok\":false,\"mensagem\":\"Dados da presença inválidos.\"}");
} catch (Exception erro) {
    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
    out.print("{\"ok\":false,\"mensagem\":\"Não foi possível registrar a presença.\"}");
}
%>
