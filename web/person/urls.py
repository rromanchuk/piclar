from django.conf.urls import patterns, include, url

urlpatterns = patterns('',
    url(r'registration/$', 'person.views.registration', name='person_registration'),
    url(r'oauth/$', 'person.views.oauth', name='person_oauth'),

    url(r'login/$', 'person.views.login', name='person_login'),
    url(r'preregistration/$', 'person.views.preregistration', name='person_preregistration'),
)
