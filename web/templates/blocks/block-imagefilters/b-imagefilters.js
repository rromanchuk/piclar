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

    this.current = null;

    this.canvas = null;
    this.ctx = null;

    this.logic();

    $.pub('b_imagefilters_init');

    return this;
};

S.blockImageFilters.prototype.setImage = function(settings) {
    if (!settings.elem) {
        S.log('[S.blockImageFilters.setImage]: provide an image to work with!');
        return;
    }

    delete this.image;
    delete this.filtered;

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

    this.active = false;

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
S.blockImageFilters.prototype.prepareCanvas = function(type) {
    this.els.filtered.html('');

    delete this.canvas;
    delete this.ctx;

    this.canvas = $('<canvas width="' + this.options.imageSize + '" height="' + this.options.imageSize + '" />');
    this.ctx = this.canvas[0].getContext('2d');

    this.ctx.drawImage(this.image.elem[0],
                      this.image.cx, this.image.cy, this.image.width, this.image.height,
                      0, 0, this.options.imageSize, this.options.imageSize
                      );

    this.els.filtered.append(this.canvas);
};
S.blockImageFilters.prototype.getFilteredImage = function() {
    if (!this.filtered[this.current]) {
        return this.filtered[this.current].clone();
    }
    else {
        var child = this.els.filtered.children('*');

        if (child[0].nodeName.toLowerCase() === 'img') {
            return child.clone();
        }
        else {
            return $('<img src="' + child[0].toDataURL() + '" />');
        }
    }
};
S.blockImageFilters.prototype.applyFilter = function(type) {
    var that = this;

    this.deactivate();

    if (this.filtered[type]) {
        this.els.filtered.html('');
        this.els.filtered.append(this.filtered[type].clone());
        this.activate();
        return;
    }

    var renderComplete = function() {
        var canvas = that.els.filtered.find('> canvas');
        if (canvas.length) {
            that.filtered[type] = $('<img src="' + canvas[0].toDataURL() + '" />');
            S.log('[S.blockImageFilters.applyFilter.renderComplete]: state saved for "' + type + '" filter.');
        }
        that.current = type;
        that.activate();
    };

    if (type === 'normal') {
        this.prepareCanvas();
        renderComplete();
    }
    else {
        this.prepareCanvas();

        Caman(this.canvas[0], function() {
            that.filters[type].call(this);
            this.render(renderComplete);
        });
    }

    $.pub('b_imagefilters_filtered');

    return this;
};


S.blockImageFilters.prototype.logic = function() {
    var that = this;

    var handleFilterClick = function() {
        if (!that.active) return;
        that.applyFilter(this.getAttribute('data-filter'));
    };

    this.els.filters.on('click', '.b-i-filter', handleFilterClick);

    return this;
};

})(jQuery);

