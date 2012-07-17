from django.shortcuts import render_to_response
from django.template import RequestContext

from models import Place

def index(request):
    popular_places = Place.objects.popular()
    return render_to_response('blocks/page-index/p-index.html',
        {
            'popular' : popular_places,
        },
        context_instance=RequestContext(request)
    )


def test(request):
    return render_to_response('blocks/page-index/p-test.html',
        {},
        context_instance=RequestContext(request)
    )

