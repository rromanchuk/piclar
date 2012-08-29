from base import *
from logging_settings import *
from media import *

from base import DEBUG
if DEBUG == False:
    # disable logging to sentry on debug
    LOGGING['root']  =  {
        'level': 'WARNING',
        'handlers': ['sentry'],
        },


try:
    from local_settings import *
except ImportError:
    pass