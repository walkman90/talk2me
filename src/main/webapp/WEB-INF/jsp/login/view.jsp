<%@ include file="../common.jsp" %>
<%--@elvariable id="user" type="com.talktome.beans.UserVO"--%>
<html>
<head>
    <script type="text/javascript" src="<c:url value="/resources/js/jquery-1.11.1.min.js" />"></script>
    <script type="text/javascript" src="<c:url value="/resources/js/jquery.xmpp.js" />"></script>
    <script type="text/javascript" src="<c:url value="/resources/js/underscore-min.js" />"></script>
    <script type="text/javascript" src="<c:url value="/resources/js/backbone-min.js" />"></script>
    <script src="<c:url value="/resources/bootstrap/js/bootstrap.min.js" />"></script>
    <link rel="stylesheet" href="<c:url value="/resources/css/login.css" />">
    <link rel="stylesheet" href="<c:url value="/resources/bootstrap/css/bootstrap.min.css" />">
    <link rel="stylesheet" href="<c:url value="/resources/bootstrap/css/bootstrap-theme.min.css" />">
    <title>Basic connection</title>
</head>

</head>
<body>
<div id="container">
    This example just connect notify when connected and show the connected contacts.
    <br>
    Jid <input type="text" id="jid"> (ej: maxpowel@gmail.com, alvaro.maxpowel@chat.facebook.com)
    <br>
    Password <input type="password" id="pass">
    <br>
    <button id="connectBut">Connect</button>
    <button id="disconnectBut">Disconnect</button>
    <br>
    <button id="send-request">Send Request to Test2</button>
    <br>
    <button type="button" data-toggle="modal" data-target="#search-modal">Add contact</button>
    <br>
    <button id="dnd">Set DND</button>
    <div id="log">
    </div>
    <ul id="contacts">
    </ul>
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
                    <input type="text" placeholder="Search"/>
                    <button id="btn-find">Find</button>
                    <div id="search-result"></div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary">Save changes</button>
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
            state: "unavailable",
            status: "none"
        },
        initialize: function () {
            this.on("change:state", function (model) {
                var jid = model.get("jid");
                $view.contactList.find("li a[jid='" + jid + "']").next().html(model.get("state"));
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
            state: "unavailable",
            status: "none",
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
   // $model.user.contacts = new ContactList();
    var subscribedToList = [];

    $("#connectBut").click(function () {
        var jid = $("#jid").val();
        var password = $("#pass").val();


        var url = "http://127.0.0.1:7070/http-bind/";
        $.xmpp.connect({url: url, jid: jid, password: password,
            onConnect: function () {
                logContainer.html("Connected");
                $.xmpp.setPresence(null);

                loadContactList($view.contactList);
            },
            onPresence: function (presence) {
                var jid = jidTrim(presence.from);
                outRequests = $model.user.get('outgoingContactRequests');
                inRequests = $model.user.get('incomingContactRequests');
                if (presence.type == 'subscribe') {
                    if ($.inArray(jid, outRequests) != -1) {
                        subscriptionAutoResponse(jid, 'subscribed');
                        $model.user.get('outgoingContactRequests').pop(jid);
                    } else if ($.inArray(jid, inRequests) != -1) {
                        subscriptionAutoResponse(jid, 'subscribed');
                        $model.user.get('incomingContactRequests').pop(jid);
                    } else {
                        var notification = $('body').find('#notification');
                        notification.html("<div class='msg'> Subscription from: " + presence.from + "</div><button class='btn btn-primary btn-xs' id='accept-btn' onclick='$(\"body\").trigger(\"acceptSubscription\", [\""+jid+"\"])'>Accept</button><button class='btn btn-default btn-xs'>Refuse</button>");
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
                    var contact =  $model.user.get('contacts').findWhere({jid: jid});
                    if (!contact) {
                        $model.user.get('contacts').add(new Contact({jid: jid, username: presence.from, status: presence.status, state: presence.type}));
                    } else {
                        contact.set('status', presence.status);
                        contact.set('state', presence.type);
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
    });

    $("#disconnectBut").click(function () {
        $.xmpp.disconnect();
    });

    $("#send-request").on('click', function () {
        $.xmpp.sendCommand("<presence to='test2@wsua-01832' type='subscribe'/>",
                function (e) {
                    e;
                });
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

    $('body').on('acceptSubscription', function(event, jid) {
        sendRequest(jid, "subscribed");
        sendRequest(jid, "subscribe");
        $('#notification').hide("slow");
    });

    $('body').on('sendSubscribe', function(event, jid) {
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
                var contactModel = $model.user.get('contacts').findWhere({jid: user.jid});
                if (!contactModel) {
                    $model.user.get('contacts').add(new Contact({jid: user.jid, username: user.jid, status: "none", state: "unavailable"}));
                }
                var contact = $("<li>");
                contact.append("<a jid='" + user.jid + "'  href='javascript:void(0)'>" + user.jid + "</a><div class='state'>none</div>");
                contact.find("a").on('click', function () {
                    var jid = $(this).attr('jid');
                    var id = MD5.hexdigest(jid);
                    var conversation = $("#" + id);
                    if (conversation.length == 0)
                        openChat({to: jid});
                });
                $view.contactList.append(contact);
            }
            if(user.subscription == "to") {
                $model.user.get('outgoingContactRequests').push(user.jid);
            }
            if(user.subscription == "from") {
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
        if(jid.indexOf('/') == -1) {
            return jid;
        } else {
            return jid.substr(0, jid.indexOf('/'));
        }
    }
});


</script>













