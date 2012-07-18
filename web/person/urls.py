from django.conf.urls import patterns, include, url

urlpatterns = patterns('',
    url(r'registration/$', 'person.views.registration', name='person-registration'),
    url(r'oauth/$', 'person.views.oauth', name='person-oauth'),

    url(r'login/$', 'django.contrib.auth.views.login', { 'template_name' : 'blocks/page-users_login/p-users_login.html'  }, name='person-login'),
    url(r'logout/$', 'django.contrib.auth.views.logout', name='person-logout'),
    url(r'preregistration/$', 'person.views.preregistration', name='person-preregistration'),
)
