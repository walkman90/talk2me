<%@ include file="../common.jsp" %>
<%--@elvariable id="user" type="com.talktome.beans.UserVO"--%>

    <c:forEach items="${users}" var="user">
        <div class="contact-container">
            ${user.name}
            <button class="contact-request-btn" jid="${user.jid}" onclick="sendSubscribe($(this))">Send contact request</button>
        </div>
    </c:forEach>
