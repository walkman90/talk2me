<%@ include file="../common.jsp" %>
<%--@elvariable id="user" type="com.talktome.beans.UserVO"--%>
<html>
<head>
    <script type="text/javascript" src="<c:url value="/resources/js/jquery-1.11.1.min.js" />"></script>
    <script type="text/javascript" src="<c:url value="/resources/js/jquery.xmpp.js" />"></script>
    <script type="text/javascript" src="<c:url value="/resources/js/underscore-min.js" />"></script>
    <script type="text/javascript" src="<c:url value="/resources/js/backbone-min.js" />"></script>
    <script src="<c:url value="/resources/vendor/bootstrap/js/bootstrap.min.js" />"></script>
    <link rel="stylesheet" href="<c:url value="/resources/css/login.css" />">
    <link rel="stylesheet" href="<c:url value="/resources/vendor/font-awesome-4.2.0/css/font-awesome.min.css" />">
    <link rel="stylesheet" href="<c:url value="/resources/vendor/bootstrap/css/bootstrap.min.css" />">
    <link rel="stylesheet" href="<c:url value="/resources/vendor/bootstrap/css/bootstrap-theme.min.css" />">
    <title>Basic connection</title>
</head>

</head>
<body>
<div id="container">
    <div class="login-box">
        <div class="login-container">
            <%@include file="form.jsp" %>
        </div>
    </div>
</div>
</body>
</html>


<script type="text/javascript">
    $(document).ready(function () {
        var container = $('#container .login-container');
        container.find('form').submit(function () {
            var form = $(this);
            $.ajax({
                url: form.attr('action'),
                type: 'POST',
                data: form.serialize(),
                success: function (data) {
                    container.html(data);
                }
            });

            return false;
        });
    });


</script>













