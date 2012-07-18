# coding=utf-8
from django.contrib.auth import login
from django.shortcuts import render_to_response, redirect
from django.template import RequestContext
from django.conf import settings
from django.core.urlresolvers import reverse

from django import forms

from person.models import Person


class RegistrationForm(forms.Form):
    firstname = forms.CharField(max_length=255, initial='', required=True)
    lastname = forms.CharField(max_length=255, initial='', required=True)
    email = forms.EmailField(initial='', required=True)
    password = forms.CharField(max_length=255, widget=forms.PasswordInput, initial='', required=True)
    password2 = forms.CharField(max_length=255, widget=forms.PasswordInput, initial='', required=True)

    def clean(self):
        cleaned_data = super(RegistrationForm, self).clean()
        if cleaned_data['password'] != cleaned_data['password2']:
            msg = u'Пароли не совпадают'
            self._errors["password2"] = self.error_class([msg])
        return cleaned_data

def registration(request):
    form = RegistrationForm(request.POST or None)
    if request.method == 'POST' and form.is_valid():
            data = form.cleaned_data
            try:
                Person.objects.register_simple(
                    data['firstname'],
                    data['lastname'],
                    data['email'],
                    data['password'],
                )
            except Person.AlreadyRegistered as e:
                pass
            return redirect('page-index')

    return render_to_response('blocks/page-users_registration/p-users_registration.html',
        { 'formset' : form},
        context_instance=RequestContext(request)
    )

# was replaced by django.contrib.auth.views.login
def login(request):
    form = RegistrationForm(request.POST or None)
    if request.method == 'POST' and form.is_valid():
        user = authenticate(username=form.cleaned_data['email'], password=form.cleaned_data['password'])
        if user is not None:
            if user.is_active:
                login(request, user)
        else:
            pass

    return render_to_response('blocks/page-users_login/p-users_login.html',
        {
            'formset' : form
        },
        context_instance=RequestContext(request)
    )


def oauth(request):
    return render_to_response('blocks/page-users_login_oauth/p-users_login_oauth.html',
        {},
        context_instance=RequestContext(request)
    )

def preregistration(request):
    return render_to_response('blocks/page-users_preregistration/p-users_preregistration.html',
        {},
        context_instance=RequestContext(request)
    )
