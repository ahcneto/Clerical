<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" encoding="UTF-8" indent="yes"/>

    <xsl:key name="por-regiao" match="ROW" use="IdRegiao"/>
    <xsl:key name="por-paroquia" match="ROW" use="concat(IdRegiao, '|', IdParoquia)"/>

    <xsl:template match="/">
        <xsl:apply-templates select="SQL/ROWSET[last()]"/>
    </xsl:template>

    <xsl:template match="SQL/ROWSET">
        <xsl:variable name="classeInformada" select="//request/parameters/classe"/>
        <xsl:variable name="classe">
            <xsl:choose>
                <xsl:when test="$classeInformada != ''"><xsl:value-of select="$classeInformada"/></xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="total" select="count(ROW)"/>
        <xsl:variable name="totalRegioes"
                      select="count(ROW[generate-id() = generate-id(key('por-regiao', IdRegiao)[1])])"/>
        <xsl:variable name="totalParoquias"
                      select="count(ROW[generate-id() = generate-id(key('por-paroquia', concat(IdRegiao, '|', IdParoquia))[1])])"/>

        <html lang="pt-br">
            <head>
                <meta charset="UTF-8"/>
                <meta name="viewport" content="width=device-width, initial-scale=1"/>
                <title>Listagem por Região</title>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet"/>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet"/>
                <style>
                    :root{--accent:#c96a0a;--ink:#172033;--muted:#64748b;--line:#e8edf3;--surface:#fff;--page:#f6f8fb}
                    *{box-sizing:border-box}
                    body{margin:0;background:var(--page);color:var(--ink);font-family:Inter,system-ui,-apple-system,"Segoe UI",sans-serif}
                    .report-shell{max-width:1180px;margin:0 auto;padding:32px 20px 48px}
                    .report-header{display:flex;align-items:center;justify-content:space-between;gap:20px;margin-bottom:24px}
                    .report-title{display:flex;align-items:center;gap:15px}
                    .title-icon{width:52px;height:52px;border-radius:15px;background:#fff1e6;color:var(--accent);display:grid;place-items:center;font-size:24px}
                    h1{font-size:29px;line-height:1.15;margin:0 0 5px;font-weight:750}
                    .subtitle{color:var(--muted);margin:0}
                    .actions{display:flex;gap:10px}
                    .btn-report{min-height:42px;border-radius:11px;padding:9px 15px;font-weight:650;text-decoration:none;display:inline-flex;align-items:center;gap:8px;border:1px solid #dbe2ea;background:#fff;color:#334155}
                    .btn-report:hover{border-color:var(--accent);color:var(--accent)}
                    .btn-primary-report{background:var(--accent);border-color:var(--accent);color:#fff}
                    .btn-primary-report:hover{background:#ad5908;color:#fff}
                    .panel{background:var(--surface);border:1px solid var(--line);border-radius:16px;box-shadow:0 3px 14px rgba(15,23,42,.045)}
                    .filters{padding:20px;margin-bottom:18px}
                    .filter-grid{display:grid;grid-template-columns:1fr 1.35fr auto;gap:14px;align-items:end}
                    label{display:block;font-size:13px;font-weight:700;color:#475569;margin-bottom:7px}
                    select{width:100%;height:44px;border:1px solid #d9e0e8;border-radius:11px;background:#fff;padding:0 12px;color:#1e293b}
                    .summary-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:22px}
                    .summary-card{padding:18px 20px;position:relative;overflow:hidden}
                    .summary-label{font-size:13px;color:var(--muted);font-weight:650;margin-bottom:7px}
                    .summary-value{font-size:29px;font-weight:760;line-height:1}
                    .summary-card i{position:absolute;right:18px;bottom:13px;font-size:30px;color:#f1cda9}
                    .section-heading{display:flex;justify-content:space-between;align-items:end;margin:29px 2px 13px}
                    .section-heading h2{font-size:19px;margin:0;font-weight:750}
                    .section-heading span{font-size:13px;color:var(--muted)}
                    .region-summary{display:grid;grid-template-columns:repeat(3,1fr);gap:12px;margin-bottom:24px}
                    .region-summary-card{padding:16px 18px;display:flex;justify-content:space-between;gap:14px;align-items:center}
                    .region-summary-name{font-size:14px;font-weight:700}
                    .region-summary-sub{font-size:12px;color:var(--muted);margin-top:3px}
                    .region-total{min-width:42px;height:32px;padding:0 10px;border-radius:9px;background:#fff1e6;color:#a85108;display:grid;place-items:center;font-weight:750}
                    .region-card{margin-bottom:18px;overflow:hidden}
                    .region-header{padding:18px 22px;background:linear-gradient(90deg,#fff8f1,#fff);display:flex;align-items:center;justify-content:space-between;border-bottom:1px solid var(--line)}
                    .region-name{font-size:18px;font-weight:760;display:flex;align-items:center;gap:9px}
                    .region-name i{color:var(--accent)}
                    .tag{font-size:12px;font-weight:700;padding:6px 10px;border-radius:999px;background:#fff1e6;color:#a85108}
                    .parish{padding:20px 22px;border-bottom:1px solid var(--line)}
                    .parish:last-child{border-bottom:0}
                    .parish-header{display:flex;justify-content:space-between;gap:12px;margin-bottom:13px}
                    .parish-name{font-size:15px;font-weight:730}
                    .parish-location{font-size:12px;color:var(--muted);margin-top:3px}
                    .parish-count{font-size:12px;color:var(--muted);white-space:nowrap}
                    .people-table{width:100%;border-collapse:collapse}
                    .people-table th{padding:8px 10px;background:#f8fafc;border-bottom:1px solid #dfe6ee;color:#64748b;font-size:11px;text-transform:uppercase;letter-spacing:.04em;text-align:left}
                    .people-table td{padding:10px;border-bottom:1px solid #edf1f5;font-size:13px;vertical-align:middle}
                    .people-table tbody tr:last-child td{border-bottom:0}
                    .people-table tbody tr:hover{background:#fffaf5}
                    .person-order{width:46px;color:#94a3b8;text-align:center}
                    .person-name{font-weight:650}
                    .person-birth{width:145px;color:var(--muted)}
                    .person-age{width:90px;white-space:nowrap;font-weight:650;color:#475569}
                    .empty{padding:45px 20px;text-align:center;color:var(--muted)}
                    .empty i{font-size:38px;color:#cbd5e1;display:block;margin-bottom:10px}
                    .report-footer{display:flex;justify-content:space-between;gap:15px;margin-top:24px;padding-top:16px;border-top:1px solid #dce3ea;color:var(--muted);font-size:12px}
                    .tag-group-1{background:#dcfce7;color:#15803d}.tag-group-2{background:#fef3c7;color:#b45309}.tag-group-3{background:#dbeafe;color:#1d4ed8}
                    @media(max-width:800px){.report-header{align-items:flex-start;flex-direction:column}.actions{width:100%;flex-wrap:wrap}.actions .btn-report{flex:1;justify-content:center}.filter-grid{grid-template-columns:1fr}.summary-grid{grid-template-columns:repeat(2,1fr)}.region-summary{grid-template-columns:1fr 1fr}}
                    @media(max-width:500px){.report-shell{padding:20px 12px}.summary-grid,.region-summary{grid-template-columns:1fr}.region-header,.parish{padding-left:16px;padding-right:16px}.person{align-items:flex-start}.report-footer{flex-direction:column}}
                    @media print{
                        @page{size:A4;margin:13mm}
                        body{background:#fff;font-size:10pt}
                        .report-shell{max-width:none;padding:0}
                        .no-print,.filters{display:none!important}
                        .report-header{margin-bottom:15px}
                        .title-icon{width:38px;height:38px}.title-icon i{font-size:18px}
                        h1{font-size:20pt}.summary-grid{grid-template-columns:repeat(4,1fr);gap:7px;margin-bottom:14px}
                        .summary-card{box-shadow:none;padding:10px;border-color:#cfd6df}.summary-value{font-size:18pt}.summary-card i{display:none}
                        .region-card{box-shadow:none;break-inside:avoid;border-color:#bfc8d3;margin-bottom:10px}
                        .region-header{padding:9px 12px}.region-name{font-size:13pt}
                        .parish{padding:9px 12px;break-inside:avoid}.parish-header{margin-bottom:6px}
                        .people-table th{padding:4px 6px}.people-table td{padding:4px 6px}
                        .report-footer{margin-top:12px}
                        body.print-list-only .summary-grid,
                        body.print-list-only .region-summary-section{display:none!important}
                        body.print-list-only .report-header{margin-bottom:8px}
                    }
                </style>
            </head>
            <body>
                <main class="report-shell">
                    <header class="report-header">
                        <div class="report-title">
                            <div class="title-icon"><i class="bi bi-people"></i></div>
                            <div>
                                <h1>Listagem por Região</h1>
                                <p class="subtitle">
                                    Membros ativos ·
                                    <xsl:call-template name="nome-classe">
                                        <xsl:with-param name="classe" select="$classe"/>
                                    </xsl:call-template>
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
                                <i class="bi bi-list-ul"></i> Somente listagem
                            </button>
                        </div>
                    </header>

                    <section class="panel filters no-print">
                        <form method="get">
                            <div class="filter-grid">
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
                                <div>
                                    <label for="regiao">Região episcopal</label>
                                    <select name="regiao" id="regiao">
                                        <option value="0">Todas as regiões</option>
                                        <xsl:for-each select="//REGIOES/REGIAO">
                                            <xsl:variable name="id" select="IdRegiao"/>
                                            <option value="{$id}">
                                                <xsl:if test="//request/parameters/regiao = $id">
                                                    <xsl:attribute name="selected">selected</xsl:attribute>
                                                </xsl:if>
                                                <xsl:value-of select="Regiao"/>
                                            </option>
                                        </xsl:for-each>
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
                            <div class="summary-value"><xsl:value-of select="$total"/></div>
                            <i class="bi bi-people"></i>
                        </div>
                        <div class="panel summary-card">
                            <div class="summary-label">Regiões</div>
                            <div class="summary-value"><xsl:value-of select="$totalRegioes"/></div>
                            <i class="bi bi-geo-alt"></i>
                        </div>
                        <div class="panel summary-card">
                            <div class="summary-label">Paróquias</div>
                            <div class="summary-value"><xsl:value-of select="$totalParoquias"/></div>
                            <i class="bi bi-building"></i>
                        </div>
                        <div class="panel summary-card">
                            <div class="summary-label">Grupo</div>
                            <span class="tag tag-group-{$classe}">
                                <xsl:call-template name="nome-classe">
                                    <xsl:with-param name="classe" select="$classe"/>
                                </xsl:call-template>
                            </span>
                            <i class="bi bi-bookmark"></i>
                        </div>
                    </section>

                    <xsl:if test="$total &gt; 0">
                        <section class="region-summary-section">
                            <div class="section-heading">
                                <h2>Resumo por região</h2>
                                <span>Distribuição dos membros encontrados</span>
                            </div>
                            <div class="region-summary">
                                <xsl:for-each select="ROW[generate-id() = generate-id(key('por-regiao', IdRegiao)[1])]">
                                    <xsl:sort select="Regiao"/>
                                    <xsl:variable name="idRegiao" select="IdRegiao"/>
                                    <div class="panel region-summary-card">
                                        <div>
                                            <div class="region-summary-name"><xsl:value-of select="Regiao"/></div>
                                            <div class="region-summary-sub">
                                                <xsl:value-of select="count(key('por-regiao', $idRegiao)[generate-id() = generate-id(key('por-paroquia', concat(IdRegiao, '|', IdParoquia))[1])])"/>
                                                <xsl:text> paróquia(s)</xsl:text>
                                            </div>
                                        </div>
                                        <div class="region-total"><xsl:value-of select="count(key('por-regiao', $idRegiao))"/></div>
                                    </div>
                                </xsl:for-each>
                            </div>
                        </section>
                    </xsl:if>

                    <div class="section-heading">
                        <h2>Membros por região e paróquia</h2>
                        <span><xsl:value-of select="$total"/> registro(s)</span>
                    </div>

                    <xsl:choose>
                        <xsl:when test="$total = 0">
                            <div class="panel empty">
                                <i class="bi bi-search"></i>
                                Nenhum membro encontrado para os filtros selecionados.
                            </div>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each select="ROW[generate-id() = generate-id(key('por-regiao', IdRegiao)[1])]">
                                <xsl:sort select="Regiao"/>
                                <xsl:variable name="idRegiao" select="IdRegiao"/>
                                <section class="panel region-card">
                                    <div class="region-header">
                                        <div class="region-name">
                                            <i class="bi bi-geo-alt-fill"></i>
                                            <xsl:value-of select="Regiao"/>
                                        </div>
                                        <span class="tag"><xsl:value-of select="count(key('por-regiao', $idRegiao))"/> membros</span>
                                    </div>

                                    <xsl:for-each select="key('por-regiao', $idRegiao)[generate-id() = generate-id(key('por-paroquia', concat(IdRegiao, '|', IdParoquia))[1])]">
                                        <xsl:sort select="Paroquia"/>
                                        <xsl:variable name="chaveParoquia" select="concat(IdRegiao, '|', IdParoquia)"/>
                                        <div class="parish">
                                            <div class="parish-header">
                                                <div>
                                                    <div class="parish-name"><xsl:value-of select="Paroquia"/></div>
                                                    <div class="parish-location">
                                                        <xsl:value-of select="Bairro"/>
                                                        <xsl:if test="Bairro != '' and Cidade != ''"> · </xsl:if>
                                                        <xsl:value-of select="Cidade"/>
                                                    </div>
                                                </div>
                                                <div class="parish-count"><xsl:value-of select="count(key('por-paroquia', $chaveParoquia))"/> membro(s)</div>
                                            </div>
                                            <table class="people-table">
                                                <thead>
                                                    <tr>
                                                        <th class="person-order">#</th>
                                                        <th>Nome</th>
                                                        <th class="person-birth">Nascimento</th>
                                                        <th class="person-age">Idade</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <xsl:for-each select="key('por-paroquia', $chaveParoquia)">
                                                        <xsl:sort select="Nome"/>
                                                        <tr>
                                                            <td class="person-order"><xsl:value-of select="position()"/></td>
                                                            <td class="person-name"><xsl:value-of select="Nome"/></td>
                                                            <td class="person-birth">
                                                                <xsl:choose>
                                                                    <xsl:when test="DtNascimento != ''"><xsl:value-of select="DtNascimento"/></xsl:when>
                                                                    <xsl:otherwise>—</xsl:otherwise>
                                                                </xsl:choose>
                                                            </td>
                                                            <td class="person-age">
                                                                <xsl:choose>
                                                                    <xsl:when test="Idade != ''"><xsl:value-of select="Idade"/> anos</xsl:when>
                                                                    <xsl:otherwise>—</xsl:otherwise>
                                                                </xsl:choose>
                                                            </td>
                                                        </tr>
                                                    </xsl:for-each>
                                                </tbody>
                                            </table>
                                        </div>
                                    </xsl:for-each>
                                </section>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>

                    <footer class="report-footer">
                        <span>Relatório de membros ativos por região episcopal</span>
                        <span>Total: <xsl:value-of select="$total"/> registro(s)</span>
                    </footer>
                </main>
                <script>
                    function printReport(listOnly) {
                        document.body.classList.toggle('print-list-only', listOnly);
                        window.print();
                    }
                    window.addEventListener('afterprint', function () {
                        document.body.classList.remove('print-list-only');
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
