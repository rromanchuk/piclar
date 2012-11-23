// @require 'js/caman/caman.full.js'

(function($){
S.blockImageFilters = function(settings) {
    this.options = $.extend({
        imageSize: 640
    }, settings);

    this.els = {};
};

S.blockImageFilters.prototype.init = function() {
    this.els.block = $('.b-imagefilters');
    this.els.filtered = this.els.block.find('.b-i-filtered');

    this.els.filters = this.els.block.find('.b-i-filterlist');

    this.active = false;
    this.filtered = {};

    this.initCanvas();
    this.logic();

    $.pub('b_imagefilters_init');

    return this;
};

S.blockImageFilters.prototype.initCanvas = function() {
    this.canvas = $('<canvas width="' + this.options.imageSize + '" height="' + this.options.imageSize + '" />');
    this.ctx = this.canvas[0].getContext('2d');
};

S.blockImageFilters.prototype.setImage = function(settings) {
    if (!settings.elem) {
        S.log('[S.blockImageFilters.setImage]: provide an image to work with!');
        return;
    }

    this.image = $.extend({
        cx: 0,
        cy: 0,
        width: this.options.imageSize,
        height: this.options.imageSize
    }, settings);

    this.filtered = {};

    this.applyFilter('normal'); // initial filtering required

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
    }
};

S.blockImageFilters.prototype.applyFilter = function(type) {
    var that = this,

        clone;

    this.deactivate();
    this.els.filtered.html('');

    $.pub('b_imagefilters_filter_changed');

    if (this.filtered[type]) {
        this.els.filtered.append(this.filtered[type]);
        this.activate();
        return;
    }

    var renderComplete = function() {
        var canvas = that.els.filtered.find('> canvas');
        that.filtered[type] = $('<img src="' + canvas[0].toDataURL() + '" />');
        that.activate();

    };

    if (type === 'normal') {
        clone = this.image.elem.clone();
        this.els.filtered.append(clone);

        Caman(clone[0], function() {
            this.crop(that.image.width, that.image.height, that.image.cx, that.image.cy);

            if (that.image.width > that.options.imageSize) {
                this.resize({ width: that.options.imageSize });
            }

            this.render(renderComplete);
        });

        $.pub('b_imagefilters_initial_filtering_performed');
    }
    else {
        clone = this.filtered['normal'].clone();
        this.els.filtered.append(clone);

        Caman(clone[0], function() {
            that.filters[type].call(this);
            this.render(renderComplete);
        });
    }

    return this;
};


S.blockImageFilters.prototype.logic = function() {
    var that = this;

    var handleFilterClick = function() {
        if (!that.active) return;
        type = this.getAttribute('data-filter');
        that.applyFilter(type);
    };

    this.els.filters.on('click', '.b-i-filter', handleFilterClick);

    return this;
};

})(jQuery);

