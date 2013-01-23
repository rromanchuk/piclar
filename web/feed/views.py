from django.http import HttpResponse, Http404
from django.shortcuts import render_to_response, redirect, get_object_or_404
from django.template import RequestContext
from django.conf import settings
from django.core.urlresolvers import reverse

from person.auth import login_required

from api.v1.serializers import to_json, iter_response, simple_refine
from feed.models import FeedItem, FeedPersonItem, FeedItemComment, ITEM_ON_PAGE
from person.models import Person
from poi.models import Place
from notification.models import Notification

from django.utils.html import escape

# DEAD CODE
def base_refine(obj):
    obj = simple_refine(obj)

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
            'format_address': obj.format_address,
            'description' : obj.description,
            'url' : obj.url,
            }

    if isinstance(obj, Person):
        return iter_response(obj.get_profile_data(), base_refine)
    return obj

# DEAD CODE
def _refine_person(person):
    def _refine(obj):
        if isinstance(obj, FeedPersonItem):
            proto = {
                'id' : obj.item.id,
                'uniqid' : obj.uniqid,
                'create_date' : _refine(obj.item.create_date),
                'share_date' : _refine(obj.create_date),
                'creator': iter_response(obj.item.creator, _refine),
                'url' : obj.item.url,
                'data' : iter_response(obj.item.get_data(), _refine),
                'liked': iter_response(obj.item.liked_person, _refine),
                'count_likes' : obj.item.count_likes,
                'me_liked' : obj.item.liked_by_person(person),
                'comments': iter_response(obj.item.get_comments(), _refine),
                }
            if hasattr(obj.item, 'show_reason'):
                proto['show_reason'] = iter_response(obj.item.show_reason, _refine)
            return proto
        return base_refine(obj)
    return _refine



@login_required
def index(request):
    person = request.user.get_profile()

    #feed = FeedItem.objects.feed_for_person(person, request.REQUEST.get('storyid', None))

    feed = FeedItem.objects.feed_for_person(person, from_uid=request.REQUEST.get('uniqid', None))
    feed_proto = [item.serialize(request) for item in feed]

    if request.is_ajax():
        next_chunk = FeedItem.objects.feed_for_person(person, from_uid=feed_proto[-1]['uniqid'], limit=1)
        if next_chunk:
            status = 'OK'
        else:
            status = 'LAST'
        return HttpResponse(to_json({
            'status' : status,
            'data' : feed_proto,
        }, custom_datetime=True))

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
            'feed_json': to_json(feed_proto, escape_entities=True, custom_datetime=True),
        },
        context_instance=RequestContext(request)
    )

@login_required
def featured(request):
    # TODO: refactor it!
    person = request.user.get_profile()

    #feed = FeedItem.objects.feed_for_person(person, request.REQUEST.get('storyid', None))

    feed = FeedItem.objects.feed_for_person(person, from_uid=request.REQUEST.get('uniqid', None))
    feed_proto = [item.serialize(request) for item in feed]

    if request.is_ajax():
        next_chunk = FeedItem.objects.feed_for_person(person, from_uid=feed_proto[-1]['uniqid'], limit=1)
        if next_chunk:
            status = 'OK'
        else:
            status = 'LAST'
        return HttpResponse(to_json({
            'status' : status,
            'data' : feed_proto,
            }, custom_datetime=True))

    return render_to_response('blocks/page-featured/p-featured.html',
            {
            'feed' : feed,
            'feed_json': to_json(feed_proto, escape_entities=True, custom_datetime=True),
            },
        context_instance=RequestContext(request)
    )

@login_required
def comment(request):
    if request.method != 'POST':
        return HttpResponse()

    action = request.POST.get('action')

    feed_id = request.POST.get('storyid')
    feed_item = get_object_or_404(FeedItem, id=feed_id)
    if action == 'DELETE':
        try:
            comment_id = request.REQUEST.get('commentid')
            feed_item.delete_comment(request.user.get_profile(), comment_id)
        except FeedItemComment.DoesNotExist:
            return Http404()
        return HttpResponse()

    if action == 'POST':
        comment = request.REQUEST.get('message')
        obj_comment = feed_item.create_comment(request.user.get_profile(), comment)
        if request.is_ajax():
            response = obj_comment.serialize()
            return HttpResponse(to_json(response, escape_entities=True, custom_datetime=True))
    return HttpResponse()

@login_required
def like(request):
    if request.REQUEST.get('action') not in ['POST', 'DELETE']:
        return HttpResponse()

    action = request.REQUEST.get('action')
    person = request.user.get_profile()
    feed_id = request.REQUEST.get('storyid')
    feed = get_object_or_404(FeedItem, id=feed_id)
    if action== 'POST':
        feed.like(request.user.get_profile())
    elif action == 'DELETE':
        feed.unlike(request.user.get_profile())

    if request.is_ajax():
        feed_person = FeedItem.objects.feeditem_for_person(feed, person)
        response = feed_person.serialize(request)
        return HttpResponse(to_json(response, escape_entities=True, custom_datetime=True))
    return HttpResponse()


@login_required
def item(request, pk):
    try:
        feed = FeedItem.objects.active_objects().get(id = pk)
    except FeedItem.DoesNotExist:
        raise Http404()

    Notification.objects.mart_as_read_for_feed(request.user.get_profile(), feed)

    context = {
        'feeditem' : feed,
        'me_liked' : request.user.get_profile().id in feed.liked
        }

    return render_to_response('blocks/page-checkin/p-checkin.html',
        context,
        context_instance=RequestContext(request)
)
