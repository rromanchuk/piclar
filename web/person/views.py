from django.shortcuts import render_to_response
from django.template import RequestContext

def registration(request):
    return render_to_response('page-users_registration/p-u-registration.html',
        {},
        context_instance=RequestContext(request)
    )
