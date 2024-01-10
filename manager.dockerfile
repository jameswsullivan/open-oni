FROM ubuntu

# Define Open ONI work dir.
ARG OPENONI_DIR="/opt/openoni"

# Set locale to UTF8.
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y nano curl unzip tzdata locales mysql-client && \
    apt-get install -y iputils-ping iproute2 openssh-server && \
    ln -fs /usr/share/zoneinfo/US/Central /etc/localtime && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 && \
    mkdir ${OPENONI_DIR}

WORKDIR ${OPENONI_DIR}
ENTRYPOINT ["tail", "-f", "/dev/null"]