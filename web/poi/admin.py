# coding=utf-8
from xact import xact
from django.template import RequestContext
from django.shortcuts import render_to_response, redirect
from django.conf.urls import patterns, url
from django.contrib.gis import admin
from django.utils.safestring import mark_safe
from django.db import models
from django.db.models import Q

from datetime import datetime, timedelta
from django import forms
from models import Place, PlacePhoto, Checkin

class CustomImageWidget(forms.TextInput):
    def render(self, name, value, attrs=None):
        if value:
            return mark_safe('<img src="%s" width=200 height=200>' % value)
        else:
            return super(CustomImageWidget,self).render(name, value, attrs)


class PhotoForm(forms.ModelForm):
    url = forms.CharField(widget=CustomImageWidget())
    class Meta:
        model = PlacePhoto
        exclude = ['name']

class PhotoInline(admin.TabularInline):
    model = PlacePhoto
    form = PhotoForm

class PlaceModerationForm(forms.ModelForm):
    class Meta:
        model = Place
        fields = ['id', 'title', 'description', 'type', 'address']


    def clean(self):
        cleaned_data = super(PlaceModerationForm, self).clean()
        if cleaned_data['type'] == Place.TYPE_UNKNOW:
            self._errors["type"] = self.error_class(['Выберите тип места'])
        return cleaned_data

def moderate_status(obj):
    return dict(Place.MODERATED_CHOICES)[obj.moderated_status]

class PlaceAdmin(admin.GeoModelAdmin):
    inlines = [
        PhotoInline,
    ]

    search_fields = [ 'title', 'address' ]
    list_display = ['title', moderate_status , 'moderated_by', 'moderated_date', 'provider_popularity']
    list_filter = [ 'moderated_status' ]
    ordering = ['moderated_date']

    change_list_template = 'admin/change_list1.html'

    @xact
    def moderation(self, request):
        if 'id' in request.GET:
            place = Place.objects.get(id=request.GET['id'])
        else:
            place_qs = Place.objects.filter(
                placephoto__isnull=False,
                moderated_status=Place.MODERATED_NONE,
            ).order_by('-provider_popularity')

            mod_lock_q = Q(lock_moderation_user=request.user) | Q(lock_moderation__lte=datetime.now()-timedelta(minutes=5)) | Q(lock_moderation__isnull=True) | Q(lock_moderation_user__isnull=True)

            place_qs = place_qs.filter(mod_lock_q)

            place_to_moderate_count = place_qs.count()
            if  place_to_moderate_count == 0:
                return render_to_response('admin/moderate.html', {}, context_instance=RequestContext(request))

            place = place_qs[0]

        place.lock_moderation = datetime.today()
        place.lock_moderation_user = request.user
        place.save()

        photos = []

        form = PlaceModerationForm(request.POST or None, instance=place)
        photos = place.placephoto_set.all()

        if request.method == 'POST':
            mod_place = Place.objects.get(id=request.POST.get('id'))
            if request.POST.get('bad'):
                mod_place.moderated_status = Place.MODERATED_BAD
                mod_place.moderated_by = request.user
                mod_place.moderated_date = datetime.today()
                mod_place.save()
                return redirect('admin:poi_place_place_moderation')
            elif request.POST.get('good') and form.is_valid():
                place = form.save()
                place.moderated_status = Place.MODERATED_GOOD
                place.moderated_by = request.user
                place.moderated_date = datetime.today()
                place.save()
                good_ids = [int(id) for id in request.POST.getlist('photo')]
                for photo in photos:
                    if photo.id in good_ids:
                        photo.moderated_status = PlacePhoto.MODERATED_GOOD
                    else:
                        photo.moderated_status = PlacePhoto.MODERATED_BAD
                    photo.save()
                return redirect('admin:poi_place_place_moderation')

        prev_qs = Place.objects.filter(moderated_by=request.user).order_by('-moderated_date')

        prev_place = None
        if prev_qs.count() > 0:
            prev_place = prev_qs[0]
        return render_to_response('admin/moderate.html', {
            'place' : place,
            'prev_place' : prev_place,
            'photos' : photos,
            'form' : form,
            'place_to_moderate_count' : place_to_moderate_count,
        }, context_instance=RequestContext(request))

    def get_urls(self):
        urls = super(PlaceAdmin, self).get_urls()
        my_urls = patterns('',
            url(r'^moderate/$', self.admin_site.admin_view(self.moderation), name='poi_place_place_moderation')
        )
        return my_urls + urls



admin.site.register(Place, PlaceAdmin)
admin.site.register(Checkin, admin.GeoModelAdmin)