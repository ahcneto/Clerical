import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.text.SimpleDateFormat;
import java.util.Base64;
import java.util.Date;
import javax.imageio.ImageIO;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

@WebServlet("/UploadFotoServlet")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 6 * 1024 * 1024)
public class UploadFotoServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        response.setCharacterEncoding("UTF-8");
        Integer usuarioId = (Integer) request.getSession().getAttribute("usuarioId");
        String idPessoa = request.getParameter("idPessoa");
        String nome = request.getParameter("nome");
        boolean ajax = "1".equals(request.getParameter("ajax"));
        if (usuarioId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().print("{\"ok\":false,\"mensagem\":\"Sessão inválida.\"}");
            return;
        }
        int pessoa;
        try { pessoa = Integer.parseInt(idPessoa); }
        catch (Exception erro) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"ok\":false,\"mensagem\":\"Pessoa inválida.\"}");
            return;
        }
        if (pessoa != usuarioId.intValue()) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().print("{\"ok\":false,\"mensagem\":\"Você só pode alterar a própria foto.\"}");
            return;
        }

        // Caminho físico da pasta "fotos"
        String uploadPath = getServletContext().getRealPath("/") + "fotos/";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        // Pasta de backup
        File bkpDir = new File(uploadPath + "bkp/");
        if (!bkpDir.exists()) bkpDir.mkdirs();

        // Nome do arquivo principal
        String fileName = "foto_" + idPessoa + ".jpg";
        File fotoAntiga = new File(uploadPath + fileName);

        try {
            String contentType = request.getContentType();

            if (contentType != null && contentType.toLowerCase().startsWith("multipart/")) {
                // 📂 Upload de arquivo tradicional
                Part filePart = request.getPart("foto");
                if (filePart != null && filePart.getSize() > 0) {
                    String tipo = filePart.getContentType();
                    if (tipo == null || !tipo.toLowerCase().startsWith("image/"))
                        throw new IllegalArgumentException("Selecione um arquivo de imagem válido.");
                    BufferedImage original = ImageIO.read(filePart.getInputStream());
                    if (original == null) throw new IllegalArgumentException("Não foi possível ler a imagem.");
                    if (fotoAntiga.exists()) {
                        String data = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
                        fotoAntiga.renameTo(new File(bkpDir, "foto_" + idPessoa + "_" + data + ".jpg"));
                    }
                    BufferedImage jpg = new BufferedImage(original.getWidth(), original.getHeight(), BufferedImage.TYPE_INT_RGB);
                    Graphics2D graphics = jpg.createGraphics();
                    graphics.drawImage(original, 0, 0, java.awt.Color.WHITE, null);
                    graphics.dispose();
                    ImageIO.write(jpg, "jpg", new File(uploadPath + fileName));
                }
            } else {
                // 📸 Upload de foto em Base64 (câmera)
                String fotoBase64 = request.getParameter("foto_base64");
                if (fotoBase64 != null && !fotoBase64.isEmpty()) {
                    // Remove prefixo "data:image/jpeg;base64,"
                    if (fotoBase64.contains(",")) {
                        fotoBase64 = fotoBase64.split(",")[1];
                    }
                    byte[] imageBytes = Base64.getDecoder().decode(fotoBase64);
                    try (FileOutputStream fos = new FileOutputStream(uploadPath + fileName)) {
                        fos.write(imageBytes);
                    }
                }
            }

        } catch (Exception e) {
            if (ajax) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().print("{\"ok\":false,\"mensagem\":\"" +
                    e.getMessage().replace("\"", "\\\"") + "\"}");
                return;
            }
            throw new ServletException("Erro ao salvar a foto: " + e.getMessage(), e);
        }

        // Redirecionar de volta para a página JSP
        if (ajax) {
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().print("{\"ok\":true,\"foto\":\"fotos/" + fileName + "\"}");
            return;
        }
        String contextPath = request.getContextPath();
		request.setAttribute("idPessoa", idPessoa);
		request.setAttribute("nome", nome);
		//request.getRequestDispatcher("/auto/paginaFoto.jsp").forward(request, response); 
        response.sendRedirect(contextPath + "/auto/paginaFoto.jsp?idPessoa=" + idPessoa + "&nome=" + nome);
    }
}
