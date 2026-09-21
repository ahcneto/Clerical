<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.File" %>
<%@ page import="java.util.List" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Upload de Foto</title>
	
	
</head>
<body>
    <h1>Upload de Foto</h1>
    <form action="upload.jsp" method="post" enctype="multipart/form-data">
        <!-- Campo oculto para enviar o IdPessoa -->
        <input type="hidden" name="IdPessoa" value="<%= request.getParameter("IdPessoa") %>">
        
        <label for="file">Selecione uma foto:</label>
        <input type="file" name="file" id="file" required>
        <br><br>
        <input type="submit" value="Enviar">
    </form>

    <%
        // Verifica se o formulário foi enviado
        if (ServletFileUpload.isMultipartContent(request)) {
            // Configurações para o upload
            DiskFileItemFactory factory = new DiskFileItemFactory();
            ServletFileUpload upload = new ServletFileUpload(factory);

            try {
                // Processa o formulário e obtém os itens
                List<FileItem> items = upload.parseRequest(request);

                String idPessoa = null;

                // Primeiro, procura o campo IdPessoa nos itens do formulário
                for (FileItem item : items) {
                    if (item.isFormField() && item.getFieldName().equals("IdPessoa")) {
                        idPessoa = item.getString(); // Obtém o valor do campo IdPessoa
                        break;
                    }
                }

                // Verifica se o IdPessoa foi encontrado
                if (idPessoa == null || idPessoa.isEmpty()) {
                    out.println("<p style='color: red;'>Erro: IdPessoa não fornecido no formulário.</p>");
                } else {
                    // Agora, processa o arquivo
                    for (FileItem item : items) {
                        if (!item.isFormField()) {
                            // Define o nome do arquivo como foto_<IdPessoa>.jpg
                            String fileName = "foto_" + idPessoa + ".jpg";

                            // Obtém o caminho absoluto da pasta do aplicativo
                            String appPath = request.getServletContext().getRealPath("/");

                            // Define o caminho da pasta "fotos"
                            String fotosPath = appPath + "fotos/";

                            // Cria a pasta "fotos" se ela não existir
                            File fotosDir = new File(fotosPath);
                            if (!fotosDir.exists()) {
                                fotosDir.mkdir(); // Cria a pasta
                            }

                            // Caminho completo do arquivo
                            String filePath = fotosPath + fileName;

                            // Verifica se o arquivo já existe
                            File arquivoExistente = new File(filePath);
                            if (arquivoExistente.exists()) {
                                // Renomeia o arquivo existente, adicionando a data atual ao nome
                                SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd_HHmmss");
                                String dataAtual = dateFormat.format(new Date());
                                String novoNomeArquivo = "foto_" + idPessoa + "_" + dataAtual + ".jpg";
                                String novoCaminhoArquivo = fotosPath + novoNomeArquivo;

                                // Renomeia o arquivo
                                boolean renomeado = arquivoExistente.renameTo(new File(novoCaminhoArquivo));
                                if (renomeado) {
                                    out.println("<p>Arquivo existente renomeado para: " + novoNomeArquivo + "</p>");
                                } else {
                                    out.println("<p style='color: red;'>Erro ao renomear o arquivo existente.</p>");
                                }
                            }

                            // Salva o novo arquivo no servidor
                            File storeFile = new File(filePath);
                            item.write(storeFile);

                            out.println("<p>Foto <strong>" + fileName + "</strong> enviada com sucesso!</p>");
                            out.println("<p>Salva em: " + filePath + "</p>");

                            // Redireciona para a página /xsql/ExibePessoa.xsql com o IdPessoa
                            response.sendRedirect("../xsql/ExibePessoa.xsql?IdPessoa=" + idPessoa);
                        }
                    }
                }
            } catch (Exception e) {
                out.println("<p style='color: red;'>Erro ao processar o upload: " + e.getMessage() + "</p>");
                e.printStackTrace(); // Exibe o stack trace no console do servidor
            }
        }
    %>
</body>
</html>