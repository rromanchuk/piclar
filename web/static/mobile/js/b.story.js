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
            data: { storyid: storyid, action: liked ? 'DELETE' : 'POST', token: S.env.token },
            type: 'POST',
            dataType: 'json'//,
            // success: handleLikeSuccess,
            //error: handleAjaxError
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

    this.els.blocks.on('click', '.b-a-s-c-like', handleLike);
};

})(Zepto);
