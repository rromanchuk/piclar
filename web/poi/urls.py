from django.conf.urls import patterns, include, url

urlpatterns = patterns('',
    url(r'(?P<pk>\d+)/$', 'poi.views.place', name='place'),
)