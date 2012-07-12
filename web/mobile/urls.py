from django.conf.urls import patterns, include, url

urlpatterns = patterns('',
   url(r'^$', 'mobile.views.index'),
   url(r'users/login/$', 'mobile.views.login', name='mobile_login'),
   url(r'users/registration/$', 'mobile.views.registration', name='mobile_registration'),
   url(r'users/oauth/$', 'mobile.views.oauth', name='mobile_oauth'),

)
