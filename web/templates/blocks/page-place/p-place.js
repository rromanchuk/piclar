// @require 'blocks/block-photogallery/b-photogallery.js'
// @require 'blocks/block-photogallery-small/b-photogallery-small.js'

(function($){
    var pg = new S.blockPhotoGallery().init(),
        pgs = new S.blockPhotoGallerySmall().init();

    var handleThumbClick = function(e, data) {
        pg.show(data);
    };

    function loadMap() {
        var mapOptions = {
            zoom: 8,
            center: new google.maps.LatLng(-34.397, 150.644),
            mapTypeId: google.maps.MapTypeId.ROADMAP
        };
        var map = new google.maps.Map($('.p-p-map')[0], mapOptions);
    }

    loadMap();
    $.sub('b_photogallery_logic_item_click', handleThumbClick);
})(jQuery);
