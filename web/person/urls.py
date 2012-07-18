from django.conf.urls import patterns, include, url

urlpatterns = patterns('',
    url(r'registration/$', 'person.views.registration', name='person-registration'),
    url(r'oauth/$', 'person.views.oauth', name='person-oauth'),
    url(r'(?P<pk>\d+)/profile/$', 'person.views.profile', name='person-profile'),
    url(r'me/profile/$', 'person.views.edit_profile', name='person-edit-profile'),

    url(r'login/$', 'django.contrib.auth.views.login', { 'template_name' : 'blocks/page-users-login/p-users-login.html'  }, name='person-login'),
    url(r'logout/$', 'django.contrib.auth.views.logout', name='person-logout'),
    url(r'preregistration/$', 'person.views.preregistration', name='person-preregistration'),
)
