package com.talktome.validators;

import com.talktome.beans.UserVO;
import com.talktome.services.XMPPService;
import org.jivesoftware.smack.XMPPException;
import org.springframework.beans.factory.annotation.Autowired;

import javax.validation.ConstraintValidator;
import javax.validation.ConstraintValidatorContext;
import java.util.ArrayList;

/**
 * Created by vokl0313 on 9/26/14.
 */
public class UniqueNameConstraintValidator implements ConstraintValidator<UniqueName, String> {

    @SuppressWarnings("SpringJavaAutowiringInspection")
    @Autowired
    XMPPService xmppService;

    @Override
    public void initialize(UniqueName name) { }

    @Override
    public boolean isValid(String usernameField, ConstraintValidatorContext cxt) {
        if(usernameField == null) {
            return false;
        }
        ArrayList<UserVO> users = null;
        try {
             users = xmppService.findUserBy(usernameField, XMPPService.UserColumn.USER_USERNAME);
        } catch (XMPPException e) {
            e.printStackTrace();
        }
        return users.size() == 0;
    }

}
