(function($){
    var page = $('#p-users-login-oauth'),
        result = S.utils.parseURL(window.location.hash),

        isPopup = !!window.opener,

        intercept = page.find('.p-u-l-o-intercept');

    if (window.location.hash.length > 0 && !result.params.error) {
        var data = window.location.hash.charAt(0) == '#' ? window.location.hash.substr(1) : window.location.hash;

        data += '&platform=vkontakte';

        $.ajax({
            url: S.urls.oauth,
            type: 'POST',
            data: data,
            success: function() {
                if (isPopup) {
                    //window.opener.location.reload();
                    window.opener.location.href = S.urls.index;
                    window.close();
                }
                else { // this is not a popup
                    window.location.href = S.urls.index;
                }
                page.addClass('success');
            },
            error: function() {
                page.addClass('failed');
            }
        });
    }
    else {
        page.addClass('failed');
    }

    var handlePopupLinks = function(e) {
        S.e(e);
        window.opener.location.href = this.getAttribute('href');
        window.close();
    };

    isPopup && intercept.on('click', handlePopupLinks);
})(jQuery);
