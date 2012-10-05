from django.core.management.base import BaseCommand, CommandError
from invitation.models import Code

import random

from logging import getLogger

log = getLogger('web.invatation.commands')

class Command(BaseCommand):

    def handle(self, *args, **kwargs):
        num_codes = int(args[0])
        population = 'abcdefghjiklmnopqrstuvwxyz0123456789'
        length = 7
        for i in range(0, num_codes):
            value = ''
            for j in range(0, length):
                value += random.choice(population)

            code = Code(value=value)
            code.save()
