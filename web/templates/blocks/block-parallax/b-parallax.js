;(function($) {
S.blockParallax = function(settings) {
    this.options = $.extend({
        maxfps: 60
    }, settings);

    this.els = {};
};

S.blockParallax.prototype.init = function() {
    this.els.block = $('.block-parallax');
    this.els.win = S.DOM.doc;
    this.els.elems = this.els.block.find('.b-p-elem');

    this.cx = this.els.win.width() / 2;
    this.cy = this.els.win.height() / 2;

    this.transform = S.utils.supports('transform');

    this.maxfps = this.options.maxfps;
    this.delay = (1 / this.maxfps) * 1000;

    this.renderT = +(S.now);

    this.transform || this.setDefaultPos();

    return this.logic();
};

S.blockParallax.prototype.setDefaultPos = function() {
    var resetElemPos = function(i, el) {
        $(el)
            .data('ex', el.position().left)
            .data('ey', el.position().top);
    };

    this.elems.each(resetElemPos);
};

S.blockParallax.prototype.logic = function() {
    var that = this;

    function prlx(e) {
        var now = +(new Date());

        if (now < that.renderT + that.delay) return;

        var moveEl = function(i, elem) {
            var el = $(el),
                ml = el.data('mult') / 100,
                ex = el.data('ex'),
                ey = el.data('ey');

            el.css({
                left: (ex + (e.clientX - that.cx) * ml) | 0,
                top: (ey + (e.clientY - that.cy) * ml) | 0
            });
        };

        that.els.elems.each(moveEl);
        that.renderT = now;
    }

    function prlxT(e) {
        var now = +(new Date());

        if (now < that.renderT + that.delay) return;

        var moveEl = function(i, elem) {
            var el = $(elem),
                ml = el.data('mult') / 100;

            el.css(that.transform, S.utils.translate((((e.clientX - that.cx) * ml) | 0) + 'px', (((e.clientY - that.cy) * ml) | 0) + 'px'));
        };

        that.els.elems.each(moveEl);
        that.renderT = now;
    }

    this.els.win.bind('mousemove', this.transform ? prlxT : prlx);

    return this;
};

})(jQuery);
