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
    this.dataMap = [];

    this.els.block = $('.b-favorites');

    this.template = MEDIA.templates['blocks/block-favorites/b-favorites.jst'].render;

    this.rendered = 0;

    this.render(this.rendered, this.options.perPage);
    this.logic();
   
    $.pub('b_favorites_init');

    return this;
};
S.blockFavorites.prototype.removeFavorite = function(placeid) {
    var index = _.indexOf(this.dataMap, +placeid);

    this.dataMap.splice(index, 1);
    this.coll.splice(index, 1);

    this.rendered--;
};
S.blockFavorites.prototype.addFavorite = function(place) {
    this.dataMap.unshift(place.id);
    this.coll.unshift(place);

    this.rendered++;
};

S.blockFavorites.prototype.logic = function() {
    var that = this;

    var handleAjaxError = function() {
        S.notifications.show({
            type: 'error',
            text: 'Произошла ошибка при обращении к серверу. Пожалуйста, попробуйте еще раз.'
        });
    };

    var handleAddFavorite = function() {
        that.addFavorite(resp);
    };

    var handleFavorite = function(e) {
        S.e(e);

        var el = $(this),
            place = el.parents('.b-f-place'),
            placeid = place.data('placeid');

        if (el.hasClass('active')) {
            el.removeClass('active');

            that.removeFavorite(placeid);

            $.ajax({
                url: S.urls.favorite,
                data: { placeid: placeid, action: 'DELETE' },
                type: 'POST',
                dataType: 'json',
                error: handleAjaxError
            });
        }
        else {
            el.addClass('active');

            $.ajax({
                url: S.urls.favorite,
                data: { placeid: placeid, action: 'PUT' },
                type: 'POST',
                dataType: 'json',
                success: handleAddFavorite,
                error: handleAjaxError
            });
        }
    };

    this.els.block.on('click', '.b-f-addfavorite', handleFavorite);

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
        this.coll[i].counter = i;
        html += this.template(this.coll[i]);
        this.dataMap[i] = +this.coll[i].id;
    }

    this.els.block.append(html);
    
    this.rendered = j;
    
    S.log('[OTA.blockFavorites.render]: rendering items ' + (start ? start : 0) + '-' + j);
    $.pub('b_favorites_render_end');
};

})(jQuery);
