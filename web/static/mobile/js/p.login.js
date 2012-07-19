S.pages['login'] = function() {
    var login = $('#p-login-link-email'),
        reg = $('#p-login-link-registration'),

        overlay = $('#p-login-overlay'),

        forms = overlay.find('form'),
        errorTmpl = MEDIA.templates['mobile/js/templates/m.validate.error.jst'].render,

        currentForm,
        currentBtn,
        currentErrorBlock,

        deferred;

    var handleLoginOverlay = function() {
        overlay.removeClass('registration').addClass('login');

        S.overlay.show();
    };

    var handleRegistrationOverlay = function() {
        overlay.removeClass('login').addClass('registration');

        S.overlay.show();
    };

// ======================================================================================
// Form submition
// ======================================================================================

    var parseFormErrors = function(errors) {
        var k;
        for (k in errors) {
            if (k === '__all__') {
                showError('__none__', errors[k]);
            }
            else {
                showError(k, $.isArray(errors[k]) ? errors[k].join('<br>') : errors[k]);
            }
        }
    };

    var handleFormSuccess = function(resp) {
        S.loading.stop();
        if (resp.status === 'ok') {
            window.location.href = S.urls.index;
            return;
        }
        
        if (resp.status === 'error') {
            parseFormErrors(resp.value);
        }
        currentBtn.removeAttr('disabled');
    };
    
    var handleFormError = function(resp) {
        if (deferred.readyState === 0) { // Cancelled request, still loading
            return;
        }
        
        S.loading.stop();
        currentBtn.removeAttr('disabled');

        showError('__none__', 'Произошел сбой соединения. Пожалуйста, попробуйте еще раз.');
    };
    
    var showError = function(name, msg) {
        currentErrorBlock.append(errorTmpl({
            name: name,
            error: msg
        }));
    };
    
    var removeErrors = function(msg) {
        currentErrorBlock.html('');
    };

    var handleFormValid = function(event, e) {
        e.preventDefault();

        if ((typeof deferred !== 'undefined') && (deferred.readyState !== 4)) {
            deferred.abort();
        }

        currentForm = $(this);
        currentBtn = currentForm.find('button');
        currentErrorBlock = currentForm.find('.m-validate-errors');

        removeErrors();
        
        S.loading.start();
        
        currentBtn.attr('disabled', 'disabled');

        deferred = $.ajax({
            url: currentForm.attr('action'),
            data: currentForm.serialize(),
            dataType: 'json',
            type: currentForm.attr('method').toUpperCase(),
            success: handleFormSuccess,
            error: handleFormError,
            context: currentForm
        });
    };

    login.onpress(handleLoginOverlay);
    reg.onpress(handleRegistrationOverlay);
    forms.on('valid', handleFormValid);

    forms.mod_validate();
};
