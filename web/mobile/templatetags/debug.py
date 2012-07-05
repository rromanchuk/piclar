# coding: utf-8 

from django import template
from django.conf import settings
import jsonpickle

register = template.Library()

@register.filter('jsonpickle')
def jsonpickle_filter(var):
    return jsonpickle.encode(var)


@register.tag
def ondebug(parser, token):
    ''' Tag for displaying something on DEBUG == True

    {% load debug %}
    {% ondebug %} debug template code {% endondebug %}
    '''
    nodelist = parser.parse(('endondebug',))
    parser.delete_first_token()
    return OndebugNode(nodelist)


class OndebugNode(template.Node):
    def __init__(self, nodelist):
        self.nodelist = nodelist

    def render(self, context):
        if settings.DEBUG:
            return self.nodelist.render(context)
        return ''


@register.tag
def onprod(parser, token):
    ''' Tag for displaying something on SERVER_ROLE == 'prod'

    {% load debug %}
    {% onprod %} prod template code {% endonprod %}
    '''
    nodelist = parser.parse(('endonprod',))
    parser.delete_first_token()
    return OnprodNode(nodelist)


class OnprodNode(template.Node):
    def __init__(self, nodelist):
        self.nodelist = nodelist

    def render(self, context):
        if settings.SERVER_ROLE == 'prod':
            return self.nodelist.render(context)
        return ''

