;(function($) {
    var dropdownSelect = function(i, elem) {
        var el = $(elem),
            label = el.find('.m-i-s-label'),
            fake = el.find('.m-i-s-fakeinput'),
            sel = el.find('select'),
            opts = sel.find('option'),
            dropdn,
            dropopts;

        var appendDropdown = function() {
            var i, l,
                html = '<ul class="m-i-s-dropdown">',
                current = sel.val();

            for (i = 0, l = opts.length; i < l; i++) {
                html += '<li' + 
                            (current === opts[i].value ? ' class="selected"' : '') + 
                            ' data-value="' + opts[i].value + '">' + 
                            opts[i].innerHTML + 
                        '<\/li>';
            }

            html += '<\/ul>';

            el.append(html);
            dropdn = el.children('.m-i-s-dropdown');
            dropopts = dropdn.children('li');
        };

        var handleDropDn = function(e) {
            e && e.stopPropagation();
            el.toggleClass('active');
        };

        var handleDropDnOpts = function(e) {
            handleDropDn(e);

            dropopts.filter('.selected').removeClass('selected');
            this.className = 'selected';
            sel.val(this.getAttribute('data-value')).trigger('change');
        };

        var handleSelect = function() {
            fake.html(opts.filter('[value="' + this.value + '"]').html());
            el.trigger('modselect');
        };

        var handleBasicClick = function(e) {
            var target = e.target,
                $target = $(target);

            if (el.hasClass('active') && !$target.is(dropdn) && !$target.is(label)) {
                handleDropDn(e);
            }
        };

        appendDropdown();
        label.on('click', handleDropDn);
        dropdn.on('click', 'li', handleDropDnOpts);
        sel.on('change', handleSelect);
        $(document).on('click', handleBasicClick);

        handleSelect.call(sel[0]);
    };

    $.fn.m_inputSelect = function(settings) {
        // var options = $.extend({}, settings);
        this.each(dropdownSelect);
    };
})(jQuery);
