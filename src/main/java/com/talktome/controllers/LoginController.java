package com.talktome.controllers;

import com.talktome.beans.LoginVO;
import com.talktome.beans.UserVO;
import com.talktome.services.XMPPService;
import com.talktome.utils.Utils;
import org.jivesoftware.smack.XMPPConnection;
import org.jivesoftware.smack.XMPPException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.ui.ModelMap;
import org.springframework.validation.BindingResult;
import org.springframework.validation.ObjectError;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import javax.servlet.http.HttpSession;

/**
 * Created by vokl0313 on 9/26/14.
 */
@Controller
public class LoginController {
    @Autowired
    XMPPService xmppService;

    @Autowired
    Utils utils;

    @ModelAttribute("loginVO")
    public LoginVO getModel() {
        return new LoginVO();
    }

    @RequestMapping(value = "/", method = RequestMethod.GET)
    public String render(ModelMap model, HttpSession session) throws XMPPException {
        // UserVO user = xmppService.findUserBy("test1", XMPPService.UserColumn.USER_NAME);
        //xmppService.createAccount("test3", "test3");
        UserVO u = (UserVO)session.getAttribute("user");
        model.addAttribute("user", session.getAttribute("user"));

        return "login/view";
    }

    @RequestMapping(value="signIn", method=RequestMethod.POST)
    public String signIn(Model model, @Validated @ModelAttribute("loginVO") LoginVO loginVO,
                         BindingResult bindingResult, HttpSession session) throws XMPPException {
        if(bindingResult.hasErrors()) {
            model.addAttribute("loginVO", loginVO);
            return "login/form";
        }

        try {
            XMPPConnection xmppConnection = new XMPPConnection("localhost");
            xmppConnection.connect();
            xmppConnection.login(loginVO.getLogin()+"@wsua-01832", loginVO.getPassword());
        } catch (XMPPException e) {
            ObjectError err = new ObjectError("loginVO", "Xmpp connection failed");
            bindingResult.addError(err);
            model.addAttribute("loginVO", loginVO);
            return "login/form";
        }

        UserVO user = xmppService.findUserBy(loginVO.getLogin(), XMPPService.UserColumn.USER_USERNAME).iterator().next();
        user.setPassword(loginVO.getPassword());
        session.setAttribute(Utils.SESSION_KEYS.USER.name(), user);
        return "login/success";
    }
}
