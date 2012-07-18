(function($){
    var form = S.DOM.content.find('.p-r-form'),
        button = form.find('button'),

        inputs = form.find('input[type=text],input[type=password]'),

        pw1 = inputs.filter('.p-r-f-password'),
        pw2 = inputs.filter('.p-r-f-password2');

    var checkAllFilled = function(fields) {
        return  _.all(fields, function(f) { return f.value.length > 0; })
    };

    var activateInput = function() {
        if (checkAllFilled(inputs)) {
            button.removeAttr('disabled');
        } else {
            button.attr('disabled', 'disabled');
        }
    };


    var checkPasswords = function() {
        return pw1.val() === pw2.val();
    };

    form.m_validate({
        validations: {
            password2: checkPasswords
        }
    });

    activateInput()
    inputs.on('keyup', activateInput);
})(jQuery);
