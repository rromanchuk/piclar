(function($){
    var lists = $('.b-friendrequests-list'),
        controls = lists.find('.b-fr-l-reqcontrols');

    var handleRequest = function(e) {
        e && S.e(e);

        var el = $(this),
            item = el.parents('.b-fr-l-request');

        $.ajax({
            url: S.urls.friends,
            data: { userid: item.data('userid') },
            type: el.hasClass('b-fr-l-add') ? 'PUT' : 'DELETE',
            dataType: 'json'
        });

        item.fadeOut(300, function() {
            item.remove();
        });
    };

    controls.on('click', '.b-fr-l-add', handleRequest);
    controls.on('click', '.b-fr-l-remove', handleRequest);
})(jQuery);
