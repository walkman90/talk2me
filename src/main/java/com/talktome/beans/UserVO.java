package com.talktome.beans;

import org.jivesoftware.smackx.packet.VCard;

/**
 * Created by vokl0313 on 9/25/14.
 */
public class UserVO {
    private String jid;
    private String name;
    private String username;
    private String password;
    private String email;
    private String avatar;
    private VCard vCard;

    public String getJid() {
        return jid;
    }

    public void setJid(String jid) {
        this.jid = jid;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public VCard getvCard() {
        return vCard;
    }

    public void setvCard(VCard vCard) {
        this.vCard = vCard;
    }

    public String getAvatar() {
        return avatar;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }
}
