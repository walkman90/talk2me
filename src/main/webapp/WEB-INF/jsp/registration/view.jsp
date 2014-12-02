<%@ include file="../common.jsp" %>
<html>
<head>
    <script type="text/javascript" src="<c:url value="/resources/js/jquery-1.11.1.min.js" />"></script>
    <script type="text/javascript" src="<c:url value="/resources/js/jquery.xmpp.js" />"></script>
    <script type="text/javascript" src="<c:url value="/resources/js/underscore-min.js" />"></script>
    <script type="text/javascript" src="<c:url value="/resources/js/backbone-min.js" />"></script>
    <script src="<c:url value="/resources/vendor/bootstrap/js/bootstrap.min.js" />"></script>
    <link rel="stylesheet" href="<c:url value="/resources/vendor/font-awesome-4.2.0/css/font-awesome.min.css" />">
    <link rel="stylesheet" href="<c:url value="/resources/vendor/bootstrap/css/bootstrap.min.css" />">
    <link rel="stylesheet" href="<c:url value="/resources/vendor/bootstrap/css/bootstrap-theme.min.css" />">
    <link rel="stylesheet" href="<c:url value="/resources/css/registration.css" />">
    <title>Registration</title>
</head>
<div class="page-header">
    <div class="logo">Talk2Me</div>
</div>

<div class="reg-block">
    <div id="reg-container">
        <%@ include file="form.jsp" %>
    </div>
</div>
</html>

<script>
    $(document).ready(function () {
        var $container = $("#reg-container");
        init($container);

        function init(container) {
            var form = container.find('form');
            form.submit(function () {
                $(this).find('button').attr('disabled', true).find('i').toggleClass('fa-chevron-right fa-spin fa-spinner')
                $.ajax({
                    url: form.attr('action'),
                    type: 'POST',
                    data: form.serialize(),
                    success: function (data) {
                        container.html(data);
                        init(container)
                    }
                });
                return false;
            });
        }
    });
</script>