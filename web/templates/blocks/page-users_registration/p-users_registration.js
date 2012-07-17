(function($){
    var form = S.DOM.content.find('.p-r-form'),
        button = form.find('button');

    form.m_validate();

    button.removeAttr('disabled');
})(jQuery);
