(function($){
    var block = $('.b-login-form'),
        registration = block.find('.b-l-f-link-registration'),

        form = block.find('.b-l-f-form'),
        button = form.find('button');
        inputs = form.find('input'),

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

    var handleRegister = function(e) {
        S.e(e);
        S.overlay.hide();
        S.overlay.show({block: '.b-registration-greeting'});
    };

    form.m_validate();

    inputs.on('keyup', activateInput);
    registration.on('click', handleRegister);
})(jQuery);
