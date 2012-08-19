from django.shortcuts import render_to_response, get_object_or_404
from django.template import RequestContext
from django.conf import settings
from django.core.urlresolvers import reverse, reverse_lazy

from feed.models import FeedItem
from poi.models import Place

from person.auth import login_required
mobile_login_required = login_required(login_url=reverse_lazy('mobile_login'))

@mobile_login_required
def index(request):
    person = request.user.get_profile()
    feed = FeedItem.objects.feed_for_person(person)

    return render_to_response('pages/m_index.html',
        {
            'feed' : feed
        },
        context_instance=RequestContext(request)
    )

def login(request):
    vk_login_url = 'http://oauth.vk.com/authorize?'\
                   'client_id=%s&'\
                   'scope=%s&'\
                   'redirect_uri=%s&'\
                   'display=%s&'\
                   'response_type=token' % (
        settings.VK_CLIENT_ID,
        'friends,notify,photos,status,wall,offline,notifications',
        request.build_absolute_uri(reverse('mobile_oauth')),
        'touch'
    )

    return render_to_response('pages/m_login.html',
        {
            'vk_login_url': vk_login_url
        },
        context_instance=RequestContext(request)
     )


def oauth(request):
    return render_to_response('pages/m_login_oauth.html',
        {},
        context_instance=RequestContext(request)
    )

@mobile_login_required
def comments(request, pk):
    feed_item = get_object_or_404(FeedItem, id=pk)
    return render_to_response('pages/m_comments.html',
        {
            'feed_item' : feed_item
        },
        context_instance=RequestContext(request)
    )

@mobile_login_required
def checkin(request, pk):
    feed_item = get_object_or_404(FeedItem, id=pk)
    return render_to_response('pages/m_checkin.html',
        {
            'feed_item' : feed_item
        },
        context_instance=RequestContext(request)
    )

@mobile_login_required
def place(request, pk):
    place = get_object_or_404(Place, id=pk)
    return render_to_response('pages/m_place.html',
        {
            'place' : place,
        },
        context_instance=RequestContext(request)
    )

@mobile_login_required
def profile(request, pk):

    return render_to_response('pages/m_profile.html',
        {
        },
        context_instance=RequestContext(request)
    )
