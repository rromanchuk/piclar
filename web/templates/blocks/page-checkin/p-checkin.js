// @require 'blocks/block-story-full/b-story-full.js'

(function($){
    var page = S.DOM.content,
        content = page.find('.p-c-content');

    new S.blockStoryFull({
        elem: content.find('.b-story-full')
    }).init();

})(jQuery);
