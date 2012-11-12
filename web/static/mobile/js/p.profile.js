S.pages['profile'] = function() {
    var page = S.DOM.content,

        follow = page.find('.p-p-follow'),
        photos = page.find('.p-p-imgfeed');


    if (follow.length) {
        var handleRequest = function() {
            var add = !follow.hasClass('following');

            $.ajax({
                url: S.urls.subscriptions,
                data: { userid: follow.data('userid'), action: add ? 'POST' : 'DELETE' },
                type: 'POST',
                dataType: 'json',
                error: S.notifications.presets['server_failed']
            });

            if (add) {
                follow.addClass('following');
            }
            else {
                follow.removeClass('following');
            }
        };

        follow.onpress(handleRequest);
    }

    photos.length && photos.mod_photoFeed();
};
