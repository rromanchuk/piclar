;(function($) {
    var handleTextarea = function(i, elem) {
        var el = $(elem),

            textarea = el.find('.m-t-a-textarea'),
            pusher = el.find('.m-t-a-pusher'),

            limited = el.hasClass('limited'),
            limit = textarea.attr('maxlength'),

            breakSign = '{{BREAK}}',

            lineRegexp = new RegExp('\r?\n', 'g'),
            breakRegexp = new RegExp(breakSign, 'g');

        var sanitize = function(str) {
            return $('<div/>').text(str).html();
        };
        
        var handleTextareaUpdate = function(e) {
            if (limited) {
                this.value = this.value.substring(0, limit);
            }

            var val = this.value || this.getAttribute('placeholder');

            val = sanitize(val.replace(lineRegexp, breakSign)).replace(breakRegexp, '<br>');
            pusher.html(val);
        };
        
        textarea.on('input keydown', handleTextareaUpdate);
        
        handleTextareaUpdate.call(textarea[0]);
    };

    $.fn.m_textareaAutogrow = function(options) {
        this.each(handleTextarea);
    };
})(jQuery);
