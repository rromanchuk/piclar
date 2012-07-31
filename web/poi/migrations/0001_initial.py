# -*- coding: utf-8 -*-
import datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models


class Migration(SchemaMigration):

    def forwards(self, orm):
        # Adding model 'Place'
        db.create_table('poi_place', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('title', self.gf('django.db.models.fields.CharField')(max_length=255)),
            ('description', self.gf('django.db.models.fields.TextField')(blank=True)),
            ('position', self.gf('django.contrib.gis.db.models.fields.PointField')()),
            ('type', self.gf('django.db.models.fields.PositiveIntegerField')(default=0, max_length=255)),
            ('type_text', self.gf('django.db.models.fields.CharField')(max_length=255, null=True, blank=True)),
            ('review', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['poi.Review'], null=True, blank=True)),
            ('address', self.gf('django.db.models.fields.CharField')(max_length=255)),
            ('create_date', self.gf('django.db.models.fields.DateTimeField')(auto_now_add=True, blank=True)),
            ('modified_date', self.gf('django.db.models.fields.DateTimeField')(auto_now=True, blank=True)),
        ))
        db.send_create_signal('poi', ['Place'])

        # Adding model 'Review'
        db.create_table('poi_review', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
        ))
        db.send_create_signal('poi', ['Review'])

        # Adding model 'PlacePhoto'
        db.create_table('poi_placephoto', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('place', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['poi.Place'])),
            ('external_id', self.gf('django.db.models.fields.CharField')(max_length=255, null=True, blank=True)),
            ('title', self.gf('django.db.models.fields.TextField')(null=True, blank=True)),
            ('url', self.gf('django.db.models.fields.CharField')(max_length=512, null=True, blank=True)),
            ('provider', self.gf('django.db.models.fields.CharField')(max_length=255, null=True, blank=True)),
            ('is_deleted', self.gf('django.db.models.fields.BooleanField')(default=False)),
        ))
        db.send_create_signal('poi', ['PlacePhoto'])

        # Adding model 'Checkin'
        db.create_table('poi_checkin', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('place', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['poi.Place'])),
            ('person', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['person.Person'])),
            ('comment', self.gf('django.db.models.fields.TextField')()),
            ('create_date', self.gf('django.db.models.fields.DateTimeField')(auto_now_add=True, blank=True)),
            ('modified_date', self.gf('django.db.models.fields.DateTimeField')(auto_now=True, blank=True)),
        ))
        db.send_create_signal('poi', ['Checkin'])

        # Adding model 'CheckinPhoto'
        db.create_table('poi_checkinphoto', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('checkin', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['poi.Checkin'])),
            ('title', self.gf('django.db.models.fields.CharField')(max_length=255, null=True, blank=True)),
            ('photo', self.gf('django.db.models.fields.files.ImageField')(max_length=2048, db_index=True)),
            ('provider', self.gf('django.db.models.fields.CharField')(max_length=255, null=True, blank=True)),
        ))
        db.send_create_signal('poi', ['CheckinPhoto'])


    def backwards(self, orm):
        # Deleting model 'Place'
        db.delete_table('poi_place')

        # Deleting model 'Review'
        db.delete_table('poi_review')

        # Deleting model 'PlacePhoto'
        db.delete_table('poi_placephoto')

        # Deleting model 'Checkin'
        db.delete_table('poi_checkin')

        # Deleting model 'CheckinPhoto'
        db.delete_table('poi_checkinphoto')


    models = {
        'auth.group': {
            'Meta': {'object_name': 'Group'},
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '80'}),
            'permissions': ('django.db.models.fields.related.ManyToManyField', [], {'to': "orm['auth.Permission']", 'symmetrical': 'False', 'blank': 'True'})
        },
        'auth.permission': {
            'Meta': {'ordering': "('content_type__app_label', 'content_type__model', 'codename')", 'unique_together': "(('content_type', 'codename'),)", 'object_name': 'Permission'},
            'codename': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'content_type': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['contenttypes.ContentType']"}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '100'})
        },
        'auth.user': {
            'Meta': {'object_name': 'User'},
            'date_joined': ('django.db.models.fields.DateTimeField', [], {'default': 'datetime.datetime.now'}),
            'email': ('django.db.models.fields.EmailField', [], {'max_length': '75', 'blank': 'True'}),
            'first_name': ('django.db.models.fields.CharField', [], {'max_length': '30', 'blank': 'True'}),
            'groups': ('django.db.models.fields.related.ManyToManyField', [], {'to': "orm['auth.Group']", 'symmetrical': 'False', 'blank': 'True'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'is_active': ('django.db.models.fields.BooleanField', [], {'default': 'True'}),
            'is_staff': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'is_superuser': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'last_login': ('django.db.models.fields.DateTimeField', [], {'default': 'datetime.datetime.now'}),
            'last_name': ('django.db.models.fields.CharField', [], {'max_length': '30', 'blank': 'True'}),
            'password': ('django.db.models.fields.CharField', [], {'max_length': '128'}),
            'user_permissions': ('django.db.models.fields.related.ManyToManyField', [], {'to': "orm['auth.Permission']", 'symmetrical': 'False', 'blank': 'True'}),
            'username': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '75'})
        },
        'contenttypes.contenttype': {
            'Meta': {'ordering': "('name',)", 'unique_together': "(('app_label', 'model'),)", 'object_name': 'ContentType', 'db_table': "'django_content_type'"},
            'app_label': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'model': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '100'})
        },
        'person.person': {
            'Meta': {'object_name': 'Person'},
            'create_date': ('django.db.models.fields.DateTimeField', [], {'auto_now_add': 'True', 'blank': 'True'}),
            'email': ('django.db.models.fields.EmailField', [], {'max_length': '75'}),
            'firstname': ('django.db.models.fields.CharField', [], {'max_length': '255'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'is_email_verified': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'lastname': ('django.db.models.fields.CharField', [], {'max_length': '255'}),
            'modified_date': ('django.db.models.fields.DateTimeField', [], {'auto_now': 'True', 'blank': 'True'}),
            'photo': ('django.db.models.fields.files.ImageField', [], {'max_length': '2048', 'db_index': 'True'}),
            'token': ('django.db.models.fields.CharField', [], {'max_length': '32'}),
            'user': ('django.db.models.fields.related.OneToOneField', [], {'to': "orm['auth.User']", 'unique': 'True'})
        },
        'poi.checkin': {
            'Meta': {'object_name': 'Checkin'},
            'comment': ('django.db.models.fields.TextField', [], {}),
            'create_date': ('django.db.models.fields.DateTimeField', [], {'auto_now_add': 'True', 'blank': 'True'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'modified_date': ('django.db.models.fields.DateTimeField', [], {'auto_now': 'True', 'blank': 'True'}),
            'person': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['person.Person']"}),
            'place': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['poi.Place']"}),
        },
        'poi.checkinphoto': {
            'Meta': {'object_name': 'CheckinPhoto'},
            'checkin': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['poi.Checkin']"}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'photo': ('django.db.models.fields.files.ImageField', [], {'max_length': '2048', 'db_index': 'True'}),
            'provider': ('django.db.models.fields.CharField', [], {'max_length': '255', 'null': 'True', 'blank': 'True'}),
            'title': ('django.db.models.fields.CharField', [], {'max_length': '255', 'null': 'True', 'blank': 'True'})
        },
        'poi.place': {
            'Meta': {'object_name': 'Place'},
            'address': ('django.db.models.fields.CharField', [], {'max_length': '255'}),
            'create_date': ('django.db.models.fields.DateTimeField', [], {'auto_now_add': 'True', 'blank': 'True'}),
            'description': ('django.db.models.fields.TextField', [], {'blank': 'True'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'modified_date': ('django.db.models.fields.DateTimeField', [], {'auto_now': 'True', 'blank': 'True'}),
            'position': ('django.contrib.gis.db.models.fields.PointField', [], {}),
            'review': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['poi.Review']", 'null': 'True', 'blank': 'True'}),
            'title': ('django.db.models.fields.CharField', [], {'max_length': '255'}),
            'type': ('django.db.models.fields.PositiveIntegerField', [], {'default': '0', 'max_length': '255'}),
            'type_text': ('django.db.models.fields.CharField', [], {'max_length': '255', 'null': 'True', 'blank': 'True'})
        },
        'poi.placephoto': {
            'Meta': {'object_name': 'PlacePhoto'},
            'external_id': ('django.db.models.fields.CharField', [], {'max_length': '255', 'null': 'True', 'blank': 'True'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'is_deleted': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'place': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['poi.Place']"}),
            'provider': ('django.db.models.fields.CharField', [], {'max_length': '255', 'null': 'True', 'blank': 'True'}),
            'title': ('django.db.models.fields.TextField', [], {'null': 'True', 'blank': 'True'}),
            'url': ('django.db.models.fields.CharField', [], {'max_length': '512', 'null': 'True', 'blank': 'True'})
        },
        'poi.review': {
            'Meta': {'object_name': 'Review'},
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'})
        }
    }

    complete_apps = ['poi']