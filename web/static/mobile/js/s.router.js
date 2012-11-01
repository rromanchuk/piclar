;S.router = function() {
    var env,
        limit = 10,
        current = window.location.pathname;

    var load = function() {
        env = S.sstore.get('s_router');

        if (!env) {
            env = {};
            env.history = [];
            env.isBack = false;

            S.log('[S.router.load]: Created new router');
        }

        $.pub('router_load', env);
        return env;
    };

    var save = function() {
        S.sstore.set('s_router', env);
        $.pub('router_save', env);
        return env;
    };

    var reset = function() {
        env = {};
        env.history = [];
        env.isBack = false;

        S.sstore.set('s_router', env);
        $.pub('router_reset', env);

        window.location.reload();
        return env;
    };

    var goBack = function() {
        var url,
            historyLen = env.history.length;

        if (historyLen < 2) {
            url = S.urls.index;
            env.history.length = 0;
            S.log('[S.router.goBack]: No previous entries in history');
        }
        else if (current === env.history[historyLen - 2]) {
            url = S.urls.index;
            env.history.splice(-2);
            S.log('[S.router.goBack]: Tried to go to the same page. Trying to fix.');
        }
        else {
            url = env.history[historyLen - 2];
            env.history.splice(-2);
        }

        env.isBack = true;
        save();

        S.log('[S.router.goBack]: Going to: ' + url);
        $.pub('router_back', url);

        window.location.href = url;
        return url;
    };

    var manage = function() {
        var historyLen = env.history.length;

        if (historyLen && current === env.history[historyLen - 1]) {
            S.log('[S.router.manage]: Noticed a page reload');
            return;
        }

        if (historyLen > 1 && current === env.history[historyLen - 2]) {
            env.history.splice(-1);
            S.log('[S.router.manage]: Went back using back button');
            return;
        }

        if (env.isBack) {
            env.isBack = false;
            S.log('[S.router.manage]: Navigated back');
        }

        env.history.push(current);

        if (historyLen + 1 > limit) { // just added one item, compensating
            env.history.shift();
        }

        save();

        S.log('[S.router.manage]: Page stored in history stack');

        return current;
    };

    load();
    manage();
    
    $.pub('router_init', current);

    return {
        load: load,
        save: save,
        reset: reset,
        back: goBack,
        env: env
    };

    // if (('standalone' in window.navigator) && !window.navigator.standalone) {
    //     return {
    //         load: load,
    //         save: save,
    //         reset: reset,
    //         back: goBack,
    //         env: env
    //     };
    // }
    // else {
    //     var noop = function() {};

    //     return {
    //         load: noop,
    //         save: noop,
    //         reset: noop,
    //         back: function() {
    //             window.history.go(-1);
    //         },
    //         env: {}
    //     };
    // }

}();
