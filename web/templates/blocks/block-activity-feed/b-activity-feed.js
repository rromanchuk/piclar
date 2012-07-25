// @require 'blocks/block-story-full/b-story-full.js'

(function($){
S.blockActivityFeed = function(settings) {
    this.options = $.extend({}, settings);

    this.els = {};
};

S.blockActivityFeed.prototype.init = function() {
    this.els.block = $('.b-activity-feed');

    this.els.overlay = S.overlay.parts.filter('.story-view');

    this.stories = {};
    this.storyid = 0;

    this.logic();
   
    $.pub('b_activity_feed_init');

    return this;
};
S.blockActivityFeed.prototype.logic = function() {
    var that = this;

    var handleStoryInit = function(e) {
        var el = $(this);

        if (!el.data('feedid')) {
            var target = $(e.target),
                id = ++that.storyid;

            that.stories[id] = new S.blockStoryFull({ elem: el });
            that.stories[id].init();
            el.data('feedid', id);

            target.trigger('click');
        }
    };

    var handleOverlayOpen = function(e) {
        S.e(e);

        var story = $(this).parents('.b-story-full');

        that.els.overlay.html('');
        that.els.overlay.append(story.clone());

        S.overlay.show({ block: '.story-view' });
    };

    this.els.block.on('click', '.b-story-full', handleStoryInit);
    this.els.block.on('click', '.b-s-f-storylink', handleOverlayOpen);

    return this;
};

})(jQuery);
