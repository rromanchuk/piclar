# coding=utf-8
from django.contrib.auth import login
from django.contrib.auth.decorators import login_required

from django.shortcuts import render_to_response, redirect, get_object_or_404
from django.template import RequestContext
from django.conf import settings
from django.core.urlresolvers import reverse

from django import forms

from models import Person
from exceptions import AlreadyRegistered, RegistrationFail


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


class EditProfileForm(RegistrationForm):
    password = forms.CharField(max_length=255, widget=forms.PasswordInput, initial='', required=False)
    password2 = forms.CharField(max_length=255, widget=forms.PasswordInput, initial='', required=False)

    def clean(self):
        # skip password validation if user didn't change it
        cleaned_data = super(RegistrationForm, self).clean()
        if not cleaned_data['password']:
            return cleaned_data

        if cleaned_data['password'] != cleaned_data['password2']:
            msg = u'Пароли не совпадают'
            self._errors["password2"] = self.error_class([msg])
        return cleaned_data

def registration(request):
    form = RegistrationForm(request.POST or None)
    if request.method == 'POST' and form.is_valid():
            data = form.cleaned_data
            try:
                person = Person.objects.register_simple(
                    data['firstname'],
                    data['lastname'],
                    data['email'],
                    data['password'],
                )
                login(request, person.user)
            except AlreadyRegistered as e:
                login(request, e.get_person().user)
                return redirect('page-index')
            except RegistrationFail:
                from django.forms.util import ErrorList
                errors = ErrorList()
                errors = form._errors.setdefault(
                    forms.forms.NON_FIELD_ERRORS, errors
                )
                errors.append('Извините, пользователь с таким именем уже существует')

            else:
                return redirect('page-index')

    return render_to_response('blocks/page-users-registration/p-users-registration.html',
        { 'formset' : form},
        context_instance=RequestContext(request)
    )


@login_required
def profile(request, pk):
    person = get_object_or_404(Person, id=pk)
    return render_to_response('blocks/page-users-profile/p-users-profile.html',
        {
            'person' : person
        },
        context_instance=RequestContext(request)
    )
@login_required
def edit_profile(request):
    person = request.user.get_profile()
    initial = {
        'firstname': person.firstname,
        'lastname': person.lastname,
        'email': person.email,
    }
    form = EditProfileForm(request.POST or None, initial=initial)
    if request.method == 'POST' and form.is_valid():
        person.change_profile(
            form.cleaned_data['firstname'],
            form.cleaned_data['lastname'],
            form.cleaned_data['email'],
            form.cleaned_data['password'],
        )

    return render_to_response('blocks/page-users-profile-edit/p-users-profile-edit.html',
        {
            'formset' : form
        },
        context_instance=RequestContext(request)
    )


def email_confirm(request):
    redirect('page-index')

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
