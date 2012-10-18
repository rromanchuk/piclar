S.pages['profile'] = function() {
    var page = S.DOM.content,

        subscribe = page.find('.p-p-s-follow');

    if (subscribe.length) {
        var handleAjaxError = function() {
            S.notifications.show({
                type: 'error',
                text: 'Произошла ошибка при обращении к серверу. Пожалуйста, попробуйте еще раз.'
            });
        };

        var handleRequest = function() {
            var add = !subscribe.hasClass('following');

            $.ajax({
                url: S.urls.subscriptions,
                data: { userid: subscribe.data('userid'), action: add ? 'POST' : 'DELETE' },
                type: 'POST',
                dataType: 'json',
                error: handleAjaxError
            });

            if (add) {
                subscribe.addClass('following');
            }
            else {
                subscribe.removeClass('following');
            }
        };

        subscribe.on('click', handleRequest);
    }
};
