S.pages['fill_email'] = function() {
    var page = S.DOM.content,

        form = page.find('.p-f-e-form'),

        pw1 = form.find('.p-f-e-password'),
        pw2 = form.find('.p-f-e-password2');

    var checkPasswords = function() {
        return pw1.val() === pw2.val();
    };

    form.mod_validate({
        validations: {
            password2: checkPasswords
        }
    });
};
