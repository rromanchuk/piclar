from django.contrib.auth.decorators import login_required
from django.http import HttpResponse
from django.shortcuts import render_to_response, redirect, get_object_or_404
from django.template import RequestContext
from django.conf import settings
from django.core.urlresolvers import reverse


from api.v2.serializers import encoder, iter_response
from api.v2.place_api import refine_place
from feed.models import FeedItem, FeedPersonItem
from person.models import Person


@login_required
def index(request):
    person = request.user.get_profile()
    def refine(obj):
        if isinstance(obj, FeedPersonItem):
            return {
                'id' : obj.item.id,
                'create_date' : obj.item.create_date,
                'creator': refine(obj.creator),
                'data' : iter_response(obj.item.get_data(), refine),
                'likes': obj.item.liked,
                'me_liked' : obj.item.liked_by_person(person),
                'comments': iter_response(list(obj.item.get_comments()), refine),
            }

        obj = refine_place(obj)
        if isinstance(obj, Person):
            return obj.get_profile_data()

        return obj


    feed = FeedItem.objects.feed_for_person(person)

    feed_proto = iter_response(feed, refine)
    return render_to_response('blocks/page-feed/p-feed.html',
        {
            'feed' : feed,
            'feed_json': encoder.encode(feed_proto),
        },
        context_instance=RequestContext(request)
    )

@login_required
def comment(request):
    if request.method != 'POST':
        return HttpResponse()

    feed_id = request.POST.get('feed_id')
    comment = request.POST.get('comment')