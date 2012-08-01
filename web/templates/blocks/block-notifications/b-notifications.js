(function($){
// Singleton this time
    var block = $('.b-notifications'),
        sign = block.find('.b-n-sign'),
        active = false;

    var show = function() {
        block.addClass('active');
        active = true;
    };

    var hide = function() {
        block.removeClass('active');
        active = false;
    };

    var handleToggleBlock = function(e) {
        S.e(e);

        if (active) {
            hide();
        }
        else {
            show();
        }
    };

    var handleMisClick = function(e) {
        if (active) {
            !$(e.target).parents('.b-n-list').length && hide();
        }
    };

    sign.on('click', handleToggleBlock);
    S.DOM.doc.on('click', handleMisClick);
})(jQuery);
