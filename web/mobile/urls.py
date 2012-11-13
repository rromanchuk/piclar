from django.conf.urls import patterns, include, url
from django.core.urlresolvers import reverse_lazy

urlpatterns = patterns('',
    url(r'^$', 'mobile.views.index', name='index'),
    url(r'feed/$', 'mobile.views.feed', name='feed'),

    url(r'login/$', 'django.contrib.auth.views.login', {'template_name': 'pages/m_login_email.html'}, name='login'),
    url(r'logout/$', 'django.contrib.auth.views.logout', { 'next_page' : reverse_lazy('index') } , name='logout'),
    url(r'oauth/$', 'mobile.views.oauth', name='oauth'),


    url(r'^comments/(?P<pk>\d+)/$', 'mobile.views.comments', name='comments'),
    url(r'^likes/(?P<pk>\d+)/$', 'mobile.views.likes', name='likes'),
    url(r'^checkin/(?P<pk>\d+)/$', 'mobile.views.checkin', name='checkin'),

    url(r'^profile/(?P<pk>\d+)/$', 'mobile.views.profile', name='profile'),
    url(r'^place/(?P<pk>\d+)/$', 'mobile.views.place', name='place'),

    url(r'^profile/(?P<pk>\d+)/(?P<action>followers|following)/$', 'mobile.views.friend_list', name='person_friends'),

    url(r'^profile/edit/$', 'mobile.views.profile_edit', name='person_edit'),
    url(r'^notifications/$', 'mobile.views.notifications', name='notifications'),

    url(r'^error404/$', 'django.shortcuts.render', dict(template_name='pages/m_error404.html')),
    url(r'^error500/$', 'django.shortcuts.render', dict(template_name='pages/m_error500.html')),

    url(r'^about/$', 'django.shortcuts.render', dict(template_name='pages/m_about.html')),
    url(r'^agreement/$', 'django.shortcuts.render', dict(template_name='pages/m_agreement.html'), name='agreement'),

    url(r'^fillemail/$', 'mobile.views.fillemail', name='person-fillemail'),
    url(r'^inviteonly/$', 'mobile.views.ask_invite', name='person-wait-invite-confirm'),
    url(r'^askinvite/$',  'mobile.views.ask_invite', name='person-ask-invite'),


)
