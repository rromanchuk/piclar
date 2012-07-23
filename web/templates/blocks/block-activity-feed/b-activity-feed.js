// @require 'blocks/block-story-full/b-story-full.js'

(function($){
S.blockActivityFeed = function(settings) {
    this.options = $.extend({}, settings);

    this.els = {};
};

S.blockActivityFeed.prototype.init = function() {
    this.els.block = $('.b-activity-feed');
    this.els.blockTextarea = this.els.block.find('.m-textarea-autogrow');
    this.els.textarea = this.els.blockTextarea.find('.m-t-a-textarea');

    this.story = null;
    this.els.blockTextarea.m_textareaAutogrow();

    this.logic();
   
    $.pub('b_activity_feed_init');

    return this;
};
S.blockActivityFeed.prototype.logic = function() {
    var that = this;

    var handleTextareaFocus = function(e) {
        var el = $(this),
            block = el.parents('.b-story-full');

        // avoiding reinitializing the same block over and over
        if (that.story && block.is(that.story.els.block)) {
            return;
        }

        // removing the previous block
        if (that.story) {
            that.story.destroy();
            delete that.story;
        }

        // creating new block
        that.story = new S.blockStoryFull({ elem: block });
        that.story.init();
    };

    this.els.textarea.on('focus', handleTextareaFocus);

    return this;
};

})(jQuery);
