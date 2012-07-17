from django.shortcuts import render_to_response
from django.template import RequestContext
from django.conf import settings
from django.core.urlresolvers import reverse

def registration(request):
    vk_login_url = 'http://oauth.vk.com/authorize?'\
        'client_id=%s&' \
        'scope=%s&'\
        'redirect_uri=%s&'\
        'display=%s&'\
        'response_type=token' % (
         settings.VK_CLIENT_ID,
        'friends,notify,photos,status,wall,offline,notifications,groups',
        request.build_absolute_uri(reverse('person_oauth')),
        'popup'
    )

    return render_to_response('blocks/page-users_registration/p-users_registration.html',
        {
            'vk_login_url': vk_login_url
        },
        context_instance=RequestContext(request)
    )


def oauth(request):
    return render_to_response('blocks/page-users_login_oauth/p-users_login_oauth.html',
        {},
        context_instance=RequestContext(request)
    )


def login(request):
    return render_to_response('blocks/page-users_login_oauth/p-users_login_oauth.html',
        {},
        context_instance=RequestContext(request)
    )


def preregistration(request):
    return render_to_response('blocks/page-users_login_oauth/p-users_login_oauth.html',
        {},
        context_instance=RequestContext(request)
    )
