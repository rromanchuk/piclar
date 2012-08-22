/* Author:
    Max Degterev @suprMax
*/

;(function($) {
    // Zepto touch device detection
    $.os.touch = !(typeof window.ontouchstart === 'undefined');
    
    var swipeLength = 150,
        safetyLength = 50;

    var $doc = $(document),
        touches = [],
        target;

    if ($.os.touch) {
        var handleTouchStart = function(e) {
            var coords = e.touches ? e.touches[0] : e; // Android weirdness fix

            touches[0] = coords.pageX;
            touches[1] = coords.pageY;

            target = e.target;
        };
        var handleTouchMove = function(e) {
            touches[2] = e.touches[0].pageX;
            touches[3] = e.touches[0].pageY;
        };
        var handleTouchEnd = function(e) {
            if (e.target !== target) { // another target?
                return;
            }
            
            var tg = $(e.target);

            var xDiff = touches[2] - touches[0],
                yDiff = touches[3] - touches[1];
            
            if (Math.abs(xDiff) > swipeLength && Math.abs(yDiff) < safetyLength) {
                if (xDiff > 0) {
                    tg.trigger('swipe', e);
                    tg.trigger('swipeRight', e);
                }
                else {
                    tg.trigger('swipe', e);
                    tg.trigger('swipeLeft', e);
                }
            }
            
            if (Math.abs(xDiff) < safetyLength && Math.abs(yDiff) > swipeLength) {
                if (yDiff > 0) {
                    tg.trigger('swipe', e);
                    tg.trigger('swipeDown', e);
                }
                else {
                    tg.trigger('swipe', e);
                    tg.trigger('swipeUp', e);
                }
            }
        };

        $doc.on('touchstart', handleTouchStart);
        $doc.on('touchmove', handleTouchMove);
        $doc.on('touchend', handleTouchEnd);
    }
})(window.Zepto || window.jQuery);
