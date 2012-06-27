from django.conf.urls import patterns, include, url

urlpatterns = patterns('',
       url(r'^user/register$', 'user_register', name='api-user-register'),

)
