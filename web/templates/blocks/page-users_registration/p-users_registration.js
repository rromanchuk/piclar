(function($){
    var vk = S.DOM.content.find('#p-users_registration_vk'),
        vkWinSettings = 'menubar=yes,toolbar=yes,location=yes,resizable=yes,scrollbars=yes,status=yes',
        vkWin;


    var handleVkWinClose = function() {
        alert(1)
        //window.location.reload();
    };

    var handleOAUTH = function(e) {
        e.preventDefault();

        vkWin = window.open(this.getAttribute('href'), 'VK Аутенфикация', vkWinSettings);
        vkWin.onclose = handleVkWinClose;
    };

    vk.on('click', handleOAUTH);
})(jQuery);
