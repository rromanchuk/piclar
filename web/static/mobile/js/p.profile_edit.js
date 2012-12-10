S.pages['profile_edit'] = function() {
    var page = S.DOM.content,
        form = page.find('.p-p-e-form');

    form.m_validate({
        validations: {
            bdaydate: function() {
                var val = this.value;
                if (val.length) {
                    var date = +S.utils.YMDToDate(val),
                        now = +S.now,
                        min = now - (1000 * 60 * 60 * 24 * 365 * 100);

                    return (date > min && date < now);
                }
                return false;
            }
        }
    });
};
