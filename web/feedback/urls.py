from django.conf.urls import patterns, include, url

urlpatterns = patterns('',
    url(r'$', 'feedback.views.feedback', name='feedback'),

)