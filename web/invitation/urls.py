from django.conf.urls import patterns, include, url
from django.core.urlresolvers import reverse_lazy

urlpatterns = patterns('',
    url(r'^internal/$', 'invitation.views.codes', name='invitation_codes'),
)
