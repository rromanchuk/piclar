(function($){
    var form = $('.p-u-p-e-form'),

        imagePreview = form.find('.p-u-p-e-photoimg'),
        imageInput = form.find('.p-u-p-e-photoinput'),

        select = form.find('.m-input-select'),

        dayInput = form.find('.p-u-r-b_day'),
        monthInput = form.find('.p-u-r-b_month'),
        yearInput = form.find('.p-u-r-b_year');

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
        return (/\.(?:jpeg|jpg|png|tiff)$/.test(this.value));
    };

    var handleImageClick = function() {
        imageInput.trigger('click');
    };

    if (window.FileReader) {
        var rFilter = /^(?:image\/jpg|image\/jpeg|image\/png|image\/tiff)$/i;

        var handleImgChange = function() {
            var file = this.files[0];

            if (rFilter.test(file.type)) {
                var reader = new FileReader();

                reader.onload = function(e) {
                    imagePreview[0].src = e.target.result;
                };
                reader.readAsDataURL(file);
            }
        };

        imageInput.on('change', handleImgChange);
    }

    imagePreview.on('click', handleImageClick);

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
