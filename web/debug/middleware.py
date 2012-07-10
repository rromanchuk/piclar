from django.conf import settings
import logging
log = logging.getLogger('debug-request')

class RequestTimeLoggingMiddleware(object):

    def log_message(self, request):
        log.info(request.REQUEST)

    def process_request(self, request):
        if settings.DEBUG:
            self.log_message(request)
