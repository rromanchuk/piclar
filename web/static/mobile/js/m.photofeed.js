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
        this.els.list = this.els.mod.find('.m-p-list');

        this.els.root = $('html');

        this.logic();
    };

    PhotoFeed.prototype.logic = function() {
        var that = this;

        var handleListTypeChange = function() {
            that.els.controls.toggleClass('list-view');
            that.els.list.toggleClass('list-view');

            // Fix rendering issues on android 4
            // $.os.android && setTimeout(function() {
            //     that.els.root.css({ display: 'none' }).css({ display: 'block' });
            // }, 100);           
        };
        this.els.controls.onpress(handleListTypeChange);
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
