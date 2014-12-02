<%@ include file="../common.jsp" %>
<form:form method="post" modelAttribute="registrationVO" action="/account/create">
    <form:input path="username" placeholder="Username" class="form-control"/>
    <form:errors path="username"/>

    <form:input path="password" placeholder="Password" type="password" class="form-control"/>
    <form:errors path="password"/>

    <form:input path="passwordVerify" placeholder="Verify Password" type="password" class="form-control"/>
    <form:errors path="passwordVerify"/>

    <form:input path="firstName" placeholder="First Name" class="form-control"/>
    <form:errors path="firstName"/>

    <form:input path="lastName" placeholder="Last Name" class="form-control"/>
    <form:errors path="lastName"/>

    <form:button class="btn btn-primary signup-btn">Sign Up <i class="fa fa-chevron-right"></i></form:button>
</form:form>
