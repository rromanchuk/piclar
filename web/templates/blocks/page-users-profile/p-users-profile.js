// @require 'blocks/block-subscriptions/b-subscriptions.js'

(function($){
    var blockSubs = $('.p-u-p-subscribe');

    if (blockSubs.length) {
        var subscribe = blockSubs.find('.p-u-p-link-subscribe'),
            unsubscribe = blockSubs.find('.p-u-p-link-unsubscribe');

        var handleAjaxError = function() {
            S.notifications.show({
                type: 'error',
                text: 'Произошла ошибка при обращении к серверу. Пожалуйста, попробуйте еще раз.'
            });
        };

        var handleRequest = function() {
            var el = $(this),
                subscribe = el.hasClass('p-u-p-link-subscribe');

            $.ajax({
                url: S.urls.subscriptions,
                data: { userid: item.data('userid') },
                type: subscribe ? 'PUT' : 'DELETE',
                dataType: 'json',
                error: handleAjaxError
            });
        };

        subscribe.on('click', handleRequest);
        unsubscribe.on('click', handleRequest);
    }

    new S.blockSubscriptions({
        data: S.data.subscriptions
    }).init();
})(jQuery);
