(function($){
S.blockUsersList = function(settings) {
    // this.options = $.extend({}, settings);
    this.els = {};
};

S.blockUsersList.prototype.init = function() {
    this.els.block = $('.b-users_list');
    // this.els.items = this.els.block.find('.b-u-l-item');
    this.els.controls = this.els.block.find('.b-u-l-control');

    this.logic();
    
    $.pub('b_users_list_init');

    return this;
};

S.blockUsersList.prototype.logic = function() {
    var that = this;

    var handleAjaxError = function() {
        S.notifications.show({
            type: 'error',
            text: 'Произошла ошибка при обращении к серверу. Пожалуйста, попробуйте еще раз.'
        });
    };

    var handleUser = function(e) {
        S.e(e);

        var el = $(this),

            item = el.parents('.b-u-l-item'),            
            subscribe = item.hasClass('follower');

        $.ajax({
            url: S.urls.subscriptions,
            data: { userid: item.data('userid'), action: subscribe ? 'POST' : 'DELETE' },
            type: 'POST',
            dataType: 'json',
            error: handleAjaxError
        });

        if (subscribe) {
            item.removeClass('follower').addClass('following');
        }
        else {
            item.removeClass('following').addClass('follower');
        }
    };

    this.els.controls.onpress(handleUser);
};

})(Zepto);
