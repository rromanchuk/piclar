# coding=utf-8
from datetime import date

from django.contrib.auth import login
from django.contrib.auth.decorators import login_required

from django.shortcuts import render_to_response, redirect, get_object_or_404
from django.template import RequestContext
from django.conf import settings
from django.core.urlresolvers import reverse

from django.contrib import messages
from django import forms

from translation import dates

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


class EditProfileForm(forms.Form):
    firstname = forms.CharField(max_length=255, initial='', required=True)
    lastname = forms.CharField(max_length=255, initial='', required=True)
    location = forms.CharField(max_length=255, initial='', required=False)
    photo = forms.FileField(required=False)
    b_day = forms.IntegerField(required=False)
    b_month = forms.IntegerField(required=False)
    b_year = forms.IntegerField(required=False)

    def clean(self):
        cleaned_data = super(EditProfileForm, self).clean()
        if cleaned_data['b_day'] or cleaned_data['b_year']:
            try:
                birthday = date(year=cleaned_data['b_year'],
                    month=cleaned_data['b_month'],
                    day=cleaned_data['b_day']
                )
                cleaned_data['birthday'] = birthday
            except TypeError:
                self._errors["b_day"] = self.error_class(['Дата рождения указана неверно'])

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
        'location' : person.location,
    }
    if person.birthday:
        initial.update({
            'b_day': person.birthday.day,
            'b_month': person.birthday.month,
            'b_year': person.birthday.year,
        })
    form = EditProfileForm(request.POST or None, request.FILES or None, initial=initial)

    if request.method == 'POST' and form.is_valid():
        person.change_profile(
            form.cleaned_data['firstname'],
            form.cleaned_data['lastname'],
            location=form.cleaned_data['location'],
            photo=form.cleaned_data['photo'],
            birthday=form.cleaned_data['birthday'],
        )
        messages.add_message(request, messages.INFO, 'Изменения профиля сохранены')

    return render_to_response('blocks/page-users-profile-edit/p-users-profile-edit.html',
        {
            'formset' : form,
            'months' : dates.MONTHS,
        },
        context_instance=RequestContext(request)
    )

@login_required
def edit_credentials(request):
    form = {}
    return render_to_response('blocks/page-users-credentials-edit/p-users-credentials-edit.html',
        {
            'formset' : form,
        },
      context_instance=RequestContext(request)
    )

@login_required
def enter_email(request):
    pass


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
