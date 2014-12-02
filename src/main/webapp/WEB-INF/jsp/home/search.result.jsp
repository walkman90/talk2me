<%@ include file="../common.jsp" %>
<%--@elvariable id="user" type="com.talktome.beans.UserVO"--%>

    <c:forEach items="${users}" var="user">
        <div class="contact-container">
            <div class="user-avatar"><img src="data:image/jpeg;base64, ${user.avatar}"></div>
            <div class="search-name">${user.vCard.firstName} ${user.vCard.lastName}</div>
            <button class="contact-request-btn btn btn-primary btn-xs" jid="${user.jid}"
                onclick="$('body').trigger('sendSubscribe', ['${user.jid}'])">
                     Send contact request <i class="fa fa-paper-plane"></i>
            </button>
        </div>
    </c:forEach>
