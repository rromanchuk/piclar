from django.conf.urls import patterns, include, url

urlpatterns = patterns('',
    url(r'registration/$', 'person.views.registration', name='person-registration'),
    url(r'oauth/$', 'person.views.oauth', name='person-oauth'),
    url(r'(?P<pk>\d+)/profile/$', 'person.views.profile', name='person-profile'),
    url(r'me/subscription/$', 'person.views.subscription', name='person-subscription'),
    url(r'me/profile/$', 'person.views.edit_profile', name='person-edit-profile'),
    url(r'me/profile/email/$', 'person.views.fill_email', name='person-fillemail'),
    url(r'me/askinvite/$', 'django.views.generic.simple.direct_to_template', {'template': 'blocks/page-error500/p-error500.html'}, name='person-ask-invite'),
    url(r'me/pleasewait/$', 'django.views.generic.simple.direct_to_template', {'template': 'blocks/page-error500/p-error500.html'}, name='person-wait-invite-confirm'),

    url(r'me/profile/email/$', 'person.views.fill_email', name='person-fillemail'),
    url(r'me/credentials/$', 'person.views.edit_credentials', name='person-edit-credentials'),
    url(r'verify/(?P<token>[0-9a-z]+)/$','person.views.email_confirm', name='person-email-confirm'),

    url(r'login/$', 'person.views.login', name='person-login'),
    url(r'logout/$', 'django.contrib.auth.views.logout', { 'next_page' : '/' } , name='person-logout'),
    url(r'preregistration/$', 'person.views.preregistration', name='person-preregistration'),
    url(r'passwordreset/$', 'person.views.password_reset', name='person-resetpassword'),
    url(r'passwordreset/(?P<uidb36>[0-9A-Za-z]+)-(?P<token>.+)/$', 'django.contrib.auth.views.password_reset_confirm', name='person-resetpassword-confirm'),
    url(r'passwordreset/done/$', 'person.views.password_reset_done', name='password_reset_done')



)
