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

    url(r'^profile/edit/$', 'mobile.views.profile_edit', name='mobile_person_edit'),

    url(r'^error404/$', 'django.shortcuts.render', dict(template_name='pages/m_error404.html')),
    url(r'^error500/$', 'django.shortcuts.render', dict(template_name='pages/m_error500.html')),

    url(r'^about/$', 'django.shortcuts.render', dict(template_name='pages/m_about.html')),
    url(r'^agreement/$', 'django.shortcuts.render', dict(template_name='pages/m_agreement.html'), name='mobile_agreement'),

    url(r'^followers/$', 'django.shortcuts.render', dict(template_name='pages/m_followers.html'), name='mobile_person_followers'),  # needs to b user based
    url(r'^following/$', 'django.shortcuts.render', dict(template_name='pages/m_following.html'), name='mobile_person_following'),  # needs to b user based
)
