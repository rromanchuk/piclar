(function($){
    var login = $('.b-registration-greeting').find('.b-r-g-link-login');

    var handleLogin = function(e) {
        S.e(e);
        S.overlay.hide();
        S.overlay.show({block: '.b-login-form'});
    };

    login.on('click', handleLogin);
})(jQuery);
