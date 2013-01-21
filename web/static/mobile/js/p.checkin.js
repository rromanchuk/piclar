S.pages['checkin'] = function() {
    var page = S.DOM.content,
        story = page.find('.b-activity-story'),

        storyid = story.data('storyid');

    var handleSwipe = function() {
        var answer = confirm ("Удалить запись?");

        if (answer) {
            var handleRemoveStorySuccess = function() {
                // TODO: fix this shit if activity feed grows
                window.location.href = S.urls.index;
            };

            $.ajax({
                url: S.url('checkin_delete', [storyid]),
                type: 'POST',
                dataType: 'json',
                success: handleRemoveStorySuccess,
                error: S.notifications.presets['server_failed']
            });
        }
    };

    new S.blockComments({
        storyid: storyid
    }).init();

    story.hasClass('deletable') && story.on('swipeLeft swipeRight', handleSwipe);
};
