package com.talktome.controllers;

import com.talktome.beans.LoginVO;
import com.talktome.beans.UserVO;
import com.talktome.services.XMPPService;
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
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.Collection;

@Controller
@RequestMapping("/")
public class LoginController {
    @Autowired
    XMPPService xmppService;

	@RequestMapping(method = RequestMethod.GET)
	public String printWelcome(ModelMap model) throws XMPPException {
		model.addAttribute("message", "Welcome!");
        ArrayList<UserVO> users = xmppService.findUserBy("test", XMPPService.UserColumn.USER_NAME);
        //xmppService.createAccount("test3", "test3");
		return "login/view";
	}

    @ModelAttribute("loginVO")
    public LoginVO getModel() {
        return new LoginVO();
    }

    @RequestMapping(value="signIn", method=RequestMethod.POST)
    public String signIn(Model model, @Validated @ModelAttribute("loginVO") LoginVO loginVO,
                               BindingResult bindingResult, HttpSession session) throws XMPPException {
        if(bindingResult.hasErrors()) {
            model.addAttribute("loginVO", loginVO);
            return "login/form";
        }

        return "login/chat";
    }

    @RequestMapping(value="search", method=RequestMethod.POST)
    public String search(Model model, @RequestParam("value") String value) throws XMPPException {
        ArrayList<UserVO> users = xmppService.findUserBy(value, XMPPService.UserColumn.USER_NAME);
        model.addAttribute("users", users);

        return "login/search.result";
    }

    @RequestMapping(value="sendPresence", method=RequestMethod.POST)
    public String sendPresenceTo(Model model, @RequestParam("from") String from,
                                @RequestParam("to") String to, @RequestParam("precense") String precense) throws XMPPException {
       //xmppService.sendPresenceTo();

       return "login/chat";
    }
}