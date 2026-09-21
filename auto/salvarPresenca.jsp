<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>

<%
    // ================================
    // 1. Dados recebidos do formulário
    // ================================
    String idUsuario    = request.getParameter("idUsuario");
    String confirmacao  = request.getParameter("confirmacao");

    double latUsuario = Double.parseDouble(request.getParameter("latitude"));
    double lonUsuario = Double.parseDouble(request.getParameter("longitude"));

    // ================================
    // 2. Coordenadas oficiais do evento
    // (idealmente vindas do banco)
    // ================================
    double latEvento = -3.7445;   // exemplo
    double lonEvento = -38.4826;  // exemplo

   // -3.7445397598335646, -38.48260254625194
    int raioPermitido = 100; // metros

    // ================================
    // 3. Cálculo da distância
    // ================================
    double distancia = distanciaEmMetros(
        latUsuario, lonUsuario,
        latEvento, lonEvento
    );

    boolean dentroDoRaio = distancia <= raioPermitido;
    boolean salvoComSucesso = false;

    // ================================
    // 4. Persistência (se válido)
    // ================================
    if ("S".equals(confirmacao) && dentroDoRaio) {

        // --- EXEMPLO JDBC ---
        // Ajuste para seu datasource/banco

        /*
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = cad.db.Database.getConnection();

            ps = conn.prepareStatement(
                "INSERT INTO PRESENCA " +
                "(ID_USUARIO, LAT_USUARIO, LON_USUARIO, DISTANCIA_METROS, DATA_REGISTRO) " +
                "VALUES (?, ?, ?, ?, SYSDATE)"
            );

            ps.setString(1, idUsuario);
            ps.setDouble(2, latUsuario);
            ps.setDouble(3, lonUsuario);
            ps.setDouble(4, distancia);

            ps.executeUpdate();
            salvoComSucesso = true;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        }
        */

        // Para testes sem banco:
        salvoComSucesso = true;
    }
%>

<%! 
    // ==================================
    // Função Haversine
    // ==================================
    public static double distanciaEmMetros(
        double lat1, double lon1,
        double lat2, double lon2) {

        final int R = 6371000;

        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);

        double a =
            Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.cos(Math.toRadians(lat1)) *
            Math.cos(Math.toRadians(lat2)) *
            Math.sin(dLon / 2) * Math.sin(dLon / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Resultado do Registro</title>
</head>
<body>

<h2>Registro de Presença</h2>

<p><strong>ID Usuário:</strong> <%= idUsuario %></p>
<p><strong>Distância até o evento:</strong> <%= Math.round(distancia) %> metros</p>

<% if (!"S".equals(confirmacao)) { %>

  <p style="color:orange;">Presença não confirmada pelo usuário.</p>

<% } else if (!dentroDoRaio) { %>

  <p style="color:red;">
    Você está fora do local do evento.<br>
    Raio permitido: <%= raioPermitido %> m
  </p>

<% } else if (salvoComSucesso) { %>

  <p style="color:green;">Presença registrada com sucesso ✅</p>

<% } else { %>

  <p style="color:red;">Erro ao registrar presença ❌</p>

<% } %>

</body>
</html>
