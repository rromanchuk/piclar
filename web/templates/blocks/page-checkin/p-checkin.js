// @require 'blocks/block-story-full/b-story-full.js'
// @require 'blocks/layout-overlay/l-overlay.js'

(function($){
    var page = S.DOM.content,
        content = page.find('.p-c-content'),
        photo = content.find('.b-s-f-image'),

        overlayPart = '.p-c-photo-view',
        overlay = S.overlay.parts.filter(overlayPart),
        overlayImg = overlay.find('.p-c-photo-view-image'),

        imgSize;

    var getBestSize = function() {
        var height = S.DOM.win.height() - 20;

        if (height > 660) {
            height = 640;
        }

        return height;
    };

    var handlePhotoClick = function(e) {
        S.e(e);

        S.overlay.show({
            block: overlayPart
        });
        handleResizeImg();
    };

    var handleOverlayClick = function(e) {
        S.e(e);
        S.overlay.hide();
    };

    var handleResizeImg = function() {
        if (!S.overlay.active()) return;

        imgSize = getBestSize();
        overlayImg.css({
            width: imgSize,
            height: imgSize
        });
    };

    overlayImg.attr('src', photo.attr('src'));
    new S.blockStoryFull({
        elem: content.find('.b-story-full')
    }).init();

    photo.on('click', handlePhotoClick);
    overlay.on('click', handleOverlayClick);
    S.DOM.win.on('resize', handleResizeImg);
    S.overlay.subscribe(overlayPart, { block: overlayPart });
})(jQuery);
