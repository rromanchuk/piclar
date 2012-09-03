(function($){
S.blockPhotoGallerySmall = function(settings) {
    this.options = $.extend({
        animDuration: 200,
        itemsPerStep: 5
    }, settings);

    this.els = {};
};

S.blockPhotoGallerySmall.prototype.init = function() {
    this.els.block = $('.b-photogallery-small');

    if (this.els.block.hasClass('disabled')) return false;

    this.els.list = this.els.block.find('.b-pgs-photolist');
    this.els.items = this.els.block.find('.b-pgs-item');
    this.els.prev = this.els.block.find('.b-pgs-before');
    this.els.next = this.els.block.find('.b-pgs-after');

    this.step = 0;
    this.itemsNum = this.els.items.length;
    this.maxStep = Math.ceil(this.itemsNum / this.options.itemsPerStep);

    if (this.itemsNum > 1) {
        this.resetSize();
        this.logic();
    }

    $.pub('b_photogallery_init');

    return this;
};
S.blockPhotoGallerySmall.prototype.resetSize = function(num) {
    this.size = {};
    this.size.itemW = this.els.items.eq(0).outerWidth();
    this.size.listW = this.itemsNum * this.size.itemW;
    this.size.step = this.size.itemW * this.options.itemsPerStep;

    this.els.list.css({ width: this.size.listW });
};

S.blockPhotoGallerySmall.prototype.stepTo = function(num) {
    this.els.list.animate({
        left: -(num * this.size.step)
    }, this.options.animDuration, 'linear');
};

S.blockPhotoGallerySmall.prototype.logic = function() {
    var that = this;

    var handleItemsClick = function(e) {
        $.pub('b_photogallery_logic_item_click', +this.getAttribute('data-photoid'));
    };

    var handleShowNext = function(e) {
        S.e(e);

        if (--that.step < 0) {
            that.step = that.maxStep - 1;
        }

        that.stepTo(that.step);
    };

    var handleShowPrev = function(e) {
        S.e(e);

        if (++that.step >= that.maxStep) {
            that.step = 0;
        }

        that.stepTo(that.step);
    };

    this.els.list.on('click', '.b-pgs-item', handleItemsClick);

    this.els.prev.on('click', handleShowNext);
    this.els.next.on('click', handleShowPrev);
};

})(jQuery);
