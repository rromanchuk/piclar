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
    };

    var save = function() {
        S.sstore.set('s_router', env);
        $.pub('router_save', env);
    };

    var goBack = function() {
        var url,
            historyLen = env.history.length;

        if (historyLen === 0 || current === env.history[historyLen - 1]) {
            url = S.urls.index;
            S.log('[S.router.goBack]: Going to index, no better match');
        }
        else {
            url = env.history.pop();
        }

        env.isBack = true;
        save();

        $.pub('router_back', url);

        window.location.href = url;
    };

    var manageHistory = function() {
        var historyLen = env.history.length;

        if (historyLen && current === env.history[historyLen - 1]) {
            // just reloaded a page
            return;
        }

        if (env.isBack) {
            env.isBack = false;
            save();
            S.log('[S.router.goBack]: Navigated back');
        }
        else {
            env.history.push(current);

            if (historyLen + 1 > limit) { // just added one item, compensating
                env.history.shift();
            }

            save();

            S.log('[S.router.goBack]: Page stored in history stack');
        }
    };

    load();
    manageHistory();

    $.pub('router_init', current);

    return {
        load: load,
        save: save,
        back: goBack,
        env: env
    };
}();
