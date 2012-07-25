from django.conf.urls import patterns, include, url

from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    url(r'^api/', include('api.urls')),
    url(r'^m/', include('mobile.urls')),
    url(r'^admin/', include(admin.site.urls)),
    url(r'^$', 'poi.views.index', name='page-index'),

    url(r'^feed/', include('feed.urls')),
    url(r'^places/', include('poi.urls')),
    url(r'^users/', include('person.urls')),
)
