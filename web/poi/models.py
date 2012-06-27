from django.contrib.gis.db import models

class Place(models.Model):
    title = models.TextField()
    description = models.TextField()
    position = models.PointField()
    photo = models.ForeignKey('Photo')
    review = models.ForeignKey('Review')

    objects = models.GeoManager()

class Review(models.Model):
    pass


class Photo(models.Model):
    pass

