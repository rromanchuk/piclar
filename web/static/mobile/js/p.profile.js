S.pages['profile'] = function() {
    var page = S.DOM.content,

        follow = page.find('.p-p-follow'),
        photos = page.find('.p-p-imgfeed');


    if (follow.length) {
        var handleAjaxError = function() {
            S.notifications.show({
                type: 'error',
                text: 'Произошла ошибка при обращении к серверу. Пожалуйста, попробуйте еще раз.'
            });
        };

        var handleRequest = function() {
            var add = !follow.hasClass('following');

            $.ajax({
                url: S.urls.subscriptions,
                data: { userid: follow.data('userid'), action: add ? 'POST' : 'DELETE' },
                type: 'POST',
                dataType: 'json',
                error: handleAjaxError
            });

            if (add) {
                follow.addClass('following');
            }
            else {
                follow.removeClass('following');
            }
        };

        follow.on('click', handleRequest);
    }

    photos.length && photos.mod_photoFeed();
};
