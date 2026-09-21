import java.io.IOException;
 
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
 
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
 

@WebFilter("/*")

public class AuthFilter implements Filter {

    public void doFilter(ServletRequest request, ServletResponse response,

                         FilterChain chain) throws IOException, ServletException {
 
        HttpServletRequest req = (HttpServletRequest) request;

        HttpServletResponse res = (HttpServletResponse) response;
 
        String loginURI = req.getContextPath() + "/login.jsp";

        String loginXSQL = req.getContextPath() + "/login.xsql";
 
        boolean loggedIn = (req.getSession() != null && req.getSession().getAttribute("user") != null);

        boolean loginRequest = req.getRequestURI().equals(loginURI) || req.getRequestURI().equals(loginXSQL);
 
        if (loggedIn || loginRequest || req.getRequestURI().contains("/css/") || req.getRequestURI().contains("/js/")) {

            chain.doFilter(request, response);

        } else {

            res.sendRedirect(loginURI);

        }

    }

}

 