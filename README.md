
# general info
ssh ubuntu@ryanromanchuk.com
cd ostronaut
source ../virtualenvs/ostronaut/bin/activate

restart postgres
$ sudo /etc/init.d/postgresql restart

restart nginx
$ sudo /etc/init.d/nginx start
