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

def _date_time_format(obj):
    if hasattr(obj, 'isoformat'):
        return obj.strftime("%Y-%m-%d %H:%M:%S %z")
    return obj

def _date_time_format_custom(obj):
    if hasattr(obj, 'astimezone'):
        return obj.astimezone(pytz.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    return obj


def _json_extra_builder(date_time_format):
    def _json_extra(obj, *arg, **kwargs):
        """
        Serialized extra data types to JSON.
        """
        if isinstance(obj, Decimal):
            return str(obj)

        if hasattr(obj, 'isoformat'):
            return date_time_format(obj)
        # datetime stuff
        if isinstance(obj, set):
            return encoder.encode(list(obj))
        raise TypeError('Cannot encode to JSON: %s' % unicode(obj))
    return _json_extra

encoder = JSONEncoder(default=_json_extra_builder(_date_time_format))

def to_json(obj, escape_entities=False, custom_datetime=False):
    """
    JSON serialization shortcut function.
    """
    if custom_datetime:
        datetime_formater = _date_time_format_custom
    else:
        datetime_formater = _date_time_format

    encoder = JSONEncoder(default=_json_extra_builder(datetime_formater))

    if escape_entities:
        obj = iter_response(obj, _escape)
    return encoder.encode(obj)


def to_json_custom(obj):
    return to_json(obj, custom_datetime=True)

def to_jsonp(obj, callback):
    """
    JSONP serialization shortcut function.
    """
    return '%s(%s);' % (callback, to_json(obj))

def to_jsonp_custom(obj, callback):
    return '%s(%s);' % (callback, to_json_custom(obj))

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

def _serialize(obj, elem_name, dateformater=None):
    """
    Serializes a different data types to XML.
    """
    if not dateformater:
        dateformater = _date_time_format

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
            res += '<%s>%s</%s>' % (k, _serialize(obj[key], k, dateformater), k)
        return res

    # Serialize iterable stuff.
    if hasattr(obj, '__iter__'):
        # A bit morphological magic to get tag name for list item.
        item_name = inflector.singular_noun(elem_name) or 'item'
        res = ''
        for value in obj:
            res += '<%s>%s</%s>' % (
                item_name,
                _serialize(value, item_name, dateformater),
                item_name
            )
        return res

    if isinstance(obj, Decimal):
        return str(obj)

    # Serialize datetime stuff.
    if hasattr(obj, 'isoformat'):
        return dateformater(obj)

    if isinstance(obj, bool):
        return '1' if obj else '0'

    if obj is None:
        return ''

    return _escape(str(obj))

def _serialize_custom(obj, elem_name):
    print 'serialize_custom'
    return _serialize(obj, elem_name, dateformater=_date_time_format_custom)


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


def to_xml_custom(obj, root_node=None):
    return to_xml(obj, root_node, serializer=_serialize_custom)

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
