(function($){
    var block = $('.b-login-form'),
        registration = block.find('.b-l-f-link-registration');

    var handleRegister = function(e) {
        S.e(e);
        S.overlay.hide();
        S.overlay.show({block: '.b-registration-greeting'});
    };

    var checkAllFilled = function(fields) {
        return  _.all(fields, function(f) { return f.value.length > 0; });
    };

    block.each(function(i, elem) {
        var form = $(elem).find('.b-l-f-form'),
            button = form.find('button'),
            inputs = form.find('input[type=email], input[type=password]'),

            inactive = inputs.length;

        var activateInput = function() {
            if (checkAllFilled(inputs)) {
                button.removeAttr('disabled');
            } else {
                button.attr('disabled', 'disabled');
            }
        };

        form.m_validate();

        inputs.on('keyup', activateInput);
        activateInput();
    });
    
    registration.on('click', handleRegister);
})(jQuery);
