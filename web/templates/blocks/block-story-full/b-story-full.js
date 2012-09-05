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

    this.els.remove = this.els.block.find('.b-s-f-removestory, .b-s-f-meta-removestory');

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

    var handleTextareaInit = function(e) {
        that.commentLogic();
    };

    var showAllComments = function(e) {
        S.e(e);
        that.els.comments.find('.b-s-f-c-listitem.hidden').removeClass('hidden');
        that.els.showAllComments.addClass('disabled');
    };

    var handleLikeSuccess = function(resp) {
        if (that.data) {
            $.extend(true, that.data, resp);
        }
    };

    var handleAjaxError = function() {
        S.notifications.show({
            type: 'error',
            text: 'Произошла ошибка при обращении к серверу. Пожалуйста, попробуйте еще раз.'
        });
    };

    var handleLike = function(e) {
        S.e(e);

        var count = that.els.like.children('.b-s-f-meta-likes-count'),
            currentNum = +count.text();

        $.ajax({
            url: S.urls.like,
            data: { storyid: that.storyid, action: that.liked ? 'DELETE' : 'POST' },
            type: 'POST',
            dataType: 'json',
            success: handleLikeSuccess,
            error: handleAjaxError
        });

        if (!that.liked) {
            count.text(++currentNum);
            that.els.like.addClass('liked');
            that.liked = true;

            if (that.data) {
                that.data.me_liked = true;
                that.data.count_likes = currentNum;
            }
        }
        else {
            count.text(--currentNum);
            that.els.like.removeClass('liked');
            that.liked = false;

            if (that.data) {
                that.data.me_liked = false;
                that.data.count_likes = currentNum;
            }
        }
    };

    var handleShowCommentForm = function(e) {
        S.e(e);
        that.els.commentsBlock.removeClass('hidden');
        that.els.textarea.trigger('focus');
    };

    var removeCommentById = function(cid) {
        var i = 0,
            l = that.data.comments.length;

        for (; i < l; i++) {
            console.log(that.data.comments[i].id === cid, i, that.data.comments[i].id, cid);
            if (that.data.comments[i].id === cid) {
                that.data.comments.splice(i, 1);
            }
        }
    };

    var handleRemoveComment = function(e) {
        S.e(e);

        var el = $(this),
            comment = el.parents('.b-s-f-c-listitem'),
            commentid = +comment.data('commentid');

        var handleRemoveCommentSuccess = function() {
            comment.remove();
            that.data && removeCommentById(commentid);
        };

        $.ajax({
            url: S.urls.comments,
            data: { commentid: commentid, storyid: that.storyid,  action: 'DELETE' },
            type: 'POST',
            dataType: 'json',
            success: handleRemoveCommentSuccess,
            error: handleAjaxError
        });
    };

    var handleRemoveStory = function(e) {
        S.e(e);

        var handleRemoveStorySuccess = function() {
            that.destroy();
        };

        $.ajax({
            url: S.urls.feed,
            data: { storyid: that.storyid,  action: 'DELETE' },
            type: 'POST',
            dataType: 'json',
            success: handleRemoveStorySuccess,
            error: handleAjaxError
        });
    };

    this.els.textarea.one('click focus', handleTextareaInit);
    this.els.showAllComments.one('click', showAllComments);
    this.els.addComment.one('click', handleShowCommentForm);

    this.els.like.on('click', handleLike);
    this.els.comments.on('click', '.b-s-f-c-remove', handleRemoveComment);

    this.els.remove.on('click', handleRemoveStory);
};
S.blockStoryFull.prototype.destroy = function() {
    $.pub('b_story_full_destroy', this.storyid);

    this.els.textarea.off('click focus');
    this.els.showAllComments.off('click');
    this.els.addComment.off('click');
    this.els.like.off('click');
    this.els.comments.off('click');
    this.els.remove.off('click');

    this.els.form.off('submit');
    this.els.textarea.off('keydown');

    if (this.options.removable) {
        this.els.block.remove();
    }
    else {
        window.location.href = S.urls.index;
    }

    $.pub('b_story_full_destroyed', this.storyid);
};

S.blockStoryFull.prototype.commentLogic = function() {
    var that = this,
        deferred,
        message;

    var addComment = function(msg) {
        var comment = $(that.template({
            id: 0,
            message: $('<div/>').text(msg).html(),
            user: S.user,
            create_date: +(new Date()),
            counter: 0
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
        if (resp.id) {
            // success
            that.els.textarea.removeAttr('disabled');
            that.els.comments.find('.temporary').attr('data-commentid', resp.id).removeClass('temporary');

            that.data && that.data.comments.push(resp);
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

        S.notifications.show({
            type: 'warning',
            text: 'Произошла ошибка при обращении к серверу. Пожалуйста, попробуйте еще раз.'
        });
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
            data: { message: message, storyid: that.storyid,  action: 'POST' },
            type: 'POST',
            dataType: 'json',
            timeout: 20000, // 20 sec
            success: handleFormSuccess,
            error: handleFormError
        });

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
