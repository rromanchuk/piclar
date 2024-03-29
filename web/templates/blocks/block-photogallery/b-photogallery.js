(function($){
S.blockPhotoGallery = function(settings) {
    this.options = $.extend({
        animDuration: 200
    }, settings);

    this.els = {};
};

S.blockPhotoGallery.prototype.init = function() {
    this.els.block = $('.b-photogallery');
    this.els.items = this.els.block.find('.b-pg-item');
    this.els.prev = this.els.block.find('.b-pg-before');
    this.els.next = this.els.block.find('.b-pg-after');

    this.current = 1;
    this.itemsNum = this.els.items.length;

    if (this.itemsNum > 1) {
        this.logic();
    }

    $.pub('b_photogallery_init');

    return this;
};

S.blockPhotoGallery.prototype.show = function(num) {
    num = +num;

    if (num === this.current) return;

    if (num < 1) {
        num = this.itemsNum;
    }

    if (num > this.itemsNum) {
        num = 1;
    }

    var active = this.els.items.filter('.active'),
        next = this.els.items.filter('[data-photoid="' + num + '"]'),
        duration = this.options.animDuration;

    var fadeOut = function() {
        active.removeClass('active');
        next.fadeIn(duration, fadeIn);
    };

    var fadeIn = function() {
        next.addClass('active');
    };

    active.fadeOut(duration, fadeOut);
    this.current = num;
};

S.blockPhotoGallery.prototype.logic = function() {
    var that = this;

    var handleShowNext = function(e) {
        S.e(e);
        that.show(that.current - 1);
    };

    var handleShowPrev = function(e) {
        S.e(e);
        that.show(that.current + 1);
    };

    this.els.prev.on('click', handleShowNext);
    this.els.next.on('click', handleShowPrev);
};

})(jQuery);
