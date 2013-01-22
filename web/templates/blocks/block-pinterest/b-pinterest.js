// @require 'js/jquery.masonry.js'

// @require 'blocks/block-story/b-story.js'
// @require 'blocks/block-story/b-story.jst'

// @require 'blocks/block-story-full/b-story-full.js'
// @require 'blocks/block-story-full/b-story-full-overlay.jst'

// @require 'blocks/block-pinterest/b-pinterest.jst'

(function($) {
S.blockPinterest = function(settings) {
    this.options = $.extend({
        collection: false,
        packetSize: 30,
        overlayPart: '.story-view',
        initDelay: 1000
    }, settings);

    this.els = {};
};

S.blockPinterest.prototype.init = function() {
    this.els.block = $('.b-pinterest');
    this.els.list = this.els.block.find('.b-pinterest-list');

    this.els.moreWrap = this.els.block.find('.b-pinterest-more');
    this.els.more = this.els.moreWrap.find('.b-pinterest-more-link');
    this.els.to_top = this.els.moreWrap.find('.b-pinterest-to_top-link');

    this.els.overlay = S.overlay.parts.filter(this.options.overlayPart);

    if (this.options.collection) {
        this.coll = this.options.collection;
        this.dataMap = [];

        this.rendered = 0;

        this.templateFeed = MEDIA.templates['blocks/block-pinterest/b-pinterest.jst'].render;
        this.templateStory = MEDIA.templates['blocks/block-story/b-story.jst'].render;
        this.templateStoryOverlay = MEDIA.templates['blocks/block-story-full/b-story-full-overlay.jst'].render;

        this.renderFeed(this.rendered, this.options.packetSize, true);
    }

    this.stories = {};
    this.storyid = 0;
    
    this.overlayStory = null;

    this.logic();

    this.masonryrise();
  
    $.pub('b_pinterest_init');

    return this;
};
S.blockPinterest.prototype.masonryrise = function() {
    var that = this,
        firstItem = this.els.list.find('.b-pinterest-item').eq(0);

    setTimeout(function() {
        that.els.list.masonry({
            itemSelector : '.b-pinterest-item',
            columnWidth : firstItem.width() + parseInt(firstItem.css('margin-left'), 10) + parseInt(firstItem.css('margin-right'), 10)
        });
    }, this.options.initDelay);
};
S.blockPinterest.prototype.getJSON = function() {
    if ((typeof this.deferred !== 'undefined') && (this.deferred.readyState !== 4)) {
        // never supposed to see this
        this.deferred.abort();
    }
    var that = this;
        
    $.pub('b_pinterest_data_loading');

    var handleAjaxError = function() {
        S.notifications.presets['server_failed']();

        $.pub('b_pinterest_data_loaded', false);
    };

    var handleResponse = function(resp) {
        if (resp.status === 'OK' || resp.status === 'LAST') {
            that.coll = _.union(that.coll, resp.data);

            if (resp.status === 'LAST') {
                that.els.moreWrap.removeClass('active');
            }
        }

        $.pub('b_pinterest_data_loaded', true);
    };

    this.deferred = $.ajax({
        url: S.url('featured'),
        type: 'GET',
        data: { 'uniqid': this.coll[this.coll.length-1]['uniqid'] },
        dataType: 'json',
        success: handleResponse,
        error: handleAjaxError
    });
};
S.blockPinterest.prototype.renderFeed = function(start, end, initial) {
    $.pub('b_pinterest_render');
    var html = '',
        len = this.coll.length,

        i = start || 0,
        j = end || len,

        fragment;
        
    if (j > len) {
        j = len;
    }

    if (!len || i == j) {
        return;
    }

    for (; i < j; i++) {
        this.dataMap.push(this.coll[i].id);
        html += this.renderFeedItem(this.coll[i]);
    }

    if (initial) {
        this.els.list.append(html);
    }
    else {
        fragment = $(html);
        this.els.list.append(fragment).masonry('appended', fragment);
    }
  
    this.rendered = j;
    
    S.log('[OTA.blockPinterest.render]: rendering items ' + (start ? start : 0) + '-' + j);
    $.pub('b_pinterest_render_end');
};
S.blockPinterest.prototype.renderFeedItem = function(data) {
    return this.templateFeed({
        story: this.templateStory(data)
    });
};
S.blockPinterest.prototype.logic = function() {
    var that = this;

    var handleStoryInit = function(e) {
        var el = $(this);

        if (!el.data('feedid')) {
            var target = $(e.target),
                id = ++that.storyid;

            that.stories[id] = new S.blockStory({
                elem: el,
                data: that.coll[_.indexOf(that.dataMap, +el.data('storyid'))]
            });
            that.stories[id].init();
            el.data('feedid', id);

            target.trigger('click');
        }
    };

    var handleOverlayLink = function(e) {
        S.e(e);

        handleOverlayOpen(+$(this).parents('.b-story').data('storyid'));
    };

    var handleOverlayOpen = function(id) {
        var storyObj = that.coll[_.indexOf(that.dataMap, id)];

        that.els.overlay.html(that.templateStoryOverlay(storyObj));

        that.overlayStory = new S.blockStoryFull({
            elem: that.els.overlay.find('.b-story-full'),
            data: storyObj,
            removable: true
        });

        S.overlay.show({
            block: that.options.overlayPart,
            hash: storyObj.id
        });

        that.overlayStory.init();
    };

    var handleOverlayHide = function(e, data) {
        if (data.block !== that.options.overlayPart) return;

        if (that.overlayStory.altered) {
            var story = that.els.list.find('.b-story[data-storyid="' + that.overlayStory.storyid + '"]'),
                storyWrap = story.parent();

            storyWrap.html(that.templateStory(that.overlayStory.data));
        }

        delete that.overlayStory;
    };

    var handleStoryDestroy = function(e, data) {
        var story = that.els.block.find('.b-story[data-storyid="' + data + '"]'),
            feedid = story.data('feedid'),
            feeditem = story.parents('.b-pinterest-item'),
            index = _.indexOf(that.dataMap, +data);

        delete that.stories[feedid];
        feeditem.remove();

        that.dataMap.splice(index, 1);
        that.coll.splice(index, 1);

        if (that.overlayStory && (that.overlayStory.storyid === data)) {
            S.overlay.hide();
        }
    };

    var handleDataLoaded = function() {
        that.renderFeed(that.rendered, that.rendered + that.options.packetSize);
        that.els.more.removeClass('disabled');
    };

    var handleLoadMore = function() {
        if (that.els.more.hasClass('disabled')) {
            return;
        }

        $.once('b_pinterest_data_loaded', handleDataLoaded);

        that.getJSON();
        that.els.more.addClass('disabled');
    };

    var scrollComments = function() {
        if (!S.overlay.active()) return;

        var block = that.els.overlay.find('.b-s-f-scrollable'),
            offset = block.scrollTop(),
            pos = block.find('.b-s-f-c-listitem').last().position().top;

        block.animate({
            scrollTop: pos + offset
        }, 300);
    };

    var handleToTop = function() {
        S.utils.scroll();
    };

    var handleOverlayPopShow = function(e, data) {
        if (S.overlay.isPart(that.options.overlayPart)) {
            var id = parseInt(S.overlay.getPart(window.location.hash).replace(that.options.overlayPart + '/', ''), 10);

            handleOverlayOpen(id);
        }
    };

    this.els.list.on('click', '.b-story', handleStoryInit);
    S.browser.isAndroid || this.els.list.on('click', '.b-s-storylink', handleOverlayLink);

    this.els.more.on('click', handleLoadMore);
    this.els.to_top.on('click', handleToTop);

    $.sub('b_story_full_destroy', handleStoryDestroy);
    $.sub('b_story_comment_sent', scrollComments);

    $.sub('l_overlay_beforehide', handleOverlayHide);
    $.sub('l_overlay_popshow', handleOverlayPopShow);

    return this;
};

})(jQuery);
