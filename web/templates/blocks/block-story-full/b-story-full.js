// @require 'blocks/block-story-full/b-story-full.jst'
// @require 'blocks/block-story-full/b-story-full-comment.jst'

(function($){
S.blockStoryFull = function(settings) {
    this.options = $.extend({
        elem: '.b-story-full',
        data: false
    }, settings);

    this.els = {};
};

S.blockStoryFull.prototype.init = function() {
    this.els.block = $(this.options.elem);

    this.els.metas = this.els.block.find('.b-s-f-meta');
    this.els.like = this.els.metas.find('.b-s-f-meta-likes');
    this.els.addComment = this.els.metas.find('.b-s-f-meta-comment');

    this.els.showAllComments = this.els.block.find('.b-s-f-c-link-showall');

    this.els.commentsBlock = this.els.block.find('.b-s-f-comments');
    this.els.comments = this.els.commentsBlock.find('.b-s-f-c-list');

    this.els.form = this.els.block.find('.b-s-f-c-addnew');
    this.els.blockTextarea = this.els.form.find('.m-textarea-autogrow');
    this.els.textarea = this.els.blockTextarea.find('.m-t-a-textarea');

    if (this.options.data) {
        this.data = this.options.data;
        this.liked = this.data.me_liked;
        this.storyid = this.data.id;
    }
    else {
        this.liked = this.els.like.hasClass('liked');
        this.storyid = this.els.block.data('storyid');
    }

    this.template = MEDIA.templates['blocks/block-story-full/b-story-full-comment.jst'].render;

    this.logic();
    
    $.pub('b_story_full_init');

    return this;
};

S.blockStoryFull.prototype.logic = function() {
    var that = this;

    var handleTextareaFocus = function(e) {
        that.commentLogic();
    };

    var showAllComments = function(e) {
        S.e(e);
        that.els.comments.find('.b-s-f-c-listitem.hidden');
        that.els.showAllComments.addClass('disabled');
    };

    var handleLike = function(e) {
        S.e(e);

        if (that.liked) {
            return;
        }

        var count = that.els.like.children('.b-s-f-meta-likes-count'),
            currentNum = +count.text();

        count.text(++currentNum);
        that.els.like.addClass('liked');
        that.liked = true;

        if (that.data) {
            that.data.me_liked = true;
            that.data.cnt_likes = currentNum;
        }

        $.ajax({
            url: S.urls.like,
            data: { storyid: that.storyid },
            type: 'PUT',
            dataType: 'json'
        });
    };

    var handleShowCommentForm = function(e) {
        S.e(e);
        that.els.commentsBlock.removeClass('hidden');
        that.els.textarea.trigger('focus');
    };

    this.els.textarea.one('focus', handleTextareaFocus);
    this.els.showAllComments.one('click', showAllComments);

    this.els.like.one('click', handleLike);
    this.els.addComment.one('click', handleShowCommentForm);
};

S.blockStoryFull.prototype.commentLogic = function() {
    var that = this,
        req,
        deferred,
        message;

    var addComment = function(msg) {
        var comment = $(that.template({
            id: 0,
            message: msg,
            user: S.user
        }));

        comment.addClass('temporary');

        that.els.comments.append(comment);
    };

    var removeComment = function() {
        var comment = that.els.comments.children('.temporary'),
            message = comment.find('.b-s-f-c-message').text();

        that.els.textarea.val(message);
        comment.remove();
    };

    var clearTemporary = function() {
        that.els.comments.children('.temporary').remove();
    };

    var handleFormSuccess = function(resp) {
        if (resp.status === 'ok') {
            // success
            that.els.textarea.removeAttr('disabled');
            that.els.comments.find('.temporary').attr('data-commentid', resp.value.id).removeClass('temporary');

            that.data && that.data.comments.push(resp.value);
        }
        else {
            // no luck
            handleFormError();
        }
    };

    var handleFormError = function() {
        if (deferred.readyState === 0) { // Cancelled request, still loading
            return;
        }

        that.els.textarea.removeAttr('disabled');
        removeComment();
    };

    var handleFormSubmit = function(e) {
        e && S.e(e);

        if (!that.els.textarea.val().length) {// basic validation
            return;
        }

        if ((typeof deferred !== 'undefined') && (deferred.readyState !== 4)) {
            // never supposed to see this
            deferred.abort();
            clearTemporary();
        }

        message = that.els.textarea.val();

        deferred = $.ajax({
            url: S.urls.comments,
            data: { comment: message, feed_id: that.storyid },
            type: 'POST',
            dataType: 'json',
            timeout: 20000 // 20 sec
        });

        req = deferred.pipe(
            function(response) {// Success pre-handler
                if ('status' in response && response.status === 'success'){
                    return response;
                } else {
                    // The response is actually a FAIL even though it
                    // came through as a success (200). Convert this
                    // promise resolution to a FAIL.
                    return $.Deferred().reject(response);
                }
            },
            function(response) {// Fail pre-handler
                return {
                    status: 'failed',
                    value: 'Произошел сбой соединения. Пожалуйста, повторите попытку.'
                };
            }
        );

        req.then(handleFormSuccess, handleFormError);

        that.els.textarea.val('');
        that.els.textarea.attr('disabled', 'disabled');

        addComment(message);
    };

    var handleInput = function(e) {
        if (e.keyCode === 13) {
            handleFormSubmit(e);
        }
    };

    this.els.blockTextarea.m_textareaAutogrow();

    this.els.form.on('submit', handleFormSubmit);
    this.els.textarea.on('keydown', handleInput);

    return this;
};

})(jQuery);
