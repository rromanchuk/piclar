// @require 'blocks/block-favorites/b-favorites.jst'

(function($) {
S.blockFavorites = function(settings) {
    this.options = $.extend({
        data: [],
        perPage: 10
    }, settings);

    this.els = {};
};

S.blockFavorites.prototype.init = function() {
    this.coll || (this.coll = this.options.data);

    this.els.block = $('.b-favorites');

    this.template = MEDIA.templates['blocks/block-favorites/b-favorites.jst'].render;

    this.rendered = 0;

    this.render(this.rendered, this.options.perPage);
    this.logic();
   
    $.pub('b_favorites_init');

    return this;
};

S.blockFavorites.prototype.logic = function() {
    var that = this;

    return this;
};
S.blockFavorites.prototype.reset = function() {
    this.els.block.html('');
    this.rendered = 0;
};
S.blockFavorites.prototype.render = function(start, end) {
    $.pub('b_favorites_render');
    var html = '',
        len = this.coll.length,

        i = start || 0,
        j = end || len;
        
    if (j > len) {
        j = len;
    }

    if (!len || i == j) {
        return;
    }

    for (; i < j; i++) {
        html += this.template(this.coll[i]);
    }

    this.els.block.append(html);
    
    this.rendered = j;
    
    S.log('[OTA.blockFavorites.render]: rendering items ' + (start ? start : 0) + '-' + j);
    $.pub('b_favorites_render_end');
};

})(jQuery);
