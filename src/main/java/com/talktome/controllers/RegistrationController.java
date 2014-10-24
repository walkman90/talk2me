package com.talktome.controllers;

import com.talktome.beans.LoginVO;
import com.talktome.beans.RegistrationVO;
import com.talktome.services.XMPPService;
import org.jivesoftware.smack.ConnectionConfiguration;
import org.jivesoftware.smack.XMPPConnection;
import org.jivesoftware.smack.XMPPException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.ui.ModelMap;
import org.springframework.validation.BindingResult;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import java.io.IOException;

/**
 * Created by vokl0313 on 9/25/14.
 */
@Controller
public class RegistrationController {
    @Autowired
    XMPPService xmppService;

    @RequestMapping(value = "/signUp")
    public String render(ModelMap model) {

        return "registration/view";
    }

    @ModelAttribute("registrationVO")
    public RegistrationVO getModel() {
        return new RegistrationVO();
    }

    @RequestMapping(value="/account/create", method=RequestMethod.POST)
    public String signIn(Model model, @Validated @ModelAttribute("registrationVO") RegistrationVO registrationVO,
                         BindingResult bindingResult) throws XMPPException, IOException {
        if(bindingResult.hasErrors()) {
            model.addAttribute("registrationVO", registrationVO);
            return "registration/form";
        }
        xmppService.createAccount(registrationVO.getUsername(), registrationVO.getPassword());
        return "registration/success";
    }
}
