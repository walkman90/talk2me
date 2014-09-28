<%@ include file="../common.jsp" %>
<%--@elvariable id="user" type="com.talktome.beans.UserVO"--%>
<html>
<head>
    <script type="text/javascript" src="<c:url value="/resources/js/jquery-1.11.1.min.js" />"></script>
    <script type="text/javascript" src="<c:url value="/resources/js/jquery.xmpp.js" />"></script>
    <title>Basic connection</title>
</head>


    <script type="text/javascript">
        $(document).ready(function () {
            $("#connectBut").click(function () {
                var jid =  $("#jid").val();
                var password = $("#pass").val();
                var logContainer = $("#log");
                var contactList = $("#contacts");

                var url = "http://127.0.0.1:7070/http-bind/";
                $.xmpp.connect({url: url, jid: jid, password: password,
                    onConnect: function () {
                        logContainer.html("Connected");
                        $.xmpp.setPresence(null);
                    },
                    onPresence: function (presence) {

                        var contact = $("<li>");
                        contact.append("<a href='javascript:void(0)'>" + presence.from + "</a>");
                        contact.find("a").click(function () {
                            var id = MD5.hexdigest(presence.from);
                            var conversation = $("#" + id);
                            if (conversation.length == 0)
                                openChat({to: presence.from});
                        });
                        contactList.append(contact);
                        $.xmpp.getRoster(function(list){
                            var user3 = list[0];
//                            $.xmpp.sendCommand("<iq from='test4' to='test3' type='get' id='e2e1'><ping xmlns='urn:xmpp:ping'/></iq>",
//                                    function(e) {
//                                     e;
//                            });
//                            $.xmpp.sendCommand("<presence to='test2' type='subscribe'/>",
//                                    function(e) {
//                                        e;
//                                    });

                        })
                    },
                    onDisconnect: function () {
                        logContainer.html("Disconnected");
                    },
                    onMessage: function (message) {

                        var jid = message.from.split("/");
                        var id = MD5.hexdigest(message.from);
                        var conversation = $("#" + id);
                        if (conversation.length == 0) {
                            openChat({to: message.from});
                        }
                        conversation = $("#" + id);
                        conversation.find(".conversation").append("<div>" + jid[0] + ": " + message.body + "</div>");
                    }, onError: function (error) {
                        alert(error.error);
                    }
                });
            });

            $("#disconnectBut").click(function () {
                $.xmpp.disconnect();
            });

        });


        function openChat(options) {
            var id = MD5.hexdigest(options.to);

            var chat = $("<div style='border: 1px solid #000000; float:left' id='" + id + "'><div style='border: 1px solid #000000;'>Chat with " + options.to + "</div><div style='height:150px;overflow: auto;' class='conversation'></div><div><input type='text' /><button>Send</button></div></div>");
            var input = chat.find("input");
            var sendBut = chat.find("button");
            var conversation = chat.find(".conversation");
            sendBut.click(function () {
                $.xmpp.sendMessage({to: options.to, body: input.val()});
                conversation.append("<div>" + $.xmpp.jid + ": " + input.val() + "</div>");
                input.val("");
            });
            $("body").append(chat);
        }

    </script>
</head>
<body>
This example just connect notify when connected and show the connected contacts.
<br>
Jid <input type="text" id="jid"> (ej: maxpowel@gmail.com, alvaro.maxpowel@chat.facebook.com)
<br>
Password <input type="password" id="pass">
<br>
<button id="connectBut">Connect</button>
<button id="disconnectBut">Disconnect</button>
<br>

<div id="log">
</div>
<ul id="contacts">
</ul>
</body>
</html>













<%--<%@ include file="../common.jsp" %>--%>
<%--<html>--%>
<%--<head>--%>
    <%--<link href="../../css/login.css" rel="stylesheet"/>--%>
    <%--<script type="text/javascript" src="<c:url value="/resources/js/jquery-1.11.1.min.js" />"></script>--%>
    <%--<script type="text/javascript" src="<c:url value="/resources/js/underscore-min.js" />"></script>--%>
    <%--<script type="text/javascript" src="<c:url value="/resources/js/backbone-min.js" />"></script>--%>

    <%--<script type="text/javascript" src="<c:url value="/resources/js/strophe.js" />"></script>--%>
    <%--<script type="text/javascript" src="<c:url value="/resources/js/strophe.roster.js" />"></script>--%>
<%--</head>--%>

<%--<title>Talk To Me</title>--%>

<%--<body>--%>
<%--<h2>${message}</h2><br>--%>

<%--<div id="login-container">--%>
    <%--<%@ include file="form.jsp" %>--%>
<%--</div>--%>

<%--<a href="/signUp">Sign Up</a> <br>--%>

<%--<div id="log">--%>
<%--</div>--%>
<%--<ul id="contacts">--%>
<%--</ul>--%>
     <%--<br>--%>
<%--<div id="sub">--%>
    <%--Subscribe: <input id="new-contact" type="text"></div>--%>
                <%--<button id="subscribe-btn">Subscribe</button>--%>
<%--</div>--%>
<%--</body>--%>
<%--</html>--%>

<%--<script type="text/javascript">--%>
    <%--var BOSH_SERVICE = "http://127.0.0.1:7070/http-bind/";--%>
    <%--var connection = null;--%>

    <%--function log(msg)--%>
    <%--{--%>
        <%--$('#log').append('<div></div>').append(document.createTextNode(msg));--%>
    <%--}--%>

    <%--function rawInput(data)--%>
    <%--{--%>
        <%--log('RECV: ' + data);--%>
    <%--}--%>

    <%--function rawOutput(data)--%>
    <%--{--%>
        <%--log('SENT: ' + data);--%>
    <%--}--%>

    <%--function onConnect(status)--%>
    <%--{--%>

        <%--if (status == Strophe.Status.CONNECTING) {--%>
            <%--log('Strophe is connecting.');--%>
            <%--connection.roster.authorize("test4");--%>
            <%--connection.send($pres());--%>
        <%--} else if (status == Strophe.Status.CONNFAIL) {--%>
            <%--log('Strophe failed to connect.');--%>
            <%--$('#connect').get(0).value = 'connect';--%>
        <%--} else if (status == Strophe.Status.DISCONNECTING) {--%>
            <%--log('Strophe is disconnecting.');--%>
        <%--} else if (status == Strophe.Status.DISCONNECTED) {--%>
            <%--log('Strophe is disconnected.');--%>
            <%--$('#connect').get(0).value = 'connect';--%>
        <%--} else if (status == Strophe.Status.CONNECTED) {--%>
            <%--log('Strophe is connected.');--%>
            <%--connection.disconnect();--%>
        <%--}--%>
    <%--}--%>

    <%--$(document).ready(function () {--%>
        <%--connection = new Strophe.Connection(BOSH_SERVICE);--%>
        <%--connection.rawInput = rawInput;--%>
        <%--connection.rawOutput = rawOutput;--%>

        <%--$('#connect').bind('click', function () {--%>
            <%--var button = $('#connect').get(0);--%>
            <%--if (button.value == 'connect') {--%>
                <%--button.value = 'disconnect';--%>

                <%--connection.connect($('#jid').get(0).value,--%>
                        <%--$('#password').get(0).value,--%>
                        <%--onConnect);--%>
            <%--} else {--%>
                <%--button.value = 'connect';--%>
                <%--connection.disconnect();--%>
            <%--}--%>
        <%--});--%>

        <%--$('#subscribe-btn').bind('click', function () {--%>
            <%--var contact = $('#new-contact').val();--%>
            <%--if (contact != null) {--%>

                <%--connection.roster.subscribe(contact);--%>
                <%--var l = connection.roster.get();--%>
            <%--} else {--%>
                <%--button.value = 'connect';--%>
                <%--connection.disconnect();--%>
            <%--}--%>
        <%--});--%>

        <%--connection.addHandler(){--%>
            <%--var presence_type = $(presence).attr('type'); // unavailable, subscribed, etc...--%>
            <%--var from = $(presence).attr('from'); // the jabber_id of the contact--%>
            <%--if (presence_type != 'error'){--%>
                <%--if (presence_type === 'unavailable'){--%>
                    <%--// Mark contact as offline--%>
                <%--}else{--%>
                    <%--var show = $(presence).find("show").text(); // this is what gives away, dnd, etc.--%>
                    <%--if (show === 'chat' || show === ''){--%>
                        <%--// Mark contact as online--%>
                    <%--}else{--%>
                        <%--// etc...--%>
                    <%--}--%>
                <%--}--%>
            <%--}--%>
            <%--//RETURN TRUE!!!!!!!!!--%>
            <%--return true;--%>
        <%--}--%>
    <%--});--%>

    <%--function openChat(options) {--%>
        <%--var id = MD5.hexdigest(options.to);--%>

        <%--var chat = $("<div style='border: 1px solid #000000; float:left' id='" + id + "'><div style='border: 1px solid #000000;'>Chat with " + options.to + "</div><div style='height:150px;overflow: auto;' class='conversation'></div><div><input type='text' /><button>Send</button></div></div>");--%>
        <%--var input = chat.find("input");--%>
        <%--var sendBut = chat.find("button");--%>
        <%--var conversation = chat.find(".conversation");--%>
        <%--sendBut.click(function () {--%>
            <%--$.xmpp.sendMessage({to: options.to, body: input.val()});--%>
            <%--conversation.append("<div>" + $.xmpp.jid + ": " + input.val() + "</div>");--%>
            <%--input.val("");--%>
        <%--});--%>
        <%--$("body").append(chat);--%>
    <%--}--%>

<%--</script>--%>