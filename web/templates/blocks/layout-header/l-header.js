(function($){
    var login = S.DOM.header.find('.l-header-login'),
        register = S.DOM.header.find('.l-header-register');

    var handleLogin = function(e) {
        S.e(e);
        S.overlay.show({block: '.b-login-form'});
    };
    var handleRegister = function(e) {
        S.e(e);
        S.overlay.show({block: '.b-registration'});
    };

    login.on('click', handleLogin);
    register.on('click', handleRegister);

    // $(document).ready(handleLogin);
})(jQuery);
