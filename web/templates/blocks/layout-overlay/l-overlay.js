S.overlay = (function() {
    var overlay = $('#l-overlay'),
        holder = overlay.find('.l-overlay-content'),
        parts = holder.children('section.l-o-part'),

        closeBtn = holder.find('.l-overlay-close'),

        isActive = false,

        options;

// ======================================================================================
// Basic overlay functions
// ======================================================================================

    var show = function(settings) {
        if (isActive) {
            return;
        }

        $.pub('l_overlay_beforeshow');

        options = $.extend({}, settings);

        if (options.block) {
            parts.filter('.active').removeClass('active');
            parts.filter(options.block).addClass('active');
        }

        overlay.addClass('active');
        isActive = true;

        $.pub('l_overlay_show');
    };

    var hide = function() {
        if (!isActive) {
            return;
        }

        $.pub('l_overlay_beforehide');

        overlay.removeClass('active');
        isActive = false;

        $.pub('l_overlay_hide');
    };

    var load = function(url, template) {
        var handleLoadSuccess = function(res) {
            parts.append(template(res));
            $.pub('l_overlay_loaded');
        };

        $.ajax({
            url: props.url,
            dataType: 'json',
            method: 'GET',
            success: handleLoadSuccess
        });

        $.pub('l_overlay_load');
    };

// ======================================================================================
// Extra overlay logic
// ======================================================================================

    var handleKeypress = function(e) {
        (e.keyCode === 27) && hide();
    };

    var handleMisClick = function(e) {
        $(e.target).is(holder) && hide();
    };

    closeBtn.on('click', hide);
    overlay.on('click', handleMisClick);
    S.DOM.doc.on('keydown', handleKeypress);

    $.pub('l_overlay_ready');
    return {
        show: show,
        hide: hide,
        load: load,
        layer: overlay,
        parts: parts
    };
})();
