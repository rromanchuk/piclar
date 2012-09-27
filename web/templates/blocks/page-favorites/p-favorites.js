// @require 'blocks/block-favorites/b-favorites.js'
// @require 'blocks/block-favorites-map/b-favorites-map.js'

(function($) {
    var page = S.DOM.content,

        feed = new S.blockFavorites({
            data: S.data.favorites
        }),
        map = new S.blockFavoritesMap();

    feed.init();
    map.init();

    $('.b-f-place').eq(0).addClass('active');
})(jQuery);
