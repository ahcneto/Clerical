<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Tirar Foto com Câmera</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <link rel="stylesheet" href="https://code.jquery.com/mobile/1.4.5/jquery.mobile.min.css" />
    <script src="https://code.jquery.com/mobile/1.4.5/jquery.mobile.min.js"></script>
    <style>
        video, canvas { width: 100%; max-width: 300px; }
    </style>
</head>
<body>
<div data-role="page">
    <div data-role="header">
        <h1>Captura de Foto</h1>
    </div>
    <div data-role="content">
        <form id="formFoto" method="post" action="UploadFotoServlet">
            <label>ID Pessoa:</label>
            <input type="text" name="id_pessoa" required>
            <label>Nome:</label>
            <input type="text" name="nome" required>
            <label>Classe:</label>
            <input type="text" name="classe" required>

            <video id="video" autoplay></video>
            <button type="button" id="btnCapture" data-icon="camera">Tirar Foto</button>
            <canvas id="canvas" style="display:none;"></canvas>
            <img id="preview" src="" alt="Prévia" style="display:none; max-width:100%;" />

            <input type="hidden" name="foto_base64" id="foto_base64">
            <button type="submit" data-icon="check">Enviar</button>
        </form>
    </div>
</div>

<script>
navigator.mediaDevices.getUserMedia({ video: true })
    .then(stream => {
        document.getElementById('video').srcObject = stream;
    })
    .catch(err => alert("Erro ao acessar a câmera: " + err));

$("#btnCapture").on("click", function() {
    const video = document.getElementById('video');
    const canvas = document.getElementById('canvas');
    canvas.style.display = 'block';
    const ctx = canvas.getContext('2d');
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    ctx.drawImage(video, 0, 0);
    const dataURL = canvas.toDataURL('image/jpeg');
    $("#foto_base64").val(dataURL);
    $("#preview").attr("src", dataURL).show();
});
</script>
</body>
</html>
