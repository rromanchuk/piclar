MEDIA_BUNDLES = (
#
#   Mobile CSS collections
#
    ('mobile-global.css',  # base global collection
      'mobile/css/s.reset.css',

      'mobile/css/s.base.scss',
      'mobile/css/f.format.scss',

      'mobile/css/m.inputs.scss',
      'mobile/css/m.buttons.scss',
      'mobile/css/m.validate.scss',
      'mobile/css/m.textarea.autogrow.scss',

      'mobile/css/s.layout.scss',
      'mobile/css/s.overlay.scss',

      'mobile/css/b.activity_feed.scss',

      'mobile/css/p.login.scss',
      'mobile/css/p.login_oauth.scss',
      'mobile/css/p.index.scss',

      'mobile/css/p.comments.scss',
        ),

    ('mobile-global.js',  # base global collection
      'mobile/js/templates/m.validate.error.jst',
      'mobile/js/templates/p.comment.jst',

      'mobile/js/libs/zepto.js',
      'mobile/js/libs/zepto.onpress.js',
      'mobile/js/libs/zepto.pubsub.js',
      'mobile/js/libs/zepto.scroll.js',
      'js/mbp.helpers.js',

      'mobile/js/s.js',
      'mobile/js/s.utils.js',

      'mobile/js/m.validate.js',
      'mobile/js/m.textarea.autogrow.js',

      'mobile/js/s.overlay.js',

      'mobile/js/p.login.js',
      'mobile/js/p.login_oauth.js',
      # 'mobile/js/p.index.js',

      'mobile/js/p.comments.js',

      'mobile/js/s.pagesmanager.js',
        ),
)
