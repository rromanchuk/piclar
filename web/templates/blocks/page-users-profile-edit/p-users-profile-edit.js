(function($){
    var form = $('.p-u-p-e-form'),
        select = form.find('.m-input-select'),

        dayInput = form.find('.p-u-r-b_day'),
        monthInput = form.find('.p-u-r-b_month'),
        yearInput = form.find('.p-u-r-b_year');

    var checkDay = function() {
        var val = +this.value,
            year = yearInput.val();

        if (!this.value.length || !year.length) {
            return;
        }

        return val <= S.utils.getDaysNum(+year, +monthInput.val() - 1);
    };

    var checkYear = function() {
        var val = +this.value;

        return this.value.length ? (val < S.now.getFullYear()) : true;
    };

    select.m_inputSelect();
    form.m_validate({
        validations: {
            b_day: checkDay,
            b_year: checkYear
        },
        isDisabled: true
    });
})(jQuery);
