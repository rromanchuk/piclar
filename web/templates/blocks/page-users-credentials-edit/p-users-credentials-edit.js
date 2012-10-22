(function($){
    var form = S.DOM.content.find('.p-u-c-e-form'),
        button = form.find('button'),

        pw1 = form.find('.p-u-c-e-password'),
        pw2 = form.find('.p-u-c-e-password2');

    var checkPasswords = function() {
        return pw1.val() === pw2.val();
    };

    form.mod_validate({
        validations: {
            new_password2: checkPasswords
        },
        isDisabled: true
    });
})(jQuery);
