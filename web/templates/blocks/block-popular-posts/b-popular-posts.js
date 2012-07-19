(function($){
S.blockPopularPosts = function(settings) {
    this.options = $.extend({
        duration: 300,
        speed: 3000,
        easing: 'linear'
    }, settings);

    this.els = {};
};

S.blockPopularPosts.prototype.init = function() {
    this.els.row = $('.b-p-p-row');
    this.els.slider = this.els.row.find('.b-p-p-storyline');
    this.els.items = this.els.slider.find('.b-story');

    this.itemsNum = this.els.items.length;

    if (/*@cc_on!@*/false) {
        this.oldDOM = true;
    }
    else {
        this.oldDOM = false;
    }

    this.transform = S.utils.supports('transform');
    this.rawTransform = S.utils.__supports('transform');
    this.transition = S.utils.supports('transition');

    this.transform && this.initTransform();

    this.getSizes();

    this.els.slider.css({ width: this.sizes.sliderW });

    this.logic();
    
    $.pub('b_popular_posts_init');
};
S.blockPopularPosts.prototype.initTransform = function() {
    var props = {};
    props[this.transition] = this.rawTransform + ' ' + (this.options.duration / 1000) + 's ' + this.options.easing;
    props[this.transform] = S.utils.translate(0, 0);
    this.els.slider.css(props);
};
S.blockPopularPosts.prototype.getSizes = function() {
    this.sizes = {};

    this.sizes.itemW = this.els.items.eq(0).outerWidth();
    this.sizes.itemOff = parseInt(this.els.items.eq(0).css('margin-left'), 10);

    this.sizes.rowW = this.els.row.outerWidth();

    this.sizes.sliderW = this.itemsNum * (this.sizes.itemW + this.sizes.itemOff);
};
S.blockPopularPosts.prototype.logic = function() {
    var that = this,
        tid = 0;

    this.currentPos = 0;
    this.currentI = 0;
    this.active = true;

    if (this.transform) {
        var slideTo = function(pos) {
            var props = {};
            props[that.transform] = S.utils.translate(-pos + 'px', 0);
            //that.els.slider.animate(props, that.options.duration);
            that.els.slider.css(props);
        };
    }
    else {
        var slideTo = function(pos) {
            that.els.slider.animate({ left: -pos }, that.options.duration, that.options.easing);
        };
    }
    

    var handleWindowResize = function() {
        that.sizes.rowW = that.els.row.outerWidth();
    };

    var activate = function() {
        if (!that.active) {
            tid = window.setTimeout(sliderLoop, that.options.speed / 2);
            that.active = true;
        }
    };

    var deactivate = function() {
        if (that.active) {
            window.clearTimeout(tid);
            that.active = false;
        }
    };

    var sliderLoop = function() {
        if (!that.active) {
            S.log('[S.blockPopularPosts.logic]: unexpected function call.');
            window.clearTimeout(tid);
            return;
        }

        var nextPos = that.currentPos + that.sizes.itemW + that.sizes.itemOff,
            nextI = that.currentI + 1;

        if (nextPos >= that.sizes.sliderW - that.sizes.rowW) {
            nextPos = 0;
            nextI = 0;
        }

        slideTo(nextPos);

        that.currentPos = nextPos;
        that.currentI = nextI;

        tid = window.setTimeout(sliderLoop, that.options.speed);
    };

    S.DOM.win.on('resize', handleWindowResize);
    S.DOM.win.on('load', sliderLoop);

    this.els.row.on('mouseleave', activate);
    this.els.row.on('mouseenter', deactivate);

    // Set active tab event handlers
    if (this.oldDOM) { // check for Internet Explorer
        document.onfocusin = activate;
        document.onfocusout = deactivate;
    } else {
        window.onfocus = activate;
        window.onblur = deactivate;
    }
};

})(jQuery);
