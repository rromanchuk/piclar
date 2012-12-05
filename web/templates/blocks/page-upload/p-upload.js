// @require 'js/jquery.exif.js'
// @require 'blocks/block-imagecrop/b-imagecrop.js'
// @require 'blocks/block-imagefilters/b-imagefilters.js'

(function($) {
    var page = S.DOM.content,

        steps = page.find('.p-u-step'),
        actions = page.find('.p-u-action'),

        nextButtons = actions.find('.p-u-a-nextlink'),

        toFilters = nextButtons.filter('[data-step="filter"]'),
        toUpload = nextButtons.filter('[data-step="upload"]'),

        reviewBlock = actions.filter('.p-u-review'),

        resultWrap = reviewBlock.find('.p-u-r-imagewrap'),
        form = reviewBlock.find('.p-u-r-form'),
        textarea = reviewBlock.find('.m-textarea-autogrow'),
        stars = reviewBlock.find('.m-input-stars'),
        saveButton = reviewBlock.find('.p-u-a-save'),

        exif = null,

        deferred;

    var crop = new S.blockImageCrop(),
        filters = new S.blockImageFilters();

    var handleCropped = function() {
        toFilters.removeClass('disabled');
    };

    var handleFiltered = function() {
        toUpload.removeClass('disabled');
    };

    var exifReady = function(result) {
        exif = result;
    };

    var handleChangeToFilters = function() {
        if (toFilters.hasClass('disabled')) return;

        steps.filter('.active').removeClass('active');
        actions.filter('.active').removeClass('active');

        steps.filter('[data-step="filter"]').addClass('active');
        actions.filter('[data-step="filter"]').addClass('active');

        filters.setImage({
            elem: crop.els.image,
            cx: crop.cropped.x,
            cy: crop.cropped.y,
            width: crop.cropped.w,
            height: crop.cropped.h
        });

        $.fileExif(crop.originalImage, exifReady);
    };

    var handleChangeToUpload = function() {
        if (toUpload.hasClass('disabled')) return;

        steps.filter('.active').removeClass('active');
        actions.filter('.active').removeClass('active');

        steps.filter('[data-step="upload"]').addClass('active');
        actions.filter('[data-step="upload"]').addClass('active');

        resultWrap.html('');
        resultWrap.append(filters.getFilteredImage());
        resultWrap.append('<input type="hidden" name="image" value="' + filters.getFilteredData() + '">');
    };

    var uploadReady = function() {
        saveButton.removeAttr('disabled');
    };

    var successHandler = function (resp) {
        form.removeClass('loading');
        saveButton.removeAttr('disabled');

        console.log('SUKSESS');// prob forward browser somewhere on this step, like your brand new checkin etc
    };
    var errorHandler = function (resp) {
        form.removeClass('loading');
        saveButton.removeAttr('disabled');

        S.notifications.presets['server_failed']();
    };

    var performRequest = function() {
        if ((typeof deferred !== 'undefined') && (deferred.readyState !== 4)) {
            deferred.abort();
        }

        resultWrap.addClass('loading');
        saveButton.attr('disabled', 'disabled');

        deferred = $.ajax({
            url: form.attr('action'),
            data: form.serialize(),
            // dataType: 'json',
            // processData: false,
            // contentType: false,
            type: form.attr('method').toUpperCase(),
            success: successHandler,
            error: errorHandler
        });
    };

    var saveResult = function(event, e) {
        S.e(e);
        performRequest();
    };

    toFilters.on('click', handleChangeToFilters);
    toUpload.on('click', handleChangeToUpload);
    stars.one('modchange', uploadReady);
    form.on('valid', saveResult);
    
    $.sub('b_imagecrop_jcrop_ready', handleCropped);
    $.sub('b_imagefilters_imageset', handleFiltered);

    crop.init();
    filters.init();

    textarea.m_textareaAutogrow();
    stars.m_inputStars();

    form.m_validate({ isDisabled: true });
})(jQuery);
