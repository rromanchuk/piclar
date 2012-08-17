from django.contrib.auth import REDIRECT_FIELD_NAME
from django.contrib.auth.decorators import user_passes_test

from django.conf import settings
from person.models import Person

def login_required(function=None, redirect_field_name=REDIRECT_FIELD_NAME, login_url=None, skip_test_active=False):
    """
    Decorator for views that checks that the user is logged in, redirecting
    to the log-in page if necessary.
    """
    login_decorator = user_passes_test(
        lambda u: u.is_authenticated(),
        login_url=login_url,
        redirect_field_name=redirect_field_name
    )
    active_decorator = user_passes_test(
        lambda u: u.is_authenticated() and  u.get_profile().status == Person.PERSON_STATUS_ACTIVE,
        login_url=settings.INACTIVE_USER_REDIRECT_URL,
        redirect_field_name=redirect_field_name
    )



    if function:
        result = login_decorator(function)
        if not skip_test_active:
            result = active_decorator(result)
        return result
    else:
        def custom_wrap(view_func):
            result = view_func
            if not skip_test_active:
                result = active_decorator(view_func)
            return login_decorator(result)
        return custom_wrap


