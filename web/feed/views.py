from django.contrib.auth.decorators import login_required

from django.shortcuts import render_to_response, redirect, get_object_or_404
from django.template import RequestContext
from django.conf import settings
from django.core.urlresolvers import reverse

from feed.models import FeedItem

@login_required
def index(request):
    person = request.user.get_profile()
    feed = FeedItem.objects.feed_for_person(person)
    return render_to_response('blocks/page-feed/p-feed.html',
        {
            'feed' : feed
        },
        context_instance=RequestContext(request)
    )