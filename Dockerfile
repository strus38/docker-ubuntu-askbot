FROM ubuntu:20.10

ARG buildtime_db_password=""
ARG buildtime_db_user=""
ARG buildtime_db_engine=2
ARG buildtime_db_name=db.sqlite

ENV DB_PASSWORD=$buildtime_db_password
ENV DB_USER=$buildtime_db_user
ENV DB_ENGINE=$buildtime_db_engine
ENV DB_NAME=$buildtime_db_name

RUN apt-get update
RUN apt-get install -y python-pip
RUN pip install askbot

RUN mkdir /site
WORKDIR /site
RUN askbot-setup --dir-name=. --db-engine=2 --db-name=db.sqlite --db-user= --db-password=
RUN sed -i "s/ROOT_URLCONF.*/ROOT_URLCONF = 'urls'/" settings.py

RUN python manage.py migrate --noinput
RUN python manage.py collectstatic --noinput

CMD ["python", "manage.py", "runserver", "0.0.0.0:8080"]
