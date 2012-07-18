# coding: utf-8

from decimal import Decimal
from json import JSONEncoder
from inflect import engine


# JSON serialization part.

def _json_extra(obj, *arg, **kwargs):
    """
    Serialized extra data types to JSON.
    """
    if isinstance(obj, Decimal):
        return str(obj)
    # datetime stuff
    if hasattr(obj, 'isoformat'):
        return obj.isoformat()
    if isinstance(obj, set):
        return encoder.encode(list(obj))
    raise TypeError('Cannot encode to JSON: %s' % unicode(obj))


encoder = JSONEncoder(default=_json_extra)


def to_json(obj):
    """
    JSON serialization shortcut function.
    """
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
    return value.replace('&', '&amp;').replace('<', '&lt;')


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
        return obj.isoformat()

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
