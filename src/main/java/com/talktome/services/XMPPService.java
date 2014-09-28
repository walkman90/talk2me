package com.talktome.services;

import com.talktome.beans.UserVO;
import org.jivesoftware.smack.AccountManager;
import org.jivesoftware.smack.XMPPConnection;
import org.jivesoftware.smack.XMPPException;
import org.jivesoftware.smack.packet.Presence;
import org.jivesoftware.smackx.Form;
import org.jivesoftware.smackx.ReportedData;
import org.jivesoftware.smackx.search.UserSearchManager;
import org.springframework.stereotype.Service;

import java.lang.reflect.Field;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

/**
 * Created by vokl0313 on 9/25/14.
 */
@Service("xmppService")
public class XMPPService {
    public static enum UserColumn {

        USER_JID("jid"),
        USER_USERNAME("Username"),
        USER_NAME("Name"),
        USER_EMAIL("Email");

        private String value;

        UserColumn(String value) {
            this.value = value;
        }

        public String getValue() {
            return value;
        }
    }

    private XMPPConnection connection;

    private XMPPConnection getConnection() {
        if (connection == null) {
            try {
//                org.jivesoftware.smack.ConnectionConfiguration config = new  org.jivesoftware.smack.ConnectionConfiguration("localhost", 5222, "wsua-01832");
//                config.setReconnectionAllowed(true);
//                config.setCompressionEnabled(false);
//                config.setCustomSSLContext(SSLContext.getDefault());
//                config.setSecurityMode(org.jivesoftware.smack.ConnectionConfiguration.SecurityMode.disabled);
                connection = new XMPPConnection("wsua-01832");
                connection.connect();
               // if(!connection.isAuthenticated()) {
                    connection.login("admin", "admin", "Smack");
               // }

            } catch (XMPPException e) {
                e.printStackTrace();
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else if (!connection.isConnected()) {
            try {
                connection.connect();
             //   if(!connection.isAuthenticated()) {
                    connection.login("admin", "admin", "Smack");
             //   }
            } catch (XMPPException e) {
                e.printStackTrace();
            }
        }
        return connection;
    }

    public void createAccount(String username, String password) throws XMPPException {
        AccountManager accountManager = getConnection().getAccountManager();
        accountManager.supportsAccountCreation();
        Collection c = accountManager.getAccountAttributes();
        Map<String, String> attr = new HashMap<String, String>();
        attr.put("name", username);
        attr.put("email", username+"@openfire.com");
        accountManager.createAccount(username, password, attr);
    }

    public UserVO findUserBy(String value, UserColumn column) throws XMPPException {
        XMPPConnection conn = getConnection();
        UserSearchManager search = new UserSearchManager(conn);
        Form searchForm = search.getSearchForm("search." + conn.getServiceName());
        Form answerForm = searchForm.createAnswerForm();
        answerForm.setAnswer("Username", true);
        answerForm.setAnswer("search", value);
        org.jivesoftware.smackx.ReportedData data = search.getSearchResults(answerForm, "search." + conn.getServiceName());

        UserVO user = null;
        if (data.getRows() != null) {
            Iterator<ReportedData.Row> it = data.getRows();
            while (it.hasNext()) {
                user = new UserVO();
                ReportedData.Row row = it.next();
                Iterator iterator = row.getValues(UserColumn.USER_JID.getValue());
                if (iterator.hasNext()) {
                    user.setJid(iterator.next().toString());
                }
                iterator = row.getValues(UserColumn.USER_USERNAME.getValue());
                if (iterator.hasNext()) {
                    user.setUsername(iterator.next().toString());
                }
                iterator = row.getValues(UserColumn.USER_NAME.getValue());
                if (iterator.hasNext()) {
                    user.setName(iterator.next().toString());
                }
                iterator = row.getValues(UserColumn.USER_EMAIL.getValue());
                if (iterator.hasNext()) {
                    user.setEmail(iterator.next().toString());
                }


                Class userClass = user.getClass();
                Field field = null;
                try {
                    field = userClass.getDeclaredField(column.getValue().toLowerCase());
                    field.setAccessible(true);
                    if (field != null) {
                        String fieldValue = (String) field.get(user);
                        if (!fieldValue.equals(value)) {
                            user = null;
                        }
                    }
                    field.setAccessible(false);
                } catch (NoSuchFieldException e) {
                    e.printStackTrace();
                } catch (IllegalAccessException e) {
                    e.printStackTrace();
                }

            }
        }

        return user;
    }

    public void sendPresenceTo(String username,Presence.Type type) throws XMPPException {
        Presence presence = new Presence(type);
        presence.setTo(username);
        connection.sendPacket(presence);
    }
}