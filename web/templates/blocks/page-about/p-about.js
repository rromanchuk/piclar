(function($){
    var page = S.DOM.content,

        howto = page.find('.p-a-usage'),

        imagesList = howto.find('.p-a-u-imageslist'),
        images = imagesList.find('.p-a-u-i-item'),
        steps = howto.find('.p-a-u-s-item'),

        imageH = images.eq(0).height(),

        animDuration = 200,
        animated = false;

    var handleChangeStep = function(e) {
        var el = $(this);

        if (el.hasClass('active') || animated) return;

        var handleAnimEnd = function() {
            animated = false;
        };

        animated = true;

        imagesList.animate({
            top: -(el.data('step') - 1) * imageH
        }, animDuration, 'linear', handleAnimEnd);

        steps.filter('.active').removeClass('active');
        el.addClass('active');
    };

    steps.on('click', handleChangeStep);
})(jQuery);
