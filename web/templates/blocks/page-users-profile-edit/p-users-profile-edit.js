(function($){
    var form = $('.p-u-p-e-form'),

        imageWrap = form.find('.p-u-p-e-photowrap'),
        imageInput = form.find('.p-u-p-e-photoinput'),
        imageSize = imageWrap.width(),

        select = form.find('.m-input-select'),

        dayInput = form.find('.p-u-r-b_day'),
        monthInput = form.find('.p-u-r-b_month'),
        yearInput = form.find('.p-u-r-b_year'),

        hasFileAPI = (typeof window.FileReader !== 'undefined');

    var checkDay = function() {
        var val = +this.value,
            year = yearInput.val();

        if (isNaN(+year)) {
            return true;
        }

        return val <= S.utils.getDaysNum(+year, +monthInput.val() - 1);
    };

    var checkYear = function() {
        var val = +this.value;

        return this.value.length ? (val < S.now.getFullYear()) : true;
    };

    var checkExtension = function() {
        if (!this.value) return true;
        else return (/\.(?:jpeg|jpg|png|tiff)$/.test(this.value));
    };

    var handleImageClick = function() {
        imageInput.trigger('click');
    };

    if (hasFileAPI) {
        var rFilter = /^(?:image\/jpg|image\/jpeg|image\/png|image\/tiff)$/i;
        var reader = new window.FileReader();

        var showUpdateError = function() {
            S.notifications.show({
                type: 'info',
                text: 'Не удалось распознать изображение'
            });
        };

        var updateImage = function(e) {
            var img = new Image(),
                span = $('<span class="p-u-p-e-photoimg" />'),
                w, h, x;

            img.src = e.target.result;

            setTimeout(function() {// lets chill for a little bit
                w = img.width;
                h = img.height;

                if (!w && !h) return; // WTF?

                if (w > h) {
                    x = (w / h) * imageSize;

                    span.css({
                        'background': 'url("' + e.target.result + '") no-repeat center center',
                        'background-size': x + 'px ' + imageSize + 'px'
                    });
                }
                else {
                    x = (h / w) * imageSize;

                    span.css({
                        'background': 'url("' + e.target.result + '") no-repeat center center',
                        'background-size': imageSize + 'px ' + x + 'px'
                    });
                }

                imageWrap.html(span);
                imageWrap.removeClass('changed');
            }, 100);

            return true;
        };

        var scanImage = function() {
            var file = imageInput[0].files[0];

            if (rFilter.test(file.type)) {
                reader.onload = function(e) {
                    if (!updateImage(e)) {
                        showUpdateError();
                    }
                };

                reader.onerror = function(e) {
                    showUpdateError();
                };
                reader.readAsDataURL(file);
            }
        };

        imageInput[0].value && scanImage();
    }

    var handleImgChange = function() {
        imageWrap.addClass('changed');

        hasFileAPI && scanImage();
    };

    S.browser.isIE || imageWrap.on('click', handleImageClick);
    imageInput.on('change', handleImgChange);

    select.m_inputSelect();
    form.m_validate({
        validations: {
            b_day: checkDay,
            b_year: checkYear,
            photo: checkExtension
        },
        isDisabled: true
    });
})(jQuery);
