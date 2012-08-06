(function($){
    var block = $('.b-feedback-form'),
        form = block.find('.b-f-f-form'),
        textareaWrap = form.find('.m-textarea-autogrow'),
        button = form.find('.button');

    var handleError = function() {
        S.notifications.show({
            type: 'error',
            text: 'Произошла ошибка при обращении к серверу. Пожалуйста, попробуйте еще раз.'
        });
        $.pub('b_feedback_error');
    };

    var handleSuccess = function() {
        S.notifications.show({
            type: 'info',
            text: 'Ваше сообщение отправлено.'
        });
        $.pub('b_feedback_success');
    };

    var handleSubmit = function(event, e) {
        S.e(e);

        $.ajax({
            url: S.urls.feedback,
            data: form.serialize(),
            type: 'POST',
            dataType: 'json',
            success: handleSuccess,
            error: handleError
        });
    };

    form.m_validate({ isDisabled: true });
    textareaWrap.m_textareaAutogrow();

    form.on('valid', handleSubmit);
})(jQuery);
