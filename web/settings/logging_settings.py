# A sample logging configuration. The only tangible logging
# performed by this configuration is to send an email to
# the site admins on every HTTP 500 error when DEBUG=False.
# See http://docs.djangoproject.com/en/dev/topics/logging for
# more details on how to customize your logging configuration.

import os.path

LOGGING_DIR = '/var/log/social/'

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'filters': {
        'require_debug_false': {
            '()': 'django.utils.log.RequireDebugFalse'
        }
    },
    'formatters': {
        'verbose': {
            'format': 'P%(process)d;%(levelname)s;%(asctime)s;%(module)s;%(message)s'
        },
    },
    'handlers': {
        'mail_admins': {
            'level': 'ERROR',
            'filters': ['require_debug_false'],
            'class': 'django.utils.log.AdminEmailHandler'
        },
        'sentry': {
            'level': 'WARNING',
            'class': 'raven.contrib.django.handlers.SentryHandler',
        },
        'console_verbose': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
            'stream': 'ext://sys.stdout',
        },
        'social_log_file': {
            'level': 'DEBUG',
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': os.path.join(LOGGING_DIR, "django.log"), # each developer of DEV has it's own log
            'maxBytes': '16777216', # 16megabytes
            'formatter': 'verbose'
        },
    },
    'loggers': {
        'django': {
            'handlers': ['console_verbose'],
            'level': 'INFO',
            'propagate': True,
            },

        'web' : {
            'handlers': ['console_verbose', 'social_log_file'],
            'level': 'INFO',
            'propagate': True,
        },
        'debug-request': {
            'handlers': ['console_verbose'],
            'level': 'INFO',
            'propagate': True,
        }

    },
}
