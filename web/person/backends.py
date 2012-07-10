from django.contrib.auth.models import User
from models import SocialPerson
from poi.provider import get_poi_client

class VkontakteBackend(object):
    def authenticate(self, access_token, user_id):
        client = get_poi_client('vkontakte')
        social_person = client.fetch_user(access_token, user_id)
        if not social_person:
            return None
        if not social_person.person:
            return None
        # save new token and load friends
        social_person.save()
        social_person.load_friends()
        return social_person.person.user

    def get_user(self, user_id):
        try:
            return User.objects.get(pk=user_id)
        except User.DoesNotExist:
            return None