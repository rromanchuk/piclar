import urllib
import json
import logging
from base import BaseClient
from person.models import Person, SocialPerson

log = logging.getLogger('web.person.social.facebook')

class Client(BaseClient):

    def fetch_friends(self, *args, **kwargs):
        pass

    def fetch_user(self, *args, **kwargs):
        pass

    def wall_post(self, *args, **kwargs):
        pass

