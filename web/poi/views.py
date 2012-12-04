from django.shortcuts import render_to_response, redirect, get_object_or_404
from django.template import RequestContext
from person.auth import login_required
from django.core.urlresolvers import reverse
from django.http import HttpResponse

from models import Place
from feed.models import FeedItem
from ostrovok_common.utils.urls import force_http
from logging import getLogger

log = getLogger('web.poi.views')

def index(request):
    if request.user.is_authenticated():
        return redirect(force_http(reverse('feed'), request))

    popular_places = Place.objects.popular()
    feed_items = {}
    for place in popular_places:
        try:
            checkin = place.checkin_set.all()[0]
            # DIRTY HACK - set property for view only
            place.likes_cnt = len(FeedItem.objects.get(id=checkin.feed_item_id).liked)
        except FeedItem.DoesNotExist:
            log.error('checkin [%s] - feeditem %s does not found' % (checkin.id, checkin.feed_item_id))
            continue

    return render_to_response('blocks/page-index/p-index.html',
        {
            'popular' : popular_places,
            'feed_items' : feed_items,
        },
        context_instance=RequestContext(request)
    )

def place(request, pk):
    place = get_object_or_404(Place, id=pk)
    return render_to_response('blocks/page-place/p-place.html',
        {
        'place' : place,
        },
        context_instance=RequestContext(request)
    )

def checkin(request):
    if request.method == 'POST' and request.POST.get('image'):
        file = request.POST['image']
        import base64
        data = base64.decodestring(file)
        return HttpResponse(data, content_type="image/png")
    return HttpResponse('')


