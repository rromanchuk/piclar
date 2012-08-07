from django.http import HttpResponse
from django.shortcuts import render_to_response, redirect, get_object_or_404
from django.template import RequestContext
from person.auth import login_required
from models import Notification

import json
from logging import getLogger

log = getLogger('web.notification')

@login_required
def list(request):
    person = request.user.get_profile()
    notifications = Notification.objects.get_person_notifications(person)
    has_unread = False
    for notification in notifications:
        if not notification.is_read:
            has_unread = True
            break

    return render_to_response('blocks/page-notifications/p-notifications.html',
        {
            'notifications' : notifications,
            'has_unread' : has_unread,
        },
        context_instance=RequestContext(request)
    )

@login_required
def mark_as_read(request):
    ids = request.POST.getlist('n_ids')
    if not ids:
        return HttpResponse(json.dumps({
            'status': 'error',
            'message' : 'parameter required'
        }))
    person = request.user.get_profile()
    if ids == ['all']:
        Notification.objects.mark_as_read_all(person)
    else:
        Notification.objects.mark_as_read(person, ids)

    return HttpResponse(json.dumps({
        'status': 'ok',
    }))