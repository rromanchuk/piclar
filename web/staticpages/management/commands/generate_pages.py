# coding=utf-8
from django.core.management.base import BaseCommand, CommandError
from django.conf import settings
from django.template.loader import render_to_string
import os

class Command(BaseCommand):

    FILES = {
        '404.html' : 'blocks/page-error404/p-error404.html',
        '500.html' : 'blocks/page-error500/p-error500.html',
        'coming_soon.html' : 'blocks/page-landing-comingsoon/p-landing-comingsoon.html',
    }

    def handle(self, *args, **options):
        for filename, template in self.FILES.items():
            f = file(os.path.join(settings.STATIC_ROOT, filename), 'wb+')
            f.write(render_to_string(template, {}).encode('utf-8'))
            f.close()