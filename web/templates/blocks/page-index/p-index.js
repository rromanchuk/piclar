// @require 'blocks/layout-overlay/l-overlay.js'

(function($) {
    var page = S.DOM.content,
        login = page.find('.p-i-h-i-links-login'),

        slider = page.find('.p-i-h-slides'),
        slides = slider.find('.p-i-h-slide'),
        slideWidth = slides.eq(0).outerWidth(),

        animDuration = 200,
        waitDuration = 3000,

        activeSlide = 0,
        sliderActive = false,

        tid;

    var handleLogin = function(e) {
        S.e(e);
        S.overlay.show({block: '.b-login-form'});
    };

    var animateSlider = function() {
        if (!sliderActive) return; // extra check

        tid && window.clearTimeout(tid);

        if (++activeSlide >= slides.length) activeSlide = 0;

        slider.animate({
            left: -(activeSlide * slideWidth)
        }, animDuration, 'linear');

        tid = window.setTimeout(animateSlider, waitDuration + animDuration);
    };

    var activateSlider = function() {
        sliderActive = true;

        animateSlider();
    };

    var deactivateSlider = function() {
        sliderActive = false;

        tid && window.clearTimeout(tid);
    };

    var startSlider = function() {
        slider.css({
            width: slides.length * slideWidth
        });

        activateSlider();

        $.sub('l_overlay_hide', activateSlider);
        $.sub('l_overlay_show', deactivateSlider);

        slider.on('mouseleave', activateSlider);
        slider.on('mouseenter', deactivateSlider);

        if (/*@cc_on!@*/false) {
            document.onfocusin = activateSlider;
            document.onfocusout = deactivateSlider;
        }
        else {
            window.onfocus = activateSlider;
            window.onblur = deactivateSlider;
        }
    };

    login.on('click', handleLogin);
    S.DOM.win.on('load', startSlider);
    S.overlay.subscribe('.b-login-form', { block: '.b-login-form' });
})(jQuery);
