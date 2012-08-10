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

            S.loading.success();
            S.loading.stop();
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

        S.loading.error();
        S.loading.stop();
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

        S.loading.start();

        deferred = $.ajax({
            url: S.urls.comments,
            data: { message: message, storyid: storyid,  action: 'POST' },
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

    textareaWrap.m_textareaAutogrow();
    form.on('submit', handleFormSubmit);
    textarea.on('keydown', handleInput);
};
