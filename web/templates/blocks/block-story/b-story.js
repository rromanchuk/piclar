// @require 'blocks/block-story-full/b-story-full-likeitem.jst'

(function($){
S.blockStory = function(settings) {
    this.options = $.extend({
        elem: '.b-story',
        // noAutoGrow: false,
        data: false
    }, settings);

    this.els = {};
};

S.blockStory.prototype.init = function() {
    this.els.block = $(this.options.elem);

    this.els.favorite = this.els.block.find('.b-s-favorite');

    this.els.metas = this.els.block.find('.b-s-meta');

    this.els.likesWrap = this.els.metas.find('.b-s-metaitem-likeswrap');
    this.els.like = this.els.likesWrap.find('.b-s-meta-likes');
    this.els.facelist = this.els.likesWrap.find('.b-s-l-facelist');

    this.els.remove = this.els.block.find('.b-s-removestory, .b-s-meta-removestory');

    this.altered = false;

    if (this.options.data) {
        this.data = this.options.data;
        this.liked = this.data.me_liked;
        this.storyid = this.data.id;

        this.favorite = this.data.checkin.place.is_favorite;
        this.placeid = this.data.checkin.place.id;

        this.updateLikesMap();
    }
    else {
        this.liked = this.els.like.hasClass('liked');
        this.storyid = this.els.block.data('storyid');

        this.favorite = this.els.favorite.hasClass('active');
        this.placeid = this.els.favorite.data('placeid');
    }

    this.likeTemplate = MEDIA.templates['blocks/block-story-full/b-story-full-likeitem.jst'].render;

    this.logic();
    
    $.pub('b_story_init');

    return this;
};
S.blockStory.prototype.updateLikesMap = function() {
    this.likesMap = [];

    var i = 0,
        l = this.data.liked.length;

    for (; i < l; i++) {
        this.likesMap.push(this.data.liked[i].id);
    }

    return this;
};

S.blockStory.prototype.logic = function() {
    var that = this;

    // var handleLikeSuccess = function(resp) {
    //     if (that.data) {
    //         $.extend(true, that.data, resp);
    //     }
    // };

    var handleLike = function(e) {
        S.e(e);

        var count = that.els.like.children('.b-s-meta-likes-count'),
            currentNum = +count.text();

        $.ajax({
            url: S.url(that.liked ? 'unlike' : 'like', [that.storyid]),
            type: 'POST',
            dataType: 'json',
            //success: handleLikeSuccess,
            error: S.notifications.presets['server_failed']
        });

        if (!that.liked) {
            count.text(++currentNum);
            that.els.like.addClass('liked');
            that.liked = true;

            if (that.data) {
                that.data.me_liked = true;
                that.data.count_likes = currentNum;

                that.likesMap.push(S.user.id);
                that.data.liked.push(S.user);
            }

            that.els.facelist.prepend(that.likeTemplate(S.user));

            if (currentNum > S.env.likes_preview) {
                that.els.likesWrap.addClass('has_likes has_extra_likes');
            }
            else {
                that.els.likesWrap.addClass('has_likes');
            }
        }
        else {
            count.text(--currentNum);
            that.els.like.removeClass('liked');
            that.liked = false;

            if (that.data) {
                that.data.me_liked = false;
                that.data.count_likes = currentNum;

                var index = _.indexOf(that.likesMap, S.user.id);

                that.likesMap.splice(index, 1);
                that.data.liked.splice(index, 1);
            }

            that.els.facelist.find('.b-s-l-f-face.own').remove();

            if (currentNum <= 0) {
                that.els.likesWrap.removeClass('has_likes');
            }

            if (currentNum <= S.env.likes_preview) {
                that.els.likesWrap.removeClass('has_extra_likes');
            }
        }

        that.altered = true;
    };

    var handleRemoveStory = function(e) {
        S.e(e);

        var answer = confirm('Навсегда удалить эту запись с сервера, чтобы ее больше никто никогда не увидел? :(');

        if (answer) {
            var handleRemoveStorySuccess = function() {
                that.destroy();
            };

            $.ajax({
                url: S.url('checkin_delete', [that.storyid]),
                type: 'POST',
                dataType: 'json',
                success: handleRemoveStorySuccess,
                error: S.notifications.presets['server_failed']
            });

            that.altered = true;
        }
    };

    var handleFavorite = function(e) {
        S.e(e);

        that.altered = true;

        if (that.favorite) {
            that.els.favorite.removeClass('active');

            $.ajax({
                url: S.urls.favorite,
                data: { placeid: that.placeid,  action: 'DELETE' },
                type: 'POST',
                dataType: 'json',
                error: handleAjaxError
            });

            if (that.data) {
                that.favorite = false;
                that.data.data.place.is_favorite = false;
            }
        }
        else {
            that.els.favorite.addClass('active');

            $.ajax({
                url: S.urls.favorite,
                data: { placeid: that.placeid, action: 'PUT' },
                type: 'POST',
                dataType: 'json',
                error: handleAjaxError
            });

            if (that.data) {
                that.favorite = true;
                that.data.data.place.is_favorite = true;
            }
        }
    };

    this.els.favorite.on('click', handleFavorite);
    this.els.like.on('click', handleLike);
    this.els.remove.on('click', handleRemoveStory);
};
S.blockStory.prototype.destroy = function() {
    $.pub('b_story_destroy', this.storyid);

    this.els.favorite.off('click');
    this.els.like.off('click');
    this.els.remove.off('click');

    this.els.block.remove();

    $.pub('b_story_destroyed', this.storyid);
};

})(jQuery);
