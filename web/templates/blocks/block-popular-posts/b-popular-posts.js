(function($){
    var animationDuration = 300,
        animationTimeout = 5000;

    var row = $('.b-p-p-row'),
        slider = row.find('.b-p-p-storyline'),
        items = slider.find('.b-story'),

        itemW = items.eq(0).outerWidth(),
        itemOff = parseInt(items.eq(0).css('margin-left'), 10),

        itemsNum = items.length,

        rowW = row.outerWidth(),

        sliderW = itemsNum * (itemW + itemOff),

        currentPos = 0,
        currentI = 0;

    var handleWindowResize = function() {
        rowW = row.outerWidth();
    };

    var slideTo = function(pos) {
        slider.animate({ left: -pos }, animationDuration);
    };

    var sliderLoop = function() {
        var nextPos = currentPos + itemW + itemOff,
            nextI = currentI + 1;

        if (nextPos >= sliderW - rowW) {
            nextPos = 0;
            nextI = 0;
        }

        slideTo(nextPos);

        currentPos = nextPos;
        currentI = nextI;

        setTimeout(sliderLoop, animationTimeout);
    };

    slider.css({ width: sliderW });

    S.DOM.win.on('resize', handleWindowResize);
    S.DOM.win.on('load', sliderLoop);

})(jQuery);
