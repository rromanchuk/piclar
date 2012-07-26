from django.conf.urls import patterns, include, url

urlpatterns = patterns('',
    url(r'(?P<pk>\d+)/$', 'poi.views.place', name='place'),
    url(r'(?P<place_pk>\d+)/checkin/(?P<checkin_pk>\d+)/$', 'poi.views.place_checkin', name='place-checkin'),
)