(function($){
S.blockNotifications = function(settings) {
    this.options = $.extend({
    }, settings);

    this.els = {};
};

S.blockNotifications.prototype.init = function() {
    this.els.block = $('.b-notifications');
    this.els.sign = this.els.block.find('.b-n-sign');
    this.els.count = this.els.sign.find('.b-n-counter-num');
    
    this.seen = false;
    this.active = false;

    this.logic();
    
    $.pub('b_notifications_init');

    return this;
};

S.blockNotifications.prototype.logic = function() {
    var that = this;
    
    var handleToggleBlock = function(e) {
        S.e(e);

        if (that.active) {
            that.hide();
        }
        else {
            that.show();
        }
    };

    var handleMisClick = function(e) {
        if (that.active) {
            !$(e.target).parents('.b-n-dropdown').length && that.hide();
        }
    };

    this.els.sign.on('click', handleToggleBlock);
    S.DOM.doc.on('click', handleMisClick);

    return this;
};

S.blockNotifications.prototype.show = function() {
    this.els.block.addClass('active');
    this.active = true;

    return this;
};

S.blockNotifications.prototype.hide = function() {
    this.els.block.removeClass('active');
    this.active = false;

    this.seen || this.markSeen();

    return this;
};

S.blockNotifications.prototype.markSeen = function() {
    this.els.block.addClass('seen');
    this.els.block.find('.b-n-list-item.unseen').removeClass('unseen');
    this.els.count.html(0);
    this.seen = true;

    return this;
};

})(jQuery);
