FROM python:3.7
LABEL maintainer="PDOK dev <pdok@kadaster.nl>"

# Add Nginx to sources
RUN echo "deb http://nginx.org/packages/mainline/debian/ stretch nginx" >> /etc/apt/sources.list
RUN wget http://nginx.org/keys/nginx_signing.key && apt-key add nginx_signing.key

# Install software
RUN apt-get -y update \
    && apt-get install -y \
               build-essential \
               libfreetype6-dev \
               libgdal-dev \
               libgeos-dev \
               libjpeg-dev \
               libproj12 \
               python-dev \
               python-imaging \
               python-lxml \
               python-virtualenv \
               python-yaml \
               zlib1g-dev \
               nginx \
               supervisor \
    && rm -rf /var/lib/apt/lists/*

RUN pip install PyYAML
RUN pip install Pillow
RUN pip install -e git+https://github.com/PDOK/mapproxy.git@master#egg=MapProxy
RUN pip install requests
RUN pip install Shapely
RUN pip install uwsgi

# Create MapProxy user and group
RUN groupadd -g 1337 mapproxy \
    && useradd --shell /bin/bash --gid 1337 -m mapproxy \
    && usermod -a -G sudo mapproxy

RUN mkdir /usr/local/mapproxy

# Create a `mapproxy` service
RUN mkdir /usr/local/mapproxy/cache_data
RUN chmod a+rwx /usr/local/mapproxy/cache_data

RUN mkdir -p /var/log/supervisor

COPY configuration-files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY configuration-files/nginx.conf /etc/nginx/conf.d/default.conf
COPY configuration-files/uwsgi.conf /uwsgi.conf
COPY configuration-files/uwsgi_params /etc/nginx/uwsgi_params
COPY configuration-files/mapproxy.yaml /usr/local/mapproxy/mapproxy.yaml
COPY configuration-files/app.py /usr/local/mapproxy/app.py
COPY configuration-files/log.ini /usr/local/mapproxy/log.ini
RUN chmod +r /uwsgi.conf && chmod +r /etc/nginx/uwsgi_params && chmod +rw -R /usr/local/mapproxy/ && chmod +rw -R /tmp/

EXPOSE 80

WORKDIR /

CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]
