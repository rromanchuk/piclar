(function($){
    var page = S.DOM.content,

        howto = page.find('.p-a-usage'),

        images = howto.find('.p-a-u-i-item'),
        steps = howto.find('.p-a-u-s-item');

    var handleChangeStep = function(e) {
        var el = $(this);

        if (el.hasClass('active')) return;

        images.filter('.active').removeClass('active');
        steps.filter('.active').removeClass('active');

        images.filter('[data-step="' + el.data('step') + '"]').addClass('active');
        el.addClass('active');
    };

    steps.on('click', handleChangeStep);
})(jQuery);
