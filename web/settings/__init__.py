from base import *
from logging_settings import *
from media import *

try:
    from local_settings import *
except ImportError:
    pass

if DEBUG == False:
    # disable logging to sentry on debug
    LOGGING['root']  =  {
        'level': 'WARNING',
        'handlers': ['sentry'],
        },

