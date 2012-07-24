// @require 'blocks/block-story-full/b-story-full.js'

(function($){
S.blockFriendsList = function(settings) {
    this.options = $.extend({}, settings);

    this.els = {};
};

S.blockFriendsList.prototype.init = function() {
    this.els.block = $('.b-friends-list');
    this.els.friends = this.els.block.find('.b-f-l-friend');
    this.els.controls = this.els.friends.find('.b-f-l-friendcontrols');

    this.count = this.els.friends.length;

    this.logic();
   
    $.pub('b_friends_list_init');

    return this;
};
S.blockFriendsList.prototype.logic = function() {
    var that = this;

    var handleRequest = function(e) {
        e && S.e(e);

        var el = $(this),
            item = el.parents('.b-f-l-friend');

        $.ajax({
            url: S.urls.friends,
            data: { userid: item.data('userid') },
            type: el.hasClass('b-f-l-add') ? 'PUT' : 'DELETE',
            dataType: 'json'
        });

        item.fadeOut(300, function() {
            item.remove();
            that.count--;

            if (that.count === 0) {
                that.els.block.addClass('empty');
            }
        });


    };

    this.els.controls.on('click', '.b-f-l-add', handleRequest);
    this.els.controls.on('click', '.b-f-l-remove', handleRequest);

    return this;
};

})(jQuery);
