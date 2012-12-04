(function($){
    var block = $('.b-feedback-form'),
        form = block.find('.b-f-f-form'),
        textareaWrap = form.find('.m-textarea-autogrow'),
        textarea = textareaWrap.find('textarea'),
        button = form.find('.button');

    var handleSuccess = function() {
        S.notifications.show({
            type: 'info',
            text: 'Ваше сообщение отправлено.'
        });

        textarea.val('');

        $.pub('b_feedback_success');
    };

    var handleSubmit = function(event, e) {
        S.e(e);
        data = form.serializeArray();
        data.push({name : 'page_url', value: document.location.href });
        $.ajax({
            url: S.urls.feedback,
            data: data,
            type: 'POST',
            dataType: 'json',
            success: handleSuccess,
            error: S.notifications.presets['server_failed']
        });
    };

    form.m_validate({ isDisabled: true });
    textareaWrap.m_textareaAutogrow();

    form.on('valid', handleSubmit);
})(jQuery);
