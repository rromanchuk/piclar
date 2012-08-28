from django.conf.urls import patterns, include, url

urlpatterns = patterns('',
    url(r'^$', 'mobile.views.index', name='mobile_index'),
    url(r'feed/$', 'mobile.views.feed', name='mobile_feed'),

    url(r'login/$', 'django.contrib.auth.views.login', {'template_name': 'pages/m_login_email.html'}, name='mobile_login'),
    url(r'oauth/$', 'mobile.views.oauth', name='mobile_oauth'),


    url(r'^comments/(?P<pk>\d+)/$', 'mobile.views.comments', name='mobile_comments'),
    url(r'^checkin/(?P<pk>\d+)/$', 'mobile.views.checkin', name='mobile_checkin'),

    url(r'^profile/(?P<pk>\d+)$', 'mobile.views.profile', name='mobile_profile'),

    url(r'^place/(?P<pk>\d+)/$', 'mobile.views.place', name='mobile_place'),

    url(r'^error404/$', 'django.shortcuts.render', dict(template_name='pages/m_error404.html')),
    url(r'^error500/$', 'django.shortcuts.render', dict(template_name='pages/m_error500.html')),
)
