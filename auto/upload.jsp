<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Upload de Foto</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- jQuery Mobile -->
    <link rel="stylesheet" href="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.css">
    <script src="https://code.jquery.com/jquery-1.11.1.min.js"></script>
    <script src="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.js"></script>

    <script>
        function capturarCamera() {
            const video = document.querySelector("#video");
            const canvas = document.querySelector("#canvas");
            const fotoInput = document.querySelector("#fotoCapturada");
            const context = canvas.getContext("2d");

            navigator.mediaDevices.getUserMedia({ video: true })
                .then(stream => {
                    video.srcObject = stream;
                    video.play();
                });

            document.querySelector("#tirarFoto").onclick = function() {
                context.drawImage(video, 0, 0, canvas.width, canvas.height);
                canvas.toBlob(blob => {
                    const file = new File([blob], "captura.jpg", { type: "image/jpeg" });
                    const dataTransfer = new DataTransfer();
                    dataTransfer.items.add(file);
                    fotoInput.files = dataTransfer.files;
                    document.querySelector("#formCamera").submit();
                }, "image/jpeg", 0.9);
            };
        }
    </script>
</head>
<body>
<div data-role="page" id="paginaUpload">
    <div data-role="header">
        <h1>Upload de Foto</h1>
    </div>

    <div role="main" class="ui-content">
        <%
            String idPessoa = request.getParameter("idPessoa");
            String nome = request.getParameter("nome");
            String fotoAtual = "uploads/fotos/" + idPessoa + ".jpg";
        %>

        <h3>Foto de <%= nome %> (ID: <%= idPessoa %>)</h3>
        <img src="<%= fotoAtual %>?t=<%= System.currentTimeMillis() %>" width="200" 
             onerror="this.src='uploads/fotos/default.jpg'" 
             style="display:block; margin:auto;">

        <div data-role="collapsible" data-collapsed="false">
            <h4>Escolher foto do dispositivo</h4>
            <form action="UploadFotoServlet" method="post" enctype="multipart/form-data">
                <input type="hidden" name="idPessoa" value="<%= idPessoa %>">
                <input type="file" name="foto" accept="image/*">
                <button type="submit" data-role="button" data-icon="arrow-u">Enviar</button>
            </form>
        </div>

        <div data-role="collapsible">
            <h4>Capturar com a câmera</h4>
            <video id="video" width="320" height="240" autoplay style="display:block; margin:auto;"></video>
            <canvas id="canvas" width="320" height="240" style="display:none;"></canvas>
            <form id="formCamera" action="UploadFotoServlet" method="post" enctype="multipart/form-data">
                <input type="hidden" name="idPessoa" value="<%= idPessoa %>">
                <input type="file" name="foto" id="fotoCapturada" style="display:none;">
                <button type="button" id="tirarFoto" data-role="button" data-icon="camera">Tirar Foto e Enviar</button>
            </form>
            <script>capturarCamera();</script>
        </div>
    </div>
</div>
</body>
</html>
