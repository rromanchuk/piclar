(function($){
    var vk = $('.b-vklogin'),

        vkHref = vk.attr('href'),
        vkWinSettings = 'width=605,height=605,menubar=yes,toolbar=no,location=yes,resizable=yes,scrollbars=yes,status=yes',

        vkWin;

    // var handlePopupCheck = function() {
    //     if (S.utils.isPopupBlocked(vkWin)) {
    //         window.location.href = vkHref;
    //     }
    // };

    var handleOAUTH = function(e) {
        e.preventDefault();

        vkWin = window.open(vkHref, 'vkauth', vkWinSettings);

        // setTimeout(handlePopupCheck, 3000);
    };

    vk.on('click', handleOAUTH);
})(jQuery);
