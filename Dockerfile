FROM ubuntu:latest

MAINTAINER Javier Quinteros

RUN apt-get update && apt-get install -y apache2 libapache2-mod-wsgi-py3 git cron curl && mkdir -p /var/www/eidaws/routing
RUN cd /var/www/eidaws/routing && git clone https://github.com/EIDA/routing.git 1

COPY docker/routing.conf /etc/apache2/conf-available/routing.conf
# Copy cronjob file to the cron.d directory
COPY docker/cronjob /etc/cron.d/routing

RUN a2enmod wsgi && service apache2 restart && a2enconf routing && service apache2 reload
RUN cd /var/www/eidaws/routing/1 && cp routing.cfg.sample routing.cfg && chown -R www-data.www-data .
RUN cd /var/www/eidaws/routing/1/data && chmod -R g+w . && cp routing.xml.sample routing.xml && ./updateAll.py -l INFO

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

EXPOSE 80

CMD service apache2 start && cron -f
