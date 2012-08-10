from django.conf.urls import patterns, include, url

urlpatterns = patterns('',
    url(r'^$', 'mobile.views.index', name='mobile_index'),
    url(r'users/login/$', 'mobile.views.login', name='mobile_login'),
    url(r'users/oauth/$', 'mobile.views.oauth', name='mobile_oauth'),


    url(r'^comments/$', 'django.shortcuts.render', dict(template_name='pages/m_comments.html')),
    url(r'^checkin/$', 'django.shortcuts.render', dict(template_name='pages/m_checkin.html')),
)
