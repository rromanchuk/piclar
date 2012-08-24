// @require 'blocks/block-story-full/b-story-full.js'
// @require 'blocks/block-story-full/b-story-full.jst'
// @require 'blocks/block-story-full/b-story-full-overlay.jst'
// @require 'blocks/block-activity-feed/b-activity-feed.jst'

(function($){
S.blockActivityFeed = function(settings) {
    this.options = $.extend({
        collection: false,
        overlayPart: '.story-view'
    }, settings);

    this.els = {};
};

S.blockActivityFeed.prototype.init = function() {
    this.els.block = $('.b-activity-feed');

    this.els.overlay = S.overlay.parts.filter(this.options.overlayPart);

    if (this.options.collection) {
        this.coll = this.options.collection;
        this.templateFeed = MEDIA.templates['blocks/block-activity-feed/b-activity-feed.jst'].render;
        this.templateStory = MEDIA.templates['blocks/block-story-full/b-story-full.jst'].render;
        this.templateStoryOverlay = MEDIA.templates['blocks/block-story-full/b-story-full-overlay.jst'].render;

        this.generateFeed();
    }

    this.stories = {};
    this.storyid = 0;
    this.overlayStory = null;

    this.logic();
   
    $.pub('b_activity_feed_init');

    return this;
};
S.blockActivityFeed.prototype.generateFeed = function() {
    var i = 0,
        l = this.coll.length,
        html = '';

    this.dataMap = [];

    for (; i < l; i++) {
        this.dataMap.push(this.coll[i].id);
        html += this.renderFeed(this.coll[i]);
    }

    this.els.block.append(html);
    return this;
};
S.blockActivityFeed.prototype.renderFeed = function(data) {
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

    var handleOverlayOpen = function(e) {
        S.e(e);

        var el = $(this).parents('.b-story-full'),
            storyObj = that.coll[_.indexOf(that.dataMap, +el.data('storyid'))];

        that.els.overlay.html(that.templateStoryOverlay(storyObj));

        that.overlayStory = new S.blockStoryFull({
            elem: that.els.overlay.find('.b-story-full').addClass('overlay'),
            data: storyObj,
            removable: true
        });

        S.overlay.show({
            block: that.options.overlayPart
        });

        that.overlayStory.init();
    };

    var handleOverlayHide = function(e, data) {
        if (data.block !== that.options.overlayPart) return;

        var story = that.els.block.find('.b-story-full[data-storyid="' + that.overlayStory.storyid + '"]'),
            storyWrap = story.parent();

        storyWrap.html(that.templateStory(that.overlayStory.data));
        delete that.overlayStory;
    };

    var handleStoryDestroy = function(e, data) {
        var story = that.els.block.find('.b-story-full[data-storyid="' + data + '"]'),
            feedid = story.data('feedid'),
            feeditem = story.parents('.b-activity-feed-item');

        delete that.stories[feedid];
        feeditem.remove();

        if (that.overlayStory && (that.overlayStory.storyid === data)) {
            S.overlay.hide();
        }
    };

    this.els.block.on('click', '.b-story-full', handleStoryInit);
    this.els.block.on('click', '.b-s-f-storylink', handleOverlayOpen);
    $.sub('b_story_full_destroy', handleStoryDestroy);
    $.sub('l_overlay_beforehide', handleOverlayHide);

    return this;
};

})(jQuery);
