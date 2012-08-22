/* Author:
    Max Degterev @suprMax
*/

;(function($) {
    // Zepto touch device detection
    $.os.touch = !(typeof window.ontouchstart === 'undefined');

    var swipeFactor = 2.3,
        safetyFactor = 2.3;
    
    var $doc = $(document),
        touches = [],
        
        swipeLength = [],
        safetyLength = [],

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
            
            // horizontal
            if (Math.abs(xDiff) > swipeLength[0] && Math.abs(yDiff) < safetyLength[1]) {
                if (xDiff > 0) {
                    tg.trigger('swipe', e);
                    tg.trigger('swipeRight', e);
                }
                else {
                    tg.trigger('swipe', e);
                    tg.trigger('swipeLeft', e);
                }
            }
            
            // vertical
            if (Math.abs(yDiff) > swipeLength[1] && Math.abs(xDiff) < safetyLength[0]) {
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

        swipeLength.push((window.innerWidth / swipeFactor) | 0);
        swipeLength.push((window.innerHeight / swipeFactor) | 0);
        safetyLength.push((window.innerWidth / (safetyFactor * 10)) | 0);
        safetyLength.push((window.innerHeight / (safetyFactor * 10)) | 0);

        $doc.on('touchstart', handleTouchStart);
        $doc.on('touchmove', handleTouchMove);
        $doc.on('touchend', handleTouchEnd);
    }
})(window.Zepto || window.jQuery);
