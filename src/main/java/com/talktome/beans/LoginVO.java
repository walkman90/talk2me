package com.talktome.beans;

import org.hibernate.validator.constraints.NotEmpty;

/**
 * Created by vokl0313 on 9/23/14.
 */
public class LoginVO {
    @NotEmpty
    private String login;

    @NotEmpty
    private String password;

    public String getLogin() {
        return login;
    }

    public void setLogin(String login) {
        this.login = login;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}
