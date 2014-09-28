package com.talktome.controllers;

import com.talktome.beans.UserVO;
import com.talktome.services.XMPPService;
import org.jivesoftware.smack.XMPPException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import javax.servlet.http.HttpSession;

/**
 * Created by vokl0313 on 9/26/14.
 */
@Controller
public class ChatController {
    @Autowired
    XMPPService xmppService;

    @RequestMapping(value = "/chat", method = RequestMethod.GET)
    public String render(ModelMap model, HttpSession session) throws XMPPException {
        // UserVO user = xmppService.findUserBy("test1", XMPPService.UserColumn.USER_NAME);
        //xmppService.createAccount("test3", "test3");
        UserVO u = (UserVO)session.getAttribute("user");
        model.addAttribute("user", session.getAttribute("user"));

        return "chat/chat";
    }
}
