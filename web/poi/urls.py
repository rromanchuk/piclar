from django.conf.urls import patterns, include, url

urlpatterns = patterns('',
    url(r'(?P<pk>\d+)/$', 'poi.views.place', name='place'),
    url(r'^favorites/$', 'poi.views.favorites', name='place_favorites'),
)