var Contact = Backbone.Model.extend({
    defaults: {
        jid: "test",
        username: "test",
        state: "offline",
        status: "",
        avatarBinVal: "",
        avatarImgType: ""
    },
    initialize: function () {
        this.on("change:state", function (model) {
            var jid = model.get("jid");
            var state = model.get("state");
            $view.contactList.find("li a[jid='" + jid + "']").next().attr('class', 'state ' + state);
        });
        this.on("change:avatarBinVal", function (model) {
            var jid = model.get("jid");
            var avatarImgType = model.get("avatarImgType");
            var avatarBin = model.get("avatarBinVal");
            $view.contactList.find("li a[jid='" + jid + "']").prev().attr('src', 'data:' + avatarImgType + ';base64, ' + avatarBin);
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
        jid: "",
        username: "",
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