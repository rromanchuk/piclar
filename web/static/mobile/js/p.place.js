S.pages['place'] = function() {
    var page = S.DOM.content,
        images = page.find('.p-p-img'),
        feed = page.find('.p-p-imgfeed'),
        slider = feed.find('.p-p-i-list'),
        items = slider.find('.p-p-i-item'),
        prevTouches = {};

    var _handleBeforeScrollStart = function(e) {// this = iScroll
        if (e.touches && e.touches.length) {
            prevTouches.pageX = e.touches[0].pageX;
            prevTouches.pageY = e.touches[0].pageY;
        }
    };
        
    var _handleBeforeScrollMove = function(e) {// this = iScroll
        var dX, dY;

        if (e.touches && e.touches.length) {
            dX = Math.abs(e.touches[0].pageX - prevTouches.pageX);
            dY = Math.abs(e.touches[0].pageY - prevTouches.pageY);

            if ((dX > dY) && // Scrolling sidewise but mostly horizontally
                (e.touches.length === 1)) { // Not multitouch
                e.stopPropagation();
                e.preventDefault();
            }
        }
    };

    var firstItem = items.eq(0),
        size = firstItem.width() + parseInt(firstItem.css('margin-left'), 10) + parseInt(firstItem.css('margin-right'), 10);

    slider.css({
        width: size * items.length
    });

    var scroll = new iScroll(feed[0], {
        snap: '.p-p-i-item',
        momentum: true,
        lockDirection: true,
        hScroll: true,
        vScroll: false,
        hScrollbar: false,
        vScrollbar: false,
        onBeforeScrollStart: _handleBeforeScrollStart,
        onBeforeScrollMove: _handleBeforeScrollMove
    });

    var handlePress = function() {
        var el = $(this),
            id = el.data('imageid');

        images.filter('.active').removeClass('active');
        images.filter('[data-imageid="' + id + '"]').addClass('active');
    };

    items.onpress(handlePress);
};
