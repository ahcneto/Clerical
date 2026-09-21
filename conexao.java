import java.sql.Connection;
import java.sql.SQLException;

public class conexao {
    public static Connection getConexao() throws SQLException {
        return cad.db.Database.getConnection();
    }
}
