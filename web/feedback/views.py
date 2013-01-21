from django.http import HttpResponse
from django.template import RequestContext
from django.shortcuts import render_to_response, redirect, get_object_or_404

from models import Feedback

def feedback(request):
    if not request.POST.get('comment'):
        return render_to_response('blocks/page-feedback/p-feedback.html', {},  context_instance=RequestContext(request))

    proto = {
        'comment' : request.POST.get('comment'),
        'page_url' : request.POST.get('page_url'),
        'ip_address' : request.META.get('REMOTE_ADDR'),
    }
    if request.user and request.user.is_authenticated():
        proto['person'] = request.user.get_profile()

    fb = Feedback(**proto)
    fb.save()
    return HttpResponse('{}')
