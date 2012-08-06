(function($){
    var feedback = S.DOM.footer.find('.l-f-feedback');

    var handleFeedback = function(e) {
        S.e(e);
        S.overlay.show({ block: '.b-feedback-form' });
    };

    var handleFeedbackSent = function() {
        S.overlay.hide();
    };

    feedback.on('click', handleFeedback);
    $.sub('b_feedback_success', handleFeedbackSent);
})(jQuery);
