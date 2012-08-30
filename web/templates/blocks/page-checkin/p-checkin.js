// @require 'blocks/block-story-full/b-story-full.js'

(function($){
    var page = S.DOM.content,
        content = page.find('.p-c-content'),

        photo = content.find('.b-s-f-image'),

        overlayPart = '.p-c-photo-view',
        overlay = S.overlay.parts.filter(overlayPart),

        height = S.DOM.win.height() - 20;

    if (height > 660) {
        height = 640;
    }

    var handlePhotoClick = function(e) {
        S.e(e);

        overlay.html('<img src="' + this.getAttribute('src') + '" style="width: ' + height + 'px; height: ' + height + 'px;" />');
        S.overlay.show({
            block: overlayPart
        });
    };

    var handleOverlayClick = function(e) {
        S.e(e);
        S.overlay.hide();
    };

    new S.blockStoryFull({
        elem: content.find('.b-story-full')
    }).init();

    photo.css({ cursor: 'pointer' });
    photo.on('click', handlePhotoClick);
    overlay.on('click', 'img', handleOverlayClick);
})(jQuery);
