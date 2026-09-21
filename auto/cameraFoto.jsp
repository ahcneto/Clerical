<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>

<%
    String idPessoa = request.getParameter("idPessoa");
    String nome = request.getParameter("nome");
   
   if (idPessoa == null) {
		response.sendRedirect("login.jsp?erro=1");
	}
%>
<html>
<head>
    <title>Tirar Foto com Câmera</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
       <link rel="stylesheet" href="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.css">
    <script src="https://code.jquery.com/jquery-1.11.3.min.js"></script>
    <script src="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.js"></script>
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
	
	
	<form id="formFoto" method="post" action="<%=request.getContextPath()%>/UploadFotoServlet" data-ajax="false">
		
		<input type="hidden" name="idPessoa" value="<%=idPessoa%>" readonly>
		<input type="hidden" name="nome" value="<%=nome%>" readonly>

		<p><strong>Nome:</strong> <%= nome %></p>
	    <video id="video" autoplay></video>
		<button type="button" id="btnCapture" data-icon="camera">Tirar Foto</button>
		<img id="preview" src="" alt="Prévia" style="display:none; max-width:100%;" />
		<button type="submit" data-icon="check">Enviar</button>
		
		<canvas id="canvas" style="display:none;"></canvas>
		

		<input type="hidden" name="foto_base64" id="foto_base64">
		
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
