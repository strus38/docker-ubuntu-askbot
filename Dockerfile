FROM tiangolo/uwsgi-nginx:python3.6-alpine3.9

ARG SITE=askbot-site
ARG ASKBOT=.
ARG buildtime_db_password=""
ARG buildtime_db_user=""
ARG buildtime_db_engine=2
ARG buildtime_db_name=db.sqlite

ENV PYTHONUNBUFFERED 1
ENV ASKBOT_SITE /${SITE}
ENV UWSGI_INI /${SITE}/askbot_app/uwsgi.ini
ENV DB_PASSWORD=$buildtime_db_password
ENV DB_USER=$buildtime_db_user
ENV DB_ENGINE=$buildtime_db_engine
ENV DB_NAME=$buildtime_db_name
ENV NGINX_WORKER_PROCESSES 1
ENV UWSGI_PROCESSES 1
ENV UWSGI_CHEAPER 0

RUN apk add --update --no-cache git py3-cffi \
	gcc g++ git make unzip mkinitfs kmod mtools squashfs-tools py3-cffi \
	libffi-dev linux-headers musl-dev libc-dev openssl-dev \
	python3-dev python3-pip zlib-dev libxml2-dev libxslt-dev jpeg-dev \
        postgresql-dev zlib jpeg libxml2 libxslt postgresql-libs \
    && python -m pip install --upgrade pip \
    && git clone https://github.com/ASKBOT/askbot-devel.git -b master /src \
    && pip install -r /src/askbot_requirements.txt \
    && pip install psycopg2

RUN cd /src/ && python setup.py install \
    && askbot-setup -n /${SITE} -e $DB_ENGINE -d $DB_NAME -u $DB_USER -p $DB_PASSWORD --logfile-name=stdout --no-secret-key --create-project container-uwsgi

RUN true \
    && cp /${SITE}/askbot_app/prestart.sh /app \
    && /usr/bin/crontab /${SITE}/askbot_app/crontab \
    && cd /${SITE} && SECRET_KEY=whatever DJANGO_SETTINGS_MODULE=askbot_app.settings python manage.py collectstatic --noinput

ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.7.3/wait /wait
RUN chmod +x /wait

WORKDIR /${SITE}
