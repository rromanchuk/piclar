(function($){
S.blockStory = function(settings) {
    // this.options = $.extend({}, settings);
    this.els = {};
};

S.blockStory.prototype.init = function() {
    this.els.blocks = $('.b-activity-story');

    this.logic();
    
    $.pub('b_story_init');

    return this;
};

S.blockStory.prototype.logic = function() {
    var that = this;

    var handleLike = function(e) {
        S.e(e);

        var el = $(this),
            currentNum = +el.text(),
            liked = el.hasClass('liked'),
            storyid = el.parents('.b-activity-story').data('storyid');

        $.ajax({
            url: S.urls.like,
            data: { storyid: storyid, action: liked ? 'DELETE' : 'POST' },
            type: 'POST',
            dataType: 'json',
            error: S.notifications.presets['server_failed']
        });

        if (!liked) {
            el.text(++currentNum);
            el.addClass('liked');
        }
        else {
            el.text(--currentNum);
            el.removeClass('liked');
        }
    };

    var handleSwipe = function() {
        var answer = confirm('Удалить запись?');

        if (answer) {
            var el = $(this),
                id = el.data('storyid');

            var handleRemoveStorySuccess = function() {
                // TODO: fix this shit if activity feed grows
                el.parent().remove();
            };

            $.ajax({
                url: S.url('checkin_delete', [id]),
                type: 'POST',
                dataType: 'json',
                success: handleRemoveStorySuccess,
                error: S.notifications.presets['server_failed']
            });
        }
    };

    this.els.blocks.onpress('.b-a-s-c-like', handleLike);
    this.els.blocks.filter('.deletable').on('swipeLeft swipeRight', handleSwipe);
};

})(Zepto);
