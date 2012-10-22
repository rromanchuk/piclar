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

        form.mod_validate({ isDisabled: true });
    });
    
    registration.on('click', handleRegister);
})(jQuery);
