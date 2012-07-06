# coding: utf-8
from pprint import pformat
import datetime
import json
from django.utils.encoding import smart_unicode
from pytz import timezone
from decimal import Decimal
from string import ascii_lowercase, digits

from ostrovok_common.utils.html_special_chars import decode as _decode_html_special_chars

import re
import math

from django import template
from django.template.defaultfilters import linebreaksbr, truncatewords_html
from django.utils.html import escape
from django.utils.safestring import mark_safe

register = template.Library()

currency_re = re.compile(r'(\d{3})')

allowed_chars = unicode(ascii_lowercase + digits + '-_')

@register.filter
def jsnum(x):
    return unicode(x).replace(',', '.')


@register.filter
def substract(value, arg):
    """Usage, {% if value|starts_with:"arg" %}"""
    return int(value) - int(arg)

@register.filter
def get_range( value, arg=1 ):
    """
    Filter - returns a list containing range made from given value
    Usage (in template):

    <ul>{% for i in 3|get_range %}
      <li>{{ i }}. Do something</li>
    {% endfor %}</ul>

    Results with the HTML:
    <ul>
      <li>0. Do something</li>
      <li>1. Do something</li>
      <li>2. Do something</li>
    </ul>

    Instead of 3 one may use the variable set in the views
    """
    return range( 1, value + 1, arg )

@register.filter
def get_range_full( value ):
    """
    Filter - returns a list containing range made from given value
    Usage (in template):

    <ul>{% for i in 3|get_range %}
      <li>{{ i }}. Do something</li>
    {% endfor %}</ul>

    Results with the HTML:
    <ul>
      <li>0. Do something</li>
      <li>1. Do something</li>
      <li>2. Do something</li>
    </ul>

    Instead of 3 one may use the variable set in the views
    """
    return range( value )


@register.filter
def currency(value, cents=False):
    """
    @rtype: unicode
    """
    if not value:
        value = 0

    value = unicode(value)

    format_str = u'{0:.2f}' if cents else u'{0:.0f}'
    value = format_str.format(Decimal(value))

    if '.00' in value:
        value = '{0:.0f}'.format(Decimal(value))

    if value > 999:
        value = currency_re.sub('\\1 ', value[::-1], 0)[::-1]

    return value.strip()
    
@register.filter
def currency_html(value, cents=False):
    """
    @rtype: unicode
    """
    value = currency(value, cents)

    if '.' in value:
        value = value.split('.')
        return mark_safe(value[0] + '<small>.' + value[1] + '</small>')
    else:
        return mark_safe(value)

@register.filter
def to_moscow_time(date):
    zone_utc = timezone('UTC')
    zone_moscow = timezone('Europe/Moscow')

    try:
        utc_date = zone_utc.localize(date)
    except Exception:
        utc_date = zone_utc.normalize(date.astimezone(zone_utc))
    moscow_date = zone_moscow.normalize(utc_date.astimezone(zone_moscow))

    return moscow_date

@register.filter
def month_english(date):
    # can be achieved with pyICU but simple map is much simpler
    month_map = {
        1: 'January',
        2: 'February',
        3: 'March',
        4: 'April',
        5: 'May',
        6: 'June',
        7: 'July',
        8: 'August',
        9: 'September',
        10: 'October',
        11: 'November',
        12: 'December',
    }

    return month_map[date.month]

@register.filter
def weekday_english(date):
    day_map = {
        0: 'Monday',
        1: 'Tuesday',
        2: 'Wednesday',
        3: 'Thursday',
        4: 'Friday',
        5: 'Saturday',
        6: 'Sunday',
    }

    return day_map[date.weekday()]


@register.filter
def rawdump(x):
    if hasattr(x, '__dict__'):
        d = {
            '__str__': str(x),
            '__unicode__': unicode(x),
            '__repr__': repr(x),
            }
        d.update(x.__dict__)
        x = d
    output = pformat(x, indent=4) + '\n'
    return output


@register.filter
def dump(x):
    return mark_safe(linebreaksbr(escape(rawdump(x).decode('unicode-escape'))))


@register.filter
def sum_string(x, options):
    from pytils.numeral import sum_string

    options = options.split(',')
    gender = int(options[0])
    variants = options[1:]
    return sum_string(int(x), gender, variants)


@register.filter
def rustime(x):

    if not x:
        return ''

    if isinstance(x, datetime.time):
        return str(x)

    try:
        result = time.strftime('%H:%M', time.strptime(x, '%I %p'))
    except ValueError:
        if x == 'Noon':
            result = '12:00'
        else:
            result = x

    return result

@register.filter
def time(x):
    return x.strftime('%H:%M')


@register.filter
def startswith(value, arg):
    """Usage, {% if value|starts_with:"arg" %}"""
    return value.startswith(arg)


@register.filter
def first(value, cnt):
    return value[:cnt]


@register.filter
def truncate_chars(value, max_length, ending='...'):
    if len(value) <= max_length:
        return value
    truncated_val = value[:max_length]
    if value[max_length] != ' ':
        rightmost_space = truncated_val.rfind(' ')
        if rightmost_space != -1:
            truncated_val = truncated_val[:rightmost_space]
    return truncated_val + ending


@register.filter
def ceil(value):
    try:
        value = float(value)
    except Exception:
        return value

    return math.ceil(value)


@register.filter
def markdown_inline(value):
    return mark_safe(re.sub('\\*(.+?)\\*', '<em>\\1</em>', value))


@register.filter
def decode_html_special_chars(text):
    return _decode_html_special_chars(text)


@register.filter
def capsentence(value):
    return ". ".join([sentence.capitalize() for sentence in value.lower().split(". ")])


@register.filter
def str_to_int(value, default):
    if not value:
        return default
    return int(value)


@register.filter
def is_none_decimal(value):

    if not isinstance(value, Decimal):
        return bool(value)

    return value is not None and value != 0

@register.filter
def currency_name(currency_code):
    """
    output ' руб' for RUB, $ fоr USD and so on
    """
    cc = str(currency_code).upper() 
    out = ''
    if cc in ('RUR', 'RUB', 'NONE'):
        out = u'руб.'
    elif cc == 'USD':
        out = u'$'
    elif cc == 'EUR':
        out = u'€'
    elif cc == 'GBP':
        out = u'£'
    elif cc == 'UAH':
        out = u'грн.'
    return out

@register.filter
def truncate_words_content_aware(value, arg):
    usual_truncate = truncatewords_html(value, arg)

    if usual_truncate.endswith('</h4>'):
        second_header_index = usual_truncate.find('<h4>', 1, -1)
        return usual_truncate[0:second_header_index]

    return smart_unicode(usual_truncate)

@register.filter
def get_item(storage, key, default=''):
    try:
        return storage[key]
    except Exception:
        return default

@register.filter
def dict_to_json(params):
    params = json.dumps(dict(params.items()))
    return mark_safe(params)
