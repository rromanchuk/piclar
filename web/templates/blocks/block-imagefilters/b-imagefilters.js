// @require 'js/caman/caman.full.js'

(function($){
S.blockImageFilters = function(settings) {
    this.options = $.extend({}, settings);

    this.els = {};
};

S.blockImageFilters.prototype.init = function() {
    this.els.block = $('.b-imagefilters');
    this.els.filtered = this.els.block.find('.b-i-filtered')

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
        cy: 0,
        resize: false,
        width: 640,
        height: 640,
        scale: 0
    }, settings);

    var that = this,
        image = $(opt.image).clone();

    this.els.filtered.append(image);

    this.active && (delete this.caman);

    this.deactivate();

    this.caman = Caman(image[0], function() {
        this.crop(opt.width, opt.height, opt.cx, opt.cy);
        that.activate();
    });

    $.pub('b_imagefilters_imageset');
};

S.blockImageFilters.prototype.activate = function() {
    this.els.block.addClass('active');

    this.active = true;

    $.pub('b_imagefilters_activated');
};
S.blockImageFilters.prototype.deactivate = function() {
    this.els.block.removeClass('active');

    this.active = true;

    $.pub('b_imagefilters_deactivated');
};

S.blockImageFilters.prototype.filters = {
    'bnw': function() {
        this.greyscale();
    },
    'sepia': function() {
        this.sepia(70);
    },
    'saturation': function() {
        this.saturation(90);
    },
    'blur': function() {
        this.radialBlur();
    },
    'noise': function() {
        this.noise(23);
    }
};


S.blockImageFilters.prototype.logic = function() {
    var that = this,
        type;

    var activate = function() {
        that.activate();
    };
    var applyFilter = function() {
        that.filters[type].call(that.caman);
        that.caman.render(activate);
    };

    var handleFilterClick = function() {
        if (!that.active) return;

        type = this.getAttribute('data-filter');

        if (typeof that.filters[type] === 'function') {
            that.deactivate();
            that.caman.revert.call(that.caman, applyFilter);
        }
    };

    this.els.filters.on('click', '.b-i-filter', handleFilterClick);

    return this;
};

})(jQuery);

