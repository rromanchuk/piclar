// @require 'blocks/block-suggested-friends/b-suggested-friends-item.jst'

(function($){
S.blockSuggestedFriends = function(settings) {
    this.options = $.extend({
        packetSize: 12,
        minSize: 6,
        animDuration: 300,
        defaultItemsNum: 3
    }, settings);

    this.els = {};
};

S.blockSuggestedFriends.prototype.init = function() {
    this.els.block = $('.b-suggested-friends');
    this.els.reload = this.els.block.find('.b-s-f-reload');
    this.els.list = this.els.block.find('.b-s-f-list');

    this.template = MEDIA.templates['blocks/block-suggested-friends/b-suggested-friends-item.jst'].render;

    this.friends = [];

    this.requestSuggestions(this.options.packetSize, true);

    this.logic();
    
    $.pub('b_suggested_friends_init');

    return this;
};
S.blockSuggestedFriends.prototype.logic = function() {
    var that = this;

    var handleRequest = function(e) {
        e && S.e(e);
        var el = $(this),
            item = el.parents('.b-s-f-item'),
            
            type = el.hasClass('b-s-f-add');

        $.ajax({
            url: S.urls.friends,
            data: { userid: item.data('userid'), action: type ? 'POST' : 'DELETE' },
            type: 'POST',
            dataType: 'json',
            error: S.notifications.presets['server_failed']
        });

        that.updateList(item);
    };

    var handleListReload = function() {
        that.updateList(that.els.list.find('.b-s-f-item'));
    };

    this.els.list.on('click', '.b-s-f-add', handleRequest);
    this.els.list.on('click', '.b-s-f-remove', handleRequest);
    this.els.reload.on('click', handleListReload);

    return this;
};

S.blockSuggestedFriends.prototype.updateList = function(els) {
    var that = this,
        count = els ? els.length : this.options.defaultItemsNum,
        i = 0,
        tmpHTML = '',
        newItems;

    var handleAnimationEnd = function() {
        els.remove();

        that.els.list.append(newItems);

        newItems.fadeIn(that.options.animDuration);
    };

    for (; i < count; i++) {
         tmpHTML += this.template(this.friends.shift());
    }

    if (els) {
        newItems = $(tmpHTML);
        newItems.css({ display: 'none' });
        els.fadeOut(this.options.animDuration, handleAnimationEnd);
    }
    else {
        this.els.list.append(newItems);
    }

    if (this.friends.length < this.options.minSize) {
        this.requestSuggestions(this.options.packetSize);
    }
};
S.blockSuggestedFriends.prototype.requestSuggestions = function(num, update) {
    if ((typeof this.deferred !== 'undefined') && (this.deferred.readyState !== 4)) {
        this.deferred.abort();
    }

    num = num || 1;

    var that = this;

    var handleRequestSuccess = function(resp) {
        if ('status' in resp && resp.status === 'success'){
            _.union(that.friends, rest.friends);

            update && that.updateList();
        }
        else {
            handleRequestFailed();
        }
    };

    var handleRequestFailed = function() {
        if (that.deferred.readyState === 0) { // Cancelled request, still loading
            return;
        }

        S.notifications.presets['server_failed']();
    };

    this.deferred = $.ajax({
        url: S.urls.friends,
        data: { num: num },// yum yum num num
        type: 'GET',
        dataType: 'json',
        success: handleRequestSuccess,
        error: handleRequestFailed
    });
};

})(jQuery);
