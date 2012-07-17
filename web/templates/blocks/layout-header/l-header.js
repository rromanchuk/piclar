(function($){
    var login = S.DOM.header.find('.l-header-login'),
        register = S.DOM.header.find('.l-header-register');

    var handleLogin = function() {
        S.overlay.show({block: '.b-login'});
    };
    var handleRegister = function() {
        S.overlay.show({block: '.b-registration'});
    };

    login.on('click', handleLogin);
    register.on('click', handleRegister);
})(jQuery);
