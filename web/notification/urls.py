from django.conf.urls import patterns, include, url

urlpatterns = patterns('',
    url(r'^list/$', 'notification.views.list', name='person-notifications'),
)