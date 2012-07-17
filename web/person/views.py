from django.shortcuts import render_to_response
from django.template import RequestContext
from django.conf import settings
from django.core.urlresolvers import reverse


def registration(request):

    return render_to_response('blocks/page-users_registration/p-users_registration.html',
        {},
        context_instance=RequestContext(request)
    )


def oauth(request):
    return render_to_response('blocks/page-users_login_oauth/p-users_login_oauth.html',
        {},
        context_instance=RequestContext(request)
    )


def login(request):
    return render_to_response('blocks/page-users_login/p-users_login.html',
        {},
        context_instance=RequestContext(request)
    )


def preregistration(request):
    return render_to_response('blocks/page-users_preregistration/p-users_preregistration.html',
        {},
        context_instance=RequestContext(request)
    )
