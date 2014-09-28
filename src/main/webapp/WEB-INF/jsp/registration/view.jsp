<%@ include file="../common.jsp" %>
<html>
<head>
    <link href="/resources/css/registration.css" rel="stylesheet"/>
    <script src="<c:url value='/resources/js/jquery-1.11.1.min.js' />"></script>
</head>

<title>Talk To Me - Registration</title>

<h2>Registration</h2><br>
<div id="reg-container">
<%@ include file="form.jsp" %>
 </div>
</html>

<script>
    $(document).ready(function() {
        $container = $("#reg-container");
        form = $container.find('form');
        form.submit(function() {
            $.ajax({
                url     : form.attr('action'),
                type    : 'POST',
                data    : form.serialize(),
                success : function(data) {
                   $container.html(data);
                }
            });
            return false;
        });
    });
</script>