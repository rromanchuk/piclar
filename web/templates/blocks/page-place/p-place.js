// @require 'blocks/block-photogallery/b-photogallery.js'
// @require 'blocks/block-photogallery-small/b-photogallery-small.js'

(function($){
    var page = S.DOM.content,
        map = page.find('.p-p-map'),

        favorite = page.find('.p-p-favorite'),

        pg = new S.blockPhotoGallery().init(),
        pgs = new S.blockPhotoGallerySmall().init();

    var handleThumbClick = function(e, data) {
        if (pg.current !== data) {
            pg.show(data);
        }
    };

    var handleAjaxError = function() {
        S.notifications.show({
            type: 'error',
            text: 'Произошла ошибка при обращении к серверу. Пожалуйста, попробуйте еще раз.'
        });
    };

    var loadMap = function () {
        var gMapOptions = {
                zoom: S.data.place.zoom,
                center: new google.maps.LatLng(S.data.place.position.latitude, S.data.place.position.longitude),
                mapTypeId: google.maps.MapTypeId.ROADMAP
            },
            gMapObj = new google.maps.Map(map[0], gMapOptions),
            gMarkerObj = new google.maps.Marker({
                icon: new google.maps.MarkerImage(S.env.marker_active),
                position: new google.maps.LatLng(S.data.place.position.latitude, S.data.place.position.longitude),
                map: gMapObj
            });
    };

    var handleFavorite = function(e) {
        S.e(e);

        if (favorite.hasClass('active')) {
            favorite.removeClass('active');

            $.ajax({
                url: S.urls.favorite,
                data: { placeid: favorite.data('placeid'),  action: 'DELETE' },
                type: 'POST',
                dataType: 'json',
                error: handleAjaxError
            });
        }
        else {
            favorite.addClass('active');

            $.ajax({
                url: S.urls.favorite,
                data: { placeid: favorite.data('placeid'),  action: 'PUT' },
                type: 'POST',
                dataType: 'json',
                error: handleAjaxError
            });
        }
    };

    $.sub('b_photogallery_logic_item_click', handleThumbClick);
    favorite.on('click', handleFavorite);

    loadMap();
})(jQuery);
