S.overlay = (function() {
    var overlay = $('#l-overlay'),
        holder = overlay.find('.l-overlay-content'),
        parts = holder.children('section.l-o-part'),

        isActive = false,
        scrolled = 0,

        hasHistory = 'pushState' in window.history,
        isInternalAction = false,
        isPopStateAction = false,
        prefix = '#overlay/',
        subscribedParts = [],
        subscribedOptions = [],

        options;

// ======================================================================================
// Basic overlay functions
// ======================================================================================

    var show = function(settings) {
        if (isActive) {
            return;
        }

        options = $.extend({
            hash: ''
        }, settings);
        $.pub('l_overlay_beforeshow', options);

        if (options.block) {
            parts.filter('.active').removeClass('active');
            parts.filter(options.block).addClass('active');
        }

        overlay.addClass('active');
        isActive = true;

        scrolled = S.DOM.win.scrollTop();
        S.DOM.win.on('scroll', preventScroll);

        if (hasHistory && !isPopStateAction) {
            isInternalAction = true;
            window.location.hash = prefix + options.block + (options.hash ? '/' + options.hash : '');
        }
        isPopStateAction = false;

        $.pub('l_overlay_show', options);
    };

    var hide = function() {
        if (!isActive) {
            return;
        }

        $.pub('l_overlay_beforehide', options);

        overlay.removeClass('active');
        isActive = false;

        S.DOM.win.off('scroll', preventScroll);

        if (hasHistory || !isPopStateAction) {
            isInternalAction = true;
            window.location.hash = '';
        }
        isPopStateAction = false;

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

    var getPartFromHash = function(part) {
        return part.replace(prefix, '');
    };
    var isProperHash = function() {
        return window.location.hash.indexOf(prefix) >= 0;
    };
    var isCurrentPart = function(part) {
        return window.location.hash.indexOf(part) >= 0;
    };

    var preventScroll = function() {
        S.DOM.win.scrollTop(scrolled);
    };

    var handleKeypress = function(e) {
        (e.keyCode === 27) && hide();
    };

    var handleMisClick = function(e) {
        $(e.target).is(holder) && hide();
    };

    var handlePopState = function(e) {
        var part = getPartFromHash(window.location.hash);

        if (isInternalAction) {
            isInternalAction = false;
            return;
        }

        if (!isActive && part) {
            isPopStateAction = true;
            
            S.log('[S.overlays.handlePopState]: dispatching popshow for ' + part);
            $.pub('l_overlay_popshow', part);
            handleSubscriptions(part);

            isInternalAction = false;
        }
        else {
            isPopStateAction = true;

            S.log('[S.overlays.handlePopState]: dispatching pophide');
            $.pub('l_overlay_pophide');

            hide();
            
            isInternalAction = false;
        }
    };

    var subscribeHashChange = function(part, options) {
        subscribedParts.push(part);
        subscribedOptions.push(options);
    };

    var handleSubscriptions = function(part) {
        var index = _.indexOf(subscribedParts, part);

        if (index >= 0) {
            if (isActive) {
                isPopStateAction = true;
                hide();
                isInternalAction = false;
                isInternalAction = false;
            }
            show(subscribedOptions[index]);
        }
    };

    if (window.location.hash && !isProperHash()) {
        hasHistory = false; // dont mess up existing hash
    }

    holder.on('click', '.l-overlay-close', hide);
    overlay.on('click', handleMisClick);
    S.DOM.doc.on('keydown', handleKeypress);
    hasHistory && S.DOM.win.on('popstate', handlePopState);

    if (hasHistory && isProperHash()) {
        S.DOM.win.on('load', handlePopState);
    }

    $.pub('l_overlay_ready');

    return {
        getPart: getPartFromHash,
        isPart: isCurrentPart,
        subscribe: subscribeHashChange,
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
