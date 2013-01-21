// @require 'blocks/block-story-full/b-story-full.js'
// @require 'blocks/block-story-full/b-story-full.jst'
// @require 'blocks/block-story-full/b-story-full-overlay.jst'
// @require 'blocks/block-activity-feed/b-activity-feed.jst'

(function($) {
S.blockActivityFeed = function(settings) {
    this.options = $.extend({
        collection: false,
        packetSize: 30,
        overlayPart: '.story-view'
    }, settings);

    this.els = {};
};

S.blockActivityFeed.prototype.init = function() {
    this.els.block = $('.b-activity-feed');
    this.els.list = this.els.block.find('.b-activity-feed-list');

    this.els.moreWrap = this.els.block.find('.b-activity-feed-more');
    this.els.more = this.els.moreWrap.find('.b-activity-feed-more-link');
    this.els.to_top = this.els.moreWrap.find('.b-activity-feed-to_top-link');

    this.els.overlay = S.overlay.parts.filter(this.options.overlayPart);

    if (this.options.collection) {
        this.coll = this.options.collection;
        this.dataMap = [];

        this.rendered = 0;

        this.templateFeed = MEDIA.templates['blocks/block-activity-feed/b-activity-feed.jst'].render;
        this.templateStory = MEDIA.templates['blocks/block-story-full/b-story-full.jst'].render;
        this.templateStoryOverlay = MEDIA.templates['blocks/block-story-full/b-story-full-overlay.jst'].render;

        this.renderFeed(this.rendered, this.options.packetSize);
    }

    this.stories = {};
    this.storyid = 0;
    
    this.overlayStory = null;

    this.logic();
   
    $.pub('b_activity_feed_init');

    return this;
};
S.blockActivityFeed.prototype.getJSON = function() {
    if ((typeof this.deferred !== 'undefined') && (this.deferred.readyState !== 4)) {
        // never supposed to see this
        this.deferred.abort();
    }
    var that = this;
        
    $.pub('b_activity_feed_data_loading');

    var handleAjaxError = function() {
        S.notifications.presets['server_failed']();

        $.pub('b_activity_feed_data_loaded', false);
    };

    var handleResponse = function(resp) {
        if (resp.status === 'OK' || resp.status === 'LAST') {
            that.coll = _.union(that.coll, resp.data);

            if (resp.status === 'LAST') {
                that.els.moreWrap.removeClass('active');
            }
        }

        $.pub('b_activity_feed_data_loaded', true);
    };

    this.deferred = $.ajax({
        url: S.url('feed'),
        type: 'GET',
        data: { 'uniqid': this.coll[this.coll.length-1]['uniqid'] },
        dataType: 'json',
        success: handleResponse,
        error: handleAjaxError
    });
};
S.blockActivityFeed.prototype.renderFeed = function(start, end) {
    $.pub('b_activity_feed_render');
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
        this.dataMap.push(this.coll[i].id);
        html += this.renderFeedItem(this.coll[i]);
    }

    this.els.list.append(html);
    
    this.rendered = j;
    
    S.log('[OTA.blockActivityFeed.render]: rendering items ' + (start ? start : 0) + '-' + j);
    $.pub('b_activity_feed_render_end');
};
S.blockActivityFeed.prototype.renderFeedItem = function(data) {
    return this.templateFeed({
        created: data.share_date,
        story: this.templateStory(data)
    });
};
S.blockActivityFeed.prototype.initStory = function(data) {
    return this.templateFeed({
        created: data.create_date,
        story: this.templateStory(data)
    });
};
S.blockActivityFeed.prototype.logic = function() {
    var that = this;

    var handleStoryInit = function(e) {
        var el = $(this);

        if (!el.data('feedid')) {
            var target = $(e.target),
                id = ++that.storyid;

            that.stories[id] = new S.blockStoryFull({
                elem: el,
                data: that.coll[_.indexOf(that.dataMap, +el.data('storyid'))],
                removable: true
            });
            that.stories[id].init();
            el.data('feedid', id);

            target.trigger('click');
        }
    };

    var handleOverlayLink = function(e) {
        S.e(e);

        handleOverlayOpen(+$(this).parents('.b-story-full').data('storyid'));
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
            var story = that.els.list.find('.b-story-full[data-storyid="' + that.overlayStory.storyid + '"]'),
                storyWrap = story.parent();

            storyWrap.html(that.templateStory(that.overlayStory.data));
        }

        delete that.overlayStory;
    };

    var handleStoryDestroy = function(e, data) {
        var story = that.els.block.find('.b-story-full[data-storyid="' + data + '"]'),
            feedid = story.data('feedid'),
            feeditem = story.parents('.b-activity-feed-item'),
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

        $.once('b_activity_feed_data_loaded', handleDataLoaded);

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

    this.els.list.on('click', '.b-story-full', handleStoryInit);
    S.browser.isAndroid || this.els.list.on('click', '.b-s-f-storylink', handleOverlayLink);
    this.els.more.on('click', handleLoadMore);
    this.els.to_top.on('click', handleToTop);
    $.sub('b_story_full_destroy', handleStoryDestroy);
    $.sub('l_overlay_beforehide', handleOverlayHide);
    $.sub('l_overlay_popshow', handleOverlayPopShow);
    $.sub('b_story_comment_sent', scrollComments);

    return this;
};

})(jQuery);
