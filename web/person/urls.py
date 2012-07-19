from django.conf.urls import patterns, include, url

urlpatterns = patterns('',
    url(r'registration/$', 'person.views.registration', name='person-registration'),
    url(r'oauth/$', 'person.views.oauth', name='person-oauth'),
    url(r'(?P<pk>\d+)/profile/$', 'person.views.profile', name='person-profile'),
    url(r'me/profile/$', 'person.views.edit_profile', name='person-edit-profile'),
    url(r'me/contacts/$', 'person.views.edit_contacts', name='person-edit-contacts'),
    url(r'verify/(?P<token>[0-9a-z]+)/$','person.views.email_confirm', name='person-email-confirm'),

    url(r'login/$', 'django.contrib.auth.views.login', { 'template_name' : 'blocks/page-users-login/p-users-login.html'  }, name='person-login'),
    url(r'logout/$', 'django.contrib.auth.views.logout', { 'next_page' : '/' } , name='person-logout'),
    url(r'preregistration/$', 'person.views.preregistration', name='person-preregistration'),
)
