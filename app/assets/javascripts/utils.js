// Precached DOM elements
app.dom = {};
app.dom.win = $(window);
app.dom.doc = $(document);
app.dom.html = $('html');
app.dom.body = $('body');

app.browser = {
    isOpera: ('opera' in window),
    isFirefox: (navigator.userAgent.indexOf('Firefox') !== -1),
    isIOS: (function() {
        if (!$.os.ios) {
            return false;
        }

        if(/OS [2-4]_\d(_\d)? like Mac OS X/i.test(navigator.userAgent)) {
            return navigator.userAgent.match(/OS ([2-4])_\d(_\d)? like Mac OS X/i)[1];
        } else if(/CPU like Mac OS X/i.test(navigator.userAgent)) {
            return 1;
        } else {
            return navigator.userAgent.match(/OS ([5-9])(_\d)+ like Mac OS X/i)[1];
        }

        return 0;
    })(),
    isAndroid: $.os.android ? parseInt(/Android\s([\d\.]+)/g.exec(navigator.appVersion)[1], 10) : false,
    isIE: (function() {
        if (!!document.all) {
            if (!!window.atob) return 10;
            if (!!document.addEventListener) return 9;
            if (!!document.querySelector) return 8;
            if (!!window.XMLHttpRequest) return 7;
        }

        return false;
    })(),
    isTouchDevice: $.os.touch
};
app.now = new Date();

// Global utility functions
app.log = function() {
    if (app.env.debug && 'console' in window) {
        (arguments.length > 1) ? console.log(Array.prototype.slice.call(arguments)) : console.log(arguments[0]);
    }
};
app.plog = function(o) {
    if (app.env.debug && 'console' in window) {
        var out = '';
        for (var p in o) {
           out += p + ': ' + o[p] + '\n';
        }
        console.log(out);
    }
};
app.e = function(e) {
    (typeof e.preventDefault === 'function') && e.preventDefault();
    (typeof e.stopPropagation === 'function') && e.stopPropagation();
};
