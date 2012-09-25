S.notifications = (function() {
    var block = $('#l-notifications'),

        template = MEDIA.templates['mobile/js/templates/l.notification.jst'].render,

        infoLifetime = 3000,

        nID = 0;

    var show = function(msg) {
        var item = $(template(msg));
        item.attr('data-nid', ++nID);
        block.append(item);

        msg.id = nID;

        // need a scope in case running within a loop
        (function(id) {
            setTimeout(function() {
                hide(id);
            }, infoLifetime);
        })(nID);

        $.pub('l_notifications_show', msg);
    };

    var hide = function(id) {
        var item = block.find('.l-n-msg[data-nid="' + id + '"]');

        item.remove();

        $.pub('l_notifications_hide', id);
    };

    var load = function() {
        var i = 0,
            l = S.messages.length;

        for (; i < l; i++) {
            show(S.messages[i]);
        }
    };

    var close = function(e) {
        S.e(e);

        var id = $(this).data('nid');

        hide(id);
    };

    block.on('click', '.l-n-msg', close);

    S.messages.length && load();

    $.pub('l_notifications_ready');

    return {
        show: show,
        hide: hide
    };
})();
