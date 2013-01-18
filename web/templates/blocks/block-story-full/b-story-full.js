// @require 'blocks/block-story-full/b-story-full.jst'
// @require 'blocks/block-story-full/b-story-full-comment.jst'
// @require 'blocks/block-story-full/b-story-full-likeitem.jst'

(function($){
S.blockStoryFull = function(settings) {
    this.options = $.extend({
        elem: '.b-story-full',
        // noAutoGrow: false,
        data: false
    }, settings);

    this.els = {};
};

S.blockStoryFull.prototype.init = function() {
    this.els.block = $(this.options.elem);

    this.els.favorite = this.els.block.find('.b-s-f-favorite');

    this.els.metas = this.els.block.find('.b-s-f-meta');

    this.els.likesWrap = this.els.metas.find('.b-s-f-metaitem-likeswrap');
    this.els.like = this.els.likesWrap.find('.b-s-f-meta-likes');
    this.els.facelist = this.els.likesWrap.find('.b-s-f-l-facelist');

    this.els.addComment = this.els.metas.find('.b-s-f-meta-comment');

    this.els.showAllComments = this.els.block.find('.b-s-f-c-link-showall');

    this.els.commentsBlock = this.els.block.find('.b-s-f-comments');
    this.els.comments = this.els.commentsBlock.find('.b-s-f-c-list');

    this.els.form = this.els.block.find('.b-s-f-c-addnew');
    this.els.blockTextarea = this.els.form.find('.m-textarea-autogrow');
    this.els.textarea = this.els.blockTextarea.find('.m-t-a-textarea');

    this.els.remove = this.els.block.find('.b-s-f-removestory, .b-s-f-meta-removestory');

    this.altered = false;

    if (this.options.data) {
        this.data = this.options.data;
        this.liked = this.data.me_liked;
        this.storyid = this.data.id;

        this.favorite = this.data.checkin.place.is_favorite;
        this.placeid = this.data.checkin.place.id;

        this.updateCommentsMap();
        this.updateLikesMap();
    }
    else {
        this.liked = this.els.like.hasClass('liked');
        this.storyid = this.els.block.data('storyid');

        this.favorite = this.els.favorite.hasClass('active');
        this.placeid = this.els.favorite.data('placeid');
    }

    this.commentTemplate = MEDIA.templates['blocks/block-story-full/b-story-full-comment.jst'].render;
    this.likeTemplate = MEDIA.templates['blocks/block-story-full/b-story-full-likeitem.jst'].render;

    this.logic();
    
    $.pub('b_story_full_init');

    return this;
};
S.blockStoryFull.prototype.updateCommentsMap = function() {
    this.commentsMap = [];

    var i = 0,
        l = this.data.comments.length;

    for (; i < l; i++) {
        this.commentsMap.push(this.data.comments[i].id);
    }

    return this;
};
S.blockStoryFull.prototype.updateLikesMap = function() {
    this.likesMap = [];

    var i = 0,
        l = this.data.liked.length;

    for (; i < l; i++) {
        this.likesMap.push(this.data.liked[i].id);
    }

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

    // var handleLikeSuccess = function(resp) {
    //     if (that.data) {
    //         $.extend(true, that.data, resp);
    //     }
    // };

    var handleLike = function(e) {
        S.e(e);

        var count = that.els.like.children('.b-s-f-meta-likes-count'),
            currentNum = +count.text();

        $.ajax({
            url: S.urls.like,
            data: { storyid: that.storyid, action: that.liked ? 'DELETE' : 'POST' },
            type: 'POST',
            dataType: 'json',
            //success: handleLikeSuccess,
            error: S.notifications.presets['server_failed']
        });

        if (!that.liked) {
            count.text(++currentNum);
            that.els.like.addClass('liked');
            that.liked = true;

            if (that.data) {
                that.data.me_liked = true;
                that.data.count_likes = currentNum;

                that.likesMap.push(S.user.id);
                that.data.liked.push(S.user);
            }

            that.els.facelist.prepend(that.likeTemplate(S.user));

            if (currentNum > S.env.likes_preview) {
                that.els.likesWrap.addClass('has_likes has_extra_likes');
            }
            else {
                that.els.likesWrap.addClass('has_likes');
            }
        }
        else {
            count.text(--currentNum);
            that.els.like.removeClass('liked');
            that.liked = false;

            if (that.data) {
                that.data.me_liked = false;
                that.data.count_likes = currentNum;

                var index = _.indexOf(that.likesMap, S.user.id);

                that.likesMap.splice(index, 1);
                that.data.liked.splice(index, 1);
            }

            that.els.facelist.find('.b-s-f-l-f-face.own').remove();

            if (currentNum <= 0) {
                that.els.likesWrap.removeClass('has_likes');
            }

            if (currentNum <= S.env.likes_preview) {
                that.els.likesWrap.removeClass('has_extra_likes');
            }
        }

        that.altered = true;
    };

    var handleShowCommentForm = function(e) {
        S.e(e);
        that.els.commentsBlock.removeClass('hidden');
        that.els.textarea.trigger('focus');
    };

    var handleRemoveComment = function(e) {
        S.e(e);

        var el = $(this),
            comment = el.parents('.b-s-f-c-listitem'),
            commentid = +comment.data('commentid');

        var handleRemoveCommentSuccess = function() {
            comment.remove();

            if (that.data) {
                var index = _.indexOf(that.commentsMap, commentid);

                that.commentsMap.splice(index, 1);
                that.data.comments.splice(index, 1);
            }
        };

        $.ajax({
            url: S.urls.comments,
            data: { commentid: commentid, storyid: that.storyid, action: 'DELETE' },
            type: 'POST',
            dataType: 'json',
            success: handleRemoveCommentSuccess,
            error: S.notifications.presets['server_failed']
        });

        that.altered = true;
    };

    var handleRemoveStory = function(e) {
        S.e(e);

        var handleRemoveStorySuccess = function() {
            that.destroy();
        };

        $.ajax({
            // FIXME: update url and data
            url: S.urls.feed,
            data: { storyid: that.storyid,  action: 'DELETE' },
            type: 'POST',
            dataType: 'json',
            success: handleRemoveStorySuccess,
            error: S.notifications.presets['server_failed']
        });

        that.altered = true;
    };

    var handleFavorite = function(e) {
        S.e(e);

        that.altered = true;

        if (that.favorite) {
            that.els.favorite.removeClass('active');

            $.ajax({
                url: S.urls.favorite,
                data: { placeid: that.placeid,  action: 'DELETE' },
                type: 'POST',
                dataType: 'json',
                error: handleAjaxError
            });

            if (that.data) {
                that.favorite = false;
                that.data.data.place.is_favorite = false;
            }
        }
        else {
            that.els.favorite.addClass('active');

            $.ajax({
                url: S.urls.favorite,
                data: { placeid: that.placeid, action: 'PUT' },
                type: 'POST',
                dataType: 'json',
                error: handleAjaxError
            });

            if (that.data) {
                that.favorite = true;
                that.data.data.place.is_favorite = true;
            }
        }
    };

    this.els.textarea.one('click focus', handleTextareaInit);
    this.els.showAllComments.one('click', showAllComments);
    this.els.addComment.one('click', handleShowCommentForm);

    this.els.favorite.on('click', handleFavorite);

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
        var comment = $(that.commentTemplate({
            id: 0,
            comment: S.utils.sanitizeString(msg),
            creator: S.user,
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

            if (that.data) {
                that.commentsMap.push(resp.id);
                that.data.comments.push(resp);
            }

            that.altered = true;

            $.pub('b_story_comment_sent', that.storyid);
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

        S.notifications.presets['server_failed']();

        $.pub('b_story_comment_error', that.storyid);
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

        $.pub('b_story_comment_sending', that.storyid);
    };

    var handleInput = function(e) {
        if (e.keyCode === 13) {
            S.browser.isAndroid && that.els.textarea.trigger('blur');
            handleFormSubmit(e);
        }
    };

    this.els.blockTextarea.m_textareaAutogrow();

    this.els.form.on('submit', handleFormSubmit);
    this.els.textarea.on('keydown', handleInput);

    return this;
};

})(jQuery);
