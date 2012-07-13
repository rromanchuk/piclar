;S.utils = {};

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
    if (S.browser.isAndroid) {
        var ver = /Android\s([\d\.]+)/g.exec(navigator.appVersion)[1];
        
        if (ver >= '4') {
            return function(x, y) {
                return 'translate3d(' + x + ', ' + y + ', 0)';
            };
        }
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

// S.utils.dateToYMD = function(date) {
//     return date.getFullYear() + '-' + ('0' + (date.getMonth() + 1)).slice(-2) + '-' + ('0' + date.getDate()).slice(-2);
// };
// S.utils.YMDToDate = function(ymd) {
//     var darr = ymd.split('-');
//     return new Date(+darr[0], +darr[1] - 1, +darr[2]);
// };
// S.utils.YMDToDateMonth = function(ymd) {
//     var darr = ymd.split('-');
//     return new Date(+darr[0], +darr[1] - 1, 1);
// };
// S.utils.getWeeksNum = function(year, month) {
//     var daysNum = S.utils.getDaysNum(year, month),
//         fDayO = new Date(year, month, 1).getDay(),
//         fDay = fDayO ? (fDayO - 1) : 6,
//         weeksNum = Math.ceil((daysNum + fDay) / 7);
//     return weeksNum;
// };
// S.utils.getDaysNum = function(year, month) { // nMonth is 0 thru 11
//     return 32 - new Date(year, month, 32).getDate();
// };
// S.utils.getDaysDiff = function(date1, date2) {
//     return Math.abs((+date1 - +date2) / (1000 * 60 * 60 * 24));
// };