// @require 'blocks/layout-overlay/l-overlay.js'

(function($){
S.blockImageCrop = function(settings) {
    this.options = $.extend({
    }, settings);

    this.els = {};
};

S.blockImageCrop.prototype.init = function() {
    this.els.block = $('.b-imagecrop');
    this.els.image = this.els.block.find('img');

    this.image = this.els.image[0];

    this.logic();

    $.pub('b_imagecrop_init');

    return this;
};

S.blockImageCrop.prototype.logic = function() {
    var that = this;

    var handleImgLoad = function() {
        $.pub('b_imagecrop_ready');
    };

    this.els.image.on('load', handleImgLoad);

    return this;
};

})(jQuery);

