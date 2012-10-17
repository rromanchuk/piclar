from django.contrib.auth.models import User
from social import ProviderException
from xact import xact

from logging import getLogger

log = getLogger('web.person.backends')
class SocialBackend(object):
    def authenticate(self, provider, access_token, user_id):
        social_person = provider.fetch_user(access_token, user_id).get_social_person()

        # here we can get existent person in two cases:
        # - we have already registred person with such external_id
        # - we have a social person was fetched as a friend of other person (such person has no access_token)
        if not social_person.person:
            # social person is a friend, so we can't sign in it
            return None

        if social_person.id:
            # check if stored token is valid
            try:
                settings = provider.get_settings(social_person=social_person)
            except ProviderException:
                # token is invalid - update it
                social_person.token = access_token
            else:
                # if received token has all necessary rights or empty token and update field in db
                settings = provider.get_settings(access_token, user_id)
                if 'wall' in settings: # and 'messages' in settings:
                    social_person.token = access_token

        with xact():
            # save new token and load friends
            social_person.save()
            try:
                social_person.load_friends()
            except Exception as e:
                log.exception(e)


        return social_person.person.user

    def get_user(self, user_id):
        try:
            return User.objects.get(pk=user_id)
        except User.DoesNotExist:
            return None