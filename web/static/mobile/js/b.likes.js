(function($){
S.blockLikes = function(settings) {
    this.options = $.extend({
        storyid: null
    }, settings);
    this.els = {};
};

S.blockLikes.prototype.init = function() {
    this.els.blocks = $('.b-likes');

    this.els.list = this.els.blocks.find('.b-l-list');
    this.els.like = this.els.blocks.find('.b-l-c-like');
    this.els.icon = this.els.blocks.find('.b-l-c-icon');

    this.storyid = this.options.storyid || this.els.blocks.data('storyid');

    this.storyid || S.log('[S.blockLikes.init]: Please provide storyid to work with!');

    this.template = MEDIA.templates['mobile/js/templates/b.like.jst'].render;

    this.logic();
    
    $.pub('b_likes_init');

    return this;
};

S.blockLikes.prototype.logic = function() {
    var that = this;

    var handleAjaxError = function() {
        S.notifications.show({
            type: 'error',
            text: 'Произошла ошибка при обращении к серверу. Пожалуйста, попробуйте еще раз.'
        });
    };

    var handleLike = function(e) {
        S.e(e);

        var currentNum = +that.els.icon.text(),
            liked = that.els.like.hasClass('liked');

        $.ajax({
            url: S.urls.like,
            data: { storyid: that.storyid, action: liked ? 'DELETE' : 'POST' },
            type: 'POST',
            dataType: 'json',
            error: handleAjaxError
        });

        if (!liked) {
            that.els.icon.text(++currentNum);
            that.els.like.addClass('liked');
            that.els.list.prepend(that.template({ user: S.user }));
        }
        else {
            that.els.icon.text(--currentNum);
            that.els.like.removeClass('liked');
            that.els.list.find('.b-l-l-item.own').remove();
        }
    };

    this.els.like.on('click', handleLike);
};

})(Zepto);
