from django.shortcuts import render_to_response, get_object_or_404
from django.template import RequestContext

from models import Code
def codes(request):
    try:
        code = Code.objects.get_code_for_internal_invite(request)
    except Code.DoesNotExist:
        code = None
    return render_to_response('blocks/page-invite-codes/p-invite-codes.html',
            {
            'code' : code,
            },
        context_instance=RequestContext(request)
    )

