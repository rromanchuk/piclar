// @require 'blocks/block-favorites/b-favorites.js'

(function($) {
    var page = S.DOM.content,

        feed = new S.blockFavorites({
            data: S.data.favorites
        });

    feed.init();
})(jQuery);
