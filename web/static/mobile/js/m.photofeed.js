/* Author:
    Max Degterev @suprMax
*/

;(function($) {
    var PhotoFeed = function(el) {
        // this.options = $.extend({
        // }, settings);
        
        this.els = {};
        this.els.mod = $(el);
        this.els.controls = this.els.mod.find('.m-p-controls');
        this.els.options = this.els.controls.find('.m-p-option');
        this.els.list = this.els.mod.find('.m-p-list');

        this.logic();
    };

    PhotoFeed.prototype.logic = function() {
        var that = this;

        var handleListTypeChange = function() {
            var el = $(this);

            if (el.hasClass('active')) return; // tapping already active type

            that.els.options.filter('.active').removeClass('active');
            el.addClass('active');

            that.els.list.removeClass('table list').addClass(el.hasClass('m-p-option-list') ? 'list' : 'table');
        };
        this.els.options.onpress(handleListTypeChange);
    };

    $.fn.mod_photoFeed = function(settings) {
        // var options = $.extend({
        // }, settings);
        
        this.forEach(function(elem, index) {
            var id = elem.getAttribute('data-moduleid');

            if (!id) {
                id = 'photofeed_' + (Math.random() * 99999 | 0);

                elem.setAttribute('data-moduleid', id);
                S.modules[id] = new PhotoFeed(elem);

                $.pub('photofeed_ready', id);
            }

            return S.modules[id];
        });
    };
})(Zepto);
