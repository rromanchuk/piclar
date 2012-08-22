S.pages['comments'] = function() {
    var page = S.DOM.content,

        comments = page.find('.p-c-list'),
        form = page.find('.p-c-addnew'),
        textareaWrap = form.find('.m-textarea-autogrow'),
        textarea = textareaWrap.find('.m-t-a-textarea'),

        storyid = page.data('storyid'),

        template = MEDIA.templates['mobile/js/templates/p.comment.jst'].render,
        deferred,
        message;

    var addComment = function(msg) {
        var comment = $(template({
            id: 0,
            message: $('<div/>').text(msg).html(),
            user: S.user,
            create_date: +(new Date()),
            counter: 0
        }));

        comment.addClass('temporary');

        comments.append(comment);
    };

    var removeComment = function() {
        var comment = comments.children('.temporary'),
            message = comment.find('.p-c-message').text();

        textarea.val(message);
        comment.remove();
    };

    var clearTemporary = function() {
        comments.children('.temporary').remove();
    };

    var handleFormSuccess = function(resp) {
        if (resp.id) {
            // success
            textarea.removeAttr('disabled');
            comments.find('.temporary').attr('data-commentid', resp.id).removeClass('temporary');
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

        textarea.removeAttr('disabled');
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

        if (!textarea.val().length) {// basic validation
            return;
        }

        if ((typeof deferred !== 'undefined') && (deferred.readyState !== 4)) {
            // never supposed to see this
            deferred.abort();
            clearTemporary();
        }

        message = textarea.val();

        deferred = $.ajax({
            url: S.urls.comments,
            data: { message: message, storyid: storyid,  action: 'POST' },
            beforeSend: function(xhr, settings) {
                xhr.setRequestHeader("X-CSRFToken", $.cookie('csrftoken'));
            },
            type: 'POST',
            dataType: 'json',
            timeout: 20000, // 20 sec
            success: handleFormSuccess,
            error: handleFormError
        });

        textarea.val('');
        textarea.attr('disabled', 'disabled');

        addComment(message);
    };

    var handleInput = function(e) {
        if (e.keyCode === 13) {
            handleFormSubmit(e);
        }
    };

    var handleCommentShowOpt = function() {
        var commentid = this.getAttribute('data-commentid');

        comments.children('.show_options').removeClass('show_options');

        this.className += ' show_options';
    };
    var handleCommentHideOpt = function() {
        $(this).removeClass('show_options');
    };
    var handleRemoveComment = function(e) {
        S.e(e);

        var el = $(this),
            comment = el.parents('.p-c-l-item');

        var handleRemoveCommentSuccess = function() {
            comment.remove();
        };

        $.ajax({
            url: S.urls.comments,
            data: { commentid: comment.data('commentid'), storyid: storyid,  action: 'DELETE' },
            beforeSend: function(xhr, settings) {
                xhr.setRequestHeader("X-CSRFToken", $.cookie('csrftoken'));
            },
            type: 'POST',
            dataType: 'json',
            success: handleRemoveCommentSuccess,
            error: handleAjaxError
        });
    };

    textareaWrap.m_textareaAutogrow();
    form.on('submit', handleFormSubmit);
    textarea.on('keydown', handleInput);
    comments.on('swipeRight', '.deletable', handleCommentShowOpt);
    comments.on('swipeLeft', '.show_options', handleCommentHideOpt);
    comments.on('click', '.p-c-delete', handleRemoveComment);
};
