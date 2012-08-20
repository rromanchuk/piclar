;(function($) {
    var handleTextarea = function(i, elem) {
        var el = $(elem),

            textarea = el.find('.m-t-a-textarea'),
            pusher = el.find('.m-t-a-pusher'),

            limited = el.hasClass('limited'),
            limit = textarea.attr('maxlength'),

            bullet = '<span class="m-t-a-invisible">.</span>',

            breakSign = '{{BREAK}}',

            lineRegexp = new RegExp('\r?\n', 'g'),
            breakRegexp = new RegExp(breakSign, 'g');

        var sanitize = function(str) {
            return $('<div/>').text(str).html();
        };
        
        var handleTextareaUpdate = function(e) {
            var val = this.value;

            if (limited) {
                this.value = val.substring(0, limit);
            }

            if (val.length) {
                val = sanitize(val.replace(lineRegexp, breakSign)).replace(breakRegexp, '<br>') + bullet;
            }
            else {
                if (document.activeElement === textarea[0]) {
                    val = bullet;
                }
                else {
                    val = sanitize(this.getAttribute('placeholder'));
                }
                
            }
            
            pusher.html(val);
        };
        
        textarea.on('input keydown focus blur', handleTextareaUpdate);
        
        handleTextareaUpdate.call(textarea[0]);
    };

    $.fn.m_textareaAutogrow = function(options) {
        this.each(handleTextarea);
    };
})(jQuery);
