// @require 'blocks/block-story-full/b-story-full.js'

(function($){
S.blockActivityFeed = function(settings) {
    this.options = $.extend({}, settings);

    this.els = {};
};

S.blockActivityFeed.prototype.init = function() {
    this.els.block = $('.b-activity-feed');

    this.stories = {};

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
                id = Math.floor(Math.random() * +(new Date()));

            that.stories[id] = new S.blockStoryFull({ elem: el });
            that.stories[id].init();
            el.data('feedid', id);

            target.trigger('click');
        }
    };

    this.els.block.on('click', '.b-story-full', handleStoryInit);

    return this;
};

})(jQuery);
