<%@ include file="../common.jsp" %>
<%--@elvariable id="user" type="com.talktome.beans.UserVO"--%>
<html>
<head>
    <script type="text/javascript" src="<c:url value="/resources/js/jquery-1.11.1.min.js" />"></script>
    <script type="text/javascript" src="<c:url value="/resources/js/jquery.xmpp.js" />"></script>
    <script type="text/javascript" src="<c:url value="/resources/js/underscore-min.js" />"></script>
    <script type="text/javascript" src="<c:url value="/resources/js/backbone-min.js" />"></script>
    <link rel="stylesheet" href="<c:url value="/resources/bootstrap/css/bootstrap.min.css" />">
    <link rel="stylesheet" href="<c:url value="/resources/bootstrap/css/bootstrap-theme.min.css" />">
    <script src="<c:url value="/resources/bootstrap/js/bootstrap.min.js" />"></script>
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
    <button type="button" data-toggle="modal" data-target="#search-modal">Add contact</button> <br>
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
        var logContainer = $("#log");
        var contactList = $("#contacts");

        var Contact = Backbone.Model.extend({
            defaults : {
                jid: "test",
                username: "test",
                status : "offline"
            },
            initialize: function(){
                this.on("change:status", function(model){
                    var st = model.get("status");
                    contactList.find("li a[jid="+this.jid+"]").next().html(st);
                });
            }
        });

        //var user = new User({ name: "Thomas", age: 67});
        var ContactList = Backbone.Collection.extend({
            model: Contact
        });

        ContactList.prototype.add = function(newContact) {
            var isDupe = this.any(function(contact) {
                return contact.get('jid') === newContact.get('jid');
            });
            if (isDupe) return;
            Backbone.Collection.prototype.add.call(this, newContact);
        }
        var contacts = new ContactList();

        $("#connectBut").click(function () {
            var jid = $("#jid").val();
            var password = $("#pass").val();


            var url = "http://127.0.0.1:7070/http-bind/";
            $.xmpp.connect({url: url, jid: jid, password: password,
                onConnect: function () {
                    logContainer.html("Connected");
                    $.xmpp.setPresence("available");

                    loadContactList(contactList);
                },
                onPresence: function (presence) {
                    if (presence.show == 'subscribe') {
                        var notifications = $('body').find('#notification');
                        notifications.html(" Subscription from: " + presence.from + "<button id='accept-btn' onclick='acceptSubscription($(this))'>Accept</button><button id='refuse-btn'>Refuse</button></div>");
                        notifications.find('#accept-btn').attr('jid', presence.from);
                    } else if(presence.show == 'subscribed' || presence.show == 'unsubscribe' || presence.show == 'unsubscribed') {

                    } else {
                       var contact = contactList.where({jid: presence.from});
                       if(!contact) {
                           contactList.add(new Contact({jid: presence.from, username: presence.from, status: presence.show}));
                       } else {
                           contact.set('status', presence.show);
                       }
                    }
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
                }, onIq: function(data) {
                    if(isRoster(data)) {
                        refreshRoster(data, contactList, contacts);
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

        $("#dnd").click(function() {
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
                for (var i = 0; i < roster.length; i++) {
                    user = roster[i];
                    if (user.subscription == "from" || user.subscription == "to") {
                        var contact = $("<li>");
                        contact.append("<a jid='"+ user.jid +"'  href='javascript:void(0)'>" + user.jid + "</a>");
                        contact.find("a").on('click', function () {
                            var jid = $(this).attr('jid');
                            var id = MD5.hexdigest(jid);
                            var conversation = $("#" + id);
                            if (conversation.length == 0)
                                openChat({to: jid});
                        });
                        contactList.append(contact);
                    }
                }
            })
        }

        function acceptSubscription(elem) {
            jid = elem.attr('jid');
            sendRequest(jid, "subscribed");
        }
        function sendSubscribe(elem) {
            jid = elem.attr('jid');
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
            $.each($(data).find("item"), function(i,item){
                var jItem = $(item);
                roster.push({name: jItem.attr("name"), subscription: jItem.attr("subscription"), jid: jItem.attr("jid")});
            });
            contactList.html("");
            for (var i = 0; i < roster.length; i++) {
                user = roster[i];
                if (user.subscription == "from" || user.subscription == "to") {
                    var contactModel = contactList.where({jid: user.jid});
                    if(!contactModel) {
                        contactList.add(new Contact({jid: user.jid, username: user.jid, status: "offline"}));
                    }
                    var contact = $("<li>");
                    contact.append("<a jid='"+ user.jid +"'  href='javascript:void(0)'>" + user.jid + "</a><div class='status'>none</div>");
                    contact.find("a").on('click', function () {
                        var jid = $(this).attr('jid');
                        var id = MD5.hexdigest(jid);
                        var conversation = $("#" + id);
                        if (conversation.length == 0)
                            openChat({to: jid});
                    });
                    contactList.append(contact);
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
    });



</script>













