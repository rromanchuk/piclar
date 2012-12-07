// @require 'js/jquery.Jcrop.js'
// @require 'js/jquery.exif.js'

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

    this.els.image = $('<img class="b-i-preview" />');
    this.imageData = {};

    this.jcrop = false;
    this.originalImage = null;
    this.cropped = {};

    this.logic();

    $.pub('b_imagecrop_init');

    return this;
};

S.blockImageCrop.prototype.readFiles = function(files) {
    var file = files[0],

        that = this;

    var exifReady = function(result) {
        if (result.gps && result.gps.latitude && result.gps.longitude) {
            that.originalImage.gps = {
                lat: result.gps.latitude.value,
                lng: result.gps.longitude.value
            };
        }

        if (result.tiff && result.tiff.Orientation) {
            that.originalImage.rotation = that.getRotationDegree(result.tiff.Orientation.value);
        }

        that.renderImage();
    };

    if (file && file.type.match('image.*')) {
        this.originalImage = {
            src: window.URL.createObjectURL(file),
            title: escape(file.name),
            rotation: 0,
            gps: null
        };
        $.parseEXIF(file, exifReady);
    }
    else {
        this.showError('Выберите изображение корректного формата, например JPG, JPEG, PNG.');
    }

    $.pub('b_imagecrop_reading_files');
};
S.blockImageCrop.prototype.getRotationDegree = function(num) {
    if (num >= 8) {
        return 270;
    }

    if (num >= 6) {
        return 90;
    }

    if (num >= 3) {
        return 180;
    }

    return 0;
};

S.blockImageCrop.prototype.renderImage = function() {
    var that = this,
        rotation = that.originalImage.rotation;

    var initImageData = function() {
        that.imageData = {
            width: that.els.image[0].width,
            height: that.els.image[0].height,
            original: that.originalImage
        };

        if (rotation > 0) {
            that.fixRotation();
            rotation = 0;
            return;
        }

        that.scaleImage() && imageReady();
    };

    var imageReady = function() {
        that.els.result.append(that.els.image);
        that.els.block.addClass('loaded');

        that.initJcrop();
    };

    this.els.image.on('load', initImageData);
    this.els.image.attr(this.originalImage);

    $.pub('b_imagecrop_rendering');
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

    $.pub('b_imagecrop_scaled');

    return true;
};

S.blockImageCrop.prototype.fixRotation = function() {
    var cw = this.imageData.width,
        ch = this.imageData.height,

        cx = 0,
        cy = 0,

        degree = this.originalImage.rotation;

    // Calculate new canvas size and x/y coorditates for image
    switch (degree) {
        case 90:
            cw = this.imageData.height;
            ch = this.imageData.width;
            cy = this.imageData.height * (-1);
            break;
        case 180:
            cx = this.imageData.width * (-1);
            cy = this.imageData.height * (-1);
            break;
        case 270:
            cw = this.imageData.height;
            ch = this.imageData.width;
            cx = this.imageData.width * (-1);
            break;
    }

    var canvas = $('<canvas width="' + cw + '" height="' + ch + '" />'),
        ctx = canvas[0].getContext('2d');

    // Rotate image
    ctx.rotate(S.utils.toRad(degree));
    ctx.drawImage(this.els.image[0], cx, cy);

    // updating SRC element causes load event to fire again
    // effectively rerendeting the image and calling initImageData at the same time
    this.els.image.attr('src', canvas[0].toDataURL());

    $.pub('b_imagecrop_rotation');
};

S.blockImageCrop.prototype.scaleImageUp = function(w, h) {
    var canvas = $('<canvas width="' + w + '" height="' + h + '" />'),
        ctx = canvas[0].getContext('2d');

    ctx.drawImage(this.els.image[0], 0, 0, this.imageData.width, this.imageData.height, 0, 0, w, h);

    // updating SRC element causes load event to fire again
    // effectively rerendeting the image and calling initImageData at the same time
    this.els.image.attr('src', canvas[0].toDataURL());

    $.pub('b_imagecrop_zooming');
};

S.blockImageCrop.prototype.initJcrop = function() {
    var that = this;

    var handleSelectedArea = function(c) {
        if (c.x < 0) {
            c.w += c.x;
            c.x = 0;
        }

        if (c.y < 0) {
            c.h += c.y;
            c.y = 0;
        }

        c.w = Math.max(c.w, that.options.minSize);
        c.h = Math.max(c.h, that.options.minSize);

        that.cropped = c;

        $.pub('b_imagecrop_cropped');
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

    $.pub('b_imagecrop_jcrop_ready');
};

S.blockImageCrop.prototype.showError = function(msg) {
    this.els.error.text(msg).addClass('active');
};
S.blockImageCrop.prototype.hideError = function() {
    this.els.error.removeClass('active');
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
    var proxyClick = function(e) {
        S.e(e);
        that.els.input.trigger('click');
    };
    var removeDragAndDropHandlers = function() {
        S.DOM.doc.off('dragenter dragover', handleDragOver);
        S.DOM.doc.off('drop', handleDrop);
    };

    this.els.input.val().length && this.els.input.val('');

    S.DOM.doc.on('dragenter dragover', handleDragOver);
    S.DOM.doc.on('drop', handleDrop);
    this.els.input.on('change', handleInputChange);
    this.els.dropzone.on('click', proxyClick);
    $.sub('b_imagecrop_reading_files', removeDragAndDropHandlers);

    return this;
};

})(jQuery);

