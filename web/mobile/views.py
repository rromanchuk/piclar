from django.shortcuts import render_to_response, get_object_or_404
from django.template import RequestContext
from django.conf import settings
from django.core.urlresolvers import reverse, reverse_lazy
from django.shortcuts import redirect
from django.views.decorators.csrf import ensure_csrf_cookie

from django import forms

from feed.models import FeedItem
from poi.models import Place, Checkin
from person.models import Person

from person.auth import login_required
mobile_login_required = login_required(login_url=reverse_lazy('mobile_login'))

@ensure_csrf_cookie
@mobile_login_required
def feed(request):
    person = request.user.get_profile()
    feed = FeedItem.objects.feed_for_person(person)

    return render_to_response('pages/m_feed.html',
        {
            'feed' : feed
        },
        context_instance=RequestContext(request)
    )

@ensure_csrf_cookie
def index(request):
    if request.user.is_authenticated():
        return redirect('mobile_feed')
    vk_login_url = 'http://oauth.vk.com/authorize?'\
                   'client_id=%s&'\
                   'scope=%s&'\
                   'redirect_uri=%s&'\
                   'display=%s&'\
                   'response_type=token' % (
        settings.VK_CLIENT_ID,
        settings.VK_SCOPES,
        request.build_absolute_uri(reverse('mobile_oauth')),
        'touch'
    )
    return render_to_response('pages/m_index.html',
        {
            'vk_login_url': vk_login_url,
        },
        context_instance=RequestContext(request)
     )

def oauth(request):
    return render_to_response('pages/m_login_oauth.html',
        {},
        context_instance=RequestContext(request)
    )

@ensure_csrf_cookie
@mobile_login_required
def comments(request, pk):
    feed_item = get_object_or_404(FeedItem, id=pk)
    return render_to_response('pages/m_comments.html',
        {
            'feed_item' : feed_item,

        },
        context_instance=RequestContext(request)
    )

@mobile_login_required
def likes(request, pk):
    feed_item = get_object_or_404(FeedItem, id=pk)
    return render_to_response('pages/m_comments.html',
        {
        'feed_item' : feed_item,

        },
    context_instance=RequestContext(request)
)


@mobile_login_required
def checkin(request, pk):
    feed_item = get_object_or_404(FeedItem, id=pk)
    return render_to_response('pages/m_checkin.html',
        {
            'feed_item' : feed_item,
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
    person = get_object_or_404(Person, id=pk)
    last_checkins = Checkin.objects.get_last_person_checkins(person)
    return render_to_response('pages/m_profile.html',
        {
            'last_checkins': last_checkins,
            'person' : person,
            'checkin_count' : Checkin.objects.get_person_checkin_count(person),
            },
        context_instance=RequestContext(request)
    )

class EditProfileForm(forms.Form):
    firstname = forms.CharField(max_length=255, initial='', required=True)
    lastname = forms.CharField(max_length=255, initial='', required=True)
    location = forms.CharField(max_length=255, initial='', required=False)
    birthday = forms.DateField(required=False)


@ensure_csrf_cookie
@mobile_login_required
def profile_edit(request):
    person = request.user.get_profile()
    initial = {
        'firstname': person.firstname,
        'lastname': person.lastname,
        'location' : person.location,
        }
    if person.birthday:
        initial['birthday'] = person.birthday.strftime('%Y-%m-%d')
    form = EditProfileForm(request.POST or None, initial=initial)
    if request.method == 'POST' and form.is_valid():
        person.change_profile(
            form.cleaned_data['firstname'],
            form.cleaned_data['lastname'],
            location=form.cleaned_data['location'],
            birthday=form.cleaned_data['birthday'],
        )
        return redirect('mobile_person_edit')

    return render_to_response('pages/m_profile_edit.html',
        {
            'person' : person,
            'form': form,
        },
        context_instance=RequestContext(request)
    )

@ensure_csrf_cookie
@mobile_login_required
def friend_list(request, pk, action):
    person = request.user.get_profile()
    person_profile = get_object_or_404(Person, id=pk)
    if action == 'following':
        person_list = Person.objects.get_following(person_profile)
    elif action == 'followers':
        person_list = Person.objects.get_followers(person_profile)

    for item in person_list:
        item.me_following = person.is_following(item)
    return render_to_response('pages/m_following.html',
            {
            'person' : person,
            'person_list' : person_list
        },
        context_instance=RequestContext(request)
    )
