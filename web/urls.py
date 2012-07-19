from django.conf.urls import patterns, include, url

from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    url(r'^api/', include('api.urls')),
    url(r'^m/', include('mobile.urls')),
    url(r'^admin/', include(admin.site.urls)),
    url(r'^$', 'poi.views.index', name='page-index'),

    url(r'feed/$', 'django.shortcuts.render', {'template_name': 'blocks/page-feed/p-feed.html'}, name='feed'),

    url(r'^test/$', 'poi.views.test', name='page-test'),
    url(r'^users/', include('person.urls')),
)
