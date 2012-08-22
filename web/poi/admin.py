# coding=utf-8
from xact import xact
from django.template import RequestContext
from django.shortcuts import render_to_response, redirect
from django.conf.urls import patterns, url
from django.contrib.gis import admin
from django.utils.safestring import mark_safe
from django.db import models

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
        fields = ['title', 'description', 'type', 'address']


    def clean(self):
        cleaned_data = super(PlaceModerationForm, self).clean()
        if cleaned_data['type'] == Place.TYPE_UNKNOW:
            self._errors["type"] = self.error_class(['Выберите тип места'])
        return cleaned_data

class PlaceAdmin(admin.GeoModelAdmin):
    inlines = [
        PhotoInline,
    ]

    @xact
    def moderation(self, request):
        place = Place.objects.filter(placephoto__isnull=False, moderated_status=Place.MODERATED_NONE).order_by('provider_popularity')[0]
        photos = []

        print place
        form = PlaceModerationForm(request.POST or None, instance=place)
        if place.placephoto_set.exclude(moderated_status=PlacePhoto.MODERATED_NONE).count() == 0:
            photos = place.placephoto_set.all()

        if request.method == 'POST':
            if request.POST.get('bad'):
                place.moderated_status = Place.MODERATED_BAD
                place.save()
            elif request.POST.get('good') and form.is_valid():
                place = form.save()
                place.moderated_status = Place.MODERATED_GOOD
                place.save()
                good_ids = [int(id) for id in request.POST.getlist('photo')]
                for photo in photos:
                    if photo.id in good_ids:
                        photo.moderated_status = PlacePhoto.MODERATED_GOOD
                    else:
                        photo.moderated_status = PlacePhoto.MODERATED_BAD
                    photo.save()
            return redirect('admin:place_moderation')

        return render_to_response('admin/moderate.html', {
            'place' : place,
            'photos' : photos,
            'form' : form,
        }, context_instance=RequestContext(request))

    def get_urls(self):
        urls = super(PlaceAdmin, self).get_urls()
        my_urls = patterns('',
            url(r'^moderate/$', self.admin_site.admin_view(self.moderation), name='place_moderation')
        )
        return my_urls + urls



admin.site.register(Place, PlaceAdmin)
admin.site.register(Checkin, admin.GeoModelAdmin)