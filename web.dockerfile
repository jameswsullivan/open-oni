FROM ubuntu:latest

# Set locale to UTF8.
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

# Define directory paths.
ENV OPENONI_SOURCE_DIR="/opt/openoni_source"
ENV OPENONI_INSTALL_DIR="/opt/openoni"
ENV ENTRYPOINT_SCRIPT_PATH="${OPENONI_SOURCE_DIR}/entrypoint.sh"

RUN apt-get -y update && \
    apt-get -y upgrade && \
    # Install locales and set locale to UTF8.
    apt-get -y install tzdata locales ca-certificates && \
    apt-get upgrade ca-certificates -y && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 && \
    # Set time zone to US Central.
    ln -fs /usr/share/zoneinfo/US/Central /etc/localtime && \
    # Install packages.
    apt-get -y install --no-install-recommends \
    apache2 gcc git libmysqlclient-dev \
    libssl-dev libxml2-dev libxslt-dev libjpeg-dev \
    mysql-client curl rsync python3-dev python3-venv nano acl && \
    apt-get -y install --no-install-recommends libapache2-mod-wsgi-py3

# Kept from original Open ONI proj.
RUN ln -sf /proc/self/fd/1 /var/log/apache2/error.log && \
    a2enmod cache cache_disk expires rewrite proxy_http ssl && \
    mkdir -p /var/cache/httpd/mod_disk_cache && \
    chown -R www-data:www-data /var/cache/httpd && \
    a2dissite 000-default.conf && \
    rm /bin/sh && ln -s /bin/bash /bin/sh && \
    mkdir /opt/openoni

# Copy files to /opt/openoni_source
COPY . ${OPENONI_SOURCE_DIR}
WORKDIR ${OPENONI_SOURCE_DIR}

RUN chmod +x ${OPENONI_SOURCE_DIR}/entrypoint.sh && \
    chmod +x ${OPENONI_SOURCE_DIR}/batch_load_batches.sh && \
    chmod +x ${OPENONI_SOURCE_DIR}/configure_permissions.sh && \
    echo "/usr/local/bin/manage delete_cache" > /etc/cron.daily/delete_cache && \
    chmod +x /etc/cron.daily/delete_cache && \
    chmod -R 777 ${OPENONI_SOURCE_DIR}/data/

WORKDIR ${OPENONI_INSTALL_DIR}

EXPOSE 80
ENTRYPOINT ${ENTRYPOINT_SCRIPT_PATH}