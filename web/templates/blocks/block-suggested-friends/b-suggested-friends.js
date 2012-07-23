// @require 'blocks/block-suggested-friends/b-suggested-friends-item.jst'

(function($){
S.blockSuggestedFriends = function(settings) {
    this.options = $.extend({
        packetSize: 12,
        minSize: 6
    }, settings);

    this.els = {};
};

S.blockSuggestedFriends.prototype.init = function() {
    this.els.block = $('.b-suggested-friends');
    this.els.reload = this.els.block.find('.b-s-f-reload');
    this.els.list = this.els.block.find('.b-s-f-list');

    this.template = MEDIA.templates['blocks/block-suggested-friends/b-suggested-friends-item.jst'].render;

    this.friends = [];

    this.requestSuggestions(this.options.initialSuggestions);

    // FIXME: REMOVE THIS WHEN BACKEND READY
    this.friends = [,,,,,,,,,,,];

    this.logic();
    
    $.pub('b_suggested_friends_init');

    return this;
};
S.blockSuggestedFriends.prototype.logic = function() {
    var that = this;

    var handleAddFriend = function(e) {
        e && S.e(e);
        var item = $(this).parents('.b-s-f-item');

        $.ajax({
            url: S.urls.friends,
            data: { userid: item.data('userid') },// yum yum num num
            type: 'PUT',
            dataType: 'json'
        });

        that.updateList(item);
    };

    var handleRemoveSuggestion = function(e) {
        e && S.e(e);
        var item = $(this).parents('.b-s-f-item');

        $.ajax({
            url: S.urls.friends,
            data: { userid: item.data('userid') },// yum yum num num
            type: 'DELETE',
            dataType: 'json'
        });

        that.updateList(item);
    };

    var handleListReload = function() {
        that.updateList(that.els.list.find('.b-s-f-item'));
    };

    this.els.list.on('click', '.b-s-f-add', handleAddFriend);
    this.els.list.on('click', '.b-s-f-remove', handleRemoveSuggestion);
    this.els.reload.on('click', handleListReload);

    return this;
};

S.blockSuggestedFriends.prototype.updateList = function(els) {
    var count = els.length,
        i = 0,
        newItems = '';

    for (; i < count; i++) {
         newItems += this.template(this.friends.shift());
    }

    els.remove();

    this.els.list.append(newItems);

    if (this.friends.length < this.options.minSize) {
        this.requestSuggestions(this.options.packetSize);
    }
};
S.blockSuggestedFriends.prototype.requestSuggestions = function(num) {
    if ((typeof this.deferred !== 'undefined') && (this.deferred.readyState !== 4)) {
        this.deferred.abort();
    }

    num = num || 1;

    var that = this;

    var handleRequestSuccess = function(resp) {
        if ('status' in resp && resp.status === 'success'){
            _.union(that.friends, rest.friends);
        }
        else {
            handleRequestFailed();
        }
    };

    var handleRequestFailed = function() {
        if (that.deferred.readyState === 0) { // Cancelled request, still loading
            return;
        }
        // NOT SUPPOSED TO HAPPEN EVER
        S.log('[S.blockSuggestedFriends.requestSuggestions]: bullix req faild');
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
