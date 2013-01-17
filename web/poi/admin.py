# coding=utf-8
from xact import xact
from django.template import RequestContext
from django.shortcuts import render_to_response, redirect
from django.conf.urls import patterns, url
from django.contrib.gis import admin
from django.utils.safestring import mark_safe
from django.db import models
from django.db.models import Q

from django import forms

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
        }, context_instance=RequestContext(request))

    def get_urls(self):
        urls = super(PlaceAdmin, self).get_urls()
        my_urls = patterns('',
            url(r'^moderate/$', self.admin_site.admin_view(self.moderation), name='poi_place_place_moderation')
        )
        return my_urls + urls

class SearchPlaceForm(forms.Form):
    lat = forms.FloatField()
    lng = forms.FloatField()

class SelectPlaceForm(forms.Form):
    place_id = forms.ChoiceField(widget=forms.RadioSelect)
    lat = forms.FloatField(widget=forms.HiddenInput)
    lng = forms.FloatField(widget=forms.HiddenInput)

    def __init__(self, *args, **kwargs):
        data = kwargs.get('additional_data', {})
        if 'additional_data' in kwargs:
            del kwargs['additional_data']

        if data:
            lat, lng = data.get('lat'), data.get('lng')

        if len(args) > 0:
            data = args[0]
            lat, lng = data.get('lat'), data.get('lng')

        places = Place.objects.search(lat, lng)

        super(SelectPlaceForm, self).__init__(*args, **kwargs)
        self.fields['place_id'] = forms.ChoiceField(widget=forms.RadioSelect, choices=[(place.id, place.title) for place in places])
        self.fields['lat'] = forms.FloatField(widget=forms.HiddenInput, initial=lat)
        self.fields['lng'] = forms.FloatField(widget=forms.HiddenInput, initial=lng)



class EditCheckinForm(forms.Form):
    place_id = forms.IntegerField(widget=forms.HiddenInput)
    rate = forms.ChoiceField(choices=[(i,i) for i in range(1,6)], widget=forms.RadioSelect)
    review = forms.CharField(widget=forms.Textarea)
    photo = forms.ImageField()

    def __init__(self, *args, **kwargs):
        data = kwargs.get('additional_data', {})
        if 'additional_data' in kwargs:
            del kwargs['additional_data']

        if data:
            place_id = data.get('place_id')

        if len(args) > 0:
            data = args[0]
            place_id = data.get('place_id')


        super(EditCheckinForm, self).__init__(*args, **kwargs)
        self.fields['place_id'] = forms.IntegerField(widget=forms.HiddenInput, initial=place_id)


class EditorialCheckin(Checkin):
    class Meta:
        proxy = True

class EditorialCheckinAdmin(admin.ModelAdmin):

    add_form_template = 'admin/checkin_add.html'

    def queryset(self, request):
        qs = super(EditorialCheckinAdmin, self).queryset(request)
        return qs.filter(is_good=True)

    def add_view(self, request, form_url='', extra_context=None):
        steps = [
            ('search_place', SearchPlaceForm,),
            ('select_place', SelectPlaceForm,),
            ('edit_checkin', EditCheckinForm)
        ]


        current_step = int(request.REQUEST.get('current_step', 0))

        form_cls = steps[current_step][1]
        current_form = form_cls(request.POST or None, request.FILES or None)

        if request.method == 'POST' and current_form.is_valid():
            data = current_form.cleaned_data
            if current_step + 1 < len(steps):
                next_form = steps[current_step+1][1](additional_data=data)
                #next_form.process_data(data)
                current_step = current_step + 1
                form_to_show = next_form
            else:
                place = Place.objects.get(id=request.POST['place_id'])

                checkin = Checkin.objects.create_checkin(request.user.get_profile(), [], place, data['review'], data['rate'], data['photo'])
                checkin.is_good = True
                checkin.save()
                self.message_user(request, u'Описание места %s было сохранено' % (place.title))
                return redirect('admin:poi_editorialcheckin_add')
        else:
            form_to_show = current_form


        extra_context = {
            'form_to_show' : form_to_show,
            'current_step' : current_step
        }
        if current_step == 2 and request.POST.get('place_id'):
            extra_context.update({
                'place' : Place.objects.get(id=request.POST['place_id'])
            })
        return super(EditorialCheckinAdmin, self).add_view(request, form_url='', extra_context=extra_context)



    def get_urls(self):
        urls = super(EditorialCheckinAdmin, self).get_urls()
        #my_urls = patterns('',
        #    url(r'^search_place/$', self.admin_site.admin_view(self.search_place), name='poi_checkin_checkin_searchplace')
        #)
        #return my_urls + urls
        return urls


admin.site.register(Place, PlaceAdmin)
admin.site.register(Checkin, admin.GeoModelAdmin)
admin.site.register(EditorialCheckin, EditorialCheckinAdmin)
