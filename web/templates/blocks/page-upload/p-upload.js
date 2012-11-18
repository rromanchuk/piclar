// @require 'blocks/block-imagecrop/b-imagecrop.js'
// @require 'blocks/block-imagefilters/b-imagefilters.js'

(function($) {
    var page = S.DOM.content,

        steps = page.find('.p-u-step'),
        actions = page.find('.p-u-action');







    var crop = new S.blockImageCrop(),
        filters = new S.blockImageFilters();

    crop.init();
    filters.init();

    var activateFilters = function() {
        filters.setImage({
            image: crop.image
        });
    };

    $.sub('b_imagecrop_ready', activateFilters);

    steps.on('click', function() {
        var el = $(this);

        steps.filter('.active').removeClass('active');
        actions.filter('.active').removeClass('active');

        el.addClass('active');
        actions.filter('[data-step="' + el.data('step') + '"]').addClass('active');
    });

    steps.eq(1).trigger('click');

    window.f = filters;
})(jQuery);
