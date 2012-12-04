// @require 'blocks/layout-overlay/l-overlay.js'
(function($){
    var block = $('.b-login-form'),
        registration = block.find('.b-l-f-link-registration');

    var handleRegister = function(e) {
        S.e(e);
        S.overlay.hide();
        S.overlay.show({block: '.b-registration-greeting'});
    };

    block.each(function(i, elem) {
        var form = $(elem).find('.b-l-f-form');

        form.m_validate({ isDisabled: true });
    });
    
    registration.on('click', handleRegister);
    S.overlay.subscribe('.b-registration-greeting', { block: '.b-registration-greeting' });
})(jQuery);
