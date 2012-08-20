S.pages['login'] = function() {
    var login = $('#p-l-link-login'),
        overlay = $('#p-login-overlay'),
        form = overlay.find('.p-l-o-form');

    var handleLoginOverlay = function() {
        S.overlay.show();
    };

    login.onpress(handleLoginOverlay);
    form.mod_validate();
};
