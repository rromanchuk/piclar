from django.conf.urls import patterns, include, url

urlpatterns = patterns('',
    url(r'place/(?P<pk>\d+)/$', 'poi.views.place', name='place'),
)