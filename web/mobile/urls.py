from django.conf.urls import patterns, include, url

urlpatterns = patterns('',
   url(r'^$', 'mobile.views.index'),
   url(r'registration/$', 'mobile.views.registration', name='mobile_registration'),
   url(r'oauth/$', 'mobile.views.oauth', name='mobile_oauth'),

)
