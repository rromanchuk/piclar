# coding=utf-8
MONTHS_PLURAL = (
    (1, 'Января',),
    (2, 'Февраля',),
    (3, 'Марта',),
    (4, 'Апреля',),
    (5, 'Мая',),
    (6, 'Июня',),
    (7, 'Июля',),
    (8, 'Августа',),
    (9, 'Сентября',),
    (10, 'Октября',),
    (11, 'Ноября',),
    (12, 'Декабря'),
)

MONTHS = (
    (1, 'Январь',),
    (2, 'Февраль',),
    (3, 'Март',),
    (4, 'Апрел',),
    (5, 'Май',),
    (6, 'Июнь',),
    (7, 'Июль',),
    (8, 'Август',),
    (9, 'Сентябрь',),
    (10, 'Октябрь',),
    (11, 'Ноябрь',),
    (12, 'Декабрь'),
)

def month_to_word_plural(month):
    return dict(MONTHS_PLURAL)[month]