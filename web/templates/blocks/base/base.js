// @require 'js/augment.js'

// @require 'js/jquery.js'

// @require 'js/jquery.pubsub.js'
// @require 'js/jquery.os.js'
// @require 'js/jquery.cookie.js'
// @require 'js/mbp.helpers.js'
// @require 'js/underscore.js'
// @require 'blocks/base/base.utils.js'
// @require 'blocks/module-textarea-autogrow/m-textarea-autogrow.js'
// @require 'blocks/module-validate/m-validate.js'
// @require 'blocks/module-input-select/m-input-select.js'



;S.browser = {
    isOpera: ('opera' in window),
    isFirefox: (navigator.userAgent.indexOf('Firefox') !== -1),
    isIOS: !!$.os.ios,
    isAndroid: !!$.os.android,
    isTouchDevice: $.os.touch
};
S.now = new Date();

// Global utility functions
S.log = function() {
    if (S.env.debug && 'console' in window) {
        (arguments.length > 1) ? console.log(Array.prototype.slice.call(arguments)) : console.log(arguments[0]);
    }
};
S.plog = function(o) {
    if (S.env.debug && 'console' in window) {
        var out = '';
        for (var p in o) {
           out += p + ': ' + o[p] + '\n';
        }
        console.log(out);
    }
};
S.e = function(e) {
    (typeof e.preventDefault !== 'undefined') && e.preventDefault();
    (typeof e.stopPropagation !== 'undefined') && e.stopPropagation();
};
(function(){
    var _storageInterface = function(storageName) {
        var hasStorage = (function() {
                try {
                    return !!window[storageName].getItem;
                } catch(e) {
                    return false;
                }
            }()),
            session = (storageName === 'sessionStorage'),
            storage = window[storageName];

        if (hasStorage) {
            return {
                set: function(key, val) {
                    storage.setItem(key, JSON.stringify(val));
                },
                get: function(key) {
                    var data = storage.getItem(key);
                    return data ? JSON.parse(data) : false;
                },
                has: function(key) {
                    return !!storage.getItem(key);
                },
                remove: function(key) {
                    storage.removeItem(key);
                }
            };
        }
        else {
            return {
                set: function(key, val) {
                    $.cookie(key, JSON.stringify(val), session ? undefined : { expires: 365 });
                },
                get: function(key) {
                    var data = $.cookie(key);
                    return data ? JSON.parse(data) : false;
                },
                has: function(key) {
                    return !!$.cookie(key);
                },
                remove: function(key) {
                    $.cookie(key, null);
                }
            };
        }
    };

    S.store = _storageInterface('localStorage');
    S.sstore = _storageInterface('sessionStorage');
})();

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
S.browser.isIOS     && S.DOM.html.addClass('ios');
S.browser.isAndroid && S.DOM.html.addClass('android');

// Browser oddities compensation
MBP.scaleFix();
MBP.enableActive();
S.browser.isIOS && MBP.preventZoom();

$.ajaxSetup({
    beforeSend: function(xhr, settings) {
        xhr.setRequestHeader("X-CSRFToken", $.cookie('csrftoken'));
    }
});
