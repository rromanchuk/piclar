# coding: utf-8

from decimal import Decimal
from unittest import TestCase
from globaltags import format


class TestReservationForm(TestCase):
    def test_currency(self):
        self.assertEqual(format.currency(None), u'0')
        self.assertEqual(format.currency(None, True), u'0')

        self.assertEqual(format.currency('12.22'), u'12')
        self.assertEqual(format.currency('12.22', True), u'12.22')

        self.assertEqual(format.currency(12.22), u'12')
        self.assertEqual(format.currency(12.22, True), u'12.22')

        self.assertEqual(format.currency(Decimal('12.22')), u'12')
        self.assertEqual(format.currency(Decimal('12.22'), True), u'12.22')

        self.assertEqual(format.currency('12.00', True), u'12')


    def test_currency_html(self):
        self.assertEqual(format.currency_html('12.22'), u'12')
        self.assertEqual(format.currency_html('12.22', True), u'12<small>.22</small>')


    def test_currency_name(self):
        self.assertEqual(format.currency_name(None), u'руб.')
        self.assertEqual(format.currency_name('RUR'), u'руб.')
        self.assertEqual(format.currency_name('RUB'), u'руб.')
        self.assertEqual(format.currency_name('USD'), u'$')
        self.assertEqual(format.currency_name('EUR'), u'€')
        self.assertEqual(format.currency_name('GBP'), u'£')
        self.assertEqual(format.currency_name('UAH'), u'грн.')
