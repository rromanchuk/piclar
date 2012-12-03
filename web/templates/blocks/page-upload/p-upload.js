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

        resultWrap = page.find('.p-u-r-imagewrap'),

        exif = null;

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
    };

    crop.init();
    filters.init();

    toFilters.on('click', handleChangeToFilters);
    toUpload.on('click', handleChangeToUpload);
    
    $.sub('b_imagecrop_jcrop_ready', handleCropped);
    $.sub('b_imagefilters_imageset', handleFiltered);

})(jQuery);


// (function() {
//     var formdata = new FormData(),
//         req,
//         deferred,

//         timestamp = +(new Date()),
//         timeout,

//         ready_files = [],

//         errors_cont = j_form.find('.status .error'),
//         progress_bar = j_form.find('.progress_wrap i'),

//         file_label = j_s_label2.find('.dropdown-current'),

//         button = j_form.find('button');

//     button.attr('disabled', 'disabled');

//     var setFileName = function (name) {
//         file_label.text(name);
//     };

//     var successHandler = function (resp) {
//         j_form.removeClass('loading');
//         //button.removeAttr('disabled');

//         ready_files = [];

//         input.val(''); // reset input
//         inputMoikrug.val(''); // reset inputMoikrug
//         setFileName('Прикрепите резюме'); // reset label

//         j_form.addClass('form_ready');
//     };
//     var errorHandler = function (resp) {
//         var msg = '';

//         $.each(resp.value, function(k, arr) {
//             arr.length && (msg += arr.join('<br/>'));
//         });

//         showError(msg);

//         j_form.removeClass('loading');
//         button.removeAttr('disabled');
//     };

//     var performRequest = function() {
//         if ((typeof deferred !== 'undefined') && (deferred.readyState !== 4)) {
//             deferred.abort();
//         }

//         formdata.append(j_select.attr('name'), j_select.val());

//         j_form.addClass('loading');
//         button.attr('disabled', 'disabled');

//         deferred = $.ajax({
//             url: j_form.attr('action'),
//             data: formdata,
//             dataType: 'json',
//             processData: false,
//             contentType: false,
//             type: j_form.attr('method').toUpperCase()
//         });

//         req = deferred.pipe(
//             function(response) {// Success pre-handler
//                 if (('status' in response) && (response.status !== 'error')){
//                     return response;
//                 } else {
//                     // The response is actually a FAIL even though it
//                     // came through as a success (200). Convert this
//                     // promise resolution to a FAIL.
//                     return $.Deferred().reject(response);
//                 }
//             },
//             function(response) {// Fail pre-handler
//                 return {
//                     status: 'failed',
//                     value: 'Произошел сбой соединения. Пожалуйста, повторите попытку.'
//                 };
//             }
//         );
//         req.then(successHandler, errorHandler);
//     };

//     var readFiles = function (files) {
//         var i = 0,
//             len = files.length,
//             reader,
//             file;

//         for (; i < len; i++ ) {
//             file = files[i];

//             if (/\.(?:rtf|doc|docx|html|htm|txt|pdf)$/.test(file.name)) {
//                 if (window.FileReader) {
//                     reader = new FileReader();

//                     reader.onloadend = function(e) {
//                         hideProgress();
//                         setFileName(OTA.utils.shortenString(file.name, 23));
//                         ready_files.push(file.name);

//                         j_select.val().length && button.removeAttr('disabled');
//                     };

//                     reader.onerror = function(e) {
//                         showError('Возникла ошибка при распознании файла, попробуйте еще раз.');
//                     };

//                     reader.onprogress = function(e) {
//                         showProgress(Math.round((e.loaded * 100) / e.total));
//                     };

//                     reader.readAsBinaryString(file);
//                 }

//                 if (formdata) {
//                     formdata.append('files[]', file);
//                 }
//             }
//             else {
//                 showError('Подходят только следующие типы файлов: rtf, doc, docx, html, htm, txt, pdf.');
//             }
//         }
//     };

//     var showError = function(msg) {
//         errors_cont.html(msg);
//         j_form.addClass('errors');
//     };

//     var hideError = function() {
//         j_form.removeClass('errors');
//     };

//     var showProgress = function(perc) {
//         if (perc >= 100) {
//             hideProgress();
//         }
//         else {
//             progress_bar.css({ left: '-' + (100 - perc) + '%' });
//         }
//     };

//     var hideProgress = function() {
//         progress_bar.css({ left: '-100%' });
//     };

//     var showNotice = function() {
//         j_form.addClass('droppable');

//         clearTimeout(timeout);
//         timeout = setTimeout(hideNotice, 2000);
//     };

//     var hideNotice = function() {
//         j_form.removeClass('droppable');
//     };

//     var validateUrl = function() {
//         var regexp = /(http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
//         if (regexp.test(inputMoikrug.val())) {
//             button.removeAttr('disabled');
//             if (formdata) {
//                 formdata.append('jobs-moikrug', inputMoikrug.val());
//             }
//         } else {
//             showError('Введите валидную ссылку на профиль');
//             button.attr('disabled', 'disabled');
//         };
//     };

//     input.bind('change', function (e) {
//         hideError();
//         readFiles(this.files);
//     });
//     inputMoikrug.bind('change', function (e) {
//         hideError();
//         validateUrl();
//     });

//     j_form.bind('submit', function(e) {
//         e.preventDefault();

//         // Validation...
//         if (!input.val().length && !ready_files.length && !inputMoikrug.val().length) {
//             showError('Выберите файл для загрузки или ссылку на профиль в Моем Круге.');
//             return;
//         }

//         if (!j_select.val().length) {
//             showError('Выберите вакансию.');
//             return;
//         }

//         hideError();
//         performRequest();
//     });

//     document.addEventListener('dragenter', function(e) {
//         OTA.utils.evtNoop(e);

//         if (+(new Date()) - timestamp < 100) {
//             return;
//         }

//         timestamp = +(new Date());
//         showNotice();
//     }, false);
//     document.addEventListener('dragover', function(e) {
//         OTA.utils.evtNoop(e);

//         if (+(new Date()) - timestamp < 100) {
//             return;
//         }

//         timestamp = +(new Date());
//         showNotice();
//     }, false);
//     document.addEventListener('drop', function (e) {
//         e = e || window.event;

//         OTA.utils.evtNoop(e);

//         var files = (e.files || e.dataTransfer.files);

//         readFiles(files);
//     }, false);

// }());
