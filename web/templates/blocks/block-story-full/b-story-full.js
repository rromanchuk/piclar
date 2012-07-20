(function($){
S.blockStoryFull = function(settings) {
    this.options = $.extend({
        elem: '.b-story-full',
        csrf: null
    }, settings);

    this.els = {};
};

S.blockStoryFull.prototype.init = function() {
    this.els.block = $(this.options.elem);
    this.els.comments = this.els.block.find('.b-s-f-c-list');

    this.els.form = this.els.block.find('.b-s-f-c-addnew');
    this.els.textarea = this.els.block.find('.m-t-a-textarea');

    this.storyid = this.els.block.data('storyid');

    this.template = MEDIA.templates['blocks/block-story-full/b-story-full-comment.jst'].render;

    this.logic();
    
    $.pub('b_popular_posts_init');

    return this;
};
S.blockStoryFull.prototype.logic = function() {
    var that = this,
        req,
        deferred;

    var addComment = function(msg) {
        var comment = $(that.template({
            message: msg,
            username: S.user.fullname,
            userpic: S.user.picture
        }));

        comment.addClass('temporary');

        that.els.comments.append(comment);
    };

    var removeComment = function() {
        var comment = that.els.comments.children('.temporary'),
            message = comment.find('.b-s-f-c-message').text();

        that.els.textarea.val(message);
        comment.remove();
    };

    var handleFormSuccess = function(resp) {
        if (resp.status === 'ok') {
            // success
            that.els.comments.find('.temporary').removeClass('temporary');
        }
        else {
            // no luck
            handleFormError();
        }
    };

    var handleFormError = function() {
        if (deferred.readyState === 0) { // Cancelled request, still loading
            return;
        }

        removeComment();
    };

    var handleFormSubmit = function(e) {
        e && S.e(e);

        if ((typeof deferred !== 'undefined') && (deferred.readyState !== 4)) {
            deferred.abort();
        }

        var message = that.els.textarea.val();

        deferred = $.ajax({
            url: S.urls.comments,
            data: { message: message, csrf: that.options.csrf, storyid: that.storyid },
            type: 'POST',
            dataType: 'json'
        });

        req = deferred.pipe(
            function(response) {// Success pre-handler
                if (('status' in response && response.status === 'success')){
                    return response;
                } else {
                    // The response is actually a FAIL even though it
                    // came through as a success (200). Convert this
                    // promise resolution to a FAIL.
                    return $.Deferred().reject(response);
                }
            },
            function(response) {// Fail pre-handler
                return {
                    status: 'failed',
                    value: 'Произошел сбой соединения. Пожалуйста, повторите попытку.'
                };
            }
        );

        req.then(handleFormSuccess, handleFormError);

        that.els.textarea.val('');

        addComment(message);
    };

    var handleInput = function(e) {
        if (e.keyCode === 13) {
            S.e(e);
            handleFormSubmit();
        }
    };

    this.els.form.on('submit', handleFormSubmit);
    this.els.textarea.on('keydown', handleInput);

    return this;
};
S.blockStoryFull.prototype.destroy = function() {
    this.els.form.off();
    this.els.textarea.off();
    this.els = {};

    $.pub('b_popular_posts_destroyed');
};

})(jQuery);
