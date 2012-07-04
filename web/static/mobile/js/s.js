;OTA.browser = {
    isOpera: ('opera' in window),
    isFirefox: (navigator.userAgent.indexOf('Firefox') !== -1),
    isIOS: !!$.os.ios,
    isAndroid: !!$.os.android,
    isTouchDevice: $.os.touch
};
OTA.now = new Date();

// Global utility functions
OTA.log = function() {
    if (OTA.settings.DEBUG && 'console' in window) {
        (arguments.length > 1) ? console.log(Array.prototype.slice.call(arguments)) : console.log(arguments[0]);
    }
};
OTA.plog = function(o) {
    if (OTA.settings.DEBUG && 'console' in window) {
        var out = '';
        for (var p in o) {
           out += p + ': ' + o[p] + '\n';
        }
        console.log(out);
    }
};
OTA.e = function(e) {
    (typeof e.preventDefault !== 'undefined') && e.preventDefault();
    (typeof e.stopPropagation !== 'undefined') && e.stopPropagation();
};
(function() {
    var _storageInterface = function(storage) {
        storage = window[storage];

        return {
            set: function(key, val) {
                storage.setItem(key, JSON.stringify(val));
            },
            get: function(key) {
                var data = storage.getItem(key);
                return data ? JSON.parse(data) : false;
            },
            has: function(key) {// Avoid at all costs. dead slow
                return !!storage.getItem(key);
            },
            remove: function(key) {
                storage.removeItem(key);
            }
        };
    };
    
    OTA.store = _storageInterface('localStorage');
    OTA.sstore = _storageInterface('sessionStorage');
})();

// Precached DOM elements
OTA.DOM = {};
OTA.DOM.win = $(window);
OTA.DOM.doc = $(document);
OTA.DOM.html = $('html');

// All module objects stored here
OTA.modules = {};

// Setting up environment for CSS
OTA.DOM.html.removeClass('no-js').addClass('js');

OTA.browser.isOpera   && OTA.DOM.html.addClass('opera');
OTA.browser.isFirefox && OTA.DOM.html.addClass('firefox');
OTA.browser.isIOS     && OTA.DOM.html.addClass('ios');
OTA.browser.isAndroid && OTA.DOM.html.addClass('android');

// Browser oddities compensation
MBP.scaleFix();
MBP.hideUrlBarOnLoad();
MBP.enableActive();
OTA.browser.isIOS && MBP.preventZoom();