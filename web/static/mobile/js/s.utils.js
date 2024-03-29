S.browser = {
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
S.url = function(url, params) {
    var matcher = function() {
        return params[+arguments[0].slice(1) - 1];
    };

    return params ? S.urls[url].replace(/(\$\d+)/g, matcher) : S.urls[url];
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
                return data ? JSON.parse(data) : null;
            },
            has: function(key) {// Avoid at all costs. dead slow
                return !!storage.getItem(key);
            },
            remove: function(key) {
                storage.removeItem(key);
            }
        };
    };
    
    S.store = _storageInterface('localStorage');
    S.sstore = _storageInterface('sessionStorage');
})();

S.utils = {};

S.utils.capfirst = function (string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
};

// S.utils.translit = function(charmap, str) {
//     var currentChar;

//     for (var i = 0, l = charmap.length; i < l; i++) {
//         currentChar = charmap[i];
//         str = str.replace(new RegExp(currentChar[0], 'g'), currentChar[1]);
//     }
//     return S.utils.capfirst(str.toLowerCase());
// };

S.utils.makeEnding = function(number, wordForms) {
    var order = number % 100;

    if ((order > 10 && order < 20) || (number === 0)) {
        return wordForms[2];
    }
    else {
        switch (number % 10) {
            case 1: return wordForms[0];
            case 2:
            case 3:
            case 4: return wordForms[1];
            default: return wordForms[2];
        }
    }
};
// Just like the Django filter
S.utils.choosePlural = function (number, endings) {
    return number + ' ' + S.utils.makeEnding.apply(this, arguments);
};

S.utils.unisex = function (number, options) {
    if (number == 2) {
        return options[1];
    }
    else {
        return options[0];
    }
};

S.utils.shortenString = function (str, len, pos) {
    var lim = ((len - 3) / 2) | 0,
        res = str;

    if (str.length > len) {
        switch(pos) {
            case 'left':
                res = '...' + str.slice(3 - len);
                break;
            case 'right':
                res = str.slice(0, len - 3) + '...';
                break;
            default:
                res = str.slice(0, lim) + '...' + str.slice(-lim);
                break;
        }
    }

    return res;
};

S.utils.calculateDistance = function (lat1, lon1, lat2, lon2) {
    var R = 6371; // km
    var dLat = S.utils.toRad(lat2 - lat1);
    var dLon = S.utils.toRad(lon2 - lon1); 
    var a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
          Math.cos(S.utils.toRad(lat1)) * Math.cos(S.utils.toRad(lat2)) * 
          Math.sin(dLon / 2) * Math.sin(dLon / 2); 
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a)); 
    return R * c;
};
S.utils.toRad = function(n) {
    return n * Math.PI / 180;
};
S.utils.formatDistance = function(dist) {
    if (dist > 1) { // dealing with kilometers here
        var km = dist | 0,
            m = ((dist - km) * 1e3) | 0;

        if (m > 0) {
            return S.utils.formatNum(km) + ' км ' + m + ' м';
        }
        else {
            return S.utils.formatNum(km) + ' км';
        }
    }
    else { // only couple meters
        return ((dist * 1e3) | 0) + ' м';
    }
};

S.utils.sanitizeString = function(str) {
    return $('<div/>').text(str).html();
};

S.utils.supports = (function() {
    var div = document.createElement('div'),
        vendors = 'Ms O Moz Webkit'.split(' '),
        len = vendors.length,
        succeeded,
        memo = {};

    return function(prop) {
        var key = prop;

        if (typeof memo[key] !== 'undefined') {
            return memo[key];
        }

        if (typeof div.style[prop] !== 'undefined') {
            memo[key] = prop;
            return memo[key];
        }

        prop = prop.replace(/^[a-z]/, function(val) {
            return val.toUpperCase();
        });

        for (var i = len - 1; i >= 0; i--) {
            if (typeof div.style[vendors[i] + prop] !== 'undefined') {
                succeeded = '-' + vendors[i] + '-' + prop;
                memo[key] = succeeded.toLowerCase();
                return memo[key];
            }
        }

        return false;
    };
})();

S.utils.translate = function() {
    if (S.browser.isAndroid && S.browser.isAndroid >= 4) {
        return function(x, y) {
            return 'translate3d(' + x + ', ' + y + ', 0)';
        };
    }
    
    if (!S.browser.isIOS) {
        return function(x, y) {
            return 'translate(' + x + ', ' + y + ')';
        };
    }
    else {
        return function(x, y) {
            return 'translate3d(' + x + ', ' + y + ', 0)';
        };
    }
}();

S.utils.scroll = function(pos, duration) {
    $.scroll(pos, duration);
};

S.utils.parseURL = function (url) {
    var a =  document.createElement('a');
    a.href = url;
    return {
        source: url,
        protocol: a.protocol.replace(':',''),
        host: a.hostname,
        port: a.port,
        query: a.search,
        params: (function() {
            var ret = {},
                seg = a.search.replace(/^\?/,'').split('&'),
                len = seg.length, i = 0, s;
            for (; i < len; i++) {
                if (!seg[i]) { continue; }
                s = seg[i].split('=');
                ret[s[0]] = s[1];
            }
            return ret;
        })(),
        file: (a.pathname.match(/\/([^\/?#]+)$/i) || [,''])[1],
        hash: a.hash.replace('#',''),
        path: a.pathname.replace(/^([^\/])/,'/$1'),
        relative: (a.href.match(/tps?:\/\/[^\/]+(.+)/) || [,''])[1],
        segments: a.pathname.replace(/^\//,'').split('/')
    };
};

// Price, wrapper, num of remainder chars, delimeter and thousands delimeter
S.utils.formatNum = function(p, w, c, d, t) {
    var n = isNaN(+p) ? 0 : +p,
        c = (typeof c === 'undefined') ? 0 : c,
        d = (typeof d === 'undefined') ? "." : d,
        t = (typeof t === 'undefined') ? " " : t,
        s = n < 0 ? '-' : '',
        i = parseInt(n = Math.abs(+n || 0).toFixed(c), 10) + "",
        j = (j = i.length) > 3 ? j % 3 : 0,
        r;

    if (typeof w === 'string' && w.length > 0) {
        r = s + (j ? i.substr(0, j) + t : '') + i.substr(j).replace(/(\d{3})(?=\d)/g, '$1' + t) + '<' + w + '>' + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : '') + '<\/' + w + '>';
    }
    else {
        r = s + (j ? i.substr(0, j) + t : '') + i.substr(j).replace(/(\d{3})(?=\d)/g, '$1' + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : '');
    }
    
    return r;
};
S.utils.monthLabels = ['январь', 'февраль', 'март', 'апрель',
                           'май', 'июнь', 'июль', 'август', 'сентябрь',
                           'октябрь', 'ноябрь', 'декабрь'];
S.utils.monthLabelsAlt = ['января', 'февраля', 'марта', 'апреля',
                           'мая', 'июня', 'июля', 'августа', 'сентября',
                           'октября', 'ноября', 'декабря'];

S.utils.dateToYMD = function(date) {
    return date.getFullYear() + '-' + ('0' + (date.getMonth() + 1)).slice(-2) + '-' + ('0' + date.getDate()).slice(-2);
};
S.utils.YMDToDate = function(ymd) {
    var darr = ymd.split('-');
    return new Date(+darr[0], +darr[1] - 1, +darr[2]);
};
S.utils.YMDToDateMonth = function(ymd) {
    var darr = ymd.split('-');
    return new Date(+darr[0], +darr[1] - 1, 1);
};
S.utils.getWeeksNum = function(year, month) {
    var daysNum = S.utils.getDaysNum(year, month),
        fDayO = new Date(year, month, 1).getDay(),
        fDay = fDayO ? (fDayO - 1) : 6,
        weeksNum = Math.ceil((daysNum + fDay) / 7);
    return weeksNum;
};
S.utils.getDaysNum = function(year, month) { // nMonth is 0 thru 11
    return 32 - new Date(year, month, 32).getDate();
};
S.utils.getDaysDiff = function(date1, date2) {
    return Math.abs((+date1 - +date2) / (1000 * 60 * 60 * 24));
};
S.utils.getHoursDiff = function(date1, date2) {
    return Math.abs((+date1 - +date2) / (1000 * 60 * 60));
};
S.utils.getMinutesDiff = function(date1, date2) {
    return Math.abs((+date1 - +date2) / (1000 * 60));
};
S.utils.getSecondsDiff = function(date1, date2) {
    return Math.abs((+date1 - +date2) / (1000));
};
S.utils.humanizeTimeSince = function(timestamp) {
    var now = +(new Date()),
        diff = Math.ceil(S.utils.getSecondsDiff(now, timestamp));

    if (!diff) {
        return '<span class="f-humanized-date">сейчас</span>';
    }
    if (diff < 60) {
        return '<span class="f-humanized-date"><b>' + diff + '</b> ' + S.utils.makeEnding(diff, ['секунду', 'секунды', 'секунд']) + ' назад</span>';
    }
    if (diff < 60 * 60) {
        diff = Math.ceil(diff / 60);
        return '<span class="f-humanized-date"><b>' + diff + '</b> ' + S.utils.makeEnding(diff, ['минуту', 'минуты', 'минут']) + ' назад</span>';
    }
    if (diff < 60 * 60 * 24) {
        diff = Math.ceil(diff / (60 * 60));
        return '<span class="f-humanized-date"><b>' + diff + '</b> ' + S.utils.makeEnding(diff, ['час', 'часа', 'часов']) + ' назад</span>';
    }

    var date = new Date(timestamp);

    return '<span class="f-humanized-date"><b>' + date.getDate() + '</b> ' + S.utils.monthLabelsAlt[date.getMonth()] + '</span>';
};
S.utils.formatDateSince = function(dateString) {
    return S.utils.humanizeTimeSince(Date.parse(dateString));
};
S.utils.starMap = [
    '<i class="f-stars">★<s>☆☆☆☆</s></i>',
    '<i class="f-stars">★★<s>☆☆☆</s></i>',
    '<i class="f-stars">★★★<s>☆☆</s></i>',
    '<i class="f-stars">★★★★<s>☆</s></i>',
    '<i class="f-stars">★★★★★</i>'
];
S.utils.formatStars = function(num) {
    num = +num;

    return S.utils.starMap[num - 1];
};
S.utils.categoriesMap = [
    'unknown',
    'hotel',
    'restaurant',
    'attraction',
    'entertainment'
];
S.utils.categorize = function(num) {
    return S.utils.categoriesMap[+num];
};
