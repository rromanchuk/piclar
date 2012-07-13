S.pages['login_oauth'] = function() {
    var data = window.location.hash.charAt(0) == '#' ? window.location.hash.substr(1) : window.location.hash;
    $.ajax({
        url: S.urls.oauth,
        type: 'POST',
        data: data,
        complete: function() {
            window.location.href = S.urls.index;
        }
    });
};
