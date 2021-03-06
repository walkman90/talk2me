package com.talktome.beans;

import com.talktome.validators.FieldMatch;
import com.talktome.validators.UniqueName;
import org.hibernate.validator.constraints.NotEmpty;

/**
 * Created by vokl0313 on 9/25/14.
 */
@FieldMatch.List({
    @FieldMatch(first = "password", second = "passwordVerify", message = "The password fields must match")
})
public class RegistrationVO {
    @NotEmpty
    @UniqueName
    private String username;
    @NotEmpty
    private String password;
    @NotEmpty
    private String passwordVerify;
    @NotEmpty
    private String firstName;
    @NotEmpty
    private String lastName;

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getPasswordVerify() {
        return passwordVerify;
    }

    public void setPasswordVerify(String passwordVerify) {
        this.passwordVerify = passwordVerify;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }
}
