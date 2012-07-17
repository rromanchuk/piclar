(function($){
    var form = $('.b-login-form').find('.b-l-f-form'),
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

    form.m_validate();

    inputs.on('keyup', activateInput);
})(jQuery);
