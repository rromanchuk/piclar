// @require 'blocks/block-subscriptions/b-subscriptions.jst'

(function($){
S.blockSubscriptions = function(settings) {
    this.options = $.extend({
        data: [],
        step: 15
    }, settings);

    this.els = {};
};

S.blockSubscriptions.prototype.init = function() {
    this.els.block = $('.b-subscriptions');
    this.els.list = this.els.block.find('.b-s-list');

    this.els.controls = this.els.block.find('.b-s-controls');

    this.els.addstep = this.els.controls.find('.b-s-showmore');
    this.els.addall = this.els.controls.find('.b-s-showall');

    this.els.step = this.els.controls.find('.b-s-stepcount');
    this.els.count = this.els.controls.find('.b-s-subcount');

    this.data = this.options.data;
    this.step = this.options.step;

    this.rendered = 0;

    this.count = this.data.length;

    this.template = MEDIA.templates['blocks/block-subscriptions/b-subscriptions.jst'].render;

    this.els.count.html(this.count);

    this.logic();
    this.itemsLogic();

    this.render(this.step);

    $.pub('b_subscriptions_init');

    return this;
};

S.blockSubscriptions.prototype.logic = function() {
    var that = this;

    var handleAddStep = function(e) {
        S.e(e);

        that.render(that.step);
    };

    var handleAddAll = function(e) {
        S.e(e);

        that.render(that.count);
    };

    this.els.addstep.on('click', handleAddStep);
    this.els.addall.on('click', handleAddAll);

    return this;
};

S.blockSubscriptions.prototype.itemsLogic = function() {
    var that = this;

    var handleError = function() {
        S.notifications.show({
            type: 'warning',
            text: 'Не удалось обновить список подписок на сервере. Пожалуйста, попробуйте еще раз.'
        });
    };

    var handleRequest = function(e) {
        S.e(e);

        var el = $(this),
            item = el.parents('.b-s-item'),

            subscribe = el.hasClass('b-s-i-subscribe');

        $.ajax({
            url: S.urls.subscriptions,
            data: { userid: item.data('userid'), action: subscribe ? 'POST' : 'DELETE' },
            type: 'POST',
            dataType: 'json',
            error: handleError
        });

        if (subscribe) {
            item.removeClass('follower').addClass('following');
        }
        else {
            item.removeClass('following').addClass('follower');
        }
    };

    this.els.list.on('click', '.b-s-i-subscribe', handleRequest);
    this.els.list.on('click', '.b-s-i-unsubscribe', handleRequest);
};

S.blockSubscriptions.prototype.render = function(num) {
    num = num || this.step;

    var html = '',

        i = this.rendered,
        max = this.rendered + num,
        end = max > this.count ? this.count : max,

        remainder = this.count - end;


    for (; i < end; i++) {
        context = this.data[i]
        context.is_profile_owner = this.options.is_profile_owner
        html += this.template(context);
    }

    this.rendered = end;
    this.els.list.append(html);

    if (remainder <= 0) {
        this.disableControls();
    }

    if (remainder > this.step) {
        this.els.step.html(this.step);
    }
    else {
        this.els.step.html(remainder);
    }

    $.pub('b_subscriptions_render', this.rendered);
};

S.blockSubscriptions.prototype.disableControls = function() {
    this.els.controls.addClass('disabled');
};

})(jQuery);
