#!/bin/bash
PATH=/var/www/social

pushd $PATH

git pull

rm -rf /ios

web/manage.py syncdb
web/manage.py migrate
web/manage.py generatemedia
web/manage.py collectstatic
web/manage.py generate_pages

service uswgi restart

popd