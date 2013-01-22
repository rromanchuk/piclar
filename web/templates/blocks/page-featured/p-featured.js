// @require 'blocks/block-pinterest/b-pinterest.js'

(function($){
    var pinterest = new S.blockPinterest({
            collection: S.data.feed
        });

    pinterest.init();
})(jQuery);
