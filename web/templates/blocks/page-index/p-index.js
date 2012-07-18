(function($){
    var login = S.DOM.content.find('.p-i-link-login'),
        register = S.DOM.content.find('.p-i-link-register');

        //bPopularPosts = new S.blockPopularPosts();

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

    //bPopularPosts.init();
})(jQuery);
