import pytz
from django.http import HttpResponse
from django.shortcuts import render_to_response, redirect, get_object_or_404
from django.template import RequestContext
from django.conf import settings
from django.core.urlresolvers import reverse

from person.auth import login_required

from api.v2.serializers import to_json, iter_response
from feed.models import FeedItem, FeedPersonItem, FeedItemComment
from person.models import Person
from poi.models import Place

from django.utils.html import escape

def base_refine(obj):

    if hasattr(obj, 'astimezone'):
        return obj.astimezone(pytz.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    if isinstance(obj, FeedItemComment):
        return {
            'id' : obj.id,
            'create_date': iter_response(obj.create_date, base_refine),
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

def _refine_person(person):
    def _refine(obj):
        if isinstance(obj, FeedPersonItem):
            return {
                'id' : obj.item.id,
                'create_date' : _refine(obj.item.create_date),
                'creator': iter_response(obj.creator, _refine),
                'url' : obj.item.url,
                'data' : iter_response(obj.item.get_data(), _refine),
                'liked': obj.item.liked,
                'count_likes' : obj.item.count_likes,
                'me_liked' : obj.item.liked_by_person(person),
                'comments': iter_response(list(obj.item.get_comments()), _refine),
                }
        return base_refine(obj)
    return _refine



@login_required
def index(request):
    person = request.user.get_profile()

    feed = FeedItem.objects.feed_for_person(person)
    feed_proto = iter_response(feed, _refine_person(person))

    if len(feed) == 0:
        return render_to_response('blocks/page-feed-empty/p-feed-empty.html',
            {
                'friends' : person.get_social_friends()
            },
            context_instance=RequestContext(request)
        )
    return render_to_response('blocks/page-feed/p-feed.html',
        {
            'feed' : feed,
            'feed_json': to_json(feed_proto),
        },
        context_instance=RequestContext(request)
    )

@login_required
def view(request):
    person = request.user.get_profile()

    feed = FeedItem.objects.feed_for_person(person)
    feed_proto = iter_response(feed, _refine_person(person))

    return render_to_response('blocks/page-checkin/p-checkin.html',
        {
            'story': feed,
            # 'feed_json': to_json(feed_proto),
        },
        context_instance=RequestContext(request)
    )


@login_required
def comment(request):
    if request.method != 'POST':
        return HttpResponse()

    feed_id = request.POST.get('storyid')
    comment = request.POST.get('message')
    feed = get_object_or_404(FeedItem, id=feed_id)
    obj_comment = feed.comment(request.user.get_profile(), comment)
    if request.is_ajax():
        response = iter_response(obj_comment, base_refine)
        return HttpResponse(to_json(response))
    return HttpResponse()

@login_required
def like(request, action):
    person = request.user.get_profile()
    feed_id = request.POST.get('storyid')
    feed = get_object_or_404(FeedItem, id=feed_id)
    if action == 'like':
        feed.like(request.user.get_profile())
    elif action == 'unlike':
        feed.unlike(request.user.get_profile())
    if request.is_ajax():
        feed_person = FeedItem.objects.feeditem_for_person(feed, person)
        response = iter_response(feed_person, _refine_person(person))
        return HttpResponse(to_json(response))
    return HttpResponse()


@login_required
def item(request, pk):
    feed = get_object_or_404(FeedItem, id=pk)
    context = {
        'feeditem' : feed,
        'me_liked' : request.user.get_profile().id in feed.liked
        }

    return render_to_response('blocks/page-checkin/p-checkin.html',
        context,
        context_instance=RequestContext(request)
)