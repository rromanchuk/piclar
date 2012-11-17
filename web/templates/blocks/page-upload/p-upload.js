// @require 'blocks/block-imagecrop/b-imagecrop.js'
// @require 'blocks/block-imagefilters/b-imagefilters.js'

(function($) {
    var crop = new S.blockImageCrop(),
        filters = new S.blockImageFilters();

    crop.init();
    filters.init();

    var activateFilters = function() {
        filters.setImage({
            image: crop.image
        });
    };

    $.sub('b_imagecrop_ready', activateFilters);


    window.f = filters;
})(jQuery);
