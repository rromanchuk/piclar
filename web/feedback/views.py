from django.http import HttpResponse

from models import Feedback

def feedback(request):
    if not request.POST.get('comment'):
        return HttpResponse()

    proto = {
        'comment' : request.POST.get('comment'),
        'page_url' : request.POST.get('page_url'),
        'ip_address' : request.META.get('REMOTE_ADDR'),
    }
    if request.user and request.user.is_authenticated():
        proto['person'] = request.user.get_profile()

    fb = Feedback(**proto)
    fb.save()
    return HttpResponse()
