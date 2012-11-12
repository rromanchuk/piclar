// @require 'blocks/layout-notifications/l-notifications.jst'

S.notifications = (function() {
    var block = $('#l-notifications'),

        template = MEDIA.templates['blocks/layout-notifications/l-notifications.jst'].render,

        infoLifetime = 3000,

        animDuration = 300,

        nID = 0;

    var show = function(msg) {
        var item = $(template(msg));
        item.hide();
        item.attr('data-nid', ++nID);
        block.append(item);
        item.fadeIn(animDuration);

        msg.id = nID;

        if (msg.type === 'info') {
            (function(id) {
                setTimeout(function() {
                    hide(id);
                }, infoLifetime);
            })(nID);
        }

        $.pub('l_notifications_show', msg);
    };

    var hide = function(id) {
        var item = block.find('.l-n-msg[data-nid="' + id + '"]');

        item.fadeOut(animDuration, function() {
            item.remove();

            $.pub('l_notifications_hide', id);
        });
    };

    var close = function(e) {
        S.e(e);

        var id = $(this).parents('.l-n-msg').data('nid');

        hide(id);
    };

    var load = function() {
        var i = 0,
            l = S.messages.length;

        for (; i < l; i++) {
            show(S.messages[i]);
        }
    };

    var presets = {
        'server_failed': function() {
            show({
                type: 'error',
                text: 'Произошла ошибка при обращении к серверу. Пожалуйста, попробуйте еще раз.'
            });
        }
    };

    block.on('click', '.l-n-close', close);

    S.messages.length && load();

    $.pub('l_notifications_ready');

    return {
        show: show,
        hide: hide,
        presets: presets
    };
})();
