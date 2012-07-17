(function($){
    var form = S.DOM.content.find('.p-r-form'),
        button = form.find('button'),

        inputs = form.find('input'),

        pw1 = inputs.filter('.p-r-f-password'),
        pw2 = inputs.filter('.p-r-f-password2'),

        inactive = inputs.length;

    var activateInput = function() {
        if (this.value.length) {
            if (this.active) {
                return;
            }
            this.active = true;
            inactive--;

            if (inactive <= 0) {
                button.removeAttr('disabled');
            }
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

    inputs.on('keyup', activateInput);
})(jQuery);
