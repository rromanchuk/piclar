(function($){
S.blockHowto = function(settings) {
    this.options = $.extend({
        animDuration: 200
    }, settings);

    this.els = {};
};

S.blockHowto.prototype.init = function() {
    this.els.block = $('.b-howto');

    this.els.imagesList = this.els.block.find('.b-h-imageslist');
    this.els.images = this.els.imagesList.find('.b-h-i-item');
    this.els.steps = this.els.block.find('.b-h-s-item');

    this.animated = false;
    
    this.getSizes();
    this.logic();
    
    $.pub('b_howto_init');

    return this;
};
S.blockHowto.prototype.getSizes = function() {
    this.sizes = {};
    this.sizes.imageH = this.els.images.eq(0).height();
};
S.blockHowto.prototype.logic = function() {
    var that = this;

    var handleChangeStep = function(e) {
        var el = $(this);

        if (el.hasClass('active') || that.animated) return;

        var handleAnimEnd = function() {
            that.animated = false;
        };

        that.animated = true;

        that.els.imagesList.animate({
            top: -(el.data('step') - 1) * that.sizes.imageH
        }, that.options.animDuration, 'linear', handleAnimEnd);

        that.els.steps.filter('.active').removeClass('active');
        el.addClass('active');
    };

    this.els.steps.on('click', handleChangeStep);

    return this;
};

})(jQuery);
