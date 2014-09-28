<%@ include file="../common.jsp" %>
<form:form method="post" modelAttribute="registrationVO" action="/account/create">
    <form:input path="username" placeholder="Username" />
    <form:errors path="username"/>
    <br>
    <form:input path="password" placeholder="Password" type="password"/>
    <form:errors path="password"/>
    <br>
    <form:input path="passwordVerify" placeholder="Verify Password" type="password"/>
    <form:errors path="passwordVerify"/>
    <br>
    <form:button class="signup-btn">Sign Up</form:button>
</form:form>
