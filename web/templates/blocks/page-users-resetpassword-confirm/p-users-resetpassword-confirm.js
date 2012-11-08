(function($){
    var form = S.DOM.content.find('.p-u-r-c-form'),

        pw1 = form.find('.p-u-r-c-password1'),
        pw2 = form.find('.p-u-r-c-password2');

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
