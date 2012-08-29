#!/bin/bash
PROJPATH=/var/www/social
pushd $PROJPATH
git pull
rm -rf /ios
web/manage.py syncdb
web/manage.py migrate
web/manage.py generatemedia
web/manage.py collectstatic --noinput
web/manage.py generate_pages
service uwsgi restart
popd