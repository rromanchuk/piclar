(function($) {
S.blockFavoritesMap = function(settings) {
    this.options = $.extend({}, settings);

    this.els = {};
};

S.blockFavoritesMap.prototype.init = function() {
    this.els.block = $('.b-favorites-map');
    this.logic();
   
    $.pub('b_favorites_map_init');

    return this;
};

S.blockFavoritesMap.prototype.logic = function() {
    var that = this;

    return this;
};

})(jQuery);
