(function($){
S.blockComments = function(settings) {
    this.options = $.extend({
        storyid: null
    }, settings);
    this.els = {};
};

S.blockComments.prototype.init = function() {
    this.els.blocks = $('.b-comments');

    this.els.comments = this.els.blocks.find('.b-c-list');
    this.els.form = this.els.blocks.find('.b-c-addnew');
    this.els.textareaWrap = this.els.form.find('.m-textarea-autogrow');
    this.els.textarea = this.els.textareaWrap.find('.m-t-a-textarea');

    this.storyid = this.options.storyid || this.els.blocks.data('storyid');

    this.storyid || S.log('[S.blockComments.init]: Please provide storyid to work with!');

    this.template = MEDIA.templates['mobile/js/templates/b.comment.jst'].render;

    this.logic();
    
    $.pub('b_comments_init');

    return this;
};

S.blockComments.prototype.logic = function() {
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
            message = comment.find('.b-c-message').text();

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

        handleAjaxError();
    };

    var handleAjaxError = function() {
        S.notifications.show({
            type: 'error',
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

    var handleCommentShowOpt = function() {
        var commentid = this.getAttribute('data-commentid');

        that.els.comments.children('.show_options').removeClass('show_options');

        this.className += ' show_options';
    };
    var handleCommentHideOpt = function() {
        $(this).removeClass('show_options');
    };
    var handleRemoveComment = function(e) {
        S.e(e);

        var el = $(this),
            comment = el.parents('.b-c-l-item');

        var handleRemoveCommentSuccess = function() {
            comment.remove();
        };

        $.ajax({
            url: S.urls.comments,
            data: { commentid: comment.data('commentid'), storyid: that.storyid,  action: 'DELETE' },
            type: 'POST',
            dataType: 'json',
            success: handleRemoveCommentSuccess,
            error: handleAjaxError
        });
    };

    this.els.textareaWrap.m_textareaAutogrow();
    this.els.form.on('submit', handleFormSubmit);
    this.els.textarea.on('keydown', handleInput);
    this.els.comments.on('swipeRight', '.deletable', handleCommentShowOpt);
    this.els.comments.on('swipeLeft', '.show_options', handleCommentHideOpt);
    this.els.comments.on('click', '.b-c-delete', handleRemoveComment);
};

})(Zepto);
