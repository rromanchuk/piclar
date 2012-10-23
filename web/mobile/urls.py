from django.conf.urls import patterns, include, url
from django.core.urlresolvers import reverse_lazy

urlpatterns = patterns('',
    url(r'^$', 'mobile.views.index', name='mobile_index'),
    url(r'feed/$', 'mobile.views.feed', name='mobile_feed'),

    url(r'login/$', 'django.contrib.auth.views.login', {'template_name': 'pages/m_login_email.html'}, name='mobile_login'),
    url(r'logout/$', 'django.contrib.auth.views.logout', { 'next_page' : reverse_lazy('mobile_index') } , name='mobile_logout'),
    url(r'oauth/$', 'mobile.views.oauth', name='mobile_oauth'),


    url(r'^comments/(?P<pk>\d+)/$', 'mobile.views.comments', name='mobile_comments'),
    url(r'^likes/(?P<pk>\d+)/$', 'mobile.views.likes', name='mobile_likes'),
    url(r'^checkin/(?P<pk>\d+)/$', 'mobile.views.checkin', name='mobile_checkin'),

    url(r'^profile/(?P<pk>\d+)/$', 'mobile.views.profile', name='mobile_profile'),
    url(r'^place/(?P<pk>\d+)/$', 'mobile.views.place', name='mobile_place'),

    url(r'^profile/(?P<pk>\d+)/(?P<action>followers|following)/$', 'mobile.views.friend_list', name='mobile_person_friends'),

    url(r'^profile/edit/$', 'mobile.views.profile_edit', name='mobile_person_edit'),

    url(r'^error404/$', 'django.shortcuts.render', dict(template_name='pages/m_error404.html')),
    url(r'^error500/$', 'django.shortcuts.render', dict(template_name='pages/m_error500.html')),

    url(r'^about/$', 'django.shortcuts.render', dict(template_name='pages/m_about.html')),
    url(r'^agreement/$', 'django.shortcuts.render', dict(template_name='pages/m_agreement.html'), name='mobile_agreement'),

    url(r'^addemail/$', 'django.shortcuts.render', dict(template_name='pages/m_fill_email.html')),
    url(r'^inviteonly/$', 'django.shortcuts.render', dict(template_name='pages/m_inviteonly.html')),
)
