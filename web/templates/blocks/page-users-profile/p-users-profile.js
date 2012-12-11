// @require 'blocks/block-subscriptions/b-subscriptions.js'
// @require 'blocks/block-photomap/b-photomap.js'

(function($){
    var blockSubs = $('.p-u-p-subscribe');

    if (blockSubs.length) {
        var subscribe = blockSubs.find('.p-u-p-link-subscribe'),
            unsubscribe = blockSubs.find('.p-u-p-link-unsubscribe');

        var handleRequest = function() {
            var el = $(this),
                subscribe = el.hasClass('p-u-p-link-subscribe');

            $.ajax({
                url: S.urls.subscriptions,
                data: { userid: blockSubs.data('userid'), action: subscribe ? 'POST' : 'DELETE' },
                type: 'POST',
                dataType: 'json',
                error: S.notifications.presets['server_failed']
            });

            if (subscribe) {
                blockSubs.addClass('following');
            }
            else {
                blockSubs.removeClass('following');
            }
        };

        subscribe.on('click', handleRequest);
        unsubscribe.on('click', handleRequest);
    }

    new S.blockSubscriptions({
        data: S.data.subscriptions,
        is_profile_owner: S.data.is_profile_owner
    }).init();

    new S.blockPhotoMap({
        places: S.data.checkins
    }).init();
})(jQuery);
