<%@ include file="../common.jsp" %>
<%--@elvariable id="user" type="com.talktome.beans.UserVO"--%>
<form:form method="POST" action="/signIn" modelAttribute="loginVO">
    <form:input path="login" cssClass="form-control" placeholder="Login"/>
    <form:errors path="login"></form:errors>
    <br>
    <form:input path="password" cssClass="form-control" type="password" placeholder="Password"/>
    <form:errors path="password"></form:errors>
    <br>
    <form:button class="btn btn-primary sign-in-btn">Sign In <i class="fa fa-sign-in"></i></form:button>
    <form:errors></form:errors>
</form:form>
<script>location.href="/home"</script>