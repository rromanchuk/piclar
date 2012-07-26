from django.shortcuts import render_to_response, redirect, get_object_or_404
from django.template import RequestContext
from django.contrib.auth.decorators import login_required

from models import Place, Checkin

def index(request):
    if request.user.is_authenticated():
        return redirect('feed')

    popular_places = Place.objects.popular()
    return render_to_response('blocks/page-index/p-index.html',
        {
            'popular' : popular_places,
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


@login_required
def place_checkin(request, place_pk, checkin_pk):
    place = get_object_or_404(Place, id=place_pk)
    checkin = get_object_or_404(Checkin, id=checkin_pk)
    return render_to_response('blocks/page-checkin/p-checkin.html',
        {
        'place' : place,
        'checkin' : checkin,
        },
        context_instance=RequestContext(request)
    )