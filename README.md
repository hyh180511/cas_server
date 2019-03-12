# cas_server项目介绍
----------------------------
　　cas作为一个著名的单点登录的实现架构，在单点登录实现过程中作为第三方服务器，实现单点登录过程中的登录、ticker的校验和登出等。cas_server项目使用了cas的4.0.0版本作为单点登录的服务器,配置了mysql数据库验证，
自定义密码验证等。

## cas_server下面介绍

#### 一、配置cas项目的数据库连接

**修改%tomcat_home%/webapps/cas/WEB_INF/deployerConfigContext.xml**

 配置数据库验证bean

 ```
 <!-- 数据源 -->
    <bean id="dataSource" class="org.apache.commons.dbcp.BasicDataSource">
        <property name="driverClassName" value="${jdbc.driverClassName}" />
        <property name="url" value="${jdbc.url}" />
        <property name="username" value="${jdbc.username}"/>
        <property name="password" value="${jdbc.password}"/>
        <property name="minIdle" value="14400"/>
    </bean>
  ```

修改authenticationManager,添加一个entry，primaryAuthenticationHandler。

创建自定义密码校验处理类

```
<bean id="authenticationManager" class="org.jasig.cas.authentication.PolicyBasedAuthenticationManager">
        <constructor-arg>
            <map>
                <!--
                   | IMPORTANT
                   | Every handler requires a unique name.
                   | If more than one instance of the same handler class is configured, you must explicitly
                   | set its name to something other than its default name (typically the simple class name).
                   -->
                <entry key-ref="proxyAuthenticationHandler" value-ref="proxyPrincipalResolver" />
                <entry key-ref="primaryAuthenticationHandler" value-ref="primaryPrincipalResolver" />
            </map>
        </constructor-arg>
  </bean>
  <bean id="primaryAuthenticationHandler" class="com.imec.authentication.handler.MyAuthenticationHandler">
        <property name="dataSource" ref="dataSource"/>
        <property name="sql" value="SELECT password, salt, status FROM t_account_cas WHERE name=?"/>
    </bean>
```

创建一个自定义的密码校验类MyAuthenticationHandler，继承AbstractJdbcUsernamePasswordAuthenticationHandler，
进行密码校验。

```
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
```

#### 二、配置cas去掉https验证

修改deployerConfigContext.xml添加p:requireSecure=”false”

```
<!-- Required for proxy ticket mechanism. -->
   <bean id="proxyAuthenticationHandler"
         class="org.jasig.cas.authentication.handler.support.HttpBasedServiceCredentialsAuthenticationHandler"
         p:httpClient-ref="httpClient" p:requireSecure="false" />
```
修改ticketGrantingTicketCookieGenerator.xml修改p:cookieSecure=”false”
```
<bean id="ticketGrantingTicketCookieGenerator" class="org.jasig.cas.web.support.CookieRetrievingCookieGenerator"
        p:cookieSecure="false"
        p:cookieMaxAge="-1"
        p:cookieName="CASTGC"
        p:cookiePath="/cas" />
```
修改warnCookieGenerator.xml修改p:cookieSecure=”false”
```
<bean id="warnCookieGenerator" class="org.jasig.cas.web.support.CookieRetrievingCookieGenerator"
        p:cookieSecure="false"
        p:cookieMaxAge="-1"
        p:cookieName="CASPRIVACY"
        p:cookiePath="/cas" />
```
