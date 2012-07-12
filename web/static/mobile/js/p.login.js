S.pages['login'] = function() {
    var login = $('#p-login-link-email'),
        reg = $('#p-login-link-registration'),

        overlay = $('#p-login-overlay');

    var handleLoginOverlay = function() {
        overlay.removeClass('registration').addClass('login');

        S.overlay.show();
    };

    var handleRegistrationOverlay = function() {
        overlay.removeClass('login').addClass('registration');

        S.overlay.show();
    };

    login.onpress(handleLoginOverlay);
    reg.onpress(handleRegistrationOverlay);

    handleLoginOverlay();
};
