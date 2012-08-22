# coding=utf-8
from django.shortcuts import render_to_response
from django.conf.urls import patterns
from django import forms
from django.utils.safestring import mark_safe
from django.contrib.gis import admin
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

class PlaceAdmin(admin.GeoModelAdmin):
    inlines = [
        PhotoInline,
    ]
    def moderation(self, request):
        places = Place.objects.filter(placephoto__isnull=False)[0]

        return render_to_response('admin/moderate.html', {
            'places' : places
        })

    def get_urls(self):
        urls = super(PlaceAdmin, self).get_urls()
        my_urls = patterns('',
            (r'^moderate/$', self.admin_site.admin_view(self.moderation))
        )
        return my_urls + urls



admin.site.register(Place, PlaceAdmin)
admin.site.register(Checkin, admin.GeoModelAdmin)