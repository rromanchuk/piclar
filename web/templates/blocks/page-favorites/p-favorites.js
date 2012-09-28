// @require 'blocks/block-favorites/b-favorites.js'
// @require 'blocks/block-favorites-map/b-favorites-map.js'

(function($) {
    var page = S.DOM.content,

        feedList = page.find('.b-f-list'),

        feed = new S.blockFavorites({
            data: S.data.favorites
        }),
        map = new S.blockFavoritesMap({
            feed: feed
        });

    map.init(); // init map first so it can subscribe to feed events
    feed.init();
    

    var updateCurrentPlace = function(e) {
        var el = $(this),
            id = el.data('placeid');

        feed.setActive(id);
    };

    feedList.on('mouseenter', '.b-f-place', updateCurrentPlace);

    window.map = map;
})(jQuery);
