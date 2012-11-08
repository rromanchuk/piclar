/* Author:
    Max Degterev @suprMax
*/

;(function($) {
    var prevTouches = {};

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

    var PhotoRow = function(el) {
        // this.options = $.extend({
        // }, settings);

        this.feed = $(el);

        this.feedSlider = this.feed.find('.m-p-list');
        this.feedItems = this.feedSlider.find('.m-p-item');

        this.init();
        // this.logic();
    };

    PhotoRow.prototype.init = function() {
        var firstFeedItem = this.feedItems.eq(0),
            feedItemSize = firstFeedItem.width() +
                           parseInt(firstFeedItem.css('margin-left'), 10) +
                           parseInt(firstFeedItem.css('margin-right'), 10);

        this.feedSlider.css({
            width: feedItemSize * this.feedItems.length
        });

        this.scroll = new iScroll(this.feed[0], {
            // snap: '.m-p-item',
            momentum: true,
            lockDirection: true,
            hScroll: true,
            vScroll: false,
            hScrollbar: false,
            vScrollbar: false,
            onBeforeScrollStart: _handleBeforeScrollStart,
            onBeforeScrollMove: _handleBeforeScrollMove
        });
    };

    // FValidate.prototype.logic = function() {
    //     var that = this;
    // };


    $.fn.mod_photoRow = function(settings) {
        // var options = $.extend({
        // }, settings);
        
        this.forEach(function(elem, index) {
            var id = elem.getAttribute('data-moduleid');

            if (!id) {
                id = 'photorow_' + (Math.random() * 99999 | 0);

                elem.setAttribute('data-moduleid', id);
                S.modules[id] = new PhotoRow(elem);

                $.pub('photorow_ready', id);
            }

            return S.modules[id];
        });
    };
})(Zepto);
