<%@ include file="../common.jsp" %>
<%--@elvariable id="user" type="com.talktome.beans.UserVO"--%>
<html>
<head>
    <script type="text/javascript" src="<c:url value="/resources/js/jquery-1.11.1.min.js" />"></script>
    <script type="text/javascript" src="<c:url value="/resources/js/jquery.xmpp.js" />"></script>
    <script type="text/javascript" src="<c:url value="/resources/js/jquery.cookie.js" />"></script>
    <script type="text/javascript" src="<c:url value="/resources/js/underscore-min.js" />"></script>
    <script type="text/javascript" src="<c:url value="/resources/js/backbone-min.js" />"></script>
    <script src="<c:url value="/resources/vendor/bootstrap/js/bootstrap.min.js" />"></script>
    <link rel="stylesheet" href="<c:url value="/resources/css/home.css" />">
    <link rel="stylesheet" href="<c:url value="/resources/vendor/font-awesome-4.2.0/css/font-awesome.min.css" />">
    <link rel="stylesheet" href="<c:url value="/resources/vendor/bootstrap/css/bootstrap.min.css" />">
    <link rel="stylesheet" href="<c:url value="/resources/vendor/bootstrap/css/bootstrap-theme.min.css" />">
    <title>Basic connection</title>
</head>

</head>
<body>
<div id="error-notifications"></div>
<div id='notifications'></div>
<div id="container">
    <div id="left-block">
        <div class="user-info">
            <div class="user-avatar"><img src="data:image/jpeg;base64, ${user.avatar}"></div>
            <div class="user-info-right-block">
                <div class="user-name">${user.vCard.firstName} ${user.vCard.lastName}</div>
                <div class="dropdown user-state">
                    <a data-toggle="dropdown" href="#">
                        <div class='state online'></div>
                        Online<span class="caret"></span></a>
                    <ul class="dropdown-menu" role="menu" aria-labelledby="dLabel">
                        <li state="chat">
                            <div class='state online'></div>
                            Online
                        </li>
                        <li state="away">
                            <div class='state away'></div>
                            Away
                        </li>
                        <li state="dnd">
                            <div class='state dnd'></div>
                            Do Not Disturb
                        </li>
                    </ul>
                </div>
            </div>
        </div>
        <div class="actions">
            <div id="home-btn" class="action go-home"><i class="fa fa-home"></i></div>
            <div data-toggle="modal" data-target="#search-modal" class="action add-contact"><i class="fa fa-user"></i><i
                    class="fa fa-plus"></i>
            </div>
            <div id="new-chat-room" class="action chat-room"><i class="fa fa-users"></i></div>
            <div id="disconnectBut" class="action sign-out"><i class="fa fa-sign-out"></i></div>
        </div>
        <div class="find-contact">
            <i class="fa fa-search"></i><input type="text" class="form-control" placeholder="Search"/>
        </div>
        <div class="contacts-block">
            <div class="contacts-tab">Contacts</div>
            <div class="rooms-tab">Rooms</div>
            <ul id="contacts">
            </ul>
        </div>
    </div>

    <div id="right-block">
        <div class="home-page">

        </div>
    </div>

    <!-- Modal Search -->

    <div class="modal fade" id="search-modal">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"><span
                            aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                    <h4 class="modal-title">Find Contact</h4>
                </div>
                <div class="modal-body">
                    <div class="ntf-block">
                        <div class='alert alert-success alert-dismissible' role='alert'>
                            <button type='button' class='close' data-dismiss='alert'><span
                                    aria-hidden='true'>&times;</span><span class='sr-only'>Close</span></button>
                            <strong>Success! </strong> Contact request successfully sent.
                        </div>
                    </div>
                    <i class="fa fa-search"></i><input type="text" class="form-control" placeholder="Search"/>
                    <button id="btn-find" class="btn btn-primary">Find</button>
                    <div id="search-result"></div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                </div>
            </div>
            <!-- /.modal-content -->
        </div>
        <!-- /.modal-dialog -->
    </div>
    <!-- /.modal -->

</div>
</body>
</html>


<script type="text/javascript">
$(document).ready(function () {
    var isDisconnect = false;

    window.onbeforeunload = function () {
        if ($.xmpp && !isDisconnect) {
//            $.cookie('talk2me.jid', $.xmpp.jid.toString());
//            $.cookie('talk2me.sid', $.xmpp.sid);
//            $.cookie('talk2me.rid', $.xmpp.rid);
//            $.cookie('talk2me.url', $.xmpp.url);
//            $.cookie('talk2me.resource', $.xmpp.resource);
//            $.cookie('talk2me.wait', $.xmpp.wait);
            $.xmpp.disconnectSync(function () {
            });
        }
    }

    var $model = $model || {};
    var $view = $view || {};
    $view.container = $("#container");
    $view.contactList = $("#contacts");
    $view.errorNotifications = $("#error-notifications");

    var Contact = Backbone.Model.extend({
        defaults: {
            jid: "test",
            username: "test",
            fullName: "",
            state: "offline",
            status: "",
            avatarBinVal: getDefaultAvatar(),
            avatarImgType: "image/jpeg"
        },
        initialize: function () {
            this.on("change:state", function (model) {
                var jid = model.get("jid");
                var state = model.get("state");
                $view.contactList.find("li a[jid='" + jid + "']").prev().attr('class', 'state ' + state);
            });
            this.on("change:avatarBinVal", function (model) {
                var jid = model.get("jid");
                var avatarImgType = model.get("avatarImgType");
                var avatarBin = model.get("avatarBinVal");
                $view.contactList.find("li a[jid='" + jid + "']").prev().find('img').attr('src', 'data:' + avatarImgType + ';base64, ' + avatarBin);
            });
            this.on("change:fullName", function (model) {
                var jid = model.get("jid");
                var fullName = model.get("fullName");
                $view.contactList.find("li a[jid='" + jid + "']").text(fullName);
            });
        }
    });

    var ContactList = Backbone.Collection.extend({
        model: Contact
    });

    ContactList.prototype.add = function (newContact) {
        var isDupe = this.any(function (contact) {
            var jid = contact.get('jid');
            jid = jid.substr(0, jid.indexOf('/'));
            return jid === newContact.get('jid');
        });
        if (isDupe) return;
        Backbone.Collection.prototype.add.call(this, newContact);
    }

    var User = Backbone.Model.extend({
        defaults: {
            jid: "test",
            username: "${user.vCard.firstName} ${user.vCard.lastName}",
            fullName: "",
            state: "offline",
            status: "",
            incomingContactRequests: new Array(),
            outgoingContactRequests: new Array(),
            contacts: new ContactList()
        },
        initialize: function () {
            this.on("change:state", function (model) {
                var jid = model.get("jid");
                $view.contactList.find("li a[jid='" + jid + "']").next().html(model.get("state"));
            });
        }
    });
    $model.user = new User();
    $view.userState = $('.dropdown.user-state');

    $view.userState.find('li').click(function () {
        if ($.xmpp.isConnected()) {
            $.xmpp.setPresence($(this).attr('state'), null);
            var select = $view.userState.find('a');
            select.html($(this).html());
            select.append('<span class="caret"></span>');
        }
    });

    var jid = '${user.jid}';
    var password = '${user.password}';
    var url = "http://${host}:7070/http-bind/";

    var onConnect = function () {
        $.xmpp.setPresence("chat", null);
        loadContactList($view.contactList);
    };
    var onPresence = function (presence) {
        var jid = jidTrim(presence.from);
        var outRequests = $model.user.get('outgoingContactRequests');
        var inRequests = $model.user.get('incomingContactRequests');
        if (presence.type == 'subscribe') {
            if ($.inArray(jid, outRequests) != -1) {
                subscriptionAutoResponse(jid, 'subscribed');
                $model.user.get('outgoingContactRequests').pop(jid);
            } else if ($.inArray(jid, inRequests) != -1) {
                subscriptionAutoResponse(jid, 'subscribed');
                $model.user.get('incomingContactRequests').pop(jid);
            } else {
                var notificationBlock = $('body').find('#notifications');
                var ntf = $("<div class='contact-req-ntf' jid='"+jid+"'><div class='ntf-sign'><i class='fa fa-bell-o'></i></div>" +
                        "<div class='msg'>Contact request from: " + presence.from + "</div>" +
                        "<button class='btn btn-default btn-xs' onclick='$(\"body\").trigger(\"rejectSubscription\", [\"" + jid + "\"])'>Reject</button>" +
                        "<button class='btn btn-primary btn-xs' id='accept-btn' onclick='$(\"body\").trigger(\"acceptSubscription\", [\"" + jid + "\"])'>Accept</button>" +
                        "</div>");
                ntf.hide(0).appendTo(notificationBlock).fadeIn(3000);
            }
            loadContactList($view.contactList);
        } else if (presence.type == 'subscribed') {

            if ($.inArray(jid, outRequests) != -1) {
                subscriptionAutoResponse(jid, 'subscribe');
                $model.user.get('outgoingContactRequests').pop(jid);
            } else if ($.inArray(jid, inRequests) != -1) {
                subscriptionAutoResponse(jid, 'subscribe');
                $model.user.get('incomingContactRequests').pop(jid);
            }
            loadContactList($view.contactList);
        } else {
            var contact = $model.user.get('contacts').findWhere({jid: jid});
            if (!contact) {
                $model.user.get('contacts').add(new Contact({jid: jid, username: usernameFromJid(presence.from), status: presence.status, state: presence.show}));
            } else {
                contact.set('status', presence.status);
                contact.set('state', presence.show);
            }
        }

    };
    var onDisconnect = function (data) {
        location.href = "/";
    };
    var onMessage = function (message) {
        var jid = message.from.split("/");
        var id = MD5.hexdigest(jid[0]);
        var conversation = $("#" + id);
        if (conversation.length == 0) {
            openChat({to: jid[0]});
        }
        conversation = $("#" + id);
        $model.contact = $model.user.get('contacts').findWhere({jid: jid[0]});
        conversation.find(".conversation").append("<div class='phrase-block'>" +
                "<div class='name'>" + $model.contact.get('fullName') + "</div>" +
                "<div class='text'>" + message.body + "</div>" +
                "<div class='timestamp'>" + getCurrentTime() + "</div></div>");
    };
    var onIq = function (data) {
        if (isRoster(data)) {
            refreshRoster(data, $view.contactList, $model.user.contacts);
        }
    };
    var onError = function (error) {
        if (error.data.statusText == "Invalid SID.") {
            var connectionParams = {url: url, jid: jid, password: password,
                resource: new Date().getTime().toString(),
                onConnect: onConnect,
                onPresence: onPresence,
                onDisconnect: onDisconnect,
                onMessage: onMessage,
                onIq: onIq,
                onError: onError
            }
            $.xmpp.connect(connectionParams);
        } else if (error.data.statusText) {
            showErrorNotification(error);
        }
    };
    var connectionParams = {url: url, jid: jid, password: password,
        resource: new Date().getTime().toString(),
        onConnect: onConnect,
        onPresence: onPresence,
        onDisconnect: onDisconnect,
        onMessage: onMessage,
        onIq: onIq,
        onError: onError
    }

//    if ($.cookie('talk2me.sid')) {
//        var options = {sid: $.cookie('talk2me.sid'), jid: $.cookie('talk2me.jid'),
//            rid: parseInt($.cookie('talk2me.rid')), url: $.cookie('talk2me.url'),
//            resource: $.cookie('talk2me.resource'), wait: parseInt($.cookie('talk2me.wait')),
//            onConnect: onConnect, onPresence: onPresence, onDisconnect: onDisconnect,
//            onMessage: onMessage, onIq: onIq, onError: onError}
//        $.xmpp.attach(options);
//    } else {
    $.xmpp.connect(connectionParams);
//    }
    $("#disconnectBut").click(function () {
        isDisconnect = true;
//        $.removeCookie('talk2me.jid');
//        $.removeCookie('talk2me.sid');
//        $.removeCookie('talk2me.rid');
//        $.removeCookie('talk2me.url');
//        $.removeCookie('talk2me.resource');
//        $.removeCookie('talk2me.wait');
        $.xmpp.disconnectSync(function () {
        });
    });

    $(".accept-btn").on('click', function () {
        jid = $(this).closest("div").attr('jid');
        $.xmpp.sendCommand("<presence to='" + jid + "' type='subscribe'/>",
                function (e) {
                    e;
                });
    });

    $searchModal = $("#search-modal");

    $searchModal.find('#btn-find').on('click', function () {
        statement = $searchModal.find('.modal-body input').val();
        $.ajax({
            url: '/search',
            type: 'POST',
            data: {value: statement},
            success: function (data) {
                $searchModal.find('#search-result').html(data);
            }
        });
        return false;
    });


    // --------------------------- functions -------------------
    function showErrorNotification(error) {
        var ntf = $("<div class='alert alert-danger alert-dismissible' role='alert'>" +
                "<button type='button' class='close' data-dismiss='alert'><span aria-hidden='true'>&times;</span><span class='sr-only'>Close</span></button>" +
                "<strong>Error! </strong> " + error.error +
                "</div>");
        $view.errorNotifications.append(ntf);
    }

    function getCurrentTime() {
        var dt = new Date();
        return dt.getHours() + ":" + pad(dt.getMinutes());
    }

    function pad(n) {
        return (n < 10) ? ("0" + n) : n;
    }

    function loadContactList(contactList) {
        $.xmpp.getRoster(function (roster) {
        });
    }

    function subscriptionAutoResponse(jid, type) {
        sendRequest(jid, type, function () {
        });
        refreshRoster(data, $view.contactList, $model.user.contacts);
    }

    $('body').on('acceptSubscription', function (event, jid) {
        sendRequest(jid, "subscribed", function () {
        });
        sendRequest(jid, "subscribe", function () {
        });
        $('#notifications').find(".contact-req-ntf[jid='"+jid+"']").remove();
    });

    $('body').on('rejectSubscription', function (event, jid) {
        sendRequest(jid, "unsubscribed", function () {
        });
        $('#notifications').find('.contact-req-ntf[jid='+jid+']').remove();
    });

    $('body').on('sendSubscribe', function (event, jid) {
        sendRequest(jid, "subscribe", function () {
            $searchModal.find('.ntf-block .alert-success').fadeIn(300).delay(1000).fadeOut(1500);
        });
    });

    function sendSubscribe(elem) {
        jid = elem.attr('jid');
        subscribedToList.push(jid);
        sendRequest(jid, "subscribe");
    }

    function sendRequest(jid, type, callback) {
        $.xmpp.sendCommand("<presence to='" + jid + "' type='" + type + "'/>",
                function (e) {
                    callback();
                });
    }

    function isRoster(data) {
        return data.outerHTML.indexOf("jabber:iq:roster") != -1
    }

    function refreshRoster(data, contactList, contacts) {
        var roster = [];
        $.each($(data).find("item"), function (i, item) {
            var jItem = $(item);
            $.xmpp.sendCommand("<iq to='" + jItem.attr("jid") + "' type='get' id='vc2'><vCard xmlns='vcard-temp'/></iq>", function (response) {
                var vCardData = $($.xmpp.fixBody(response));
                $.each($(vCardData).find('iq#vc2'), function (i, item) {
                    var vCard = $(item);
                    var jid = jidTrim(vCard.attr('from'));
                    var imgType = vCard.find('PHOTO').find('TYPE').text();
                    var imgBinVal = vCard.find('PHOTO').find('BINVAL').text();
                    var fullName = vCard.find('FN').text();

                    $model.contact = $model.user.get('contacts').findWhere({jid: jid});
                    if ($model.contact) {
                        if (imgBinVal) {
                            $model.contact.set('avatarImgType', imgType);
                            $model.contact.set('avatarBinVal', imgBinVal);
                        }
                        if (fullName) {
                            $model.contact.set('fullName', fullName);
                        }
                    }
                });

            });
            roster.push({name: jItem.attr("name"), subscription: jItem.attr("subscription"), jid: jItem.attr("jid")});
        });
        $view.contactList.html("");
        for (var i = 0; i < roster.length; i++) {
            user = roster[i];
            if (user.subscription == "both") {
                $model.contact = $model.user.get('contacts').findWhere({jid: user.jid});
                if (!$model.contact) {
                    $model.user.get('contacts').add(new Contact({jid: user.jid, username: usernameFromJid(user.jid), status: "", state: "offline"}));
                    $model.contact = $model.user.get('contacts').findWhere({jid: user.jid});
                }
                var contact = $("<li class='contact-item unselected'>");
                var state = $model.contact.get('state');
                var avatarBinVal = $model.contact.get('avatarBinVal');
                var avatarImgType = $model.contact.get('avatarImgType');
                contact.append("<div class='state " + state + "'><img src='data:"+avatarImgType+";base64, "+avatarBinVal+"'/></div><a jid='" + $model.contact.get('jid') + "'  href='javascript:void(0)'>" + $model.contact.get('username') + "</a>");
                contact.on('click', function () {
                    $view.contactList.find('.contact-item').attr('class', 'contact-item unselected');
                    $(this).attr('class', 'contact-item selected');
                    var jid = $(this).find('a').attr('jid');
                    var id = MD5.hexdigest(jid);
                    var conversation = $("#" + id);
                    $view.container.find('.chat-window').css('display', 'none');
                    if (conversation.length == 0) {
                        openChat({to: jid});
                    } else {
                        conversation.closest('.chat-window').css('display', '');
                    }
                });
                $view.contactList.append(contact);
            }
            if (user.subscription == "to") {
                $model.user.get('outgoingContactRequests').push(user.jid);
            }
            if (user.subscription == "from") {
                $model.user.get('incomingContactRequests').push(user.jid);
            }
        }
    }

    function openChat(options) {
        var id = MD5.hexdigest(options.to);
        $model.contact = $model.user.get('contacts').findWhere({jid: jidTrim(options.to)});
        var chat = getChatWindow(id, $model.contact);
        var textarea = chat.find("textarea");
        var sendBut = chat.find("button");
        var conversation = chat.find(".conversation");
        sendBut.click(function () {
            $.xmpp.sendMessage({to: options.to, body: textarea.val()});
            conversation.append("<div class='phrase-block'><div class='name'>" + $model.user.get('username') + "</div>" +
                    "<div class='text'>" + textarea.val() + "</div>" +
                    "<div class='timestamp'>" + getCurrentTime() + "</div></div>");
            textarea.val("");
        });
        $("#container #right-block").append(chat);
    }

    function getChatWindow(id, contact) {
        var jid = contact.get("fullName");
        var avatarImageType = contact.get("avatarImgType");
        var avatarBin = contact.get("avatarBinVal");
        $view.contactList.find("li a[jid='" + jid + "']").prev().attr('src', 'data:image/png;base64, ' + avatarBin);
        return $("<div class='chat-window' id='" + id + "'>" +
                "<div class='header' ><img src='data:" + avatarImageType + ";base64, " + avatarBin + "'/>Chat with " + jid + "</div><div class='conversation'></div>" +
                "<div class='input-msg-block'><textarea class='form-control' rows='3' placeholder='Input message here...' type='text' />" +
                "<button class='btn btn-primary'>Send</button></div></div>");
    }

    function jidTrim(jid) {
        if (jid.indexOf('/') == -1) {
            return jid;
        } else {
            return jid.substr(0, jid.indexOf('/'));
        }
    }

    function usernameFromJid(jid) {
        if (jid.indexOf('@') == -1) {
            return jid;
        } else {
            return jid.substr(0, jid.indexOf('@'));
        }
    }

    function getDefaultAvatar() {
        return "R0lGODlhyADIAPcAAMLCwsPDw8TExMXFxcbGxsfHx8jIyMnJycrKysvLy8zMzM3Nzc7Ozs/Pz9DQ0NHR0dLS0tPT09TU1NXV1dbW1tfX19jY2NnZ2dra2tvb29zc3N3d3d7e3t/f3+Dg4OHh4eLi4uPj4wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACwAAAAAyADIAEcI/wBDCBxIsKDBgwgTKlzIsKHDhxAjSpxIsaLFixgzatzIsaNHjCAmXKjQAcSHCAQEAFjJMsLHlzBjyjxowQDLmzhz6tx5U4AEDjODCh0KgafRo0iT4lTgYajTpwwzKJ1KterOABSgan1qtatXqxC2ipVJ4KvZszsXjF37cUMBtHDPPmBL1yODuHipNmhat+/FCHkDV2XgtzBFDwgEK+aZ1bBji0UXB8bwuLJGDwokf7VgubPHBZqVcvZMGiPi0F4dlF59kMOEsqhDE6DAl7VMEBsqKAgQu3doAQ0ygLAtUMMA38iTm8X6gW1i5dCjwz3QQagG2NKza/8qYPjLBtvDi//32qAj4PHo0ytFULuiW/Xw4/Ms716+/fs3ievfz9/phgYbcFBdfwQGhcFdOQWAnVEKYKBBgRBG1EEC4gUgwYARroYBfjkRQFmGfp3HoVEJNAfiWiMmVcCJa0WW4lUXsLgWBS/qFJaMYlVQI0/U4bjVATvmdKOPY1Vw3IsLmEhkXafJ59KSnmHAm3ZqQbmaBQ6IJ4EAG1hpGAgZvHXfAV16CRMHFDwX5FcHRKCBkjJ6QMGCa9qHAAbeGeZinXzytEB7Qj3Q56BUDQnTBIQmalUFH4Gn6KNVIbDRBZBWatUBGDlq6aZTMUoRaJyGqpShZpZq6qmolgZCnqm2apAFByD/ACp9rnoJwqwhaBABAgXYpBMCQNUK4gcV0DldBcEKS5oHmiYXgAN4KkuXBxSqN4AErEorEwe+ckirth5RMOWOnoKbEbeDJmtuRd3yKcCH61KkqALxVqToivVOpGafT+YbkQWEGqCuvw6BkFmfgBJcMJ89KhyRB7n1OYHDD4E6qMAUN6RBogNnnBDAfBZQpscNeXDkjoSRLBEGKnFoocoW7RufBDCDZKx4/dacUZbiEfCgzp9pN0AGQL90c3IMgBBj0RmB0G547DFdEQcnqzey1AtlcPCLCRAt9QYRVP1oARYkrCwIGkzwtKhIAXeB2RF2UAEC47KtGQJl2+aBA3Xb/y10BHDWtYHYfsenAIZa3Vr4jgLADZPii68pqVAgR15nAKPFBKTlgyb90nucE9qdRx6E/ui7HF1nOqRLZ3T06pdnbhGCsEP6c0WV1z721RK9rjufCVSE6O+WwgtRk8RDWiXWzDfv/PPQRy99vSBU4Pj0j32AAAVqy469XyDURsFxA0zZ8PdsfQBBACLnOr7MKw2AOPpQHcgSAQ4wIG4AfbMUgALZol9MPAABwlllAAVowPwEqJEPMKBlggmAASJwPQY2xEi+kWAEFmjBhDBLaA/oWAcF4gGLhScAwBqhQEAgqPgEIAIBxF4G+gcfBwROejwbUQDKFT3MBCl40ttckP/O17wcSu55LBsUzZpHOz5hjHm+exEPmaaolGFNUQZo3r20mKgsMk9Mg1qe1EzIp4kxTwKEGlrzktgnADavA0Ksk/ek1sI6edF5G7tc65wXRfuoJnpoXNP/YqgzECSgV31aACFhtqeQ8Q5odexT1LBGI0ItEWsgIBQBntesIGHueRkwYIpKBL1GvigAFQSaBGh4HwHsMXqRxE8Abjc9OI5IATeU3gY4RIBFRk9c9mlfBwMJn8apMASrVM8TjykV9CTAlwJEV3gmAE0Lri05qDsmQsioHDVq8yDwU44ZvzkQDnAgPAITozZR0jMA5EyFlEpPNlUITPX0coQcqFZ8HpD/S+lNAIz3KQC2pOcBdgaJAIDD2gcoYABW7giFF6jmujbgAIBaCoU/yRdFr1k4AiSgAv20ErEW0MfQCSABEggphDwwgQUUwKHJw8kAFuA1Ai30ADCNaVJQaLzSZIBuOhXMABjAQb9wgJtBVcwCHskWDFg0qb9xgERn4kOoKmeQY+kABK161XE+JZRc1c47g3LOsGpnh05RnVnPWlSPgKCka0XNJGMCubhu51svqaRdw/PKjnggp3v1jTDditTARseKHbkAYA3rm55qhKOMhQ4RM5K7yG7nkhn5gD4tu50AqDQiiuXseOaikcKKFjqDtUjpTjseUlGEmKzt7FQTotnYPI7HqxMBq23DQ8qKwHa32ZnnROII3Oy49iGZLC46KxJP5W6nrQuJpXOjM0WH1Ha62sGrQ6SJXen01iABAQA7";
    }
});


</script>













