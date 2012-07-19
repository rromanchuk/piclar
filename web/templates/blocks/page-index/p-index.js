// @require 'blocks/block-popular-posts/b-popular-posts.js'

(function($){
    var login = S.DOM.content.find('.p-i-link-login'),
        register = S.DOM.content.find('.p-i-link-register');

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

    new S.blockPopularPosts().init();
})(jQuery);
