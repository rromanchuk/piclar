from django.http import HttpResponse
from django.shortcuts import render_to_response, redirect, get_object_or_404
from django.template import RequestContext
from person.auth import login_required
from models import Notification

@login_required
def list(request):
    person = request.user.get_profile()
    notifications = Notification.objects.get_person_notifications(person)

    return render_to_response('blocks/page-notifications/p-notifications.html',
        {
            'notifications' : notifications,
        },
        context_instance=RequestContext(request)
    )