from django.conf.urls import patterns, include, url

urlpatterns = patterns('',
   url(r'comment/$', 'feed.views.comment', name='feed-comments'),
   #url(r'$', 'feed.views.index', name='feed'),
   url(r'view/$', 'feed.views.view', name='view-feed'),

)
