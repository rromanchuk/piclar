from utils import  filter_fields, AuthTokenMixin, doesnotexist_to_404, date_in_words, CommonRefineMixin
from base import *
from game.models import Score

class ScoreGetPost(ApiMethod,CommonRefineMixin):
    def get(self):
        return [{'name' : score.name, 'score': score.score} for score in Score.objects.get_high_score()]
    def post(self):
        Score.objects.create_score(self.request.POST.get('name'), self.request.POST.get('score'))
        return {}
