from django.conf.urls import patterns, include, url
from django.shortcuts import render
from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    url(r'^api/', include('api.urls')),
    url(r'^m/', include('mobile.urls')),
    url(r'^admin/', include(admin.site.urls)),
    url(r'^$', 'poi.views.index', name='page-index'),

    url(r'^feed/', include('feed.urls')),
    url(r'^places/', include('poi.urls')),
    url(r'^notification/', include('notification.urls')),
    url(r'^users/', include('person.urls')),
    url(r'^feedback/', include('feedback.urls')),

    url(r'^about/$', 'django.shortcuts.render', dict(template_name='blocks/page-about/p-about.html'), name='page-about'),
    url(r'^agreement/$', 'django.shortcuts.render', dict(template_name='blocks/page-agreement/p-agreement.html'), name='page-agreement'),
    url(r'^404/$', 'django.shortcuts.render', dict(template_name='blocks/page-error404/p-error404.html')),
    url(r'^500/$', 'django.shortcuts.render', dict(template_name='blocks/page-error500/p-error500.html')),

    url(r'^comingsoon/$', 'django.shortcuts.render', dict(template_name='blocks/page-landing-comingsoon/p-landing-comingsoon.html')),
    url(r'^lounge/$', 'django.shortcuts.render', dict(template_name='blocks/page-lounge/p-lounge.html')),

    url(r'^resetpassword/$', 'django.shortcuts.render', dict(template_name='blocks/page-users-resetpassword/p-users-resetpassword.html'), name='page-resetpassword'),
)

def error_handler(template):
    def wrap(request):
        return render(request, template_name=template)
    return wrap

handler404 = error_handler('blocks/page-error404/p-error404.html')
handler500 = error_handler('blocks/page-error500/p-error500.html')
