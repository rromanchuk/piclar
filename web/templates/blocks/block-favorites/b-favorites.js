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
    this.els.list = this.els.block.find('.b-f-list');

    this.els.moreWrap = this.els.block.find('.b-f-more');
    this.els.more = this.els.moreWrap.find('.b-f-more-link');
    this.els.to_top = this.els.moreWrap.find('.b-f-to_top-link');

    this.template = MEDIA.templates['blocks/block-favorites/b-favorites.jst'].render;

    this.reset();

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

    $.pub('b_favorites_removed', placeid);
};
S.blockFavorites.prototype.addFavorite = function(place) {
    this.dataMap.unshift(place.id);
    this.coll.unshift(place);

    this.rendered++;

    $.pub('b_favorites_added', place);
};

S.blockFavorites.prototype.setActive = function(id) {
    this.els.list.find('.b-f-place.active').removeClass('active');

    id && this.els.list.find('.b-f-place[data-placeid="' + id + '"]').addClass('active');
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

    var handleLoadMore = function() {
        if (that.rendered + that.options.perPage > that.coll.length) {
            that.els.moreWrap.removeClass('active');
        }

        that.render(that.rendered, that.rendered + that.options.perPage);
    };

    var handleToTop = function() {
        S.utils.scroll();
    };

    this.els.block.on('click', '.b-f-addfavorite', handleFavorite);
    this.els.more.on('click', handleLoadMore);
    this.els.to_top.on('click', handleToTop);

    return this;
};
S.blockFavorites.prototype.reset = function() {
    this.dataMap = [];
    this.els.list.html('');
    this.rendered = 0;
    this.counter = 0;

    if (this.coll.length > this.options.perPage) {
        this.els.moreWrap.addClass('active');
    }

    $.pub('b_favorites_reset');
};
S.blockFavorites.prototype.render = function(start, end) {
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

    $.pub('b_favorites_render', {
        from: i,
        to: j
    });

    for (; i < j; i++) {
        this.coll[i].counter = ++this.counter;
        html += this.template(this.coll[i]);
        this.dataMap[i] = +this.coll[i].id;
    }

    this.els.list.append(html);
    
    this.rendered = j;
    
    S.log('[OTA.blockFavorites.render]: rendering items ' + (start ? start : 0) + '-' + j);
    $.pub('b_favorites_render_end', this.rendered);
};

})(jQuery);
