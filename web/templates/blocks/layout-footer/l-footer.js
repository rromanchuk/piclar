(function($){
    var footer = S.DOM.footer,
        feedback = footer.find('.l-f-feedback'),
        mobile = footer.find('.l-f-mobileversion');

    var handleFeedback = function(e) {
        S.e(e);
        S.overlay.show({ block: '.b-feedback-form' });
    };

    var handleFeedbackSent = function() {
        S.overlay.hide();
    };

    var handleMobileClick = function(e) {
        S.e(e);
        window.open(mobile.attr('href'),'Ostronaut','width=320,height=480,menubar=yes,location=yes,resizable=yes,scrollbars=yes,status=yes');
    };

    mobile.on('click', handleMobileClick);
    feedback.on('click', handleFeedback);
    $.sub('b_feedback_success', handleFeedbackSent);
})(jQuery);
