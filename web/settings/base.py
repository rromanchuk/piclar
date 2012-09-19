# coding=utf-8
# Django settings for web project.
import os

DIRNAME = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
HOMEDIR = os.path.abspath(os.path.join(DIRNAME, '..'))

DEBUG = True
TEMPLATE_DEBUG = DEBUG

ADMINS = (
# ('Your Name', 'your_email@example.com'),
)

MANAGERS = ADMINS
POSTGIS_SQL_PATH = '/usr/share/postgresql/9.1/contrib/postgis/'

DICTIONARY_PATH = os.path.join(DIRNAME, 'poi/management/commands/dictionary/')

DATABASES = {
    'default': {
        'ENGINE': 'django.contrib.gis.db.backends.postgis',
        'NAME': 'social',
        'USER': 'postgres',
        'PASSWORD': '***REMOVED***',
        'HOST': '***REMOVED***',
        'PORT': '5432',
        'OPTIONS': {
            # https://docs.djangoproject.com/en/dev/ref/databases/#autocommit-mode
            'autocommit': True,
            }
    },
}

# Local time zone for this installation. Choices can be found here:
# http://en.wikipedia.org/wiki/List_of_tz_zones_by_name
# although not all choices may be available on all operating systems.
# On Unix systems, a value of None will cause Django to use the same
# timezone as the operating system.
# If running in a Windows environment this must be set to the same as your
# system time zone.
TIME_ZONE = 'Europe/Moscow'

# Language code for this installation. All choices can be found here:
# http://www.i18nguy.com/unicode/language-identifiers.html
LANGUAGE_CODE = 'ru-ru'

SITE_ID = 1

# If you set this to False, Django will make some optimizations so as not
# to load the internationalization machinery.
USE_I18N = True

# If you set this to False, Django will not format dates, numbers and
# calendars according to the current locale.
USE_L10N = True

# If you set this to False, Django will not use timezone-aware datetimes.
USE_TZ = True

# Absolute filesystem path to the directory that will hold user-uploaded files.
# Example: "/home/media/media.lawrence.com/media/"
MEDIA_ROOT = ''

# URL that handles the media served from MEDIA_ROOT. Make sure to use a
# trailing slash.
# Examples: "http://media.lawrence.com/media/", "http://example.com/media/"
MEDIA_URL = ''

# Absolute path to the directory static files should be collected to.
# Don't put anything in this directory yourself; store your static files
# in apps' "static/" subdirectories and in STATICFILES_DIRS.
# Example: "/home/media/media.lawrence.com/static/"

STATIC_ROOT = os.path.join(HOMEDIR, 'htdocs/static')

# URL prefix for static files.
# Example: "http://media.lawrence.com/static/"
STATIC_URL = '/static/'

# Additional locations of static files
STATICFILES_DIRS = (
    # Put strings here, like "/home/html/static" or "C:/www/django/static".
    # Always use forward slashes, even on Windows.
    # Don't forget to use absolute paths, not relative paths.
    os.path.join(DIRNAME, 'static'),
)

# List of finder classes that know how to find static files in
# various locations.
STATICFILES_FINDERS = (
    'django.contrib.staticfiles.finders.FileSystemFinder',
    'django.contrib.staticfiles.finders.AppDirectoriesFinder',
#    'django.contrib.staticfiles.finders.DefaultStorageFinder',
    )

# Make this unique, and don't share it with anybody.
SECRET_KEY = '***REMOVED***'

# List of callables that know how to import templates from various sources.
TEMPLATE_LOADERS = (
    'django.template.loaders.filesystem.Loader',
    'django.template.loaders.app_directories.Loader',
    #     'django.template.loaders.eggs.Loader',
    )

MIDDLEWARE_CLASSES = (
    'django.middleware.common.CommonMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'mediagenerator.middleware.MediaMiddleware',
    # Uncomment the next line for simple clickjacking protection:
    # 'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'debug.middleware.RequestTimeLoggingMiddleware',
    'debug_toolbar.middleware.DebugToolbarMiddleware',
    )

TEMPLATE_CONTEXT_PROCESSORS = (
    "django.contrib.auth.context_processors.auth",
    "django.core.context_processors.debug",
    "django.core.context_processors.i18n",
    "django.core.context_processors.tz",
    "django.core.context_processors.media",
    "django.core.context_processors.static",
    "django.contrib.messages.context_processors.messages",
    "person.context_processors.site_settings",
    "notification.context_processors.notifications",
)

MESSAGE_STORAGE = 'django.contrib.messages.storage.session.SessionStorage'

ROOT_URLCONF = 'urls'

MEDIA_DEV_MODE = True
MEDIA_BLOCKS = True
PRODUCTION_MEDIA_URL    = '/static/'

MEDIA_CSS_EXT = ('css', 'scss') # какие расширения проверять ( в этом случае для блока index.html будут проверены файлы static/css/index.css и static/css/index.scss )
MEDIA_JS_EXT = ('js',) # какие расширения проверять для js
MEDIA_CSS_LOCATION      = ['', 'templates']
MEDIA_JS_LOCATION       = ['', 'templates']
GENERATED_MEDIA_DIR     = os.path.join(HOMEDIR, 'htdocs/static')
DEV_MEDIA_URL           = '/static-dev/'
GLOBAL_MEDIA_DIRS       = [os.path.join(DIRNAME, 'static')] # force mediagenerator to do not walk over _generated_media dir


# Python dotted path to the WSGI application used by Django's runserver.
WSGI_APPLICATION = 'wsgi.application'

TEMPLATE_DIRS = (
    # Put strings here, like "/home/html/django_templates" or "C:/www/django/templates".
    # Always use forward slashes, even on Windows.
    # Don't forget to use absolute paths, not relative paths.
    os.path.join(DIRNAME, 'templates'),
    os.path.join(DIRNAME, 'templates-m'),
    )

INSTALLED_APPS = (
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
#    'django.contrib.sites',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'django.contrib.gis',
    'django.contrib.admin',
    'south',
    'pytils',
    'tastypie',
    'mediagenerator',
    'person',
    'api',
    'poi.provider.altergeo',
    'poi.provider.foursquare',
    'poi.provider.ota',
    'poi',
    'mobile',
    'globaltags',
    'feed',
    'notification',
    'feedback',
    'staticpages',
    'raven.contrib.django',
    'debug_toolbar'
    )



AUTHENTICATION_BACKENDS = (
    'person.backends.VkontakteBackend',
    'django.contrib.auth.backends.ModelBackend',
)

AUTH_PROFILE_MODULE = 'person.Person'

VK_CLIENT_ID = '***REMOVED***'
VK_CLIENT_SECRET = '***REMOVED***'
VK_SCOPES = 'friends,photos,status,wall,offline'

POI_PROVIDER_CLIENTS = {
    'altergeo'      : 'poi.provider.altergeo.client.Client',
    'foursquare'    : 'poi.provider.foursquare.client.Client',

    'instagram'     : 'poi.provider.instagram.client.Client',
    'ota'           : 'poi.provider.ota.client.Client',
}

SOCIAL_PROVIDER_CLIENTS = {
    'vkontakte'     : 'person.social.vkontakte.Client',
}

SERVER_ROLE = 'DEBUG'

IMAGE_STORAGE_HOST = '***REMOVED***'
IMAGE_STORAGE_WRITE_TIMEOUT = 10

CDN_URL_SECURABLE = '//%s/' % IMAGE_STORAGE_HOST
CDN_URL_HTTP_ONLY = 'http:'+ CDN_URL_SECURABLE

PERSON_IMAGE_FORMAT_ORIG = 'orig'
PERSON_IMAGE_FORMAT_120 = '100x100'
PERSON_IMAGE_FORMAT_40 = '40x40'

PERSON_IMAGE_FORMATS = (
    PERSON_IMAGE_FORMAT_ORIG,
    PERSON_IMAGE_FORMAT_120,
    PERSON_IMAGE_FORMAT_40
)

CHECKIN_IMAGE_FORMAT_ORIG = 'orig'
CHECKIN_IMAGE_FORMAT_640 = '640x640' # change it after add new sizes to preset

CHEKIN_IMAGE_FORMATS = (
    CHECKIN_IMAGE_FORMAT_ORIG,
    CHECKIN_IMAGE_FORMAT_640
)
PERSON_IMAGE_PATH = 'social/person'

CHECKIN_IMAGE_PATH = 'social/checkin'

MEDIA_ROOT = os.path.join(DIRNAME, 'static/1/')
MEDIA_URL = STATIC_URL + '1/'

TASTYPIE_FULL_DEBUG = DEBUG

APPSTORE_APP_URL = 'http://www.apple.com/itunes/'

from django.core.urlresolvers import reverse_lazy
LOGIN_URL = reverse_lazy('person_login')
LOGOUT_URL = reverse_lazy('person_logout')
LOGIN_REDIRECT_URL = reverse_lazy('page-index')

INACTIVE_USER_REDIRECT_URL = reverse_lazy('person-fillemail')

DEFAULT_FROM_EMAIL = '***REMOVED***'

#EMAIL_BACKEND = 'django.core.mail.backends.filebased.EmailBackend'
#EMAIL_FILE_PATH = '/tmp/social-mail'

API_CLIENT_SALT = '***REMOVED***'

DATETIME_FORMAT = "%Y-%m-%d %H:%M:%S %z"

GMAPS_API_KEY = '***REMOVED***'

YANDEXMAPS_API_KEY = '***REMOVED***'

DEFAULT_USERPIC_URL = STATIC_URL + 'img/common/default_userpic.jpg'

GIS_HOST = 'http://***REMOVED***'


DEBUG_VK_WALL_ACCESS_TOKEN = '***REMOVED***'
DEBUG_VK_WALL_USER_ID = 181349200

ANALYTICS_ID = '***REMOVED***' # ***REMOVED***

# Set your DSN value
SENTRY_DSN = '***REMOVED***'
HTTPS_SUPPORT = False
