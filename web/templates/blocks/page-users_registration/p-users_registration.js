(function($){
    var vk = S.DOM.content.find('#p-users_registration_vk');

    var handleOAUTH = function(e) {
        e.preventDefault();

        window.open(this.getAttribute('href'));
    };

    vk.on('click', handleOAUTH);
})(jQuery);
