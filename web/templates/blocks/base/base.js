// @require 'js/jquery.js'

// @require 'js/jquery.pubsub.js'
// @require 'js/jquery.os.js'
// @require 'js/jquery.cookie.js'
// @require 'js/underscore.js'
// @require 'blocks/base/base.utils.js'
// @require 'blocks/module-textarea-autogrow/m-textarea-autogrow.js'
// @require 'blocks/module-validate/m-validate.js'
// @require 'blocks/module-input-select/m-input-select.js'

// Precached DOM elements
S.DOM = {};
S.DOM.win = $(window);
S.DOM.doc = $(document);
S.DOM.html = $('html');
S.DOM.header = $('#l-header');
S.DOM.footer = $('#l-footer');
S.DOM.content = $('#l-content');

// All module objects stored here
S.modules = {};

// Setting up environment for CSS
S.DOM.html.removeClass('no-js').addClass('js');

S.browser.isOpera   && S.DOM.html.addClass('opera');
S.browser.isFirefox && S.DOM.html.addClass('firefox');
S.browser.isIE      && S.DOM.html.addClass('ie ie' + S.browser.isIE);
S.browser.isIOS     && S.DOM.html.addClass('ios ios' + S.browser.isIOS);
S.browser.isAndroid && S.DOM.html.addClass('android android' + S.browser.isAndroid);

$.ajaxSetup({
    beforeSend: function(xhr, settings) {
        xhr.setRequestHeader("X-CSRFToken", $.cookie('csrftoken'));
    }
});
