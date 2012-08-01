# coding=utf-8
from datetime import date

from django.contrib.auth import login, authenticate
from django.contrib.auth.decorators import login_required

from django.shortcuts import render_to_response, redirect, get_object_or_404
from django.template import RequestContext
from django.conf import settings
from django.core.urlresolvers import reverse

from django.contrib import messages
from django import forms

from translation import dates

from poi.models import Checkin


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

class CredentialForm(forms.Form):
    email = forms.EmailField(initial='', required=True)
    old_password = forms.CharField(max_length=255, widget=forms.PasswordInput, initial='', required=True)
    new_password = forms.CharField(max_length=255, widget=forms.PasswordInput, initial='', required=False)
    new_password2 = forms.CharField(max_length=255, widget=forms.PasswordInput, initial='', required=False)

    def clean(self):
        cleaned_data = super(CredentialForm, self).clean()
        if  cleaned_data['new_password'] or cleaned_data['new_password2']:
            if cleaned_data['new_password'] != cleaned_data['new_password2']:
                msg = u'Пароли не совпадают'
                self._errors["new_password2"] = self.error_class([msg])
        return cleaned_data



class EditProfileForm(forms.Form):
    firstname = forms.CharField(max_length=255, initial='', required=True)
    lastname = forms.CharField(max_length=255, initial='', required=True)
    location = forms.CharField(max_length=255, initial='', required=False)
    photo = forms.FileField(required=False)
    b_day = forms.IntegerField(required=False, min_value=1, max_value=31)
    b_month = forms.IntegerField(required=False, min_value=1, max_value=12)
    b_year = forms.IntegerField(required=False, max_value=date.today().year)

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
            'person' : person,
            'lastcheckin' : Checkin.objects.get_last_person_checkin(person),
            'checkin_count' : Checkin.objects.get_person_checkin_count(person),
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
            'b_day': unicode(person.birthday.day),
            'b_month': unicode(person.birthday.month),
            'b_year': unicode(person.birthday.year),
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
    person = request.user.get_profile()
    initial = {
        'email' : person.email,
    }
    form = CredentialForm(request.POST or None, initial=initial)
    if request.method == 'POST' and form.is_valid():
        user = authenticate(username=person.email, password=form.cleaned_data['old_password'])
        if not user or not user.is_active:

            from django.forms.util import ErrorList
            errors = ErrorList()
            errors = form._errors.setdefault(
                forms.forms.NON_FIELD_ERRORS, errors
            )
            errors.append('Старый пароль введен неверно')
        else:
            person.change_credentials(form.cleaned_data['email'], form.cleaned_data['old_password'], form.cleaned_data['new_password'])
            message = []
            if person.email != form.cleaned_data['email']:
                message.append('Email изменен')
            if form.cleaned_data['new_password']:
                message.append('Пароль изменен')

            if message:
                messages.add_message(request, messages.INFO, ', '.join(message))
            else:
                messages.add_message(request, messages.INFO, 'Изменения сохранены')

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
