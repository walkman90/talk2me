package com.talktome.components;

import com.talktome.beans.UserVO;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Component;

/**
 * Created by vokl0313 on 9/26/14.
 */
@Component
@Scope("session")
public class Session {
    private UserVO user;
}
