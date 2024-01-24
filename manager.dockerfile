FROM ubuntu

# Define directory paths.
ENV OPENONI_SOURCE_DIR="/opt/openoni_source"
ENV OPENONI_INSTALL_DIR="/opt/openoni"
ENV ENTRYPOINT_SCRIPT_FILENAME="manager-entrypoint.sh"
ENV ENTRYPOINT_SCRIPT_PATH="${OPENONI_SOURCE_DIR}/${ENTRYPOINT_SCRIPT_FILENAME}"

# Set locale to UTF8.
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y git nano curl unzip tzdata locales mysql-client && \
    apt-get install -y iputils-ping iproute2 openssh-server && \
    ln -fs /usr/share/zoneinfo/US/Central /etc/localtime && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# Copy files to /opt/openoni_source
COPY . ${OPENONI_SOURCE_DIR}
WORKDIR ${OPENONI_SOURCE_DIR}

RUN chmod +x ${OPENONI_SOURCE_DIR}/web-entrypoint.sh && \
    chmod +x ${OPENONI_SOURCE_DIR}/manager-entrypoint.sh && \
    chmod +x ${OPENONI_SOURCE_DIR}/batch_load_batches.sh && \
    chmod +x ${OPENONI_SOURCE_DIR}/compile_themes.sh && \
    chmod -R 777 ${OPENONI_SOURCE_DIR}/data/

WORKDIR ${OPENONI_INSTALL_DIR}

ENTRYPOINT ${ENTRYPOINT_SCRIPT_PATH}