// @require 'blocks/block-favorites/b-favorites.js'
// @require 'blocks/block-favorites-map/b-favorites-map.js'

(function($) {
    var page = S.DOM.content,

        feedList = page.find('.b-f-list'),

        citiesBlock = page.find('.p-f-cities'),
        mapsBlock = page.find('.b-favorites-map'),

        citiesPos = citiesBlock.offset().top,
        mapsPos = mapsBlock.offset().top - 40,

        citiesFixed = false,
        mapsFixed = false,

        feed = new S.blockFavorites({
            data: S.data.favorites
        }),
        map = new S.blockFavoritesMap({
            feed: feed
        });

    var updateCurrentPlace = function(e) {
        var el = $(this),
            id = el.data('placeid');

        feed.setActive(id);
    };

    var handleWindowScroll = _.debounce(function(e) {
        var pos = S.DOM.win.scrollTop();

        if (pos > citiesPos && !citiesFixed) {
            citiesBlock.addClass('fixed');
            citiesFixed = true;
        }
        else if (pos <= citiesPos && citiesFixed) {
            citiesBlock.removeClass('fixed');
            citiesFixed = false;
        }

        if (pos > mapsPos && !mapsFixed) {
            mapsBlock.addClass('fixed');
            mapsFixed = true;
        }
        else if (pos <= mapsPos && mapsFixed) {
            mapsBlock.removeClass('fixed');
            mapsFixed = false;
        }
    }, 1000 / 60); // 60fps

    feed.init();
    map.init();

    feedList.on('mouseenter', '.b-f-place', updateCurrentPlace);
    S.DOM.win.on('scroll', handleWindowScroll);

    window.map = map;
})(jQuery);
