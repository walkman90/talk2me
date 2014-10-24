<%@ include file="../common.jsp" %>
<%--@elvariable id="user" type="com.talktome.beans.UserVO"--%>
<html>
<head>
    <script type="text/javascript" src="<c:url value="/resources/js/jquery-1.11.1.min.js" />"></script>
    <script type="text/javascript" src="<c:url value="/resources/js/jquery.xmpp.js" />"></script>
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
<div id="container">
    <div id="left-block">
        <div class="user-info">
            <div class="avatar"></div>
            ${user.name}
        </div>
        <div class="actions">
            <div data-toggle="modal" data-target="#search-modal" class="action add-contact"><i class="fa fa-user"></i><i class="fa fa-plus"></i></div>
        </div>
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
        <div id="log">
        </div>
        <ul id="contacts">
        </ul>
    </div>

    <div id="right-block">
        <button id="disconnectBut">Disconnect</button>
    </div>

    <div id='notification'></div>

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
    var $model = $model || {};
    var $view = $view || {};
    var logContainer = $("#log");
    $view.contactList = $("#contacts");

    var Contact = Backbone.Model.extend({
        defaults: {
            jid: "test",
            username: "test",
            state: "offline",
            status: ""
        },
        initialize: function () {
            this.on("change:state", function (model) {
                var jid = model.get("jid");
                var state = model.get("state");
                $view.contactList.find("li a[jid='" + jid + "']").next().attr('class', 'state ' + state);
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
            username: "test",
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


    // $("#connectBut").click(function () {
    var jid = '${user.jid}';
    var password = '${user.password}';


    var url = "http://127.0.0.1:7070/http-bind/";
    $.xmpp.connect({url: url, jid: jid, password: password,
        onConnect: function () {
            logContainer.html("Connected");
            $.xmpp.setPresence("chat", null);

            loadContactList($view.contactList);
        },
        onPresence: function (presence) {
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
                    var notification = $('body').find('#notification');
                    notification.html("<div class='msg'> Subscription from: " + presence.from + "</div><button class='btn btn-primary btn-xs' id='accept-btn' onclick='$(\"body\").trigger(\"acceptSubscription\", [\"" + jid + "\"])'>Accept</button><button class='btn btn-default btn-xs'>Refuse</button>");
                    notification.find('#accept-btn').attr('jid', presence.from);
                    notification.show("slow");
                }
            } else if (presence.type == 'subscribed') {

                if ($.inArray(jid, outRequests) != -1) {
                    subscriptionAutoResponse(jid, 'subscribe');
                    $model.user.get('outgoingContactRequests').pop(jid);
                } else if ($.inArray(jid, inRequests) != -1) {
                    subscriptionAutoResponse(jid, 'subscribe');
                    $model.user.get('incomingContactRequests').pop(jid);
                }
            } else {
                var contact = $model.user.get('contacts').findWhere({jid: jid});
                if (!contact) {
                    $model.user.get('contacts').add(new Contact({jid: jid, username: presence.from, status: presence.status, state: presence.show}));
                } else {
                    contact.set('status', presence.status);
                    contact.set('state', presence.show);
                }
            }
            loadContactList($view.contactList);
        },
        onDisconnect: function () {
            logContainer.html("Disconnected");
        },
        onMessage: function (message) {

            var jid = message.from.split("/");
            var id = MD5.hexdigest(jid[0]);
            var conversation = $("#" + id);
            if (conversation.length == 0) {
                openChat({to: jid[0]});
            }
            conversation = $("#" + id);
            conversation.find(".conversation").append("<div>" + jid[0] + ": " + message.body + "</div>");
        }, onIq: function (data) {
            if (isRoster(data)) {
                refreshRoster(data, $view.contactList, $model.user.contacts);
            }
        }, onError: function (error) {
            alert(error.error);
        }
    });
    //});

    $("#disconnectBut").click(function () {
        $.xmpp.disconnect();
    });


    $("#dnd").click(function () {
        $.xmpp.setPresence("dnd");
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
    function loadContactList(contactList) {
        $.xmpp.getRoster(function (roster) {
        });
    }

    function subscriptionAutoResponse(jid, type) {
        sendRequest(jid, type);
        refreshRoster(data, $view.contactList, $model.user.contacts);
    }

    $('body').on('acceptSubscription', function (event, jid) {
        sendRequest(jid, "subscribed");
        sendRequest(jid, "subscribe");
        $('#notification').hide("slow");
    });

    $('body').on('sendSubscribe', function (event, jid) {
        sendRequest(jid, "subscribe");
    });

    function sendSubscribe(elem) {
        jid = elem.attr('jid');
        subscribedToList.push(jid);
        sendRequest(jid, "subscribe");
    }

    function sendRequest(jid, type) {
        $.xmpp.sendCommand("<presence to='" + jid + "' type='" + type + "'/>",
                function (e) {
                    e;
                });
    }

    function isRoster(data) {
        return data.outerHTML.indexOf("jabber:iq:roster") != -1
    }

    function refreshRoster(data, contactList, contacts) {
        var roster = [];
        $.each($(data).find("item"), function (i, item) {
            var jItem = $(item);
            roster.push({name: jItem.attr("name"), subscription: jItem.attr("subscription"), jid: jItem.attr("jid")});
        });
        $view.contactList.html("");
        for (var i = 0; i < roster.length; i++) {
            user = roster[i];
            if (user.subscription == "both") {
                $model.contact = $model.user.get('contacts').findWhere({jid: user.jid});
                if (!$model.contact) {
                    $model.user.get('contacts').add(new Contact({jid: user.jid, username: user.jid, status: "", state: "offline"}));
                    $model.contact = $model.user.get('contacts').findWhere({jid: user.jid});
                }
                var contact = $("<li>");
                contact.append("<a jid='" + $model.contact.get('jid') + "'  href='javascript:void(0)'>" + $model.contact.get('jid') + "</a><div class='state " + $model.contact.get('state') + "'></div>");
                contact.find("a").on('click', function () {
                    var jid = $(this).attr('jid');
                    var id = MD5.hexdigest(jid);
                    var conversation = $("#" + id);
                    if (conversation.length == 0)
                        openChat({to: jid});
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

    function jidTrim(jid) {
        if (jid.indexOf('/') == -1) {
            return jid;
        } else {
            return jid.substr(0, jid.indexOf('/'));
        }
    }
});


</script>













