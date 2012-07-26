// @require 'blocks/block-story-full/b-story-full.js'
// @require 'blocks/block-story-full/b-story-full.jst'
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

    this.els.overlayPart = S.overlay.parts.filter(this.options.overlayPart);
    this.els.overlay = this.els.overlayPart.find('.p-f-story-holder');

    if (this.options.collection) {
        this.coll = this.options.collection;
        this.templateFeed = MEDIA.templates['blocks/block-activity-feed/b-activity-feed.jst'].render;
        this.templateStory = MEDIA.templates['blocks/block-story-full/b-story-full.jst'].render;

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
        story: this.renderStory(data)
    });
};
S.blockActivityFeed.prototype.renderStory = function(data) {
    return this.templateStory(data);
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
                data: that.coll[_.indexOf(that.dataMap, +el.data('storyid'))]
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

        that.els.overlay.html(that.renderStory(storyObj));

        that.overlayStory = new S.blockStoryFull({
            elem: that.els.overlay.find('.b-story-full').addClass('overlay'),
            data: storyObj
        });

        S.overlay.show({
            block: that.options.overlayPart
        });

        that.overlayStory.init();
    };

    var handleOverlayHide = function() {
        var story = that.els.block.find('.b-story-full[data-storyid="' + that.overlayStory.storyid + '"]'),
            storyWrap = story.parent();

        storyWrap.html(that.renderStory(that.coll[_.indexOf(that.dataMap, that.overlayStory.storyid)]));
        delete that.overlayStory;
    };

    this.els.block.on('click', '.b-story-full', handleStoryInit);
    this.els.block.on('click', '.b-s-f-storylink', handleOverlayOpen);
    $.sub('l_overlay_beforehide', handleOverlayHide);

    return this;
};

})(jQuery);
