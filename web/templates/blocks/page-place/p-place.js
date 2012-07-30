// @require 'blocks/block-photogallery/b-photogallery.js'
// @require 'blocks/block-photogallery-small/b-photogallery-small.js'

(function($){
    var pg = new S.blockPhotoGallery().init(),
        pgs = new S.blockPhotoGallerySmall().init();

    var handleThumbClick = function(e, data) {
        pg.show(data);
    };

    $.sub('b_photogallery_logic_item_click', handleThumbClick);
})(jQuery);
