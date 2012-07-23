// @require 'blocks/block-story-full/b-story-full.js'

(function($){
S.blockActivityFeed = function(settings) {
    this.options = $.extend({}, settings);

    this.els = {};
};

S.blockActivityFeed.prototype.init = function() {
    this.els.block = $('.b-activity-feed');

    this.els.metas = this.els.block.find('.b-s-f-meta');
    this.els.like = this.els.metas.find('.b-s-f-meta-likes');
    this.els.addComment = this.els.metas.find('.b-s-f-meta-comment');

    this.els.showAllComments = this.els.block.find('.b-s-f-c-link-showall');

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

    var showAllComments = function() {
        var el = $(this),
            commentsBlock = el.siblings('.b-s-f-c-list'),
            hiddenComments = commentsBlock.find('.b-s-f-c-listitem.hidden');

        hiddenComments.removeClass('hidden');
        el.addClass('disabled');
    };

    var handleLike = function() {
        var el = $(this);

        if (el.hasClass('liked')) {
            return;
        }

        var count = el.children('.b-s-f-meta-likes-count'),
            currentNum = +count.text(),
            storyid = el.parents('.b-story-full').data('storyid');

        count.text(++currentNum);
        el.addClass('liked');

        $.ajax({
            url: S.urls.like,
            data: { storyid: storyid },// yum yum num num
            type: 'PUT',
            dataType: 'json'
        });
    };

    var handleShowCommentForm = function() {
        var el = $(this),
            story = el.parents('.b-story-full'),
            commentsBlock = story.find('.b-s-f-comments'),
            textarea = commentsBlock.find('.m-t-a-textarea'),
            isDisabled = commentsBlock.hasClass('hidden');

        if (isDisabled) {
            commentsBlock.removeClass('hidden');
        }

        textarea.trigger('focus');
    };

    this.els.textarea.on('focus', handleTextareaFocus);
    this.els.showAllComments.on('click', showAllComments);

    this.els.metas.on('click', '.b-s-f-meta-likes', handleLike);
    this.els.metas.on('click', '.b-s-f-meta-comment', handleShowCommentForm);

    return this;
};

})(jQuery);
