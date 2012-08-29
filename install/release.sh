#!/bin/bash
PROJPATH='/var/www/social'
pushd $PROJPATH

echo "Starting release"

git pull

if [ $? -ne 0 ]; then
    echo "Git update failed. Release stoped."
    popd
    exit 1
fi

rm -rf $PROJPATH/ios

web/manage.py syncdb
web/manage.py migrate
web/manage.py generatemedia
web/manage.py collectstatic --noinput
web/manage.py generate_pages
service uwsgi restart

echo "Release done".
popd