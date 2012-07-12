;S.loading = function () {
    var layer = $('#l-loading'),
        msg = layer.children('.l-loading-message'),
        
        loadingTxt = msg.data('loading'),
        errorTxt = msg.data('error'),
        successTxt = msg.data('success');

    return {
        start: function() {
            msg.html(loadingTxt);
            layer.css({ display: 'block' })
                 .animate({ opacity: 1 }, 200, 'ease-in', function() {
                     $.pub('loading_shown');
                 });
        },
        stop: function() {
            layer.animate({ opacity: 0 }, 200, 'ease-in', function() {
                layer.css({ display: 'none' });
                $.pub('loading_hidden');
            });
        },
        error: function() {
            msg.html(errorTxt);
        },
        success: function() {
            msg.html(successTxt);
        },
        message: msg
    };
}();

S.overlay = function() {
    var layer = $('#l-overlay'),
        close = layer.find('.l-overlay-close'),

        inputs = layer.find('input, select, textarea'),

        transform = S.browser.isOpera ? false : S.utils.supports('transform'),
        settings,
        isAnimated = false,
        isVisible = false,
        isFromOnStateChange = false,
        hasHistory = 'pushState' in window.history && !window.location.hash,
        pagePos = 0;
        
    if (!layer.length) {
        return {
            layer: null
        };
    }
    
    var handleKeyboard = function() {
        var factor = function(e, i) {
            e.blur();
        };
        inputs.forEach(factor);
    };

    var animateOverlayShow = function() {
        if (transform) {
            return function() {
                var props = {};
                isAnimated = true;

                // TODO: make this shorter
                switch (settings.slide) {
                    case 'up':
                        props[transform] = S.utils.translate(0, '-100%');
                        layer.css({
                                left: 0,
                                top: '100%'
                            });
                        break;

                    case 'right':
                        props[transform] = S.utils.translate('100%', 0);
                        layer.css({
                                left: '-100%',
                                top: 0
                            });
                        break;

                    case 'down':
                        props[transform] = S.utils.translate(0, '100%');
                        layer.css({
                                left: 0,
                                top: '-100%'
                            });
                        break;

                    case 'left':
                        props[transform] = S.utils.translate('-100%', 0);
                        layer.css({
                                left: '100%',
                                top: 0
                            });
                        break;
                }
                layer.animate(props, settings.duration, 'ease', animationShowEnd);
            };
        }
        else {
            return function() {
                isAnimated = true;
                switch (settings.slide) {
                    case 'up':
                        layer.css({
                                left: 0,
                                top: '100%'
                            })
                            .animate({ top: 0 }, settings.duration, 'ease', animationShowEnd);
                        break;

                    case 'right':
                        layer.css({
                                left: '-100%',
                                top: 0
                            })
                            .animate({ left: 0 }, settings.duration, 'ease', animationShowEnd);
                        break;

                    case 'down':
                        layer.css({
                                left: 0,
                                top: '-100%'
                            })
                            .animate({ top: 0 }, settings.duration, 'ease', animationShowEnd);
                        break;

                    case 'left':
                        layer.css({
                                left: '100%',
                                top: 0
                            }).animate({ left: 0 }, settings.duration, 'ease', animationShowEnd);
                        break;
                }
            };
        }
    }();
    var animateOverlayHide = function() {
        if (transform) {
            return function() {
                var props = {};
                isAnimated = true;
                
                props[transform] = S.utils.translate(0, 0);
                layer.animate(props, settings.duration, 'ease', animationHideEnd);
            };
        }
        else {
            return function() {
                isAnimated = true;
                switch (settings.slide) {
                    case 'up':
                        layer.animate({ top: '100%' }, settings.duration, 'ease', animationHideEnd);
                        break;

                    case 'right':
                        layer.animate({ left: '-100%' }, settings.duration, 'ease', animationHideEnd);
                        break;

                    case 'down':
                        layer.animate({ top: '-100%' }, settings.duration, 'ease', animationHideEnd);
                        break;

                    case 'left':
                        layer.animate({ left: '100%' }, settings.duration, 'ease', animationHideEnd);
                        break;
                }
            };
        }
    }();
    
    var animationShowEnd = function() {
        isAnimated = false;
        isVisible = true;

        settings.className.length && S.DOM.html.addClass(settings.className);
        $.pub('overlay_show_end');
    };
    var animationHideEnd = function() {
        isAnimated = false;
        resetOverlay();

        $.pub('overlay_hide_end');
        isVisible = false;

    };
    var resetOverlay = function() {
        close.removeClass('changed');
        layer.css({
            left: '-100%',
            top: '-100%'
        });
    };
    
    var changeLabel = function() {
        close.addClass('changed');
    };
    
    var show = function(options) {
        if (isAnimated) {
            S.log('[S.overlay.show]: Already animating layer!');
            return;
        }

        settings = $.extend({
            slide: 'left',
            duration: 200,
            closable: true,
            scrollable: true,
            hideContent: true,
            
            className: ''
        }, options);
        
        if (settings.closable) {
            settings.className += ' has_overlay';
        }
        
        if (settings.hideContent) {
            settings.className += ' hide_main_cont';
        }
        
        settings.scrollable || S.DOM.doc.on('touchmove', S.e);

        pagePos = (document.body.scrollTop === 0 || document.body.scrollTop === 1) ? 0 : document.body.scrollTop;
        pagePos && S.utils.scroll();
        
        $.pub('overlay_show_start');
        animateOverlayShow();
        
        // If the browser supports push states, add overlay state which will respond to back button
        // presses and properly close the overlay modal
        hasHistory && window.history.pushState({overlay: 'true'}, document.title, "#overlay");

    };
    
    var hide = function(e) {
        e && S.e(e);
        settings.className.length && S.DOM.html.removeClass(settings.className);
        //contentWrap.prepend(contentBlock);
        
        // Hides keyboard and other inputs
        handleKeyboard();
        
        pagePos && S.utils.scroll(pagePos);
        settings.scrollable || S.DOM.doc.off('touchmove', S.e);
    
        $.pub('overlay_hide_start');
        animateOverlayHide();
        // Since we dont support showing the overlay on backbutton press, let's pop the history stack
        // to not mess up the user's back button 
        if ((hasHistory && location.hash) || (hasHistory && !isFromOnStateChange)) {
            window.history.go(-1);
            isFromOnStateChange = false;
        }
    };
    
    var handlePopState = function(e) {
        isFromOnStateChange = true; 
        isVisible && S.overlay.hide();
    };
    
    transform && layer.css(transform, S.utils.translate(0, 0));
    close.onpress(hide);
    
    $.pub('overlay_ready');
    hasHistory && S.DOM.win.on('popstate', handlePopState);
    return {
        layer: layer,
        show: show,
        hide: hide,
        changed: changeLabel
    };
}();
