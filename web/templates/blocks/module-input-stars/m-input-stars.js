;(function($) {
    var initStars = function(i, elem) {
        var el = $(elem),
            
            items = el.find('.m-i-s-item'),
            input = el.find('.m-i-s-input'),

            current = parseInt(input.val(), 10);

        var handleMouseEnter = function() {
            $(this).prevAll().addBack().addClass('hover');
        };

        var handleMouseLeave = function() {
            items.filter('.hover').removeClass('hover');
        };

        var handleClick = function(e) {
            var item = $(this),
                i = item.index();

            if (e && (+input.val() === (i + 1))) {
                // input.val(0).trigger('change');
                return;
            }
            else {
                items.removeClass('active');
                input.val(i + 1);
                item.prevAll().addBack().addClass('active');
            }

            input.trigger('change');
            item.trigger('modchange');
        };

        current && handleClick.call(items.eq(current - 1)[0]);

        items.on('mouseenter', handleMouseEnter);
        items.on('mouseleave', handleMouseLeave);
        items.on('click', handleClick);
    };

    $.fn.m_inputStars = function(settings) {
        // var options = $.extend({}, settings);
        this.each(initStars);
    };
})(jQuery);
