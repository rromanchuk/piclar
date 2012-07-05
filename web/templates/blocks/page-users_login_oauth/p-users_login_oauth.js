(function($){
    if (window.location.hash.length > 0) {
        var data = window.location.hash.charAt(0) == '#' ? window.location.hash.substr(1) : window.location.hash;
        $.ajax({
            url: S.env.url.oauth,
            type: 'POST',
            data: data,
            complete: function() {
                if (window.opener) { // this is a popup
                    //window.close();
                }
                else { // this is not a popup
                    //window.location.href = S.env.url.index;
                }
            }
        });
    }
})(jQuery);
