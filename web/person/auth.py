from django.contrib.auth import REDIRECT_FIELD_NAME
from django.contrib.auth.decorators import user_passes_test
from django.utils.decorators import available_attrs
from django.conf import settings

from functools import wraps

from person.models import Person


def login_required(view_func=None, login_url=None, redirect_field_name=REDIRECT_FIELD_NAME, skip_test_active=False):
    """
    Decorator for views that checks that the user passes the given test,
    redirecting to the log-in page if necessary. The test should be a callable
    that takes the user object and returns True if the user passes.
    """

    def decorator(view_func):
        @wraps(view_func, assigned=available_attrs(view_func))
        def _wrapped_view(request, *args, **kwargs):
            if not request.user.is_authenticated() or not request.user.get_profile():
                redirect_url = login_url
            elif not skip_test_active and not request.user.get_profile().is_active():
                redirect_url = request.user.get_profile().status_steps.get_action_url()
            else:
                return view_func(request, *args, **kwargs)

            path = request.build_absolute_uri()
            # If the login url is the same scheme and net location then just
            # use the path as the "next" url.
            login_scheme, login_netloc = urlparse.urlparse(redirect_url or
                                                           settings.LOGIN_URL)[:2]
            current_scheme, current_netloc = urlparse.urlparse(path)[:2]
            if ((not login_scheme or login_scheme == current_scheme) and
                (not login_netloc or login_netloc == current_netloc)):
                path = request.get_full_path()
            from django.contrib.auth.views import redirect_to_login
            return redirect_to_login(path, redirect_url, redirect_field_name)
        return _wrapped_view
    if view_func:
        return decorator(view_func)
    else:
        return decorator

