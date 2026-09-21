package cad.grupos;

import cad.db.Database;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

public final class GrupoCatalogo {
    private static final long DURACAO_CACHE_MS = 30000L;
    private static volatile Map<Integer, Grupo> cache = Collections.emptyMap();
    private static volatile long expiraEm = 0L;

    private GrupoCatalogo() {}

    private static Map<Integer, Grupo> grupos() {
        if (System.currentTimeMillis() < expiraEm && !cache.isEmpty()) return cache;
        synchronized (GrupoCatalogo.class) {
            if (System.currentTimeMillis() < expiraEm && !cache.isEmpty()) return cache;
            Map<Integer, Grupo> novos = new HashMap<>();
            String sql = "SELECT IdGrupo,NomeSingular,NomePlural,Cor FROM grupos WHERE StatusGrupo='ATIVO'";
            try (Connection c = Database.getConnection();
                 PreparedStatement p = c.prepareStatement(sql);
                 ResultSet r = p.executeQuery()) {
                while (r.next()) novos.put(r.getInt(1), new Grupo(r.getString(2), r.getString(3), r.getString(4)));
                cache = Collections.unmodifiableMap(novos);
                expiraEm = System.currentTimeMillis() + DURACAO_CACHE_MS;
            } catch (Exception e) {
                if (cache.isEmpty()) expiraEm = System.currentTimeMillis() + 5000L;
            }
            return cache;
        }
    }

    public static String singular(int id) {
        Grupo g = grupos().get(id);
        return g == null ? "Grupo " + id : g.singular;
    }

    public static String plural(int id) {
        Grupo g = grupos().get(id);
        return g == null ? "Grupo " + id : g.plural;
    }

    public static String cor(int id) {
        Grupo g = grupos().get(id);
        return g == null || g.cor == null || !g.cor.matches("#[0-9a-fA-F]{6}") ? "#64748b" : g.cor;
    }

    public static void invalidar() {
        expiraEm = 0L;
    }

    private static final class Grupo {
        final String singular, plural, cor;
        Grupo(String singular, String plural, String cor) { this.singular = singular; this.plural = plural; this.cor = cor; }
    }
}
