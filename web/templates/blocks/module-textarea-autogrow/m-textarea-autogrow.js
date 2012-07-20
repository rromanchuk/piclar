;(function($) {
    var handleTextarea = function(i, elem) {
        var el = $(elem),

            textarea = el.find('.m-t-a-textarea'),
            pusher = el.find('.m-t-a-pusher'),

            limited = el.hasClass('limited'),
            limit = textarea.attr('maxlength');
        
        var handleTextareaUpdate = function(e) {
            if (limited) {
                this.value = this.value.substring(0, limit);
            }

            var val = this.value.trim() || this.getAttribute('placeholder');
            pusher.text(val);
        };
        
        textarea.on('input keydown', handleTextareaUpdate);
        
        handleTextareaUpdate.call(textarea[0]);
    };

    $.fn.m_textareaAutogrow = function(options) {
        this.each(handleTextarea);
    };
})(jQuery);
