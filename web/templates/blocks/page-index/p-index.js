(function($){
    var login = S.DOM.content.find('.p-i-h-i-links-login');

    var handleLogin = function(e) {
        S.e(e);
        S.overlay.show({block: '.b-login-form'});
    };

    login.on('click', handleLogin);
})(jQuery);
