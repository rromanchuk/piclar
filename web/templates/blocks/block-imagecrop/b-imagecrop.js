// @require 'blocks/layout-overlay/l-overlay.js'

(function($){
S.blockImageCrop = function(settings) {
    this.options = $.extend({
    }, settings);

    this.els = {};
};

S.blockImageCrop.prototype.init = function() {
    this.els.block = $('.b-imagecrop');
    
    this.els.upload = this.els.block.find('.b-i-upload');
    this.els.result = this.els.block.find('.b-i-result');

    this.els.input = this.els.upload.find('.b-i-fileinput');
    this.els.dropzone = this.els.upload.find('.b-i-dropzone');
    this.els.error = this.els.upload.find('.b-i-error');

    this.els.progress = this.els.result.find('.b-i-progress');

    this.els.image = $('<img class="b-i-preview" />');

    this.logic();

    $.pub('b_imagecrop_init');

    return this;
};

S.blockImageCrop.prototype.readFiles = function(files) {
    var that = this,

        i = 0,
        len = files.length,

        file,
        reader;

    var end = function(e) {
        that.hideProgress();

        that.showImage({
            src: e.target.result,
            title: escape(file.name)
        });
    };

    var error = function(e) {
        that.showError('Возникла ошибка при распознании файла, попробуйте еще раз.');
    };

    var progress = function(e) {
        that.showProgress(Math.round((e.loaded * 100) / e.total));
    };

    for (; i < len; i++) {
        file = files[i];

        if (file.type.match('image.*')) {
            reader = new FileReader();

            reader.onloadend = end;
            reader.onerror = error;
            reader.onprogress = progress;

            reader.readAsDataURL(file);
        }
        else {
            this.showError('Выберите изображение корректного формата, например JPG, JPEG, PNG.');
        }
    }
};

S.blockImageCrop.prototype.showImage = function(attrs) {
    this.els.image.attr(attrs);
    this.els.result.append(this.els.image);
    this.els.block.addClass('.loaded');
};

S.blockImageCrop.prototype.showError = function(msg) {
    this.els.error.text(msg).addClass('active');
};
S.blockImageCrop.prototype.hideError = function() {
    this.els.error.removeClass('active');
};
S.blockImageCrop.prototype.showProgress = function(perc) {
    if (perc >= 100) {
        this.els.progress.html('100%');
    }
    else {
        this.els.progress.html((100 - perc) + '%');
    }
};
S.blockImageCrop.prototype.hideProgress = function() {
    this.els.progress.html('');
};

S.blockImageCrop.prototype.logic = function() {
    var that = this,
        timestamp = Date.now(),
        droppableShown = false,
        timeout;

    var showDroppable = function() {
        if (!droppableShown) {
            that.els.dropzone.addClass('droppable');
            droppableShown = true;

            clearTimeout(timeout);
            timeout = setTimeout(hideDroppable, 1000);
        }
    };

    var hideDroppable = function() {
        if (droppableShown) {
            that.els.dropzone.removeClass('droppable');
            droppableShown = false;
        }
    };

    var handleDragOver = function(e) {
        S.e(e);
        showDroppable();
    };

    var handleDrop = function(e) {
        var files;

        if (e) {
            S.e(e);
            files = (e.originalEvent.files || e.originalEvent.dataTransfer.files);
        }
        else {
            e = window.event;
            files = (e.files || e.dataTransfer.files);
        }

        hideDroppable();
        that.readFiles(files);
    };
    var handleInputChange = function() {
        that.hideError();
        that.readFiles(this.files);
    };

    this.els.input.val().length && this.els.input.val('');

    S.DOM.doc.on('dragenter dragover', handleDragOver);
    S.DOM.doc.on('drop', handleDrop);
    this.els.input.on('change', handleInputChange);

    return this;
};

})(jQuery);

