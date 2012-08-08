from django.db import models
from person.models import Person

class Feedback(models.Model):
    comment = models.TextField()
    person = models.ForeignKey(Person, null=True)
    page_url = models.CharField(max_length=255, blank=True, null=True)
    ip_address = models.IPAddressField()
    create_date = models.DateTimeField(auto_now_add=True)
