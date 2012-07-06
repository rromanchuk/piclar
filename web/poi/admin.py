from django.contrib.gis import admin
from models import Place, Checkin

admin.site.register(Place, admin.GeoModelAdmin)
admin.site.register(Checkin, admin.GeoModelAdmin)