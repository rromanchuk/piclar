(function($){
    var page = S.DOM.content,

        howto = page.find('.p-a-usage'),

        images = howto.find('.p-a-u-i-item'),
        steps = howto.find('.p-a-u-s-item'),

        animDuration = 200,
        animated = false;

    var handleChangeStep = function(e) {
        var el = $(this);

        if (el.hasClass('active') || animated) return;

        var currentImage = images.filter('.active'),
            nextImage = images.filter('[data-step="' + el.data('step') + '"]');

        var handleFadeOut = function() {
            currentImage.removeClass('active').css({
                display: 'block'
            });

            nextImage.css({
                display: 'none'
            }).addClass('active').fadeIn(animDuration, handleFadeIn);
        };

        var handleFadeIn = function() {
            animated = false;
        };

        animated = true;
        currentImage.fadeOut(animDuration, handleFadeOut);

        steps.filter('.active').removeClass('active');
        el.addClass('active');
    };

    steps.on('click', handleChangeStep);
})(jQuery);
