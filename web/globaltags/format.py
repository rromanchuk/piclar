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
from django.utils.encoding import force_unicode
from translation.dates import month_to_word_plural
from django.conf import settings

register = template.Library()

currency_re = re.compile(r'(\d{3})')

allowed_chars = unicode(ascii_lowercase + digits + '-_')


def plural_ending(number, wordForms):
    order = number % 100

    if ((order > 10 and order < 20) or (number == 0)):
        return wordForms[2]
    elif number % 10 == 1:
        return wordForms[0]
    elif number % 10 == 4:
        return wordForms[1]
    return wordForms[2]


@register.filter
def unisex(number, wordForms):
    options = wordForms.split(',')

    if (number == 2):
        return options[1]
    else:
        return options[0]


@register.filter
def humanize_since(x):
    if not x:
        return
    now = datetime.datetime.now(tz=x.tzinfo)
    diff = (now - x).total_seconds()

    if diff == 0:
        result = 'сейчас'
    elif diff < 60:
        result = '<b>%s</b> %s назад' % (diff, plural_ending(diff, ['секунду', 'секунды', 'секунд']))
    elif diff < 3600:
        diff_s = int(diff / 60)
        result  = '<b>%s</b> %s назад</span>' % (diff_s, plural_ending(diff_s, ['минуту', 'минуты', 'минут']))
    elif (diff < 60 * 60 * 24):
        diff_s = int(ceil(diff / (60 * 60)))
        result = '<b>%s</b> %s назад</span>' % (diff_s, plural_ending(diff_s, ['час', 'часа', 'часов']))
    else:
        result = '<b>%s</b> %s' % (x.day, month_to_word_plural(x.month))
    return mark_safe('<span class="f-humanized-date">%s</span>' % result)


@register.filter
def jsnum(x):
    return unicode(x).replace(',', '.')


@register.filter
def stars(x):
    try:
        x = int(x)
    except ValueError:
        x = 1

    return mark_safe({
        1: u'<i class="f-stars">★☆☆☆☆</i>',
        2: u'<i class="f-stars">★★☆☆☆</i>',
        3: u'<i class="f-stars">★★★☆☆</i>',
        4: u'<i class="f-stars">★★★★☆</i>',
        5: u'<i class="f-stars">★★★★★</i>'
    }.get(x, u''))


@register.filter
def safestars(x):
    return {
        u'1': u'★☆☆☆☆',
        u'2': u'★★☆☆☆',
        u'3': u'★★★☆☆',
        u'4': u'★★★★☆',
        u'5': u'★★★★★'
    }.get(force_unicode(x), u'')


# @register.filter
# def stars(x):
#     try:
#         x = int(x)
#     except ValueError:
#         x = 1

#     return mark_safe({
#         1: u'<i class="f-stars">★<s>★★★★</s></i>',
#         2: u'<i class="f-stars">★★<s>★★★</s></i>',
#         3: u'<i class="f-stars">★★★<s>★★</s></i>',
#         4: u'<i class="f-stars">★★★★<s>★</s></i>',
#         5: u'<i class="f-stars">★★★★★</i>'
#     }.get(x, u''))


# @register.filter
# def safestars(x):
#     return {
#         u'1': u'★☆☆☆☆',
#         u'2': u'★★☆☆☆',
#         u'3': u'★★★☆☆',
#         u'4': u'★★★★☆',
#         u'5': u'★★★★★'
#     }.get(force_unicode(x), u'')

@register.filter
def place_categorize(x):
    return {
        u'0': u'unknown',
        u'1': u'hotel',
        u'2': u'restaurant',
        u'3': u'attraction',
        u'4': u'entertainment'
    }.get(force_unicode(x), u'')

@register.filter
def substract(value, arg):
    """Usage, {% if value|starts_with:"arg" %}"""
    return int(value) - int(arg)


@register.filter
def get_range(value, arg=1):
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
    return range(1, value + 1, arg)


@register.filter
def get_range_full(value):
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
    return range(value)


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
    if settings.DEBUG:
        return mark_safe(linebreaksbr(escape(rawdump(x).decode('unicode-escape'))))
    else:
        return ''

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

@register.filter
def to_json(params):
    params = json.dumps(params)
    return mark_safe(params)


@register.filter
def naturaltime(value):
    """
    For date and time values shows how many seconds, minutes or hours ago
    compared to current timestamp returns representing string.
    """
    if not isinstance(value, date): # datetime is a subclass of date
        return value

    now = datetime.now(utc if is_aware(value) else None)
    if value < now:
        delta = now - value
        if delta.days != 0:
            return pgettext(
                'naturaltime', '%(delta)s ago'
            ) % {'delta': defaultfilters.timesince(value)}
        elif delta.seconds == 0:
            return _(u'now')
        elif delta.seconds < 60:
            return ungettext(
                u'a second ago', u'%(count)s seconds ago', delta.seconds
            ) % {'count': delta.seconds}
        elif delta.seconds // 60 < 60:
            count = delta.seconds // 60
            return ungettext(
                u'a minute ago', u'%(count)s minutes ago', count
            ) % {'count': count}
        else:
            count = delta.seconds // 60 // 60
            return ungettext(
                u'an hour ago', u'%(count)s hours ago', count
            ) % {'count': count}
    else:
        delta = value - now
        if delta.days != 0:
            return pgettext(
                'naturaltime', '%(delta)s from now'
            ) % {'delta': defaultfilters.timeuntil(value)}
        elif delta.seconds == 0:
            return _(u'now')
        elif delta.seconds < 60:
            return ungettext(
                u'a second from now', u'%(count)s seconds from now', delta.seconds
            ) % {'count': delta.seconds}
        elif delta.seconds // 60 < 60:
            count = delta.seconds // 60
            return ungettext(
                u'a minute from now', u'%(count)s minutes from now', count
            ) % {'count': count}
        else:
            count = delta.seconds // 60 // 60
            return ungettext(
                u'an hour from now', u'%(count)s hours from now', count
            ) % {'count': count}

