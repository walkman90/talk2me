package com.talktome.controllers;

import com.talktome.beans.LoginVO;
import com.talktome.beans.UserVO;
import com.talktome.services.XMPPService;
import com.talktome.utils.Utils;
import org.jivesoftware.smack.XMPPException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.ui.ModelMap;
import org.springframework.validation.BindingResult;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpSession;
import java.util.ArrayList;

@Controller
public class HomeController {
    @Autowired
    XMPPService xmppService;

    @Value("${talk2me.host}")
    private String host;

	@RequestMapping(value="/home", method = RequestMethod.GET)
	public String render(ModelMap model, HttpSession session) throws XMPPException {
        UserVO user = (UserVO)session.getAttribute(Utils.SESSION_KEYS.USER.name());
		model.addAttribute("user", user);
        model.addAttribute("host", host);
		return "home/view";
	}

    @RequestMapping(value="/search", method=RequestMethod.POST)
    public String search(Model model, @RequestParam("value") String value) throws XMPPException {
        ArrayList<UserVO> users = xmppService.findUserBy(value, XMPPService.UserColumn.USER_NAME);
        model.addAttribute("users", users);

        return "home/search.result";
    }

}