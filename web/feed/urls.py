from django.conf.urls import patterns, include, url

urlpatterns = patterns('',
   url(r'$', 'feed.views.index', name='feed'),
   url(r'$', 'feed.views.comment', name='feed-comments'),
)
