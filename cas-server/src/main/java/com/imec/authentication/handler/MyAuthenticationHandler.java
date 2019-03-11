package com.imec.authentication.handler;

import org.apache.shiro.crypto.hash.Md5Hash;
import org.jasig.cas.adaptors.jdbc.AbstractJdbcUsernamePasswordAuthenticationHandler;
import org.jasig.cas.authentication.HandlerResult;
import org.jasig.cas.authentication.PreventedException;
import org.jasig.cas.authentication.UsernamePasswordCredential;
import org.jasig.cas.authentication.principal.SimplePrincipal;
import org.springframework.dao.DataAccessException;
import org.springframework.dao.IncorrectResultSizeDataAccessException;

import javax.security.auth.login.AccountLockedException;
import javax.security.auth.login.AccountNotFoundException;
import javax.security.auth.login.FailedLoginException;
import javax.validation.constraints.NotNull;
import java.security.GeneralSecurityException;
import java.util.Map;
public class MyAuthenticationHandler extends AbstractJdbcUsernamePasswordAuthenticationHandler{
    @NotNull
    private String sql;


    @Override
    protected HandlerResult authenticateUsernamePasswordInternal(UsernamePasswordCredential usernamePasswordCredential) throws GeneralSecurityException, PreventedException {
        final String username = usernamePasswordCredential.getUsername();
        final String password = usernamePasswordCredential.getPassword();
        try {
            final Map<String, Object> values = getJdbcTemplate().queryForMap(this.sql, username);
            String dbPassword = (String) values.get("password");
            String salt = (String) values.get("salt");
            salt=username+salt;
            Integer status = (Integer) values.get("status");
            if(!status.equals(1)) { //判断帐号是否被冻结
                throw new AccountLockedException("This user is disabled.");
            }

            //密码加盐并迭代1024次
            String encryptedPassword = new Md5Hash(usernamePasswordCredential.getPassword(), salt, 2).toHex();
            if (!dbPassword.equals(encryptedPassword)) {
                throw new FailedLoginException("Password does not match value on record.");
            }
        } catch (final IncorrectResultSizeDataAccessException e) {
            if (e.getActualSize() == 0) {
                throw new AccountNotFoundException(username + " not found with SQL query");
            } else {
                throw new FailedLoginException("Multiple records found for " + username);
            }
        } catch (final DataAccessException e) {
            e.printStackTrace();
            throw new PreventedException("SQL exception while executing query for " + username, e);
        }
        return createHandlerResult(usernamePasswordCredential, new SimplePrincipal(username), null);
    }

    /**
     * @param sql The sql to set.
     */
    public void setSql(final String sql) {
        this.sql = sql;
    }

}
