from django.contrib import admin
from models import Person, SocialPerson
from poi.models import Checkin

from django.shortcuts import redirect
from django.conf.urls import patterns, url

class PersonToApprove(Person):
    class Meta:
        proxy = True

class PersonApprovalAdmin(admin.ModelAdmin):
    change_form_template = 'admin/my_change_form.html'

    search_fields = [ 'full_name', 'email' ]
    list_display = ['full_name', 'email', 'create_date', 'modified_date']

    def queryset(self, request):
        qs = super(PersonApprovalAdmin, self).queryset(request)
        return qs.filter(status=Person.PEREON_STATUS_WAIT_FOR_CONFIRM_INVITATION).order_by('create_date')

    def change_view(self, request, object_id, form_url='', extra_context=None):
        if not extra_context:
            extra_context = {}
        person = Person.objects.get(id=object_id)
        extra_context['checkin'] = Checkin.objects.get_last_person_checkin(person)
        return super(PersonApprovalAdmin, self).change_view(request, object_id, form_url='', extra_context=extra_context)

    def approve(self, request):
        person = Person.objects.get(id=request.POST['obj_id'])
        if 'approve' in request.POST:
            person.status = person.status_steps.get_next_state()
            from notification import urbanairship
            urbanairship.send_notification(person.id, u'Ваша заявка одобрена! Добро пожаловать в Ostronaut!', extra={'type': 'notification_approved'})
            person.save()

        return redirect('admin:person_persontoapprove_change', person.id);

    def get_urls(self):
        urls = super(PersonApprovalAdmin, self).get_urls()
        my_urls = patterns('',
            url(r'^approve/$', self.admin_site.admin_view(self.approve), name='person_approve')
        )
        return my_urls + urls


admin.site.register(PersonToApprove, PersonApprovalAdmin)
admin.site.register(Person)
admin.site.register(SocialPerson)
