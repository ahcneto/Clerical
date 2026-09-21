<%@ page contentType="text/html;charset=UTF-8" %>
<%
if (session.getAttribute("usuarioId") != null) {
    response.sendRedirect("index.jsp");
    return;
}

String erro = request.getParameter("erro");
%>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Clerical</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">

    <link rel="stylesheet" href="css/style.css">
</head>
<body class="login-body">

<div class="login-container">

    <div class="login-left">
        <div>
            <h1>Clerical</h1>
            <h3>CAD - Comissão Arquidiocesana dos Diáconos</h3>
            <h3>Arquidiocese de Fortaleza</h3>

            <p class="mt-4">
                Sistema de gestão para membros, encontros,
                presença e contribuições financeiras.
            </p>
        </div>
    </div>

    <div class="login-right">

        <div class="login-card">

            <h2 class="fw-bold mb-3">Entrar</h2>
            <p class="text-muted mb-4">Acesse sua conta</p>
			
			<div id="loginError" class="login-error mt-3"
     style="<%= erro != null ? "display:block;" : "display:none;" %>">

    <%= erro != null ? "Telefone ou senha inválidos." : "" %>

</div>

            <div class="mb-3">
                <label>Telefone</label>
                <input id="telefone"
                       class="form-control"
                       placeholder="(85) 99999-9999">
            </div>

            <div class="mb-4">
                <label>Senha</label>
                <input id="senha"
                       type="password"
                       class="form-control"
                       placeholder="Data de nascimento (DDMMAAAA ou DDMMAA)">
            </div>

           <button class="btn btn-orange w-100" onclick="login()">
			Entrar
		</button>

        </div>

    </div>

</div>
<script src="js/login.js"></script>
</body>
</html>
