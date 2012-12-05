// @require 'blocks/block-favorites/b-favorites.js'
// @require 'blocks/block-favorites-map/b-favorites-map.js'

(function($) {
    var page = S.DOM.content,

        feedList = page.find('.b-f-list'),

        citiesBlock = page.find('.p-f-cities'),
        mapsBlock = page.find('.b-favorites-map'),

        citiesItems = citiesBlock.find('.p-f-c-city'),

        citiesPos = citiesBlock.offset().top,
        mapsPos = mapsBlock.offset().top - 40,

        citiesFixed = false,
        mapsFixed = false,

        feed = new S.blockFavorites({
            autoRender: false,
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

    var handleMarkerClick = function(e, id) {
        var item = feedList.find('.b-f-place[data-placeid="' + id + '"]'),
            pos = item.offset().top;

        // item[0].scrollIntoView();
        S.utils.scroll(pos - 40);
        feed.setActive(id);
    };

    var handleFilter = function(e) {
        var item = $(this);

        citiesItems.filter('.active').removeClass('active');

        feed.filterByCityId(+item.data('cityid'));
        item.addClass('active');
    };

    feed.init();
    map.init();

    feedList.on('mouseenter', '.b-f-place', updateCurrentPlace);
    citiesBlock.on('click', '.p-f-c-city', handleFilter);
    S.DOM.win.on('scroll', handleWindowScroll);
    $.sub('b_favorites_map_marker_click', handleMarkerClick);

    citiesItems.eq(0).trigger('click');
})(jQuery);
