from utils import  filter_fields, AuthTokenMixin, doesnotexist_to_404, date_in_words, CommonRefineMixin
from base import *
from game.models import Score
from base64 import b64decode

import json
from hashlib import md5


class ScoreGetPost(ApiMethod,CommonRefineMixin):
    def get(self):
        return [{'name' : score.name, 'score': score.score} for score in Score.objects.get_high_score()]

    def post(self):
        data = self.request.POST.get('data')
        sign = self.request.POST.get('signature')

        #if sign <> md5(data).hexdigest():
        #    return self.error(status=401, message='unauthorized')
        if not data or not sign:
            return self.error(message="incorrect params")

        data = json.loads(b64decode(data))
        Score.objects.create_score(data.get('name'), data.get('score'))
        return self.get()

