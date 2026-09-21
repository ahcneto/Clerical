<%@ page contentType="text/html;charset=UTF-8"
         import="java.sql.*, java.util.*" %>
<html>

<%
    String titulo = request.getParameter("titulo");

    boolean mostraLinha  = "on".equalsIgnoreCase(request.getParameter("exibe_linha"));
    boolean mostraTotal  = "on".equalsIgnoreCase(request.getParameter("exibe_total"));
    boolean mostraData   = "on".equalsIgnoreCase(request.getParameter("exibe_data"));
    boolean exibeGrade   = "on".equalsIgnoreCase(request.getParameter("exibe_grade"));
    boolean listaZebrada = "on".equalsIgnoreCase(request.getParameter("lista_zebrada"));
%>

<head>
  <title>Resultado da Consulta</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet"
        href="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.css" />

<style>
  table {
    width: 100%;
    border-collapse: collapse;
  }

<% if (exibeGrade) { %>
  table th, table td {
    border: 1px solid #ccc;
    padding: 6px;
  }
<% } else { %>
  table th, table td {
    padding: 6px;
  }
<% } %>

<% if (listaZebrada) { %>
  table tbody tr:nth-child(even) {
    background-color: #fafafa;
  }
<% } %>

  table th {
    background-color: #f5f5f5;
    font-weight: bold;
  }

  .grupo {
    background-color: #e9e9e9;
    font-weight: bold;
  }
</style>
</head>

<body>

<div data-role="page" id="resultado">
  <div data-role="header"><h1><%=titulo%></h1></div>
  <div role="main" class="ui-content">

<%
    String[] campos = request.getParameterValues("campos");

    if (campos == null || campos.length == 0) {
        out.println("<p>Nenhum campo selecionado!</p>");
    } else {

        /* ===============================
           Identificar campos de grupo
           =============================== */
        List<String> camposGrupo = new ArrayList<>();

        for (String c : campos) {
            if ("on".equalsIgnoreCase(request.getParameter("grp_" + c))) {
                camposGrupo.add(c);
            }
        }

        /* ===============================
           Montar SQL
           =============================== */
        StringBuilder sql = new StringBuilder("SELECT ");

        for (int i = 0; i < campos.length; i++) {
            sql.append(campos[i]);
            if (i < campos.length - 1) sql.append(", ");
        }

        sql.append(" FROM sqlPessoas WHERE 1=1 ");

        // filtros
        for (String c : campos) {
            String filtro = request.getParameter("filtro_" + c);
            if (filtro != null && !filtro.trim().isEmpty()) {
                sql.append(" AND ").append(c)
                   .append(" LIKE '%")
                   .append(filtro.replace("'", "''"))
                   .append("%'");
            }
        }

        // GROUP BY
        if (!camposGrupo.isEmpty()) {
            sql.append(" GROUP BY ");
            for (int i = 0; i < camposGrupo.size(); i++) {
                sql.append(camposGrupo.get(i));
                if (i < camposGrupo.size() - 1) sql.append(", ");
            }
            for (String c : campos) {
                if (!camposGrupo.contains(c)) {
                    sql.append(", ").append(c);
                }
            }
        }

        // ORDER BY (mesmos campos do grupo)
        if (!camposGrupo.isEmpty()) {
            sql.append(" ORDER BY ");
            for (int i = 0; i < camposGrupo.size(); i++) {
                sql.append(camposGrupo.get(i));
                if (i < camposGrupo.size() - 1) sql.append(", ");
            }
        }

        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = cad.db.Database.getConnection();

            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql.toString());

            /* ===============================
               Exibir tabela
               =============================== */
            out.println("<table data-role='table' class='ui-responsive'><thead><tr>");

            if (mostraLinha) out.println("<th>#</th>");
            for (String c : campos) out.println("<th>" + c + "</th>");

            out.println("</tr></thead><tbody>");

            int totalRegistros = 0;
            Map<String, String> ultimoGrupo = new HashMap<>();

            while (rs.next()) {

                // detectar quebra de grupo
                boolean mudouGrupo = false;
                for (String g : camposGrupo) {
                    String valorAtual = rs.getString(g);
                    if (!valorAtual.equals(ultimoGrupo.get(g))) {
                        mudouGrupo = true;
                        ultimoGrupo.put(g, valorAtual);
                    }
                }

                // imprimir cabeçalho do grupo
                if (mudouGrupo && !camposGrupo.isEmpty()) {
                    out.println("<tr class='grupo'><td colspan='" +
                        (campos.length + (mostraLinha ? 1 : 0)) + "'>");

                    for (int i = 0; i < camposGrupo.size(); i++) {
                        String g = camposGrupo.get(i);
                        out.println(g + ": " + rs.getString(g));
                        if (i < camposGrupo.size() - 1) out.println(" | ");
                    }

                    out.println("</td></tr>");
                }

                totalRegistros++;
                out.println("<tr>");

                if (mostraLinha) {
                    out.println("<td>" + totalRegistros + "</td>");
                }

                for (String c : campos) {
                    out.println("<td>" + rs.getString(c) + "</td>");
                }

                out.println("</tr>");
            }

            out.println("</tbody></table>");

            if (mostraTotal) {
                out.println("<p><strong>Total de registros:</strong> " + totalRegistros + "</p>");
            }

            if (mostraData) {
                java.text.SimpleDateFormat sdf =
                    new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
                out.println("<p><em>Relatório gerado em: " +
                    sdf.format(new java.util.Date()) + "</em></p>");
            }

        } catch (Exception e) {
            out.println("<p>Erro: " + e.getMessage() + "</p>");
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (stmt != null) try { stmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    }
%>

  </div>
</div>
</body>
</html>
