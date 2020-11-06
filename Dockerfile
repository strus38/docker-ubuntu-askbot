FROM ubuntu:20.10

ARG buildtime_db_password=""
ARG buildtime_db_user=""
ARG buildtime_db_engine=2
ARG buildtime_db_name=db.sqlite

ENV DB_PASSWORD=$buildtime_db_password
ENV DB_USER=$buildtime_db_user
ENV DB_ENGINE=$buildtime_db_engine
ENV DB_NAME=$buildtime_db_name

RUN apt-get update && apt-get install -y python3-pip git
# RUN pip3 install askbot
RUN git clone https://github.com/ASKBOT/askbot-devel.git -b master
RUN mkdir /site

COPY askbot-devel/* /site/.

WORKDIR /site
RUN askbot-setup --dir-name=. -e $DB_ENGINE -d $DB_NAME -u $DB_USER -p $DB_PASSWORD
RUN sed -i "s/ROOT_URLCONF.*/ROOT_URLCONF = 'urls'/" settings.py

RUN python3 manage.py migrate --noinput
RUN python3 manage.py collectstatic --noinput

CMD ["python3", "manage.py", "runserver", "0.0.0.0:8080"]
