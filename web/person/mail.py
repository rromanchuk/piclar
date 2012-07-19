from django.core.mail import EmailMessage
from django.conf import settings
from django.template.loader import render_to_string

def send_mail_to_person(person, type, params):
    message = EmailMessage()
    message.to_email = person.email
    message.subject = 'Notification [%s]' % type
    context = {
        'sender' : person,
        'type' : type,
    }
    context.update(params)

    message.body = render_to_string('mail/%s.html' % type, context)
    message.send()
