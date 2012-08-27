from django.contrib.auth.models import User
from social import provider

class VkontakteBackend(object):
    def authenticate(self, access_token, user_id):
        client = provider('vkontakte')
        social_person = client.fetch_user(access_token, user_id)
        if not social_person:
            return None
        if not social_person.person:
            return None


        if social_person.id:
            # for existent person check if received token has all necessary rights and update field in db
            settings = client.get_settings(social_person=social_person)
            if 'wall' in settings: # and 'messages' in settings:
                social_person.token = access_token

        # save new token and load friends
        social_person.save()
        social_person.load_friends()
        return social_person.person.user

    def get_user(self, user_id):
        try:
            return User.objects.get(pk=user_id)
        except User.DoesNotExist:
            return None