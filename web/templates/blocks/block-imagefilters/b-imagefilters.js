// @require 'js/caman/caman.full.js'

(function($){
S.blockImageFilters = function(settings) {
    this.options = $.extend({
    }, settings);

    this.els = {};
};

S.blockImageFilters.prototype.init = function() {
    this.els.block = $('.b-imagefilters');
    this.els.canvas = this.els.block.find('.b-i-canvas');

    this.canvas = this.els.canvas[0];
    this.ctx = this.canvas.getContext('2d');

    this.els.filters = this.els.block.find('.b-i-filterlist');

    this.active = false;

    this.logic();

    $.pub('b_imagefilters_init');

    return this;
};

S.blockImageFilters.prototype.setImage = function(settings) {
    if (!settings.image) {
        S.log('[S.blockImageFilters.setImage]: provide an image to work with!');
        return;
    }

    var opt = $.extend({
        cx: 0,
        cy: 0
    }, settings);

    this.ctx.drawImage(opt.image, opt.cx, opt.cx, 640, 640, 0, 0, 640, 640);

    this.active && (delete this.caman);

    this.caman = Caman(this.canvas, function() {});
    var that = this;
    $(window).on('load', function() {
        setTimeout(function(){
            that.caman.sepia(140).render();
        }, 3000);
    });
    

    this.active = true;
};

S.blockImageFilters.prototype.logic = function() {
    var that = this;

    var handleFilterClick = function() {
        if (!that.active) return;
    };

    this.els.filters.on('click', '.b-i-filter', handleFilterClick);

    return this;
};

})(jQuery);

