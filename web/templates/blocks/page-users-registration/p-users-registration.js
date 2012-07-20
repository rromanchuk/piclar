(function($){
    var form = S.DOM.content.find('.p-u-r-form'),

        pw1 = form.find('.p-u-r-password'),
        pw2 = form.find('.p-u-r-password2');

    var checkPasswords = function() {
        return pw1.val() === pw2.val();
    };

    form.m_validate({
        isDisabled: true,
        validations: {
            password2: checkPasswords
        }
    });

})(jQuery);
