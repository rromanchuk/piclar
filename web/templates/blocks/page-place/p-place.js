// @require 'blocks/block-photogallery/b-photogallery.js'
// @require 'blocks/block-photogallery-small/b-photogallery-small.js'

(function($){
    var page = S.DOM.content,
        map = page.find('.p-p-map'),

        pg = new S.blockPhotoGallery().init(),
        pgs = new S.blockPhotoGallerySmall().init();

    var handleThumbClick = function(e, data) {
        pg.show(data);
    };

    function loadMap() {
        var gMapOptions = {
                zoom: S.data.place.zoom,
                center: new google.maps.LatLng(S.data.place.position.latitude, S.data.place.position.longitude),
                mapTypeId: google.maps.MapTypeId.ROADMAP
            },
            gMapObj = new google.maps.Map(map[0], gMapOptions),
            gMarkerObj = new google.maps.Marker({
                //icon: 'beachflag.png',
                position: new google.maps.LatLng(S.data.place.position.latitude, S.data.place.position.longitude),
                map: gMapObj
            });
    }

    loadMap();
    $.sub('b_photogallery_logic_item_click', handleThumbClick);
})(jQuery);
