(function($){
    var page = $('#p-users-login-oauth'),
        result = S.utils.parseURL(window.location.hash);

    if (window.location.hash.length > 0 && !result.params.error) {
        var data = window.location.hash.charAt(0) == '#' ? window.location.hash.substr(1) : window.location.hash;
        $.ajax({
            url: S.urls.oauth,
            type: 'POST',
            data: data,
            success: function() {
                if (window.opener) { // this is a popup
                    window.opener.location.reload();
                    window.close();
                }
                else { // this is not a popup
                    window.location.href = S.env.url.index;
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
})(jQuery);
