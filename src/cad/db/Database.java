package cad.db;

import java.sql.Connection;
import java.sql.SQLException;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

/** Ponto unico de acesso ao pool de conexoes configurado no Tomcat. */
public final class Database {
    private static final String JNDI_NAME = "java:comp/env/jdbc/CadDB";
    private static volatile DataSource dataSource;

    private Database() {
    }

    public static Connection getConnection() throws SQLException {
        return getDataSource().getConnection();
    }

    private static DataSource getDataSource() throws SQLException {
        DataSource atual = dataSource;
        if (atual == null) {
            synchronized (Database.class) {
                atual = dataSource;
                if (atual == null) {
                    try {
                        atual = (DataSource) new InitialContext().lookup(JNDI_NAME);
                        dataSource = atual;
                    } catch (NamingException erro) {
                        throw new SQLException("DataSource " + JNDI_NAME + " nao configurado.", erro);
                    }
                }
            }
        }
        return atual;
    }
}
