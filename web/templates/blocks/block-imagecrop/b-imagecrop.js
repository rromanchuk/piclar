// @require 'js/jquery.Jcrop.js'

(function($){
S.blockImageCrop = function(settings) {
    this.options = $.extend({
        minSize: 640,
        maxSize: 800
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
    this.imageData = {};

    this.jcrop = false;

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

        that.renderImage({
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

S.blockImageCrop.prototype.renderImage = function(attrs) {
    var that = this;

    var initImageData = function() {
        that.imageData = {
            width: that.els.image[0].width,
            height: that.els.image[0].height
        };

        that.scaleImage() && imageReady();
    };

    var imageReady = function() {
        that.els.result.append(that.els.image);
        that.els.block.addClass('loaded');

        that.initJcrop();
    };

    this.els.image.on('load', initImageData);
    this.els.image.attr(attrs);
};

S.blockImageCrop.prototype.scaleImage = function() {
    var ratio = this.imageData.width / this.imageData.height,

        scaleR,
        scaledW,
        scaledH;

    if ((this.imageData.width < this.options.minSize) && (this.imageData.height < this.options.minSize)) {
        if (this.imageData.width < this.imageData.height) {
            scaledW = this.options.minSize;
            scaledH = (scaledW / ratio) | 0;
        }
        else {
            scaledH = this.options.minSize;
            scaledW = (scaledH * ratio) | 0;
        }

        this.scaleImageUp(scaledW, scaledH);

        return false;
    }

    if (this.imageData.width > this.options.maxSize) {
        scaledW = this.options.maxSize;
        scaledH = (scaledW / ratio) | 0;
    }

    if (this.imageData.width > this.imageData.height) {
        scaleR = this.imageData.height / this.options.minSize;
    }
    else {
        scaleR = this.imageData.width / this.options.minSize;
    }

    this.imageData.scaledWidth = scaledW;
    this.imageData.scaledHeight = scaledH;
    this.imageData.scaleRatio = scaleR;

    this.imageData.center = [(this.imageData.width / 2) | 0, (this.imageData.height / 2) | 0];

    return true;
};

S.blockImageCrop.prototype.scaleImageUp = function(w, h) {
    var canvas = $('<canvas width="' + w + '" height="' + h + '" />'),
        ctx = canvas[0].getContext('2d');

    ctx.drawImage(this.els.image[0], 0, 0, this.imageData.width, this.imageData.height, 0, 0, w, h);

    // updating SRC element causes load event to fire again
    // effectively rerendeting the image and calling initImageData at the same time
    this.els.image.attr('src', canvas[0].toDataURL());
};

S.blockImageCrop.prototype.initJcrop = function() {
    var that = this;

    var handleSelectedArea = function(c) {
        console.log(c);
    };

    this.els.image.Jcrop({
        boxWidth: this.imageData.scaledWidth,
        boxHeight: this.imageData.scaledHeight,
        trueSize: [this.imageData.width, this.imageData.height],
        aspectRatio: 1,
        onSelect: handleSelectedArea,
        minSize:[
            this.options.minSize,
            this.options.minSize
        ],
        setSelect: [
            this.imageData.center[0] - (this.options.minSize / 2),
            this.imageData.center[1] - (this.options.minSize / 2),
            this.imageData.center[0] + (this.options.minSize / 2),
            this.imageData.center[1] + (this.options.minSize / 2)
        ]
    },function(){
        that.jcrop = this;
    });
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

