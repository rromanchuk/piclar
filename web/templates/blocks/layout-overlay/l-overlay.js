S.overlay = (function() {
    var overlay = $('#l-overlay'),
        holder = overlay.find('.l-overlay-content'),
        parts = holder.children('section.l-o-part'),

        isActive = false,

        options;

// ======================================================================================
// Basic overlay functions
// ======================================================================================

    var show = function(settings) {
        if (isActive) {
            return;
        }

        options = $.extend({}, settings);
        $.pub('l_overlay_beforeshow', options);

        if (options.block) {
            parts.filter('.active').removeClass('active');
            parts.filter(options.block).addClass('active');
        }

        overlay.addClass('active');
        isActive = true;

        $.pub('l_overlay_show', options);
    };

    var hide = function() {
        if (!isActive) {
            return;
        }

        $.pub('l_overlay_beforehide', options);

        overlay.removeClass('active');
        isActive = false;

        $.pub('l_overlay_hide', options);
    };

    var load = function(url, template) {
        var handleLoadSuccess = function(res) {
            holder.append(template(res));
            parts = holder.children('section.l-o-part');
            $.pub('l_overlay_load_success', { url: url, template: template });
        };

        var handleLoadError = function() {
            S.notifications.show({
                type: 'error',
                text: 'Произошла ошибка при обращении к серверу. Пожалуйста, попробуйте еще раз.'
            });
            $.pub('l_overlay_load_error', { url: url, template: template });
        };

        $.ajax({
            url: props.url,
            dataType: 'json',
            type: 'GET',
            success: handleLoadSuccess,
            error: handleLoadError
        });

        $.pub('l_overlay_load', { url: url, template: template });
    };

    var add = function(html, id) {
        if (parts.filter(id).length) {
            S.log('[S.overlays.add]: part "' + id + '" already exists.');
            return;
        }

        var el = (typeof html === 'object') ? html : $(html);

        holder.append(el);
        el.wrap('<section class="l-o-part ' + id.substr(1) + '" />');

        parts = holder.children('section.l-o-part');

        $.pub('l_overlay_add', { html: html, id: id });
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

    holder.on('click', '.l-overlay-close', hide);
    overlay.on('click', handleMisClick);
    S.DOM.doc.on('keydown', handleKeypress);

    $.pub('l_overlay_ready');

    return {
        show: show,
        hide: hide,
        load: load,
        add: add,
        layer: overlay,
        parts: parts,
        active: function() {
            return isActive;
        }
    };
})();
