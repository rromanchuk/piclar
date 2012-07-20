from django.contrib.auth.decorators import login_required

from django.shortcuts import render_to_response, redirect, get_object_or_404
from django.template import RequestContext
from django.conf import settings
from django.core.urlresolvers import reverse


@login_required
def index(request):
    return render_to_response('blocks/page-feed/p-feed.html',
        {

        },
        context_instance=RequestContext(request)
    )