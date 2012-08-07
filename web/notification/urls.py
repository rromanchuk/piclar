from django.conf.urls import patterns, include, url

urlpatterns = patterns('',
    url(r'^markread/$', 'notification.views.mark_as_read', name='notifications-mark-read'),
    url(r'^list/$', 'notification.views.list', name='person-notifications'),
)