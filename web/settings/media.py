MEDIA_BUNDLES = (
#
#   Mobile CSS collections
#
    ('mobile-global.css',  # base global collection
      'mobile/css/s.reset.css',
      'mobile/css/s.base.scss',
      'mobile/css/s.layout.scss',
        ),

    ('mobile-global.js',  # base global collection
      'mobile/js/libs/zepto.js',
      'mobile/js/libs/zepto.onpress.js',
      'mobile/js/libs/zepto.pubsub.js',
      'mobile/js/libs/zepto.scroll.js',
      'js/mbp.helpers.js',

      'mobile/js/s.js',

      'mobile/js/p.index.js',
      'mobile/js/p.login.js',
      'mobile/js/p.login_oauth.js',
      'mobile/js/p.login_registration.js',

      'mobile/js/s.pagesmanager.js',
        ),
)
