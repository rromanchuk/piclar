# coding=utf-8
from datetime import date

import django.contrib.auth
from django.http import HttpResponse
from django.shortcuts import render_to_response, redirect, get_object_or_404
from django.template import RequestContext
from django.conf import settings
from django.core.urlresolvers import reverse

from django.contrib import messages
from django import forms

from translation import dates

from poi.models import Checkin
from person.auth import login_required
from models import Person

from notification.models import Notification
from exceptions import AlreadyRegistered, RegistrationFail

import json

from logging import getLogger

log = getLogger('web.person.view')

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
        cleaned_data['birthday'] = None
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

class EmailForm(forms.Form):
    email = forms.EmailField(initial='', required=True)
    password = forms.CharField(max_length=255, widget=forms.PasswordInput, initial='', required=True)

    def __init__(self, *args, **kwargs):

        if 'person' in kwargs:
            self.person = kwargs['person']
            del kwargs['person']
        else:
            self.person = None

        super(EmailForm, self).__init__(*args, **kwargs)

    def clean(self):
        cleaned_data = super(EmailForm, self).clean()
        persons_with_same_email = Person.objects.filter(email=cleaned_data['email'])
        duplicated_email = (persons_with_same_email.count() > 0)
        if persons_with_same_email.count() == 1 and self.person and persons_with_same_email[0].id == self.person.id:
            duplicated_email = False

        if duplicated_email:
            self._errors["email"] = self.error_class(['Пользователь с таким email уже существует'])

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
                django.contrib.auth.login(request, person.user)
            except AlreadyRegistered as e:
                django.contrib.auth.login(request, e.get_person().user)
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
def subscription(request):
    if not request.is_ajax():
        return redirect('page-index')

    if request.method != 'POST':
        return HttpResponse(json.dumps({
            'status' : 'error',
            'message' : 'incorrect method'
        }))

    if 'userid' not in request.POST and request.is_ajax():
        return HttpResponse(json.dumps({
            'status' : 'error',
            'message' : 'parameter userid is required'
        }))

    person = request.user.get_profile()

    friend = get_object_or_404(person, id=request.POST['userid'])
    action = request.POST.get('action')
    if  action == 'POST':
        person.follow(friend)
    elif action == 'DELETE':
        person.unfollow(friend)

    return HttpResponse(json.dumps({
        'status' : 'ok',
        'message' : 'operation success'
    }))



@login_required
def profile(request, pk):
    person = request.user.get_profile()
    profile_person = get_object_or_404(Person, id=pk)
    Notification.objects.mart_as_read_for_friend(person, profile_person)

    friends = {}
    def fill_friend(user, k1, k2):
        if user.id not in friends:
            friends[user.id] = {}
            friends[user.id]['user'] = user.serialize()

        friends[user.id][k1] = True
        if k2 not in friends[user.id]:
            friends[user.id][k2] = False

        if person.is_following(user):
            friends[user.id]['me_following'] = True
        else:
            friends[user.id]['me_following'] = False

    for user in Person.objects.get_following(profile_person):
        fill_friend(user, 'person_following', 'person_follower')

    for user in Person.objects.get_followers(profile_person):
        fill_friend(user, 'person_follower', 'person_following')

    return render_to_response('blocks/page-users-profile/p-users-profile.html',
        {
            'person' : profile_person,
            'lastcheckin' : Checkin.objects.get_last_person_checkin(profile_person),
            'checkins' : list(Checkin.objects.get_last_person_checkins(profile_person, count=30)),
            'checkin_count' : Checkin.objects.get_person_checkin_count(profile_person),
            'friends' : friends.values(),
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
        return redirect('person-edit-profile')

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
        user = django.contrib.auth.authenticate(username=person.email, password=form.cleaned_data['old_password'])
        if not user or not user.is_active:

            from django.forms.util import ErrorList
            errors = ErrorList()
            errors = form._errors.setdefault(
                forms.forms.NON_FIELD_ERRORS, errors
            )
            errors.append('Старый пароль введен неверно')
        else:
            message = []
            if person.email != form.cleaned_data['email']:
                message.append('Email изменен')
            if form.cleaned_data['new_password']:
                message.append('Пароль изменен')

            person.change_credentials(form.cleaned_data['email'], form.cleaned_data['old_password'], form.cleaned_data['new_password'])
            if message:
                messages.add_message(request, messages.INFO, ', '.join(message))
            else:
                messages.add_message(request, messages.INFO, 'Изменения сохранены')
            return redirect('person_edit_credentials')

    return render_to_response('blocks/page-users-credentials-edit/p-users-credentials-edit.html',
        {
            'formset' : form,
        },
      context_instance=RequestContext(request)
    )

@login_required(skip_test_active=True)
def fill_email(request):
    # IMPORTANT: this page change email and password without checking old password
    # IMPORTANT: it should work once and only for PERSON_STATUS_WAIT_EMAIL

    person = request.user.get_profile()

    if person.status != Person.PERSON_STATUS_WAIT_FOR_EMAIL:
        redirect('person_edit_credentials')

    form = EmailForm(request.POST or None, person=person)

    if request.method == 'POST' and form.is_valid():
        person.change_email(form.cleaned_data['email'])
        person.change_password(form.cleaned_data['password'])
        person.status = person.status_steps.get_next_state()
        person.save()
        return redirect('page-index')

    return render_to_response('blocks/page-users-fill-email/p-users-fill-email.html',
        {
            'formset' : form,
            'person' : person,
        },
        context_instance=RequestContext(request)
    )

@login_required(skip_test_active=True)
def ask_invite(request):
    return render_to_response('blocks/page-users-ask-invite/p-users-ask-invite.html',
        {
        },
        context_instance=RequestContext(request)
    )

@login_required(skip_test_active=True)
def please_wait(request):
    return render_to_response('blocks/page-users-please-wait/p-users-please-wait.html',
            {
        },
        context_instance=RequestContext(request)
    )

def email_confirm(request, token):
    redirect('page-index')

def oauth(request):
    if request.method == 'POST':
        try:
            import social
            social_client = social.provider(request.POST.get('provider', 'vkontakte'))
            person = Person.objects.register_provider(provider=social_client,
                user_id=request.POST.get('user_id'),
                access_token=request.POST.get('access_token')
            )
            django.contrib.auth.login(request, person.user)
        except AlreadyRegistered as e:
            django.contrib.auth.login(request, e.get_person().user)
        except RegistrationFail as e:
            log.exception(e)
            log.error('registration failed')

        if request.is_ajax():
            return HttpResponse('{ status: "ok"}')
        return redirect('page-index')
    else:
        return render_to_response('blocks/page-users-login-oauth/p-users-login-oauth.html',
                {},
                context_instance=RequestContext(request)
            )

def preregistration(request):
    return render_to_response('blocks/page-users-preregistration/p-users-preregistration.html',
        {},
        context_instance=RequestContext(request)
    )

def login(request):
    import django.contrib.auth.views
    if request.user.is_authenticated():
        return redirect('page-index')

    return django.contrib.auth.views.login(request, template_name='blocks/page-users-login/p-users-login.html')

def password_reset(request):
    import django.contrib.auth.views
    return django.contrib.auth.views.password_reset(request, template_name='blocks/page-users-resetpassword/p-users-resetpassword.html', post_reset_redirect=reverse('person-passwordreset-done'))

