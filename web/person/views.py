from django.shortcuts import render_to_response
from django.template import RequestContext
from django.conf import settings
from django.core.urlresolvers import reverse

from django import forms

class RegistrationForm(forms.Form):
    firstname = forms.CharField(max_length=255, initial='', required=True)
    lastname = forms.CharField(max_length=255, initial='', required=True)
    email = forms.EmailField(initial='', required=True)
    password = forms.CharField(max_length=255, widget=forms.PasswordInput,  required=True)
    password2 = forms.CharField(max_length=255, widget=forms.PasswordInput, required=True)

def registration(request):
    form = RegistrationForm(request.POST or None)
    if request.method == 'POST':
        if form.is_valid():
            pass

    return render_to_response('blocks/page-users_registration/p-users_registration.html',
        { 'formset' : form},
        context_instance=RequestContext(request)
    )


def oauth(request):
    return render_to_response('blocks/page-users_login_oauth/p-users_login_oauth.html',
        {},
        context_instance=RequestContext(request)
    )

def login(request):

    return render_to_response('blocks/page-users_login/p-users_login.html',
        {},
        context_instance=RequestContext(request)
    )


def preregistration(request):
    return render_to_response('blocks/page-users_preregistration/p-users_preregistration.html',
        {},
        context_instance=RequestContext(request)
    )
