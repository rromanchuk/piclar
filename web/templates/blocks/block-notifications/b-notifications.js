(function($){
// Singleton this time
    var block = $('.b-notifications'),
        sign = block.find('.b-n-sign');

    var handleToggleBlock = function(e) {
        S.e(e);

        block.toggleClass('active');
    };

    sign.on('click', handleToggleBlock);
})(jQuery);
