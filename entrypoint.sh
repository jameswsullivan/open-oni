#!/bin/bash
#
# entrypoint.sh copies the startup and management files into their proper
# locations, then fires off startup.sh

# Customization
OPENONI_SOURCE_DIR="/opt/openoni_source"
OPENONI_INSTALL_DIR="/opt/openoni"

echo "Begin copying files ..."
if [ -n "$(ls -A "${OPENONI_INSTALL_DIR}")" ]; then
    echo "${OPENONI_INSTALL_DIR} already exists and not empty. Skipping the copy."
else
    echo "${OPENONI_INSTALL_DIR} does not exist or ${OPENONI_INSTALL_DIR} is empty."
    echo "Open ONI files will be copied from ${OPENONI_SOURCE_DIR} to ${OPENONI_INSTALL_DIR} ..."
    cp -a ${OPENONI_SOURCE_DIR}/* ${OPENONI_INSTALL_DIR}
    echo "Files copied from ${OPENONI_SOURCE_DIR} to ${OPENONI_INSTALL_DIR}"
fi

ls -al /opt
echo "Continue to the rest of the scripts ... "

# src=/opt/openoni/docker
src=${OPENONI_SOURCE_DIR}/docker

# Set source to the read-only ONI source mount for test runs
if [[ $ONLY_RUN_TESTS == 1 ]]; then
  src=/usr/local/src/openoni/docker
fi

mkdir -p /var/local/onidata/batches
cp $src/pip-install.sh /pip-install.sh
cp $src/pip-reinstall.sh /pip-reinstall.sh
cp $src/pip-update.sh /pip-update.sh
cp $src/load_batch.sh /load_batch.sh
cp $src/_startup_lib.sh /_startup_lib.sh

cp $src/test.sh /test.sh
cp $src/manage /usr/local/bin/manage
cp $src/django-admin /usr/local/bin/django-admin

# Copy startup script based on whether this is a test-only container
if [[ $ONLY_RUN_TESTS == 1 ]]; then
  cp $src/test-startup.sh /startup.sh
else
  cp $src/startup.sh /startup.sh
fi

# Make all scripts executable
chmod u+x /*.sh
chmod u+x /usr/local/bin/*

/startup.sh