<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" encoding="UTF-8" indent="yes"/>

    <xsl:key name="pessoas" match="ROW" use="IdPessoa"/>

    <xsl:template match="/">
        <xsl:apply-templates select="SQL"/>
    </xsl:template>

    <xsl:template match="SQL">
        <xsl:variable name="classeInformada" select="request/parameters/classe"/>
        <xsl:variable name="classe">
            <xsl:choose>
                <xsl:when test="$classeInformada != ''"><xsl:value-of select="$classeInformada"/></xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="anoInformado" select="request/parameters/Ano"/>
        <xsl:variable name="ano">
            <xsl:choose>
                <xsl:when test="$anoInformado != ''"><xsl:value-of select="$anoInformado"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="ANOS/ANO[1]/Valor"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="totalEncontros" select="count(DATAS/DATA)"/>
        <xsl:variable name="totalPessoas"
                      select="count(ROWSET/ROW[generate-id() = generate-id(key('pessoas', IdPessoa)[1])])"/>
        <xsl:variable name="totalRegistros" select="count(ROWSET/ROW)"/>
        <xsl:variable name="totalPresentes" select="count(ROWSET/ROW[flgPresenca = 1])"/>
        <xsl:variable name="totalJustificados" select="count(ROWSET/ROW[flgPresenca = 2])"/>
        <xsl:variable name="totalAusentes" select="$totalRegistros - $totalPresentes - $totalJustificados"/>

        <html lang="pt-br">
            <head>
                <meta charset="UTF-8"/>
                <meta name="viewport" content="width=device-width, initial-scale=1"/>
                <title>Mapa de Presença</title>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet"/>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet"/>
                <style>
                    :root{--accent:#c96a0a;--ink:#172033;--muted:#64748b;--line:#dfe6ee;--surface:#fff;--page:#f6f8fb;--ok:#15803d;--warn:#b45309;--bad:#b91c1c}
                    *{box-sizing:border-box}
                    body{margin:0;background:var(--page);color:var(--ink);font-family:Inter,system-ui,-apple-system,"Segoe UI",sans-serif}
                    .report-shell{max-width:1450px;margin:0 auto;padding:32px 20px 48px}
                    .report-header{display:flex;align-items:center;justify-content:space-between;gap:20px;margin-bottom:24px}
                    .report-title{display:flex;align-items:center;gap:15px}
                    .title-icon{width:52px;height:52px;border-radius:15px;background:#fff1e6;color:var(--accent);display:grid;place-items:center;font-size:24px}
                    h1{font-size:29px;line-height:1.15;margin:0 0 5px;font-weight:750}
                    .subtitle{color:var(--muted);margin:0}
                    .actions{display:flex;gap:10px}
                    .btn-report{min-height:42px;border-radius:11px;padding:9px 15px;font-weight:650;text-decoration:none;display:inline-flex;align-items:center;justify-content:center;gap:8px;border:1px solid #dbe2ea;background:#fff;color:#334155;cursor:pointer}
                    .btn-report:hover{border-color:var(--accent);color:var(--accent)}
                    .btn-primary-report{background:var(--accent);border-color:var(--accent);color:#fff}
                    .btn-primary-report:hover{background:#ad5908;color:#fff}
                    .panel{background:var(--surface);border:1px solid #e8edf3;border-radius:16px;box-shadow:0 3px 14px rgba(15,23,42,.045)}
                    .filters{padding:20px;margin-bottom:18px}
                    .filter-grid{display:grid;grid-template-columns:1fr 1fr auto;gap:14px;align-items:end}
                    label{display:block;font-size:13px;font-weight:700;color:#475569;margin-bottom:7px}
                    select{width:100%;height:44px;border:1px solid #d9e0e8;border-radius:11px;background:#fff;padding:0 12px;color:#1e293b}
                    .summary-grid{display:grid;grid-template-columns:repeat(5,1fr);gap:12px;margin-bottom:22px}
                    .summary-card{padding:17px 18px;position:relative;overflow:hidden}
                    .summary-label{font-size:12px;color:var(--muted);font-weight:650;margin-bottom:7px}
                    .summary-value{font-size:27px;font-weight:760;line-height:1}
                    .summary-detail{font-size:11px;color:var(--muted);margin-top:7px}
                    .value-ok{color:var(--ok)}.value-warn{color:var(--warn)}.value-bad{color:var(--bad)}
                    .map-panel{overflow:hidden}
                    .map-heading{display:flex;align-items:center;justify-content:space-between;gap:15px;padding:17px 20px;border-bottom:1px solid var(--line)}
                    .map-heading h2{font-size:18px;margin:0;font-weight:750}
                    .legend{display:flex;gap:12px;flex-wrap:wrap;font-size:12px;color:var(--muted)}
                    .legend span{display:inline-flex;align-items:center;gap:5px}
                    .legend-dot{width:9px;height:9px;border-radius:50%}
                    .dot-ok{background:#22c55e}.dot-warn{background:#f59e0b}.dot-bad{background:#ef4444}
                    .table-wrap{overflow-x:auto}
                    .attendance-table{width:100%;border-collapse:separate;border-spacing:0;min-width:760px}
                    .attendance-table th,.attendance-table td{border-right:1px solid var(--line);border-bottom:1px solid var(--line);padding:9px 8px;text-align:center;font-size:12px}
                    .attendance-table th:last-child,.attendance-table td:last-child{border-right:0}
                    .attendance-table tbody tr:last-child td{border-bottom:0}
                    .attendance-table thead th{background:#f8fafc;color:#475569;font-size:11px;font-weight:750;white-space:nowrap;position:sticky;top:0;z-index:2}
                    .attendance-table tbody tr:hover td{background:#fffaf5}
                    .attendance-table .name-col{text-align:left;min-width:230px;position:sticky;left:0;background:#fff;z-index:1;font-weight:650}
                    .attendance-table thead .name-col{background:#f8fafc;z-index:3}
                    .attendance-table .percent-col{min-width:120px}
                    .date-col{min-width:64px}
                    .status{display:inline-grid;place-items:center;width:28px;height:28px;border-radius:8px;font-size:12px;font-weight:800}
                    .status-ok{background:#dcfce7;color:var(--ok)}
                    .status-warn{background:#fef3c7;color:var(--warn)}
                    .status-bad{background:#fee2e2;color:var(--bad)}
                    .percentage{font-weight:750;color:#334155}
                    .fraction{display:block;font-size:10px;color:var(--muted);margin-top:2px}
                    .empty{padding:45px 20px;text-align:center;color:var(--muted)}
                    .empty i{font-size:38px;color:#cbd5e1;display:block;margin-bottom:10px}
                    .report-footer{display:flex;justify-content:space-between;gap:15px;margin-top:22px;padding-top:15px;border-top:1px solid #dce3ea;color:var(--muted);font-size:12px}
                    @media(max-width:900px){.report-header{align-items:flex-start;flex-direction:column}.actions{width:100%;flex-wrap:wrap}.actions .btn-report{flex:1}.filter-grid{grid-template-columns:1fr}.summary-grid{grid-template-columns:repeat(2,1fr)}}
                    @media(max-width:520px){.report-shell{padding:20px 12px}.summary-grid{grid-template-columns:1fr}.map-heading{align-items:flex-start;flex-direction:column}.report-footer{flex-direction:column}}
                    @media print{
                        @page{size:landscape;margin:8mm}
                        body{background:#fff}
                        .report-shell{max-width:none;padding:0}
                        .no-print,.filters{display:none!important}
                        .report-header{margin-bottom:10px}.title-icon{width:38px;height:38px}.title-icon i{font-size:18px}
                        h1{font-size:18pt}
                        .summary-grid{grid-template-columns:repeat(5,1fr);gap:6px;margin-bottom:10px}
                        .summary-card{box-shadow:none;padding:8px 10px;border-color:#cfd6df}.summary-value{font-size:17pt}.summary-detail{margin-top:3px}
                        .map-panel{box-shadow:none;border-color:#bfc8d3;border-radius:0}
                        .map-heading{padding:7px 9px}.map-heading h2{font-size:12pt}
                        .table-wrap{overflow:visible}
                        .attendance-table{min-width:0}
                        .attendance-table th,.attendance-table td{padding:3px 2px;font-size:7.5pt}
                        .attendance-table thead th{position:static}
                        .attendance-table .name-col{position:static;min-width:115px}
                        .attendance-table .percent-col{min-width:65px}
                        .date-col{min-width:0}
                        .status{width:18px;height:18px;border-radius:4px;font-size:7pt}
                        .report-footer{margin-top:8px}
                        body.print-map-only .summary-grid{display:none!important}
                        body.print-map-only .report-header{margin-bottom:6px}
                    }
                </style>
            </head>
            <body>
                <main class="report-shell">
                    <header class="report-header">
                        <div class="report-title">
                            <div class="title-icon"><i class="bi bi-calendar-check"></i></div>
                            <div>
                                <h1>Mapa de Presença</h1>
                                <p class="subtitle">
                                    <xsl:call-template name="nome-classe">
                                        <xsl:with-param name="classe" select="$classe"/>
                                    </xsl:call-template>
                                    <xsl:text> · Ano </xsl:text><xsl:value-of select="$ano"/>
                                </p>
                            </div>
                        </div>
                        <div class="actions no-print">
                            <a href="../relatorios.jsp" class="btn-report">
                                <i class="bi bi-arrow-left"></i> Voltar
                            </a>
                            <button type="button" class="btn-report" onclick="printReport(false)">
                                <i class="bi bi-printer"></i> Relatório completo
                            </button>
                            <button type="button" class="btn-report btn-primary-report" onclick="printReport(true)">
                                <i class="bi bi-table"></i> Somente mapa
                            </button>
                        </div>
                    </header>

                    <section class="panel filters no-print">
                        <form method="get">
                            <div class="filter-grid">
                                <div>
                                    <label for="Ano">Ano</label>
                                    <select name="Ano" id="Ano">
                                        <xsl:for-each select="ANOS/ANO">
                                            <option value="{Valor}">
                                                <xsl:if test="$ano = Valor">
                                                    <xsl:attribute name="selected">selected</xsl:attribute>
                                                </xsl:if>
                                                <xsl:value-of select="Valor"/>
                                            </option>
                                        </xsl:for-each>
                                    </select>
                                </div>
                                <div>
                                    <label for="classe">Grupo</label>
                                    <select name="classe" id="classe">
                                        <option value="1">
                                            <xsl:if test="$classe = 1"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
                                            Diáconos
                                        </option>
                                        <option value="2">
                                            <xsl:if test="$classe = 2"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
                                            Candidatos
                                        </option>
                                        <option value="3">
                                            <xsl:if test="$classe = 3"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
                                            Vocacionados
                                        </option>
                                    </select>
                                </div>
                                <button type="submit" class="btn-report btn-primary-report">
                                    <i class="bi bi-funnel"></i> Aplicar filtros
                                </button>
                            </div>
                        </form>
                    </section>

                    <section class="summary-grid">
                        <div class="panel summary-card">
                            <div class="summary-label">Membros</div>
                            <div class="summary-value"><xsl:value-of select="$totalPessoas"/></div>
                            <div class="summary-detail">membros ativos</div>
                        </div>
                        <div class="panel summary-card">
                            <div class="summary-label">Encontros</div>
                            <div class="summary-value"><xsl:value-of select="$totalEncontros"/></div>
                            <div class="summary-detail">no ano selecionado</div>
                        </div>
                        <div class="panel summary-card">
                            <div class="summary-label">Presenças</div>
                            <div class="summary-value value-ok"><xsl:value-of select="$totalPresentes"/></div>
                            <div class="summary-detail">
                                <xsl:choose>
                                    <xsl:when test="$totalRegistros &gt; 0">
                                        <xsl:value-of select="format-number(($totalPresentes div $totalRegistros) * 100, '0.0')"/>%
                                    </xsl:when>
                                    <xsl:otherwise>0%</xsl:otherwise>
                                </xsl:choose>
                            </div>
                        </div>
                        <div class="panel summary-card">
                            <div class="summary-label">Justificadas</div>
                            <div class="summary-value value-warn"><xsl:value-of select="$totalJustificados"/></div>
                            <div class="summary-detail">
                                <xsl:choose>
                                    <xsl:when test="$totalRegistros &gt; 0">
                                        <xsl:value-of select="format-number(($totalJustificados div $totalRegistros) * 100, '0.0')"/>%
                                    </xsl:when>
                                    <xsl:otherwise>0%</xsl:otherwise>
                                </xsl:choose>
                            </div>
                        </div>
                        <div class="panel summary-card">
                            <div class="summary-label">Ausências</div>
                            <div class="summary-value value-bad"><xsl:value-of select="$totalAusentes"/></div>
                            <div class="summary-detail">
                                <xsl:choose>
                                    <xsl:when test="$totalRegistros &gt; 0">
                                        <xsl:value-of select="format-number(($totalAusentes div $totalRegistros) * 100, '0.0')"/>%
                                    </xsl:when>
                                    <xsl:otherwise>0%</xsl:otherwise>
                                </xsl:choose>
                            </div>
                        </div>
                    </section>

                    <section class="panel map-panel">
                        <div class="map-heading">
                            <h2>Participação por encontro</h2>
                            <div class="legend">
                                <span><i class="legend-dot dot-ok"></i>P = Presente</span>
                                <span><i class="legend-dot dot-warn"></i>J = Justificado</span>
                                <span><i class="legend-dot dot-bad"></i>F = Ausente</span>
                            </div>
                        </div>

                        <xsl:choose>
                            <xsl:when test="$totalPessoas = 0 or $totalEncontros = 0">
                                <div class="empty">
                                    <i class="bi bi-calendar-x"></i>
                                    Nenhuma informação de presença encontrada para os filtros selecionados.
                                </div>
                            </xsl:when>
                            <xsl:otherwise>
                                <div class="table-wrap">
                                    <table class="attendance-table">
                                        <thead>
                                            <tr>
                                                <th class="name-col">Nome</th>
                                                <th class="percent-col">Participação</th>
                                                <xsl:for-each select="DATAS/DATA">
                                                    <xsl:sort select="DataCompleta"/>
                                                    <th class="date-col" title="{Descricao}">
                                                        <xsl:value-of select="DataFormatada"/>
                                                    </th>
                                                </xsl:for-each>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <xsl:for-each select="ROWSET/ROW[generate-id() = generate-id(key('pessoas', IdPessoa)[1])]">
                                                <xsl:sort select="Nome"/>
                                                <xsl:variable name="idPessoa" select="IdPessoa"/>
                                                <xsl:variable name="presencas" select="count(key('pessoas', $idPessoa)[flgPresenca = 1])"/>
                                                <tr>
                                                    <td class="name-col"><xsl:value-of select="Nome"/></td>
                                                    <td class="percent-col">
                                                        <span class="percentage">
                                                            <xsl:choose>
                                                                <xsl:when test="$totalEncontros &gt; 0">
                                                                    <xsl:value-of select="format-number(($presencas div $totalEncontros) * 100, '0.0')"/>%
                                                                </xsl:when>
                                                                <xsl:otherwise>0%</xsl:otherwise>
                                                            </xsl:choose>
                                                        </span>
                                                        <span class="fraction"><xsl:value-of select="$presencas"/>/<xsl:value-of select="$totalEncontros"/></span>
                                                    </td>
                                                    <xsl:for-each select="//DATAS/DATA">
                                                        <xsl:sort select="DataCompleta"/>
                                                        <xsl:variable name="idEncontro" select="IdEncontro"/>
                                                        <xsl:variable name="registro"
                                                                      select="//ROWSET/ROW[IdPessoa = $idPessoa and IdEncontro = $idEncontro][1]"/>
                                                        <td>
                                                            <xsl:choose>
                                                                <xsl:when test="$registro/flgPresenca = 1">
                                                                    <span class="status status-ok" title="Presente">P</span>
                                                                </xsl:when>
                                                                <xsl:when test="$registro/flgPresenca = 2">
                                                                    <span class="status status-warn" title="Justificado">J</span>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <span class="status status-bad" title="Ausente">F</span>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </td>
                                                    </xsl:for-each>
                                                </tr>
                                            </xsl:for-each>
                                        </tbody>
                                    </table>
                                </div>
                            </xsl:otherwise>
                        </xsl:choose>
                    </section>

                    <footer class="report-footer">
                        <span>Mapa anual de presença nos encontros</span>
                        <span><xsl:value-of select="$totalPessoas"/> membro(s) · <xsl:value-of select="$totalEncontros"/> encontro(s)</span>
                    </footer>
                </main>

                <script>
                    function printReport(mapOnly) {
                        document.body.classList.toggle('print-map-only', mapOnly);
                        window.print();
                    }
                    window.addEventListener('afterprint', function () {
                        document.body.classList.remove('print-map-only');
                    });
                </script>
            </body>
        </html>
    </xsl:template>

    <xsl:template name="nome-classe">
        <xsl:param name="classe"/>
        <xsl:choose>
            <xsl:when test="$classe = 2">Candidatos</xsl:when>
            <xsl:when test="$classe = 3">Vocacionados</xsl:when>
            <xsl:otherwise>Diáconos</xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
