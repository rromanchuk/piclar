// @require 'blocks/block-subscriptions/b-subscriptions.js'

(function($){
    window.x = new S.blockSubscriptions({
        data: S.data.subscriptions
    }).init();
})(jQuery);
