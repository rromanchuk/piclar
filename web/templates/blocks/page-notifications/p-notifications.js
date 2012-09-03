(function($){
    var page = S.DOM.content,

        list = page.find('.p-n-list'),

        readall = page.find('.p-n-markreadall');

    var handleError = function() {
        S.notifications.show({
            type: 'warning',
            text: 'Не удалось обновить список подписок на сервере. Пожалуйста, попробуйте еще раз.'
        });
    };

    var markRead = function(e) {
        S.e(e);
        var el = $(this),
            item = el.parents('.p-n-l-item');

        $.ajax({
            url: S.urls.notifications_markread,
            data: { n_ids: [ item.data('nid') ] },
            type: 'POST',
            traditional: true,
            dataType: 'json',
            error: handleError
        });

        item.removeClass('unseen');

        // last unseen item
        list.find('.p-n-l-item.unseen').length || readall.addClass('disabled');
    };

    var markAllRead = function(e) {
        S.e(e);

        if (readall.hasClass('disabled')) {
            return;
        }

        $.ajax({
            url: S.urls.notifications_markread,
            data: { n_ids: 'all' },
            type: 'POST',
            dataType: 'json',
            error: handleError
        });

        list.find('.unseen').removeClass('unseen');

        readall.addClass('disabled');
    };

    list.on('click', '.p-n-l-markread', markRead);
    readall.one('click', markAllRead);
})(jQuery);
