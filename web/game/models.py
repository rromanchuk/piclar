from django.db import models

class ScoreManager(models.Manager):

    def create_score(self, name, score):
        score = Score(**{'name': name, 'score': score})
        score.save()

    def get_high_score(self):
        return self.get_query_set().order_by('score')[:10]

class Score(models.Model):
    name = models.CharField(max_length=255)
    score = models.IntegerField(default=0, null=False)

    objects = ScoreManager()