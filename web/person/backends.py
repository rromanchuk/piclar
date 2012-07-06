from django.contrib.auth.models import User
from models import SocialPerson

class VkontakteBackend(object):
    def authenticate(self, access_token):
        client = VkClient()
        fetched_person = client.fetch_user(access_token, user_id)
        if 'error' in fetched_person:
            return None

        try:
            person = SocialPerson.objects.get(
                provider=SocialPerson.PROVIDER_VKONTAKTE,
                external_id=fetched_person['uid'],
            )
            return person.user
        except SocialPerson.DoesNotExist:
            return None