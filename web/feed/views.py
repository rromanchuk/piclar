import json
import time
from django.contrib.auth.decorators import login_required
from django.http import HttpResponse
from django.shortcuts import render_to_response, redirect, get_object_or_404
from django.template import RequestContext
from django.conf import settings
from django.core.urlresolvers import reverse


from api.v2.serializers import encoder, iter_response
from feed.models import FeedItem, FeedPersonItem, FeedItemComment
from person.models import Person
from poi.models import Place

def base_refine(obj):
    if hasattr(obj, 'timetuple'):
        return time.mktime(obj.timetuple())

    if isinstance(obj, FeedItemComment):
        return {
            'id' : obj.id,
            'message': obj.comment,
            'user': iter_response(obj.creator, base_refine)

        }
    if isinstance(obj, Place):
        return {
            'id' : obj.id,
            'title' : obj.title,
            'address' : obj.address,
            'description' : obj.description,
            'url' : obj.url,
            }

    if isinstance(obj, Person):
        return iter_response(obj.get_profile_data(), base_refine)
    return obj


@login_required
def index(request):
    person = request.user.get_profile()

    def refine(obj):
        if isinstance(obj, FeedPersonItem):
            return {
                'id' : obj.item.id,
                'create_date' : refine(obj.item.create_date),
                'creator': iter_response(obj.creator, refine),
                'data' : iter_response(obj.item.get_data(), refine),
                'likes': obj.item.liked,
                'cnt_likes' : len(obj.item.liked),
                'me_liked' : obj.item.liked_by_person(person),
                'comments': iter_response(list(obj.item.get_comments()), refine),
                }
        return base_refine(obj)


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
    feed = get_object_or_404(FeedItem, id=feed_id)
    obj_comment = feed.comment(request.user.get_profile(), comment)
    if request.is_ajax():
        response = iter_response(obj_comment, base_refine)
        return HttpResponse(encoder.encode(response))
    return HttpResponse()
