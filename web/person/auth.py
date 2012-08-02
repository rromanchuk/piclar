from django.contrib.auth.decorators import login_required as django_login_required

def login_required(f):
        def wrap(request, *args, **kwargs):
            pass
        return django_login_required(f)