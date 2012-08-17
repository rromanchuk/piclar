from django.shortcuts import render_to_response
from django.template import RequestContext
from django.conf import settings
from django.core.urlresolvers import reverse, reverse_lazy


from person.auth import login_required

@login_required(login_url=reverse_lazy('mobile_login'))
def index(request):
    return render_to_response('pages/m_index.html',
        {},
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
