(function($){
S.blockStoryFull = function(settings) {
    this.options = $.extend({
        elem: '.b-story-full'
    }, settings);

    this.els = {};
};

S.blockStoryFull.prototype.init = function() {
    this.els.block = $(this.options.elem);
    this.els.form = this.els.block.find('.b-s-f-c-addnew');

//    this.els.blockTextarea = this.els.form.find('.m-textarea-autogrow');
    this.els.textarea = this.els.blockTextarea.find('.m-t-a-textarea');

    this.logic();
    
    $.pub('b_popular_posts_init');

    return this;
};
S.blockStoryFull.prototype.logic = function() {
    var that = this,
        deferred;

    var handleFormSubmit = function(e) {
        e && S.e(e);

        console.log('sending "' + that.els.textarea.val() + '"');
        //deferred = $.ajax({});
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
