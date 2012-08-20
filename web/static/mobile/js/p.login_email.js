S.pages['login_email'] = function() {
    var page = S.DOM.content,
        form = page.find('.p-l-o-form');

    form.mod_validate();
};
