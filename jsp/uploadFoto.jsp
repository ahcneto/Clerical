<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Upload de Foto</title>
    <link rel="stylesheet" href="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.css" />
    <script src="https://code.jquery.com/jquery-1.12.4.min.js"></script>
    <script src="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.js"></script>
</head>
<body>
<div data-role="page" id="page1">
    <div data-role="header">
        <h1>Foto da Pessoa</h1>
    </div>
    <div data-role="content">
        <form id="formFoto" action="UploadFotoServlet" method="post" enctype="multipart/form-data">
            <label for="id_pessoa">ID Pessoa:</label>
            <input type="text" name="id_pessoa" id="id_pessoa" required>

            <label for="nome">Nome:</label>
            <input type="text" name="nome" id="nome" required>

            <label for="classe">Classe:</label>
            <input type="text" name="classe" id="classe" required>

            <label for="foto">Escolher/Tirar Foto:</label>
            <input type="file" name="foto" accept="image/*" capture="environment" required>

            <input type="submit" value="Enviar Foto" data-icon="check">
        </form>
    </div>
</div>
</body>
</html>
