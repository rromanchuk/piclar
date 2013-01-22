from django.conf.urls import patterns, include, url

urlpatterns = patterns('',
   url(r'^comment/$', 'feed.views.comment', name='feed-comments'),
   url(r'^(?P<pk>\d+)/$', 'feed.views.item', name='feed-item'),
   url(r'^like/$', 'feed.views.like', name='feed-like'),
   url(r'^featured/$', 'feed.views.featured', name='feed-featured'),
   url(r'^$', 'feed.views.index', name='feed'),
   # url(r'view/$', 'feed.views.view', name='view-feed'),

)
