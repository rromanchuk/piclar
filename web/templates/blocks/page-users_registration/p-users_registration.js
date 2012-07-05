(function($){
    var vk = S.DOM.content.find('#p-users_registration_vk'),
        vkWinSettings = 'menubar=yes,toolbar=yes,location=yes,resizable=yes,scrollbars=yes,status=yes';

    var handleOAUTH = function(e) {
        e.preventDefault();

        window.open(this.getAttribute('href'), 'VK Аутенфикация', vkWinSettings);
    };

    vk.on('click', handleOAUTH);
})(jQuery);
