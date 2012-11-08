// @require 'blocks/block-notifications/b-notifications.js'
// @require 'blocks/layout-overlay/l-overlay.js'

(function($){
    var login = S.DOM.header.find('.l-header-login'),
        register = S.DOM.header.find('.l-header-register');

    var handleLogin = function(e) {
        S.e(e);
        S.overlay.show({block: '.b-login-form'});
    };
    var handleRegister = function(e) {
        S.e(e);
        S.overlay.show({block: '.b-registration-greeting'});
    };

    login.on('click', handleLogin);
    register.on('click', handleRegister);
    S.overlay.subscribe('.b-login-form', { block: '.b-login-form' });
    S.overlay.subscribe('.b-registration-greeting', { block: '.b-registration-greeting' });

    new S.blockNotifications().init();
})(jQuery);
