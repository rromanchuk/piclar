from django.conf.urls import patterns, include, url

urlpatterns = patterns('',
    url(r'^$', 'mobile.views.index', name='mobile_index'),
    url(r'users/login/$', 'mobile.views.login', name='mobile_login'),
    url(r'users/oauth/$', 'mobile.views.oauth', name='mobile_oauth'),


    url(r'^(?P<pk>\d+)/comments/$', 'mobile.views.comments', name='mobile_comments'),
    url(r'^checkin/$', 'django.shortcuts.render', dict(template_name='pages/m_checkin.html')),

    url(r'^profile/$', 'django.shortcuts.render', dict(template_name='pages/m_profile.html')),

    url(r'^place/$', 'django.shortcuts.render', dict(template_name='pages/m_place.html')),

    url(r'^error404/$', 'django.shortcuts.render', dict(template_name='pages/m_error404.html')),
    url(r'^error500/$', 'django.shortcuts.render', dict(template_name='pages/m_error500.html')),
)
