import cad.db.Database;
import java.io.*;
import java.nio.file.*;
import java.sql.*;
import java.text.Normalizer;
import java.util.Locale;
import javax.servlet.*;
import javax.servlet.http.*;

public class DocumentoMembroServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final int MAXIMO = 3 * 1024 * 1024;

    public void init() throws ServletException {
        try (Connection c=Database.getConnection(); Statement s=c.createStatement()) {
            if(!coluna(c,"documentacao_checklist_item","PermiteUpload"))s.executeUpdate("ALTER TABLE documentacao_checklist_item ADD COLUMN PermiteUpload TINYINT(1) NOT NULL DEFAULT 0 AFTER ExibirMembro");
            if(!coluna(c,"documentacao_checklist_item","PrefixoArquivo"))s.executeUpdate("ALTER TABLE documentacao_checklist_item ADD COLUMN PrefixoArquivo VARCHAR(40) NULL AFTER PermiteUpload");
            s.executeUpdate("CREATE TABLE IF NOT EXISTS documentacao_pessoa_arquivo (IdPessoa INT NOT NULL,IdItem INT NOT NULL,NomeArquivo VARCHAR(255) NOT NULL,NomeOriginal VARCHAR(255) NULL,TipoMime VARCHAR(100) NOT NULL,TamanhoBytes INT NOT NULL,DtUpload DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,IdUsuarioUpload INT NOT NULL,PRIMARY KEY(IdPessoa,IdItem),KEY idx_documentacao_arquivo_pessoa(IdPessoa,DtUpload),CONSTRAINT fk_documentacao_arquivo_item FOREIGN KEY(IdItem) REFERENCES documentacao_checklist_item(IdItem)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        } catch(Exception e) { throw new ServletException("Não foi possível preparar o armazenamento de documentos.",e); }
    }

    private boolean coluna(Connection c,String tabela,String nome)throws SQLException{
        try(ResultSet r=c.getMetaData().getColumns(c.getCatalog(),null,tabela,nome)){return r.next();}
    }
    private String json(String s){return s==null?"":s.replace("\\","\\\\").replace("\"","\\\"").replace("\r","\\r").replace("\n","\\n");}
    private void erro(HttpServletResponse r,int status,String mensagem)throws IOException{r.setStatus(status);r.setContentType("application/json;charset=UTF-8");r.getWriter().print("{\"ok\":false,\"mensagem\":\""+json(mensagem)+"\"}");}
    private int inteiro(String s,int padrao){try{return Integer.parseInt(s);}catch(Exception e){return padrao;}}
    private String seguro(String s){
        String n=Normalizer.normalize(s==null?"":s,Normalizer.Form.NFD).replaceAll("\\p{M}","").toUpperCase(Locale.ROOT).replaceAll("[^A-Z0-9]+","_").replaceAll("^_+|_+$","");
        return n.isEmpty()?"ARQUIVO":n;
    }
    private File pasta(){File f=new File(getServletContext().getRealPath("/WEB-INF"),"documentos_membros");if(!f.exists()&&!f.mkdirs())throw new IllegalStateException("Não foi possível criar a pasta de documentos.");return f;}
    private String[] tipo(byte[] b){
        if(b.length>=4&&b[0]=='%'&&b[1]=='P'&&b[2]=='D'&&b[3]=='F')return new String[]{"PDF","application/pdf"};
        if(b.length>=3&&(b[0]&255)==255&&(b[1]&255)==216&&(b[2]&255)==255)return new String[]{"JPG","image/jpeg"};
        if(b.length>=8&&(b[0]&255)==137&&b[1]=='P'&&b[2]=='N'&&b[3]=='G')return new String[]{"PNG","image/png"};
        if(b.length>=6&&b[0]=='G'&&b[1]=='I'&&b[2]=='F')return new String[]{"GIF","image/gif"};
        if(b.length>=12&&b[0]=='R'&&b[1]=='I'&&b[2]=='F'&&b[3]=='F'&&b[8]=='W'&&b[9]=='E'&&b[10]=='B'&&b[11]=='P')return new String[]{"WEBP","image/webp"};
        return null;
    }
    private byte[] ler(Part p)throws IOException{
        if(p.getSize()<=0||p.getSize()>MAXIMO)throw new IllegalArgumentException("O arquivo deve ter no máximo 3 MB.");
        ByteArrayOutputStream o=new ByteArrayOutputStream((int)p.getSize());byte[] buf=new byte[8192];int total=0,l;
        try(InputStream in=p.getInputStream()){while((l=in.read(buf))!=-1){total+=l;if(total>MAXIMO)throw new IllegalArgumentException("O arquivo deve ter no máximo 3 MB.");o.write(buf,0,l);}}
        return o.toByteArray();
    }

    protected void doPost(HttpServletRequest req,HttpServletResponse resp)throws IOException,ServletException{
        req.setCharacterEncoding("UTF-8");Integer usuario=(Integer)req.getSession().getAttribute("usuarioId");
        if(usuario==null){erro(resp,401,"Sessão inválida.");return;}
        int item=inteiro(req.getParameter("item"),0);Part parte;
        try{parte=req.getPart("arquivo");}catch(Exception e){erro(resp,400,"Não foi possível receber o arquivo. Verifique o limite de 3 MB.");return;}
        if(item==0||parte==null){erro(resp,400,"Item ou arquivo inválido.");return;}
        try{
            byte[] bytes=ler(parte);String[] tipo=tipo(bytes);if(tipo==null)throw new IllegalArgumentException("Envie um PDF ou uma imagem JPG, PNG ou GIF.");
            String sigla,prefixo,nomePessoa;
            try(Connection c=Database.getConnection();PreparedStatement p=c.prepareStatement("SELECT g.Sigla,i.PrefixoArquivo,p.Nome FROM pessoas p JOIN grupos g ON g.IdGrupo=p.Classe JOIN documentacao_checklist ch ON ch.Classe=p.Classe AND ch.StatusChecklist='ATIVO' JOIN documentacao_checklist_item i ON i.IdChecklist=ch.IdChecklist AND i.IdItem=? AND i.StatusItem='ATIVO' AND i.ExibirMembro=1 AND i.PermiteUpload=1 WHERE p.IdPessoa=? AND p.Status=1")){
                p.setInt(1,item);p.setInt(2,usuario);try(ResultSet r=p.executeQuery()){if(!r.next())throw new IllegalArgumentException("Este item não está disponível para upload.");sigla=r.getString(1);prefixo=r.getString(2);nomePessoa=r.getString(3);}
                if(sigla==null||sigla.trim().isEmpty())throw new IllegalArgumentException("O grupo não possui sigla cadastrada.");String[] nomes=seguro(nomePessoa).split("_");String dois=nomes[0]+(nomes.length>1?"_"+nomes[1]:"");
                String nome=seguro(sigla)+"_"+seguro(prefixo)+"_"+usuario+"_"+dois+"."+tipo[0];
                File destino=new File(pasta(),nome);Path temporario=Files.createTempFile(pasta().toPath(),"UPLOAD_",".TMP");Files.write(temporario,bytes);
                try{Files.move(temporario,destino.toPath(),StandardCopyOption.REPLACE_EXISTING,StandardCopyOption.ATOMIC_MOVE);}catch(AtomicMoveNotSupportedException e){Files.move(temporario,destino.toPath(),StandardCopyOption.REPLACE_EXISTING);}
                try(PreparedStatement grava=c.prepareStatement("INSERT INTO documentacao_pessoa_arquivo(IdPessoa,IdItem,NomeArquivo,NomeOriginal,TipoMime,TamanhoBytes,IdUsuarioUpload) VALUES(?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE NomeArquivo=VALUES(NomeArquivo),NomeOriginal=VALUES(NomeOriginal),TipoMime=VALUES(TipoMime),TamanhoBytes=VALUES(TamanhoBytes),DtUpload=NOW(),IdUsuarioUpload=VALUES(IdUsuarioUpload)")){grava.setInt(1,usuario);grava.setInt(2,item);grava.setString(3,nome);grava.setString(4,parte.getSubmittedFileName());grava.setString(5,tipo[1]);grava.setInt(6,bytes.length);grava.setInt(7,usuario);grava.executeUpdate();}
                try(PreparedStatement entrega=c.prepareStatement("INSERT INTO documentacao_pessoa_item(IdPessoa,IdItem,StatusEntrega,DtConclusao,IdUsuarioAtualizacao) VALUES(?,?,'CONCLUIDO',CURDATE(),?) ON DUPLICATE KEY UPDATE StatusEntrega='CONCLUIDO',DtConclusao=CURDATE(),IdUsuarioAtualizacao=VALUES(IdUsuarioAtualizacao),DtAtualizacao=NOW()")){entrega.setInt(1,usuario);entrega.setInt(2,item);entrega.setInt(3,usuario);entrega.executeUpdate();}
                resp.setContentType("application/json;charset=UTF-8");resp.getWriter().print("{\"ok\":true,\"arquivo\":\""+json(nome)+"\"}");
            }
        }catch(IllegalArgumentException e){erro(resp,400,e.getMessage());}catch(Exception e){erro(resp,500,"Não foi possível salvar o arquivo.");}
    }

    protected void doGet(HttpServletRequest req,HttpServletResponse resp)throws IOException{
        Integer usuario=(Integer)req.getSession().getAttribute("usuarioId");String perfil=(String)req.getSession().getAttribute("usuarioPerfil");
        if(usuario==null){resp.sendError(401);return;}int pessoa=inteiro(req.getParameter("pessoa"),usuario),item=inteiro(req.getParameter("item"),0);
        if(pessoa!=usuario&&!("ADM".equals(perfil)||"REP".equals(perfil)||"EXT".equals(perfil))){resp.sendError(403);return;}
        try(Connection c=Database.getConnection();PreparedStatement p=c.prepareStatement("SELECT NomeArquivo,TipoMime FROM documentacao_pessoa_arquivo WHERE IdPessoa=? AND IdItem=?")){
            p.setInt(1,pessoa);p.setInt(2,item);try(ResultSet r=p.executeQuery()){if(!r.next()){resp.sendError(404);return;}String nome=r.getString(1),mime=r.getString(2);File f=new File(pasta(),nome);if(!f.isFile()){resp.sendError(404);return;}resp.setContentType(mime);resp.setHeader("Content-Disposition","inline; filename=\""+nome+"\"");resp.setContentLengthLong(f.length());Files.copy(f.toPath(),resp.getOutputStream());}
        }catch(Exception e){resp.sendError(500);}
    }
}
