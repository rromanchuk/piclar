# coding=utf-8
from django.contrib.auth import login
from django.shortcuts import render_to_response, redirect, get_object_or_404
from django.template import RequestContext
from django.conf import settings
from django.core.urlresolvers import reverse

from django import forms

from person.models import Person


class EditProfileForm(forms.Form):
    firstname = forms.CharField(max_length=255, initial='', required=True)
    lastname = forms.CharField(max_length=255, initial='', required=True)
    email = forms.EmailField(initial='', required=True)
    password = forms.CharField(max_length=255, widget=forms.PasswordInput, initial='', required=True)
    password2 = forms.CharField(max_length=255, widget=forms.PasswordInput, initial='', required=True)

    def clean(self):
        cleaned_data = super(EditProfileForm, self).clean()
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

    return render_to_response('blocks/page-users-registration/p-users-registration.html',
        { 'formset' : form},
        context_instance=RequestContext(request)
    )

# was replaced by django.contrib.auth.views.login
def login(request):
    form = EditProfileForm(request.POST or None)
    if request.method == 'POST' and form.is_valid():
        user = authenticate(username=form.cleaned_data['email'], password=form.cleaned_data['password'])
        if user is not None:
            if user.is_active:
                login(request, user)
        else:
            pass

    return render_to_response('blocks/page-users-login/p-users-login.html',
        {
            'formset': form
        },
        context_instance=RequestContext(request)
    )

def profile(request, pk):
    person = get_object_or_404(Person, id=pk)
    return render_to_response('blocks/page-users-login-oauth/p-users-login-oauth.html',
        {
            'person' : person
        },
        context_instance=RequestContext(request)
    )

def edit_profile(request):
    form = EditProfileForm(request.POST or None)
    return render_to_response('blocks/page-users-login-oauth/p-users-login-oauth.html',
        {
            'formset' : form
        },
        context_instance=RequestContext(request)
    )

def oauth(request):
    return render_to_response('blocks/page-users-login-oauth/p-users-login-oauth.html',
        {},
        context_instance=RequestContext(request)
    )


def preregistration(request):
    return render_to_response('blocks/page-users-preregistration/p-users-preregistration.html',
        {},
        context_instance=RequestContext(request)
    )
