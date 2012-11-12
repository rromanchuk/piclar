# coding: utf-8
import pytz

from decimal import Decimal
from json import JSONEncoder
from inflect import engine
from django.utils.html import escape

class SerializationWrapper(dict):
    def set_original(self, original):
        self.original = original
    def get_original(self):
        return self.original


def wrap_serialization(proto, original):
    wraped = SerializationWrapper(proto)
    wraped.set_original(original)
    return wraped

# JSON serialization part.

def _json_extra(obj, *arg, **kwargs):
    """
    Serialized extra data types to JSON.
    """
    if isinstance(obj, Decimal):
        return str(obj)
    # datetime stuff
    if hasattr(obj, 'isoformat'):
        return obj.strftime("%Y-%m-%d %H:%M:%S %z")
    if isinstance(obj, set):
        return encoder.encode(list(obj))
    raise TypeError('Cannot encode to JSON: %s' % unicode(obj))


encoder = JSONEncoder(default=_json_extra)

def to_json(obj, escape_entities=False):
    """
    JSON serialization shortcut function.
    """
    if escape_entities:
        obj = iter_response(obj, _escape)
    return encoder.encode(obj)


def to_jsonp(obj, callback):
    """
    JSONP serialization shortcut function.
    """
    return '%s(%s);' % (callback, to_json(obj))


# XML serialization part.

inflector = engine()


def _escape(value):
    """
    Escapes a special XML entities.
    """
    if isinstance(value, unicode):
        return escape(value)
    if isinstance(value, str):
        return escape(value)
    return value

def _serialize(obj, elem_name):
    """
    Serializes a different data types to XML.
    """
    if isinstance(obj, unicode):
        return _escape(obj.encode('utf-8'))

    # Serialize dict stuff.
    if hasattr(obj, 'iteritems'):
        res = ''
        for key in sorted(obj.keys()):
            if isinstance(key, unicode):
                k = key.encode('utf-8')
            else:
                k = str(key)
            res += '<%s>%s</%s>' % (k, _serialize(obj[key], k), k)
        return res

    # Serialize iterable stuff.
    if hasattr(obj, '__iter__'):
        # A bit morphological magic to get tag name for list item.
        item_name = inflector.singular_noun(elem_name) or 'item'
        res = ''
        for value in obj:
            res += '<%s>%s</%s>' % (
                item_name,
                _serialize(value, item_name),
                item_name
            )
        return res

    if isinstance(obj, Decimal):
        return str(obj)

    # Serialize datetime stuff.
    if hasattr(obj, 'isoformat'):
        return obj.strftime("%Y-%m-%d %H:%M:%S %z")

    if isinstance(obj, bool):
        return '1' if obj else '0'

    if obj is None:
        return ''

    return _escape(str(obj))


def to_xml(obj, root_node=None, serializer=None):
    """
    XML serialization shortcut function.
    """
    node_name = root_node or 'response'
    return (
        '<?xml version="1.0" encoding="utf-8"?><%s>%s</%s>' % (
            node_name,
            (serializer or _serialize)(obj, node_name),
            node_name
        )
    )

def iter_response(obj, callback):

    if isinstance(obj, SerializationWrapper):
        obj = callback(obj)

    # Serialize dict stuff.
    if hasattr(obj, 'iteritems'):
        res = {}
        for key in sorted(obj.keys()):
            if isinstance(key, unicode):
                k = key.encode('utf-8')
            else:
                k = str(key)
            res[k] = iter_response(obj[k], callback)
        return res

    # Serialize iterable stuff.
    if hasattr(obj, '__iter__'):
        res = []

        for value in obj:
            res.append(iter_response(value, callback))
        return res

    return callback(obj)


def simple_refine(obj):
    if hasattr(obj, 'astimezone'):
        return obj.astimezone(pytz.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    return obj
