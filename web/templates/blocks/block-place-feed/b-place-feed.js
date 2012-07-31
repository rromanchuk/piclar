// @require 'blocks/block-story-full/b-story-full.js'

(function($){
S.blockPlaceFeed = function(settings) {
    this.options = $.extend({
        collection: false
    }, settings);

    this.els = {};
};

S.blockPlaceFeed.prototype.init = function() {
    this.els.block = $('.b-place-feed');

    this.stories = {};
    this.storyid = 0;

    this.logic();
   
    $.pub('b_activity_feed_init');

    return this;
};
S.blockPlaceFeed.prototype.logic = function() {
    var that = this;

    var handleStoryInit = function(e) {
        var el = $(this);

        if (!el.data('feedid')) {
            var target = $(e.target),
                id = ++that.storyid;

            that.stories[id] = new S.blockStoryFull({
                elem: el
            });
            that.stories[id].init();
            el.data('feedid', id);

            target.trigger('click');
        }
    };

    this.els.block.on('click', '.b-story-full', handleStoryInit);

    return this;
};

})(jQuery);
