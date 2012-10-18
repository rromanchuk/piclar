S.pages['place'] = function() {
    var page = S.DOM.content,

        feed = page.find('.p-p-imgfeed'),
        feedSlider = feed.find('.p-p-i-list'),
        feedItems = feedSlider.find('.p-p-i-item'),

        prevTouches = {};

    if (feed.length) {
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

        var firstFeedItem = feedItems.eq(0),
            feedItemSize = firstFeedItem.width() +
                           parseInt(firstFeedItem.css('margin-left'), 10) +
                           parseInt(firstFeedItem.css('margin-right'), 10);

        feedSlider.css({
            width: feedItemSize * feedItems.length
        });
        
        var scroll = new iScroll(feed[0], {
            // snap: '.p-p-i-item',
            momentum: true,
            lockDirection: true,
            hScroll: true,
            vScroll: false,
            hScrollbar: false,
            vScrollbar: false,
            onBeforeScrollStart: _handleBeforeScrollStart,
            onBeforeScrollMove: _handleBeforeScrollMove
        });
    }
};
